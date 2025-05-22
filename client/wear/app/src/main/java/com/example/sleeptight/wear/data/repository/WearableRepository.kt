package com.example.sleeptight.wear.data.repository

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import com.example.sleeptight.wear.data.model.HealthData
import com.google.android.gms.tasks.Tasks
import com.google.android.gms.wearable.DataClient
import com.google.android.gms.wearable.PutDataMapRequest
import com.google.android.gms.wearable.Wearable
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

private const val TAG = "WearRepository"
private const val PREFS_NAME = "health_data_prefs"
private const val KEY_WATER = "water_amount"
private const val KEY_CAFFEINE = "caffeine_amount"
private const val KEY_STEPS = "steps_count"
private const val KEY_CALORIES = "calories_amount"
private const val KEY_LAST_DATE = "last_date_saved"

/**
 * 웨어러블 통신 리포지토리
 * 스마트폰 앱과 데이터를 주고받는 역할을 수행합니다.
 */
class WearableRepository(private val context: Context) {
    
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    
    private val _healthData = MutableStateFlow(loadHealthDataFromPrefs())
    val healthData: StateFlow<HealthData> = _healthData.asStateFlow()
    
    // 데이터 클라이언트
    private val dataClient = Wearable.getDataClient(context)
    
    // 브로드캐스트 리시버
    private val dataReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                "com.example.sleeptight.wear.HEALTH_DATA_UPDATED" -> {
                    val jsonData = intent.getStringExtra("data") ?: return
                    updateFromMobileData(jsonData)
                }
                "com.example.sleeptight.wear.HEALTH_DATA_REQUEST" -> {
                    scope.launch {
                        requestHealthData()
                    }
                }
                "com.example.sleeptight.wear.WATER_UPDATE_RESULT",
                "com.example.sleeptight.wear.CAFFEINE_UPDATE_RESULT" -> {
                    val success = intent.getBooleanExtra("success", false)
                    Log.d(TAG, "업데이트 결과 수신: success=$success, action=${intent.action}")
                }
            }
        }
    }
    
    // ISO8601 형식 날짜 포맷터
    private val iso8601Format = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).apply {
        timeZone = TimeZone.getTimeZone("UTC")
    }
    
    // 초기화
    fun initialize() {
        Log.d(TAG, "WearableRepository 초기화 시작")
        
        // 날짜 변경 확인 및 초기화
        checkAndResetDailyData()
        
        // 브로드캐스트 리시버 등록
        registerReceiver()
        
        Log.d(TAG, "WearableRepository 초기화 완료")
    }
    
    // 리소스 해제
    fun destroy() {
        try {
            unregisterReceiver()
        } catch (e: Exception) {
            Log.e(TAG, "리시버 해제 중 오류", e)
        }
        scope.cancel()
    }
    
    // 날짜 변경 시 데이터 초기화
    private fun checkAndResetDailyData() {
        val currentDate = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        val lastSavedDate = prefs.getString(KEY_LAST_DATE, "") ?: ""
        
        if (lastSavedDate != currentDate) {
            // 날짜가 변경되었으면 일일 데이터 초기화
            val editor = prefs.edit()
            editor.putInt(KEY_WATER, 0)
            editor.putInt(KEY_CAFFEINE, 0)
            editor.putString(KEY_LAST_DATE, currentDate)
            editor.apply()
            
            // 메모리상의 데이터도 초기화
            val currentData = _healthData.value
            _healthData.value = currentData.copy(
                water = 0,
                caffeine = 0
            )
            
            Log.d(TAG, "날짜 변경으로 일일 데이터 초기화 완료 (${lastSavedDate} → ${currentDate})")
        }
    }
    
    // SharedPreferences에서 저장된 데이터 로드
    private fun loadHealthDataFromPrefs(): HealthData {
        return HealthData(
            steps = prefs.getInt(KEY_STEPS, 0),
            calories = prefs.getInt(KEY_CALORIES, 0),
            water = prefs.getInt(KEY_WATER, 0),
            caffeine = prefs.getInt(KEY_CAFFEINE, 0)
        )
    }
    
    // SharedPreferences에 데이터 저장
    private fun saveHealthDataToPrefs(healthData: HealthData) {
        prefs.edit().apply {
            putInt(KEY_STEPS, healthData.steps)
            putInt(KEY_CALORIES, healthData.calories)
            putInt(KEY_WATER, healthData.water)
            putInt(KEY_CAFFEINE, healthData.caffeine)
            putString(KEY_LAST_DATE, SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date()))
            apply()
        }
    }
    
    // 로컬 상태 업데이트 및 저장
    private fun updateLocalData(newData: HealthData) {
        _healthData.value = newData
        saveHealthDataToPrefs(newData)
        Log.d(TAG, "로컬 데이터 업데이트 완료 - 물: ${newData.water}ml, 카페인: ${newData.caffeine}mg")
    }
    
    // 브로드캐스트 리시버 등록
    fun registerReceiver() {
        try {
            val filter = IntentFilter().apply {
                addAction("com.example.sleeptight.wear.HEALTH_DATA_UPDATED")
                addAction("com.example.sleeptight.wear.HEALTH_DATA_REQUEST")
                addAction("com.example.sleeptight.wear.WATER_UPDATE_RESULT")
                addAction("com.example.sleeptight.wear.CAFFEINE_UPDATE_RESULT")
            }
            context.registerReceiver(dataReceiver, filter)
            Log.d(TAG, "브로드캐스트 리시버 등록 완료")
        } catch (e: Exception) {
            Log.e(TAG, "브로드캐스트 리시버 등록 실패", e)
        }
    }
    
    // 브로드캐스트 리시버 해제
    fun unregisterReceiver() {
        try {
            context.unregisterReceiver(dataReceiver)
            Log.d(TAG, "브로드캐스트 리시버 해제 완료")
        } catch (e: Exception) {
            Log.e(TAG, "브로드캐스트 리시버 해제 실패", e)
        }
    }
    
    // 리소스 해제 (destroy 대신 cleanup으로 이름 변경)
    fun cleanup() {
        try {
            context.unregisterReceiver(dataReceiver)
        } catch (e: Exception) {
            Log.e(TAG, "리시버 해제 중 오류", e)
        }
        scope.cancel()
        Log.d(TAG, "리소스 해제 완료")
    }
    
    // 헬스 데이터 요청 (non-suspend 버전으로 변경)
    fun requestHealthData() {
        scope.launch {
            try {
                val request = PutDataMapRequest.create("/request_health_data").apply {
                    dataMap.putString("request_time", iso8601Format.format(Date()))
                    dataMap.putLong("timestamp", System.currentTimeMillis())
                }
                
                val putDataReq = request.asPutDataRequest().setUrgent()
                
                withContext(Dispatchers.IO) {
                    val result = Tasks.await(dataClient.putDataItem(putDataReq))
                    Log.d(TAG, "헬스 데이터 요청 전송 완료: ${result.uri}")
                }
            } catch (e: Exception) {
                Log.e(TAG, "헬스 데이터 요청 실패", e)
            }
        }
    }
    
    // 물 섭취량 증가
    fun incrementWater() {
        val currentData = _healthData.value
        val newWaterAmount = currentData.water + 250 // 250ml씩 증가
        
        scope.launch {
            updateWaterIntake(newWaterAmount)
        }
    }
    
    // 카페인 섭취량 증가
    fun incrementCaffeine() {
        val currentData = _healthData.value
        val newCaffeineAmount = currentData.caffeine + 50 // 50mg씩 증가
        
        scope.launch {
            updateCaffeineIntake(newCaffeineAmount)
        }
    }
    
    // 물 섭취량 업데이트
    suspend fun updateWaterIntake(ml: Int): Boolean {
        // 로컬 변경 내용 즉시 적용
        val currentData = _healthData.value
        val updatedData = currentData.copy(water = ml)
        updateLocalData(updatedData)
        
        return try {
            Log.d(TAG, "물 섭취량 업데이트 요청: $ml ml")
            
            val request = PutDataMapRequest.create("/update_water_intake").apply {
                dataMap.putDouble("amount", ml.toDouble())
                dataMap.putString("dateTime", iso8601Format.format(Date()))
                dataMap.putLong("timestamp", System.currentTimeMillis())
            }
            
            val putDataReq = request.asPutDataRequest().setUrgent()
            
            withContext(Dispatchers.IO) {
                val result = Tasks.await(dataClient.putDataItem(putDataReq))
                Log.d(TAG, "물 섭취량 업데이트 요청 전송 완료: ${result.uri}")
            }
            
            true
        } catch (e: Exception) {
            Log.e(TAG, "물 섭취량 업데이트 요청 실패", e)
            false
        }
    }
    
    // 카페인 섭취량 업데이트
    suspend fun updateCaffeineIntake(mg: Int): Boolean {
        // 로컬 변경 내용 즉시 적용
        val currentData = _healthData.value
        val updatedData = currentData.copy(caffeine = mg)
        updateLocalData(updatedData)
        
        return try {
            Log.d(TAG, "카페인 섭취량 업데이트 요청: $mg mg")
            
            val request = PutDataMapRequest.create("/update_caffeine_intake").apply {
                dataMap.putDouble("amount", mg.toDouble())
                dataMap.putString("dateTime", iso8601Format.format(Date()))
                dataMap.putLong("timestamp", System.currentTimeMillis())
            }
            
            val putDataReq = request.asPutDataRequest().setUrgent()
            
            withContext(Dispatchers.IO) {
                val result = Tasks.await(dataClient.putDataItem(putDataReq))
                Log.d(TAG, "카페인 섭취량 업데이트 요청 전송 완료: ${result.uri}")
            }
            
            true
        } catch (e: Exception) {
            Log.e(TAG, "카페인 섭취량 업데이트 요청 실패", e)
            false
        }
    }
    
    // 모바일로부터 받은 헬스 데이터로 업데이트
    fun updateFromMobileData(jsonData: String) {
        try {
            Log.d(TAG, "모바일 앱 데이터 수신: $jsonData")
            val jsonObject = JSONObject(jsonData)
            
            val steps = jsonObject.optInt("steps", 0)
            val calories = jsonObject.optInt("calories", 0)
            val water = jsonObject.optDouble("water", 0.0).toInt()
            val caffeine = jsonObject.optDouble("caffeine", 0.0).toInt()
            
            val stepsGoal = jsonObject.optInt("steps_goal", 10000)
            val caloriesGoal = jsonObject.optInt("calories_goal", 2000)
            val waterGoal = jsonObject.optInt("water_goal", 2000)
            val caffeineGoal = jsonObject.optInt("caffeine_goal", 400)
            
            val updatedData = HealthData(
                steps, calories, water, caffeine,
                stepsGoal, caloriesGoal, waterGoal, caffeineGoal
            )
            
            updateLocalData(updatedData)
            Log.d(TAG, "모바일 앱 데이터로 업데이트 완료")
        } catch (e: Exception) {
            Log.e(TAG, "헬스 데이터 파싱 실패", e)
        }
    }
} 