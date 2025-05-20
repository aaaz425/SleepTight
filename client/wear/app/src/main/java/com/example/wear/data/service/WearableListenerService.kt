package com.example.wear.data.service

import android.content.Intent
import android.util.Log
import com.google.android.gms.wearable.DataClient
import com.google.android.gms.wearable.DataEvent
import com.google.android.gms.wearable.DataEventBuffer
import com.google.android.gms.wearable.DataMapItem
import com.google.android.gms.wearable.WearableListenerService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import org.json.JSONObject
import java.nio.charset.StandardCharsets

private const val TAG = "WearCommunication"

/**
 * 모바일 앱으로부터 데이터를 수신하는 백그라운드 서비스
 */
class WearableListenerService : com.google.android.gms.wearable.WearableListenerService() {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "📲 서비스: WearableListenerService 시작됨")
    }
    
    override fun onDataChanged(dataEvents: DataEventBuffer) {
        Log.d(TAG, "📲 데이터 변경 감지됨: ${dataEvents.count}개 이벤트")
        
        try {
            for (event in dataEvents) {
                if (event.type == DataEvent.TYPE_CHANGED) {
                    val uri = event.dataItem.uri
                    val path = uri.path ?: ""
                    Log.d(TAG, "📲 데이터 수신됨: path=$path")
                    
                    // 데이터맵 가져오기
                    val dataMapItem = DataMapItem.fromDataItem(event.dataItem)
                    val dataMap = dataMapItem.dataMap
                    
                    when (path) {
                        "/health_data_response" -> {
                            // 헬스 데이터 응답 처리
                            val jsonObject = JSONObject()
                            
                            // DataMap에서 JSON으로 변환
                            for (key in dataMap.keySet()) {
                                when {
                                    dataMap.containsKey(key) -> {
                                        when {
                                            dataMap.getDataMap(key) != null -> { /* 중첩된 데이터맵 처리 */ }
                                            dataMap.getString(key, "") != null -> jsonObject.put(key, dataMap.getString(key, ""))
                                            dataMap.containsKey(key) -> {
                                                when {
                                                    dataMap.getInt(key) != 0 -> jsonObject.put(key, dataMap.getInt(key))
                                                    else -> jsonObject.put(key, dataMap.getDouble(key))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            val dataString = jsonObject.toString()
                            Log.d(TAG, "📲 수신된 헬스 데이터: $dataString")
                            
                            // 앱 내에 데이터 전달을 위한 브로드캐스트
                            val intent = Intent("com.example.wear.HEALTH_DATA_UPDATED")
                            intent.putExtra("data", dataString)
                            sendBroadcast(intent)
                        }
                        
                        "/update_water_intake_result", "/update_caffeine_intake_result" -> {
                            // 업데이트 결과 처리
                            val success = dataMap.getBoolean("success", false)
                            
                            // 브로드캐스트로 결과 알림
                            val intent = Intent(
                                if (path == "/update_water_intake_result") 
                                    "com.example.wear.WATER_UPDATE_RESULT" 
                                else 
                                    "com.example.wear.CAFFEINE_UPDATE_RESULT"
                            )
                            intent.putExtra("success", success)
                            sendBroadcast(intent)
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
    
    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "📲 서비스: WearableListenerService 종료됨")
    }
} 