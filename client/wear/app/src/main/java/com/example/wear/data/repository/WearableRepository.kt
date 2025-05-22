package com.example.wear.data.repository

import android.content.Context
import android.util.Log
import com.example.wear.data.model.HealthData
import com.google.android.gms.tasks.Task
import com.google.android.gms.wearable.DataClient
import com.google.android.gms.wearable.DataItem
import com.google.android.gms.wearable.PutDataMapRequest
import com.google.android.gms.wearable.PutDataRequest
import com.google.android.gms.wearable.Node
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
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import java.util.Calendar

private const val TAG = "WearCommunication"
private const val PREFS_NAME = "health_data_prefs"
private const val KEY_WATER = "water_amount"
private const val KEY_CAFFEINE = "caffeine_amount"
private const val KEY_STEPS = "steps_count"
private const val KEY_CALORIES = "calories_amount"
private const val KEY_LAST_DATE = "last_date_saved"

/**
 * 웨어러블 통신 리포지토리
 * 스마트폰 앱과 데이터를 주고받는 역할을 합니다.
 */
class WearableRepository(private val context: Context) {
    
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    
    private val _healthData = MutableStateFlow(loadHealthDataFromPrefs())
    val healthData: StateFlow<HealthData> = _healthData.asStateFlow()
    
