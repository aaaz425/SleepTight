package com.example.sleeptight.wear.data.service

import android.content.Intent
import android.util.Log
import com.example.sleeptight.wear.SleepTightApplication
import com.example.sleeptight.wear.data.util.ConnectionChecker
import com.google.android.gms.wearable.DataClient
import com.google.android.gms.wearable.DataEvent
import com.google.android.gms.wearable.DataEventBuffer
import com.google.android.gms.wearable.DataMapItem
import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.WearableListenerService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import org.json.JSONObject
import java.nio.charset.StandardCharsets

private const val TAG = "WearCommunication"
private const val MOBILE_APP_PACKAGE = "com.example.sleeptight" // 모바일 앱 패키지

/**
 * 모바일 앱과의 통신을 담당하는 WearableListenerService
 * DataLayer API를 통해 모바일 앱으로부터 데이터를 수신하는 백그라운드 서비스
 * 독립형(Standalone) 모드에서도 작동하며, 모바일 앱과 연결될 때만 실제 데이터를 동기화합니다.
 */
class WearableMessageService : WearableListenerService() {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    
    // 연결 상태 체커
    private lateinit var connectionChecker: ConnectionChecker
    
    // 모바일 앱과 연결되어 있는지 여부
    private val isConnectedToMobile: Boolean
        get() = runBlocking { connectionChecker.connectedState.first() }
    
    override fun onCreate() {
        super.onCreate()
        // Application에서 연결 체커 가져오기
        connectionChecker = (application as SleepTightApplication).connectionChecker
        
        Log.d(TAG, "📱 서비스: WearableMessageService 시작됨 (패키지: $MOBILE_APP_PACKAGE)")
    }
    
