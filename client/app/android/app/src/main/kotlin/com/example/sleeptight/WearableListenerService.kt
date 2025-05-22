package com.example.sleeptight

import android.content.Intent
import android.util.Log
import com.google.android.gms.wearable.DataClient
import com.google.android.gms.wearable.DataEvent
import com.google.android.gms.wearable.DataEventBuffer
import com.google.android.gms.wearable.DataMapItem
import com.google.android.gms.wearable.PutDataMapRequest
import com.google.android.gms.wearable.Wearable
import com.google.android.gms.wearable.WearableListenerService
import org.json.JSONObject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await

/**
 * Wear OS로부터 데이터를 수신하는 백그라운드 서비스
 * 앱이 백그라운드나 종료된 상태에서도 데이터를 수신할 수 있습니다.
 */
class WearableListenerService : WearableListenerService(), DataClient.OnDataChangedListener {

    private val TAG = "WearableListener"
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "📲 서비스: WearableListenerService 시작됨")
        Wearable.getDataClient(this).addListener(this)
    }

    override fun onDestroy() {
        super.onDestroy()
        Wearable.getDataClient(this).removeListener(this)
        Log.d(TAG, "📲 서비스: WearableListenerService 종료됨")
    }
    
    // DataClient에서 데이터 수신
    override fun onDataChanged(dataEvents: DataEventBuffer) {
        Log.d(TAG, "📲 데이터 변경 감지: ${dataEvents.count}개의 이벤트")
        
        try {
            for (event in dataEvents) {
                if (event.type == DataEvent.TYPE_CHANGED) {
                    val uri = event.dataItem.uri
                    val path = uri.path ?: ""
                    Log.d(TAG, "📲 데이터 수신됨: path=$path")
                    
                    val dataMapItem = DataMapItem.fromDataItem(event.dataItem)
                    val dataMap = dataMapItem.dataMap
                    
                    // MainActivity에 브로드캐스트로 전달
                    val mainIntent = Intent("com.example.sleeptight.WEARABLE_DATA")
                    mainIntent.putExtra("path", path)
                    
                    when (path) {
                        "/request_health_data" -> {
                            // 건강 데이터 요청 처리
                            Log.d(TAG, "📲 건강 데이터 요청 수신")
                            mainIntent.putExtra("request_type", "health_data")
                            
                            // 브로드캐스트 전송
                            sendBroadcastAndRespond(mainIntent, path)
                        }
                        "/update_water_intake" -> {
                            // 물 섭취량 업데이트 처리
                            val amount = dataMap.getDouble("amount", 0.0)
                            val dateTime = dataMap.getString("dateTime", "")
                            Log.d(TAG, "📲 물 섭취량 업데이트 수신: $amount ml, $dateTime")
                            
                            mainIntent.putExtra("request_type", "water_intake")
                            mainIntent.putExtra("amount", amount)
                            mainIntent.putExtra("dateTime", dateTime)
                            
                            // 브로드캐스트 전송
                            sendBroadcastAndRespond(mainIntent, "/update_water_intake_result")
                        }
                        "/update_caffeine_intake" -> {
                            // 카페인 섭취량 업데이트 처리
                            val amount = dataMap.getDouble("amount", 0.0)
                            val dateTime = dataMap.getString("dateTime", "")
                            Log.d(TAG, "📲 카페인 섭취량 업데이트 수신: $amount mg, $dateTime")
                            
                            mainIntent.putExtra("request_type", "caffeine_intake")
                            mainIntent.putExtra("amount", amount)
                            mainIntent.putExtra("dateTime", dateTime)
                            
                            // 브로드캐스트 전송
                            sendBroadcastAndRespond(mainIntent, "/update_caffeine_intake_result")
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
    
    // 브로드캐스트 전송 및 응답 전송
    private fun sendBroadcastAndRespond(intent: Intent, responsePath: String) {
        // 플래그 추가 및 브로드캐스트 전송
        intent.addFlags(Intent.FLAG_INCLUDE_STOPPED_PACKAGES)
        sendBroadcast(intent)
        
        // 워치에 처리 완료 알림 (DataClient 사용)
        scope.launch {
            try {
                val request = PutDataMapRequest.create(responsePath).apply {
                    dataMap.putBoolean("success", true)
                    dataMap.putLong("timestamp", System.currentTimeMillis())
                }
                
                val putDataReq = request.asPutDataRequest().setUrgent()
                val dataItemTask = Wearable.getDataClient(this@WearableListenerService).putDataItem(putDataReq)
                dataItemTask.await()
                
                Log.d(TAG, "📤 응답 데이터 전송 완료: $responsePath")
            } catch (e: Exception) {
                Log.e(TAG, "응답 데이터 전송 실패: $responsePath", e)
            }
        }
    }
} 