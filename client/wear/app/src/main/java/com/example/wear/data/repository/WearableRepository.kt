package com.example.wear.data.repository

import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import com.example.wear.data.model.HealthData
import com.google.android.gms.wearable.*
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.cancel

private const val TAG = "WearCommunication"
private const val PREFS_NAME = "health_data_prefs"
private const val KEY_WATER = "water_amount"
private const val KEY_CAFFEINE = "caffeine_amount"
private const val KEY_STEPS = "steps_count"
private const val KEY_CALORIES = "calories_amount"
private const val TEST_MODE = false // 테스트 모드 활성화 (실제 워치 없이 테스트할 때 true로 설정)

/**
 * 웨어러블 통신 리포지토리
 * 스마트폰 앱과 데이터를 주고받는 역할을 합니다.
 */
class WearableRepository(private val context: Context) : DataClient.OnDataChangedListener,
    MessageClient.OnMessageReceivedListener {
    
    private val dataClient = Wearable.getDataClient(context)
    private val messageClient = Wearable.getMessageClient(context)
    private val nodeClient = Wearable.getNodeClient(context)
    
    // 코루틴 스코프 추가
    private val scope = CoroutineScope(Dispatchers.Main)
    
    // SharedPreferences 추가
    private val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    
    private val _healthData = MutableStateFlow(loadHealthDataFromPrefs())
    val healthData: StateFlow<HealthData> = _healthData.asStateFlow()
    
    // ISO8601 형식 날짜 포맷터
    private val iso8601Format = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).apply {
        timeZone = TimeZone.getTimeZone("UTC")
    }
    
    // 초기화 및 리스너 등록
    fun initialize() {
        Wearable.getDataClient(context).addListener(this)
        Wearable.getMessageClient(context).addListener(this)
    }
    
    // 리스너 등록 (이전 메서드와 호환성 유지)
    fun registerListeners() {
        initialize()
    }
    
    // 리스너 해제
    fun unregisterListeners() {
        Wearable.getDataClient(context).removeListener(this)
        Wearable.getMessageClient(context).removeListener(this)
    }
    
    // 리소스 해제
    fun destroy() {
        unregisterListeners()
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
            apply()
        }
    }
    
    // 스마트폰에 헬스 데이터 요청
    suspend fun requestHealthData() {
        if (TEST_MODE) {
            // 테스트 모드: 더미 데이터 사용
            Log.d(TAG, "테스트 모드: 더미 데이터 로드")
            val currentData = _healthData.value
            // 기존 값 유지하면서 일부 데이터만 업데이트 (걸음수, 칼로리는 테스트용으로 랜덤값)
            val dummyData = HealthData(
                steps = (3000..8000).random(),
                calories = (500..1500).random(),
                water = currentData.water,  // 기존 물 섭취량 유지
                caffeine = currentData.caffeine, // 기존 카페인 섭취량 유지
                stepsGoal = 10000,
                caloriesGoal = 2000,
                waterGoal = 2000,
                caffeineGoal = 400
            )
            _healthData.value = dummyData
            saveHealthDataToPrefs(dummyData)
            return
        }
        
        try {
            Log.d(TAG, "📱 요청: 헬스 데이터 요청 시작")
            val nodes = nodeClient.connectedNodes.await()
            Log.d(TAG, "📱 연결된 노드: ${nodes.size}개")
            nodes.forEach { node -> 
                Log.d(TAG, "📱 노드 정보: ID=${node.id}, 이름=${node.displayName}")
            }
            nodes.firstOrNull()?.let { node ->
                // 모바일 앱에 메시지 전송
                Log.d(TAG, "📱 요청: /request_health_data 메시지 전송 -> ${node.displayName}")
                messageClient.sendMessage(node.id, "/request_health_data", byteArrayOf()).await()
                Log.d(TAG, "📱 요청: /request_health_data 메시지 전송 완료")
            } ?: Log.w(TAG, "❌ 연결된 노드 없음: 헬스 데이터를 요청할 수 없음")
        } catch (e: Exception) {
            // 오류 처리
            Log.e(TAG, "❌ 헬스 데이터 요청 실패", e)
        }
    }
    
    // 로컬 상태 업데이트 및 저장 (네트워크 통신과 무관하게 즉시 적용)
    fun updateLocalData(newData: HealthData) {
        _healthData.value = newData
        saveHealthDataToPrefs(newData)
        Log.d(TAG, "💾 로컬 데이터 업데이트 및 저장 완료 - 물: ${newData.water}, 카페인: ${newData.caffeine}")
    }
    
    // 물 섭취량 업데이트 (스마트폰으로 전송)
    suspend fun updateWaterIntake(ml: Int) {
        // 로컬 변경 내용 일단 저장 - 즉각적인 UI 피드백 위함
        val currentData = _healthData.value
        val updatedData = currentData.copy(water = ml)
        updateLocalData(updatedData)
        
        if (TEST_MODE) {
            // 테스트 모드: 로컬에서만 값 변경 (이미 위에서 처리됨)
            Log.d(TAG, "테스트 모드: 물 섭취량 업데이트 $ml ml")
            return
        }
        
        try {
            val data = JSONObject().apply {
                put("amount", ml.toDouble())
                put("dateTime", iso8601Format.format(Date()))
            }
            
            Log.d(TAG, "📱 요청: 물 섭취량 업데이트 시작 - $ml ml")
            val nodes = nodeClient.connectedNodes.await()
            Log.d(TAG, "📱 연결된 노드: ${nodes.size}개")
            
            nodes.firstOrNull()?.let { node ->
                Log.d(TAG, "📱 요청: /update_water_intake 메시지 전송 -> ${node.displayName}")
                // 모바일로 업데이트 요청 전송 - 응답은 onMessageReceived 에서 처리
                // 응답 수신 후 모바일 데이터가 최종 반영됨
                messageClient.sendMessage(
                    node.id,
                    "/update_water_intake",
                    data.toString().toByteArray()
                ).await()
                Log.d(TAG, "📱 요청: /update_water_intake 메시지 전송 완료")
            } ?: Log.w(TAG, "❌ 연결된 노드 없음: 물 섭취량을 업데이트할 수 없음")
        } catch (e: Exception) {
            // 오류 처리
            Log.e(TAG, "❌ 물 섭취량 업데이트 실패", e)
        }
    }
    
    // 카페인 섭취량 업데이트 (스마트폰으로 전송)
    suspend fun updateCaffeineIntake(mg: Int) {
        // 로컬 변경 내용 일단 저장 - 즉각적인 UI 피드백 위함
        val currentData = _healthData.value
        val updatedData = currentData.copy(caffeine = mg)
        updateLocalData(updatedData)
        
        if (TEST_MODE) {
            // 테스트 모드: 로컬에서만 값 변경 (이미 위에서 처리됨)
            Log.d(TAG, "테스트 모드: 카페인 섭취량 업데이트 $mg mg")
            return
        }
        
        try {
            val data = JSONObject().apply {
                put("amount", mg.toDouble())
                put("dateTime", iso8601Format.format(Date()))
            }
            
            Log.d(TAG, "📱 요청: 카페인 섭취량 업데이트 시작 - $mg mg")
            val nodes = nodeClient.connectedNodes.await()
            Log.d(TAG, "📱 연결된 노드: ${nodes.size}개")
            
            nodes.firstOrNull()?.let { node ->
                Log.d(TAG, "📱 요청: /update_caffeine_intake 메시지 전송 -> ${node.displayName}")
                messageClient.sendMessage(
                    node.id,
                    "/update_caffeine_intake",
                    data.toString().toByteArray()
                ).await()
                Log.d(TAG, "📱 요청: /update_caffeine_intake 메시지 전송 완료")
            } ?: Log.w(TAG, "❌ 연결된 노드 없음: 카페인 섭취량을 업데이트할 수 없음")
        } catch (e: Exception) {
            // 오류 처리
            Log.e(TAG, "❌ 카페인 섭취량 업데이트 실패", e)
        }
    }
    
    // 메시지 수신 처리
    override fun onMessageReceived(messageEvent: MessageEvent) {
        Log.d(TAG, "📲 응답: 메시지 수신 - ${messageEvent.path}")
        when (messageEvent.path) {
            "/health_data_response" -> {
                val jsonString = String(messageEvent.data)
                try {
                    Log.d(TAG, "📲 응답: 헬스 데이터 수신 - $jsonString")
                    val jsonObject = JSONObject(jsonString)
                    
                    // 모바일에서 받은 데이터로 로컬 데이터 업데이트 (모바일 데이터 우선)
                    val calories = jsonObject.optDouble("calories", 0.0).toInt()
                    val steps = jsonObject.optInt("steps", 0)
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
                    
                    Log.d(TAG, "📲 응답: 모바일 데이터 적용 - 물: $water, 카페인: $caffeine")
                    _healthData.value = updatedData
                    saveHealthDataToPrefs(updatedData)
                    
                    Log.d(TAG, "📲 응답: 헬스 데이터 업데이트 완료 - 걸음: $steps, 칼로리: $calories, 물: $water, 카페인: $caffeine")
                } catch (e: Exception) {
                    Log.e(TAG, "❌ 헬스 데이터 파싱 실패", e)
                }
            }
            "/update_water_intake_result", "/update_caffeine_intake_result" -> {
                // 업데이트 결과 처리 (필요한 경우)
                val jsonString = String(messageEvent.data)
                try {
                    Log.d(TAG, "📲 응답: 업데이트 결과 수신 - $jsonString")
                    val jsonObject = JSONObject(jsonString)
                    val success = jsonObject.optBoolean("success", false)
                    
                    if (success) {
                        Log.d(TAG, "📲 응답: 업데이트 성공 - 헬스 데이터 다시 요청")
                        // 성공 시 헬스 데이터 다시 요청 (코루틴 스코프 내에서 호출)
                        scope.launch {
                            requestHealthData()
                        }
                    } else {
                        Log.w(TAG, "⚠️ 응답: 업데이트 실패")
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "❌ 업데이트 결과 파싱 실패", e)
                }
            }
        }
    }
    
    // 데이터 동기화가 필요한 경우 이 메서드 구현
    override fun onDataChanged(dataEvents: DataEventBuffer) {
        // 현재는 메시지 통신만 사용하므로 구현하지 않음
    }
} 