    // MessageAPI를 통한 메시지 수신 처리
    override fun onMessageReceived(messageEvent: MessageEvent) {
        val path = messageEvent.path
        val data = String(messageEvent.data, StandardCharsets.UTF_8)
        
        Log.d(TAG, "📱 메시지 수신: path=$path, sourceNodeId=${messageEvent.sourceNodeId}")
        Log.d(TAG, "📱 메시지 데이터: $data")
        
        try {
            // 메시지 내용을 JSON으로 파싱
            val jsonObject = JSONObject(data)
            
            // 경로에 따라 처리
            when (path) {
                "/request_health_data" -> {
                    Log.d(TAG, "📱 헬스 데이터 요청 메시지 수신")
                    broadcastIntent("com.example.sleeptight.wear.HEALTH_DATA_REQUEST", messageEvent.sourceNodeId)
                }
                
                "/update_water" -> {
                    val amount = jsonObject.optDouble("amount", 0.0)
                    Log.d(TAG, "📱 물 섭취량 업데이트 메시지: $amount ml")
                    
                    val intent = Intent("com.example.sleeptight.wear.WATER_UPDATE")
                    intent.putExtra("amount", amount)
                    intent.putExtra("sourceNodeId", messageEvent.sourceNodeId)
                    sendBroadcast(intent)
                }
                
                "/update_caffeine" -> {
                    val amount = jsonObject.optDouble("amount", 0.0)
                    Log.d(TAG, "📱 카페인 섭취량 업데이트 메시지: $amount mg")
                    
                    val intent = Intent("com.example.sleeptight.wear.CAFFEINE_UPDATE")
                    intent.putExtra("amount", amount)
                    intent.putExtra("sourceNodeId", messageEvent.sourceNodeId)
                    sendBroadcast(intent)
                }
                
                else -> {
                    Log.d(TAG, "📱 처리되지 않은 메시지 경로: $path")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "메시지 처리 중 오류 발생", e)
        }
    }
    
    // DataLayer API를 통한 데이터 변경 이벤트 처리
    override fun onDataChanged(dataEvents: DataEventBuffer) {
        Log.d(TAG, "📱 데이터 변경 감지됨: ${dataEvents.count}개 이벤트")
        
        try {
            for (event in dataEvents) {
                if (event.type == DataEvent.TYPE_CHANGED) {
                    val uri = event.dataItem.uri
                    val path = uri.path ?: ""
                    Log.d(TAG, "📱 데이터 수신됨: path=$path")
                    
                    // 데이터맵 가져오기
                    val dataMapItem = DataMapItem.fromDataItem(event.dataItem)
                    val dataMap = dataMapItem.dataMap
                    
                    when (path) {
                        "/health_data_response" -> {
                            handleHealthDataResponse(dataMap)
                        }
                        
                        "/update_water_intake_result", "/update_caffeine_intake_result" -> {
                            handleUpdateResult(path, dataMap)
                        }
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "데이터 처리 중 오류 발생", e)
        } finally {
            dataEvents.release()
        }
    }
    
    // 헬스 데이터 응답 처리
    private fun handleHealthDataResponse(dataMap: com.google.android.gms.wearable.DataMap) {
        Log.d(TAG, "📱 헬스 데이터 응답 수신 시작")
        
        // 데이터 로깅
        val steps = dataMap.getInt("steps", 0)
        val calories = dataMap.getInt("calories", 0)
        val water = dataMap.getDouble("water", 0.0)
        val caffeine = dataMap.getDouble("caffeine", 0.0)
        val timestamp = dataMap.getLong("timestamp", 0L)
        
        Log.d(TAG, "📱 수신된 헬스 데이터: steps=$steps, calories=$calories, water=${water}ml, caffeine=${caffeine}mg")
        
        // DataMap에서 JSON으로 변환
        val jsonObject = convertDataMapToJson(dataMap)
        val dataString = jsonObject.toString()
        
        // 앱 내 브로드캐스트로 데이터 전달
        val intent = Intent("com.example.sleeptight.wear.HEALTH_DATA_UPDATED")
        intent.putExtra("data", dataString)
        intent.putExtra("isOfflineData", false)
        sendBroadcast(intent)
        
        Log.d(TAG, "📱 헬스 데이터 브로드캐스트 전송 완료")
    }
    
    // 물/카페인 업데이트 결과 처리
    private fun handleUpdateResult(path: String, dataMap: com.google.android.gms.wearable.DataMap) {
        val isWater = path == "/update_water_intake_result"
        val success = dataMap.getBoolean("success", false)
        
        Log.d(TAG, "📱 ${if (isWater) "물" else "카페인"} 업데이트 결과 수신: success=$success")
        
        // 브로드캐스트로 결과 알림
        val intent = Intent(
            if (isWater) 
                "com.example.sleeptight.wear.WATER_UPDATE_RESULT" 
            else 
                "com.example.sleeptight.wear.CAFFEINE_UPDATE_RESULT"
        )
        intent.putExtra("success", success)
        sendBroadcast(intent)
        
        Log.d(TAG, "📱 업데이트 결과 브로드캐스트 전송 완료")
    }
    
    // 헬퍼 메소드: 브로드캐스트 인텐트 전송
    private fun broadcastIntent(action: String, sourceNodeId: String? = null) {
        val intent = Intent(action)
        if (sourceNodeId != null) {
            intent.putExtra("sourceNodeId", sourceNodeId)
        }
        
        // 연결 상태 추가
        intent.putExtra("isConnectedToMobile", isConnectedToMobile)
        
        sendBroadcast(intent)
        
        // 모바일 앱과 연결되지 않은 경우 오프라인 데이터 사용
        if (!isConnectedToMobile && action == "com.example.sleeptight.wear.HEALTH_DATA_REQUEST") {
            Log.d(TAG, "📱 모바일 앱과 연결되지 않음 - 오프라인 데이터 사용")
            sendOfflineHealthData()
        }
    }
    
    // 오프라인 상태일 때 기본 데이터 제공
    private fun sendOfflineHealthData() {
        val intent = Intent("com.example.sleeptight.wear.HEALTH_DATA_UPDATED")
        
        // 오프라인 기본값 설정
        val jsonObject = JSONObject().apply {
            put("steps", 0)
            put("stepsGoal", 7000)
            put("calories", 0)
            put("caloriesGoal", 2500)
            put("water", 0.0)
            put("waterGoal", 1800.0)
            put("caffeine", 0.0)
            put("caffeineGoal", 350.0)
            put("timestamp", System.currentTimeMillis())
        }
        
        intent.putExtra("data", jsonObject.toString())
        intent.putExtra("isOfflineData", true)
        sendBroadcast(intent)
        
        Log.d(TAG, "📱 오프라인 헬스 데이터 브로드캐스트 전송: $jsonObject")
    }
    
    // 헬퍼 메소드: DataMap을 JSONObject로 변환
    private fun convertDataMapToJson(dataMap: com.google.android.gms.wearable.DataMap): JSONObject {
        val jsonObject = JSONObject()
        
        for (key in dataMap.keySet()) {
            try {
                when {
                    dataMap.getString(key, "") != "" -> jsonObject.put(key, dataMap.getString(key, ""))
                    dataMap.containsKey(key) -> {
                        when {
                            dataMap.getInt(key) != 0 -> jsonObject.put(key, dataMap.getInt(key))
                            dataMap.getDouble(key, 0.0) != 0.0 -> jsonObject.put(key, dataMap.getDouble(key, 0.0))
                            dataMap.getLong(key, 0L) != 0L -> jsonObject.put(key, dataMap.getLong(key, 0L))
                            dataMap.getBoolean(key, false) -> jsonObject.put(key, dataMap.getBoolean(key, false))
                        }
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "JSON 변환 중 오류: $key", e)
            }
        }
        
        return jsonObject
    }
    
    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "📱 서비스: WearableMessageService 종료됨")
    }
} 