    // ISO8601 형식 날짜 포맷터
    private val iso8601Format = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).apply {
        timeZone = TimeZone.getTimeZone("UTC")
    }
    
    // 데이터 클라이언트 초기화
    fun initialize() {
        Log.d(TAG, "WearableRepository 초기화")
        
        // 날짜 변경 확인 및 초기화
        checkAndResetDailyData()
        
        // 저장된 값 로그 출력
        logCurrentStoredValues()
        
        try {
            // 필요한 경우 DataClient 초기화 
            val dataClient = Wearable.getDataClient(context)
            
            // 데이터 동기화 요청
            dataClient.addListener { dataEvents ->
                for (event in dataEvents) {
                    if (event.type == com.google.android.gms.wearable.DataEvent.TYPE_CHANGED) {
                        val path = event.dataItem.uri.path
                        Log.d(TAG, "데이터 변경 이벤트 수신: $path")
                    }
                }
            }
            
            Log.d(TAG, "데이터 클라이언트 초기화 완료")
        } catch (e: Exception) {
            Log.e(TAG, "데이터 클라이언트 초기화 실패", e)
        }
    }
    
    // 날짜 변경 시 데이터 초기화
    private fun checkAndResetDailyData() {
        val currentDate = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        val lastSavedDate = prefs.getString(KEY_LAST_DATE, "")
        
        Log.d(TAG, "날짜 확인 - 현재: $currentDate, 마지막 저장: $lastSavedDate")
        
        if (lastSavedDate != currentDate) {
            // 날짜가 변경되었으면 일일 데이터 초기화
            val editor = prefs.edit()
            editor.putInt(KEY_WATER, 0)
            editor.putInt(KEY_CAFFEINE, 0)
            // 걸음수와 칼로리는 초기화하지 않고 누적 (선택사항)
            // editor.putInt(KEY_STEPS, 0)
            // editor.putInt(KEY_CALORIES, 0)
            editor.putString(KEY_LAST_DATE, currentDate)
            editor.apply()
            
            // 메모리상의 데이터도 초기화
            val currentData = _healthData.value
            _healthData.value = currentData.copy(
                water = 0,
                caffeine = 0
                // steps = 0,
                // calories = 0
            )
            
            Log.d(TAG, "날짜 변경으로 일일 데이터 초기화 완료 (${lastSavedDate} → ${currentDate})")
        }
    }
    
    // 현재 저장된 값 로그 출력
    private fun logCurrentStoredValues() {
        val water = prefs.getInt(KEY_WATER, 0)
        val caffeine = prefs.getInt(KEY_CAFFEINE, 0)
        val steps = prefs.getInt(KEY_STEPS, 0)
        val calories = prefs.getInt(KEY_CALORIES, 0)
        
        Log.d(TAG, "현재 저장된 값 - 물: ${water}ml, 카페인: ${caffeine}mg, 걸음수: $steps, 칼로리: ${calories}kcal")
    }
    
    // 리소스 해제
    fun destroy() {
        scope.cancel()
    }
    
    // SharedPreferences에서 저장된 데이터 로드
    private fun loadHealthDataFromPrefs(): HealthData {
        return HealthData(
            steps = prefs.getInt(KEY_STEPS, 0),
            calories = prefs.getInt(KEY_CALORIES, 0),
            water = prefs.getInt(KEY_WATER, 0),
            caffeine = prefs.getInt(KEY_CAFFEINE, 0),
            stepsGoal = 10000,
            caloriesGoal = 2000,
            waterGoal = 2000,
            caffeineGoal = 400
        )
    }
    
    // SharedPreferences에 데이터 저장
    private fun saveHealthDataToPrefs(healthData: HealthData) {
        prefs.edit().apply {
            putInt(KEY_STEPS, healthData.steps)
            putInt(KEY_CALORIES, healthData.calories)
            putInt(KEY_WATER, healthData.water)
            putInt(KEY_CAFFEINE, healthData.caffeine)
            // 마지막 저장 날짜 업데이트
            putString(KEY_LAST_DATE, SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date()))
            apply()
        }
        
        // 저장 후 로그
        Log.d(TAG, "데이터 저장 완료 - 물: ${healthData.water}ml, 카페인: ${healthData.caffeine}mg")
    }
    
    // 로컬 상태 업데이트 및 저장
    fun updateLocalData(newData: HealthData) {
        _healthData.value = newData
        saveHealthDataToPrefs(newData)
        Log.d(TAG, "💾 로컬 데이터 업데이트 완료 - 물: ${newData.water}ml, 카페인: ${newData.caffeine}mg, 걸음수: ${newData.steps}, 칼로리: ${newData.calories}kcal")
    }
    
    // 모든 연결된 노드 가져오기
    private suspend fun getConnectedNodes(): List<Node> {
        return try {
            Wearable.getNodeClient(context).connectedNodes.await()
        } catch (e: Exception) {
            Log.e(TAG, "노드 검색 실패", e)
            emptyList()
        }
    }
    
    // 데이터 전송 (DataClient 사용)
    private suspend fun sendData(path: String, dataMap: JSONObject): Boolean {
        try {
            Log.d(TAG, "DataClient를 사용하여 데이터 전송: $path")
            Log.d(TAG, "전송 데이터 내용: $dataMap")
            
            // PutDataMapRequest 생성
            val request = PutDataMapRequest.create(path).apply {
                dataMap.keys().forEach { key ->
                    when (val value = dataMap.get(key)) {
                        is String -> this.dataMap.putString(key, value)
                        is Int -> this.dataMap.putInt(key, value)
                        is Double -> this.dataMap.putDouble(key, value)
                        is Long -> this.dataMap.putLong(key, value)
                        is Boolean -> this.dataMap.putBoolean(key, value)
                    }
                }
            }
            
            // 항상 고유한 데이터 아이템을 만들기 위해 타임스탬프 추가
            request.dataMap.putLong("timestamp", System.currentTimeMillis())
            
            // PutDataRequest 생성 및 전송
            val putDataReq = request.asPutDataRequest().setUrgent()
            val dataItemTask = Wearable.getDataClient(context).putDataItem(putDataReq)
            
            // 결과 대기 및 반환
            val dataItem = dataItemTask.await()
            Log.d(TAG, "데이터 전송 성공: ${dataItem.uri}")
            return true
            
        } catch (e: Exception) {
            Log.e(TAG, "데이터 전송 중 오류", e)
            return false
        }
    }
    
    // 헬스 데이터 요청
    suspend fun requestHealthData(): Boolean {
        Log.d(TAG, "헬스 데이터 요청 시작")
        
        val dataMap = JSONObject().apply {
            put("request_time", iso8601Format.format(Date()))
        }
        
        return sendData("/request_health_data", dataMap)
    }
    
    // 물 섭취량 업데이트
    suspend fun updateWaterIntake(ml: Int): Boolean {
        // 로컬 변경 내용 즉시 적용
        val currentData = _healthData.value
        val updatedData = currentData.copy(water = ml)
        updateLocalData(updatedData)
        
        // 모바일 앱으로 전송
        try {
            Log.d(TAG, "물 섭취량 업데이트 전송: $ml ml")
            val dataMap = JSONObject().apply {
                put("amount", ml.toDouble())
                put("dateTime", iso8601Format.format(Date()))
            }
            
            return sendData("/update_water_intake", dataMap)
        } catch (e: Exception) {
            Log.e(TAG, "물 섭취량 업데이트 실패", e)
            return false
        }
    }
    
    // 카페인 섭취량 업데이트
    suspend fun updateCaffeineIntake(mg: Int): Boolean {
        // 로컬 변경 내용 즉시 적용
        val currentData = _healthData.value
        val updatedData = currentData.copy(caffeine = mg)
        updateLocalData(updatedData)
        
        // 모바일 앱으로 전송
        try {
            Log.d(TAG, "카페인 섭취량 업데이트 전송: $mg mg")
            val dataMap = JSONObject().apply {
                put("amount", mg.toDouble()) 
                put("dateTime", iso8601Format.format(Date()))
            }
            
            return sendData("/update_caffeine_intake", dataMap)
        } catch (e: Exception) {
            Log.e(TAG, "카페인 섭취량 업데이트 실패", e)
            return false
        }
    }
    
    // 모바일로부터 받은 헬스 데이터로 업데이트
    fun updateFromMobileData(jsonData: String) {
        try {
            Log.d(TAG, "모바일 앱에서 헬스 데이터 수신 상세: $jsonData")
            val jsonObject = JSONObject(jsonData)
            
            val calories = jsonObject.optDouble("calories", 0.0).toInt()
            val steps = jsonObject.optInt("steps", 0)
            val water = jsonObject.optDouble("water", 0.0).toInt()
            val caffeine = jsonObject.optDouble("caffeine", 0.0).toInt()
            
            val stepsGoal = jsonObject.optInt("steps_goal", 10000)
            val caloriesGoal = jsonObject.optInt("calories_goal", 2000)
            val waterGoal = jsonObject.optInt("water_goal", 2000)
            val caffeineGoal = jsonObject.optInt("caffeine_goal", 400)
            
            Log.d(TAG, "파싱된 데이터 - 걸음수: $steps, 칼로리: $calories, 물: ${water}ml, 카페인: ${caffeine}mg")
            
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