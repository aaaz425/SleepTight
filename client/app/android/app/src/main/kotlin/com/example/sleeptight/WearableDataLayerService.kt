package com.example.sleeptight

import android.content.Context
import android.util.Log
import com.google.android.gms.tasks.Tasks
import com.google.android.gms.wearable.*
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import kotlinx.coroutines.*
import java.nio.charset.StandardCharsets
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.ArrayList

/**
 * Wear OS Data Layer API와 통신하는 서비스
 * Flutter 앱과 연결하여 워치앱과 데이터를 주고받는 역할을 담당합니다.
 */
class WearableDataLayerService(private val context: Context) : DataClient.OnDataChangedListener {

    private val TAG = "WearableDataLayer"
    private val scope = CoroutineScope(Dispatchers.Main)
    
    private val nodeClient = Wearable.getNodeClient(context)
    private val dataClient = Wearable.getDataClient(context)
    
    // 데이터 콜백을 저장할 맵 (데이터 경로별로 분류)
    private val dataCallbacks = mutableMapOf<String, MethodChannel.Result>()
    
    // ISO8601 형식 날짜 포맷터
    private val iso8601Format = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).apply {
        timeZone = TimeZone.getTimeZone("UTC")
    }
    
    // 리스너가 등록되었는지 여부
    private var isListenerRegistered = false

    /**
     * 서비스 초기화 및 리스너 등록
     */
    fun initialize() {
        Log.d(TAG, "WearableDataLayerService 초기화 시작 - 리스너 등록 전")
        try {
            // 혹시 이미 등록된 리스너가 있으면 제거
            try {
                Wearable.getDataClient(context).removeListener(this)
                Log.d(TAG, "기존 리스너 제거됨")
            } catch (e: Exception) {
                Log.w(TAG, "기존 리스너 제거 중 오류 발생 (무시해도 됨)", e)
            }
            
            // 새로 리스너 등록
            Wearable.getDataClient(context).addListener(this)
            Log.d(TAG, "데이터 리스너 등록 완료")
            
            isListenerRegistered = true
            Log.d(TAG, "WearableDataLayerService 초기화 완료")
        } catch (e: Exception) {
            Log.e(TAG, "리스너 등록 중 오류 발생", e)
            isListenerRegistered = false
        }
    }
    
    /**
     * WearableListenerService로부터 전달받은 데이터 처리
     */
    fun handleReceivedData(path: String, dataMap: DataMap) {
        Log.d(TAG, "WearableListenerService로부터 데이터 전달받음: path=$path")
        
        // 데이터 경로에 따라 처리
        when (path) {
            "/request_health_data" -> {
                Log.d(TAG, "헬스 데이터 요청 감지 - 테스트 데이터 생성 시작")
                scope.launch {
                    try {
                        // 테스트용 헬스 데이터 응답 생성
                        val request = PutDataMapRequest.create("/health_data_response").apply {
                            dataMap.putBoolean("success", true)
                            dataMap.putString("message", "데이터 요청 수신함")
                            // 테스트 데이터 값
                            dataMap.putInt("steps", 7500)
                            dataMap.putInt("calories", 1800)
                            dataMap.putDouble("water", 1200.0)
                            dataMap.putDouble("caffeine", 180.0)
                            dataMap.putInt("steps_goal", 10000)
                            dataMap.putInt("calories_goal", 2200)
                            dataMap.putInt("water_goal", 2000)
                            dataMap.putInt("caffeine_goal", 400)
                            dataMap.putLong("timestamp", System.currentTimeMillis())
                            
                            Log.d(TAG, "테스트 헬스 데이터 생성 완료: steps=7500, calories=1800, water=1200ml, caffeine=180mg")
                        }
                        
                        Log.d(TAG, "테스트 헬스 데이터 전송 시작")
                        
                        // 응답 전송
                        withContext(Dispatchers.IO) {
                            val putDataReq = request.asPutDataRequest().setUrgent()
                            val dataItemTask = Wearable.getDataClient(context).putDataItem(putDataReq)
                            val result = Tasks.await(dataItemTask)
                            Log.d(TAG, "테스트 헬스 데이터 전송 결과: ${result.uri}")
                        }
                        
                        Log.d(TAG, "헬스 데이터 응답 전송 완료")
                    } catch (e: Exception) {
                        Log.e(TAG, "헬스 데이터 응답 전송 실패", e)
                    }
                }
            }
            
            "/update_water_intake" -> {
                try {
                    val amount = dataMap.getDouble("amount", 0.0)
                    val dateTime = dataMap.getString("dateTime", "")
                    
                    Log.d(TAG, "물 섭취량 수신: ${amount}ml, 시간: $dateTime")
                    
                    // 여기서 데이터를 처리하고 응답 전송
                    scope.launch {
                        try {
                            val request = PutDataMapRequest.create("/update_water_intake_result").apply {
                                dataMap.putBoolean("success", true)
                                dataMap.putString("message", "물 섭취량 업데이트 완료")
                                dataMap.putDouble("amount", amount)
                                dataMap.putLong("timestamp", System.currentTimeMillis())
                            }
                            
                            withContext(Dispatchers.IO) {
                                val putDataReq = request.asPutDataRequest().setUrgent()
                                val dataItemTask = Wearable.getDataClient(context).putDataItem(putDataReq)
                                Tasks.await(dataItemTask)
                            }
                            
                            Log.d(TAG, "물 섭취량 업데이트 응답 전송 완료")
                        } catch (e: Exception) {
                            Log.e(TAG, "물 섭취량 업데이트 응답 전송 실패", e)
                        }
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "물 섭취량 업데이트 요청 파싱 실패", e)
                }
            }
            
            "/update_caffeine_intake" -> {
                try {
                    val amount = dataMap.getDouble("amount", 0.0)
                    val dateTime = dataMap.getString("dateTime", "")
                    
                    Log.d(TAG, "카페인 섭취량 수신: ${amount}mg, 시간: $dateTime")
                    
                    // 여기서 데이터를 처리하고 응답 전송
                    scope.launch {
                        try {
                            val request = PutDataMapRequest.create("/update_caffeine_intake_result").apply {
                                dataMap.putBoolean("success", true)
                                dataMap.putString("message", "카페인 섭취량 업데이트 완료")
                                dataMap.putDouble("amount", amount)
                                dataMap.putLong("timestamp", System.currentTimeMillis())
                            }
                            
                            withContext(Dispatchers.IO) {
                                val putDataReq = request.asPutDataRequest().setUrgent()
                                val dataItemTask = Wearable.getDataClient(context).putDataItem(putDataReq)
                                Tasks.await(dataItemTask)
                            }
                            
                            Log.d(TAG, "카페인 섭취량 업데이트 응답 전송 완료")
                        } catch (e: Exception) {
                            Log.e(TAG, "카페인 섭취량 업데이트 응답 전송 실패", e)
                        }
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "카페인 섭취량 업데이트 요청 파싱 실패", e)
                }
            }
            
            else -> {
                Log.d(TAG, "처리되지 않은 데이터 경로: $path")
            }
        }
    }
    
    /**
     * 리스너 재등록 (앱이 백그라운드에서 포그라운드로 돌아왔을 때 호출)
     */
    fun reRegisterListeners() {
        if (!isListenerRegistered) {
            initialize()
        } else {
            Log.d(TAG, "리스너가 이미 등록되어 있습니다.")
        }
    }

    /**
     * 리소스 해제
     */
    fun dispose() {
        Log.d(TAG, "WearableDataLayerService 리소스 해제")
        try {
            Wearable.getDataClient(context).removeListener(this)
            isListenerRegistered = false
        } catch (e: Exception) {
            Log.e(TAG, "리스너 제거 중 오류 발생", e)
        }
        scope.cancel()
    }
    
    /**
     * 모든 연결된 노드(기기) 목록 가져오기
     */
    fun getConnectedNodes(result: MethodChannel.Result) {
        scope.launch {
            try {
                val nodes = withContext(Dispatchers.IO) {
                    Tasks.await(nodeClient.connectedNodes)
                }
                
                Log.d(TAG, "연결된 노드: ${nodes.size}개")
                val nodesList = mutableListOf<Map<String, String>>()
                
                nodes.forEach { node ->
                    Log.d(TAG, "노드 ID: ${node.id}, 표시명: ${node.displayName}")
                    // 명시적으로 모든 값을 String으로 변환하여 Flutter에서 타입 변환 오류 방지
                    nodesList.add(mapOf(
                        "id" to node.id.toString(),
                        "displayName" to node.displayName.toString(),
                        "isNearby" to node.isNearby.toString()
                    ))
                }
                
                result.success(nodesList)
            } catch (e: Exception) {
                Log.e(TAG, "연결된 노드 가져오기 실패", e)
                result.error("NODES_ERROR", "연결된 노드 가져오기 실패", e.message)
            }
        }
    }
    
    /**
     * 연결된 노드 동기식으로 가져오기 (내부 사용)
     */
    suspend fun getConnectedNodesSync(): List<Node> {
        return withContext(Dispatchers.IO) {
            Tasks.await(nodeClient.connectedNodes)
        }
    }
    
    /**
     * 데이터 전송
     */
    fun sendData(path: String, jsonData: JSONObject, result: MethodChannel.Result) {
        scope.launch {
            try {
                Log.d(TAG, "데이터 전송: 경로=$path")
                
                val request = PutDataMapRequest.create(path).apply {
                    // JSON 객체에서 DataMap으로 변환
                    val iterator = jsonData.keys()
                    while (iterator.hasNext()) {
                        val key = iterator.next()
                        when (val value = jsonData.get(key)) {
                            is String -> dataMap.putString(key, value)
                            is Int -> dataMap.putInt(key, value)
                            is Double -> dataMap.putDouble(key, value)
                            is Long -> dataMap.putLong(key, value)
                            is Boolean -> dataMap.putBoolean(key, value)
                        }
                    }
                    
                    // 타임스탬프 추가
                    dataMap.putLong("timestamp", System.currentTimeMillis())
                }
                
                val putDataReq = request.asPutDataRequest().setUrgent()
                
                val dataItem = withContext(Dispatchers.IO) {
                    Tasks.await(dataClient.putDataItem(putDataReq))
                }
                
                // 데이터 경로별로 콜백 저장 (결과 받기 위해)
                val responsePath = if (path.endsWith("_result")) path else "${path}_result"
                dataCallbacks[responsePath] = result
                
                Log.d(TAG, "데이터 전송 성공: ${dataItem.uri}, 응답 경로: $responsePath")
                // 결과는 데이터 응답이 오면 처리
            } catch (e: Exception) {
                Log.e(TAG, "데이터 전송 실패", e)
                result.error("SEND_ERROR", "데이터 전송 실패", e.message)
            }
        }
    }
    
    /**
     * 메시지 직접 전송 (MessageAPI 활용)
     */
    fun sendMessage(nodeId: String, path: String, message: String, result: MethodChannel.Result) {
        scope.launch {
            try {
                Log.d(TAG, "메시지 전송 시작: 노드=$nodeId, 경로=$path")
                
                if (nodeId.isEmpty()) {
                    Log.e(TAG, "유효하지 않은 노드 ID")
                    result.error("INVALID_NODE", "유효하지 않은 노드 ID", null)
                    return@launch
                }
                
                // MessageClient를 사용하여 메시지 전송
                val messageClient = Wearable.getMessageClient(context)
                val sendMessageTask = messageClient.sendMessage(
                    nodeId,
                    path,
                    message.toByteArray(Charsets.UTF_8)
                )
                
                Tasks.await(sendMessageTask)
                Log.d(TAG, "메시지 전송 성공")
                result.success(true)
            } catch (e: Exception) {
                Log.e(TAG, "메시지 전송 실패", e)
                result.error("MESSAGE_ERROR", "메시지 전송 실패", e.message)
            }
        }
    }
    
    /**
     * 헬스 데이터 요청
     */
    fun requestHealthData(result: MethodChannel.Result) {
        scope.launch {
            try {
                // 헬스 데이터 요청을 DataClient로 전송
                val request = PutDataMapRequest.create("/request_health_data").apply {
                    dataMap.putString("request_time", iso8601Format.format(Date()))
                    dataMap.putLong("timestamp", System.currentTimeMillis())
                }
                
                val putDataReq = request.asPutDataRequest().setUrgent()
                
                withContext(Dispatchers.IO) {
                    Tasks.await(dataClient.putDataItem(putDataReq))
                }
                
                // 응답을 처리할 콜백 저장
                dataCallbacks["/health_data_response"] = result
                Log.d(TAG, "헬스 데이터 요청 전송 완료")
                
            } catch (e: Exception) {
                Log.e(TAG, "헬스 데이터 요청 실패", e)
                result.error("REQUEST_ERROR", "헬스 데이터 요청 실패", e.message)
            }
        }
    }
    
    /**
     * 물 섭취량 업데이트
     */
    fun updateWaterIntake(amount: Double, result: MethodChannel.Result) {
        scope.launch {
            try {
                val request = PutDataMapRequest.create("/update_water_intake").apply {
                    dataMap.putDouble("amount", amount)
                    dataMap.putString("dateTime", iso8601Format.format(Date()))
                    dataMap.putLong("timestamp", System.currentTimeMillis())
                }
                
                val putDataReq = request.asPutDataRequest().setUrgent()
                
                withContext(Dispatchers.IO) {
                    Tasks.await(dataClient.putDataItem(putDataReq))
                }
                
                // 응답을 처리할 콜백 저장
                dataCallbacks["/update_water_intake_result"] = result
                Log.d(TAG, "물 섭취량 업데이트 요청 전송 완료: ${amount}ml")
                
            } catch (e: Exception) {
                Log.e(TAG, "물 섭취량 업데이트 실패", e)
                result.error("UPDATE_ERROR", "물 섭취량 업데이트 실패", e.message)
            }
        }
    }
    
    /**
     * 카페인 섭취량 업데이트
     */
    fun updateCaffeineIntake(amount: Double, result: MethodChannel.Result) {
        scope.launch {
            try {
                val request = PutDataMapRequest.create("/update_caffeine_intake").apply {
                    dataMap.putDouble("amount", amount)
                    dataMap.putString("dateTime", iso8601Format.format(Date()))
                    dataMap.putLong("timestamp", System.currentTimeMillis())
                }
                
                val putDataReq = request.asPutDataRequest().setUrgent()
                
                withContext(Dispatchers.IO) {
                    Tasks.await(dataClient.putDataItem(putDataReq))
                }
                
                // 응답을 처리할 콜백 저장
                dataCallbacks["/update_caffeine_intake_result"] = result
                Log.d(TAG, "카페인 섭취량 업데이트 요청 전송 완료: ${amount}mg")
                
            } catch (e: Exception) {
                Log.e(TAG, "카페인 섭취량 업데이트 실패", e)
                result.error("UPDATE_ERROR", "카페인 섭취량 업데이트 실패", e.message)
            }
        }
    }

    /**
     * 데이터 변경 이벤트 처리
     */
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
                    
                    when (path) {
                        "/health_data_response" -> {
                            Log.d(TAG, "📲 헬스 데이터 응답 수신")
                            
                            // DataMap을 JSONObject로 변환
                            val jsonObject = JSONObject()
                            for (key in dataMap.keySet()) {
                                when {
                                    dataMap.getString(key, "") != "" -> jsonObject.put(key, dataMap.getString(key, ""))
                                    dataMap.getInt(key) != 0 -> jsonObject.put(key, dataMap.getInt(key))
                                    dataMap.containsKey(key) -> jsonObject.put(key, dataMap.getDouble(key))
                                }
                            }
                            
                            val jsonString = jsonObject.toString()
                            
                            // Flutter로 결과 전달
                            val callback = dataCallbacks.remove("/health_data_response")
                            if (callback != null) {
                                Log.d(TAG, "📲 헬스 데이터 응답 콜백 호출")
                                callback.success(jsonString)
                            } else {
                                Log.w(TAG, "⚠️ 헬스 데이터 응답 콜백이 없습니다")
                            }
                        }
                        
                        "/update_water_intake_result" -> {
                            handleUpdateResult(path, dataMap, "/update_water_intake_result")
                        }
                        
                        "/update_caffeine_intake_result" -> {
                            handleUpdateResult(path, dataMap, "/update_caffeine_intake_result")
                        }
                        
                        "/request_health_data" -> {
                            Log.d(TAG, "📲 헬스 데이터 요청 수신 (워치에서)")
                            handleReceivedData(path, dataMap)
                        }
                        
                        "/update_water_intake" -> {
                            Log.d(TAG, "📲 물 섭취량 업데이트 요청 수신 (워치에서)")
                            handleReceivedData(path, dataMap)
                        }
                        
                        "/update_caffeine_intake" -> {
                            Log.d(TAG, "📲 카페인 섭취량 업데이트 요청 수신 (워치에서)")
                            handleReceivedData(path, dataMap)
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
    
    /**
     * 업데이트 결과 처리 메소드
     */
    private fun handleUpdateResult(path: String, dataMap: DataMap, callbackKey: String) {
        Log.d(TAG, "📲 ${if (path == "/update_water_intake_result") "물" else "카페인"} 업데이트 결과 수신")
        
        // DataMap을 JSONObject로 변환
        val jsonObject = JSONObject()
        for (key in dataMap.keySet()) {
            when {
                dataMap.getString(key, "") != "" -> jsonObject.put(key, dataMap.getString(key, ""))
                dataMap.getInt(key) != 0 -> jsonObject.put(key, dataMap.getInt(key))
                dataMap.containsKey(key) -> jsonObject.put(key, dataMap.getDouble(key))
            }
        }
        
        val jsonString = jsonObject.toString()
        
        // Flutter로 결과 전달
        val callback = dataCallbacks.remove(callbackKey)
        if (callback != null) {
            Log.d(TAG, "📲 업데이트 결과 콜백 호출")
            callback.success(jsonString)
        } else {
            Log.w(TAG, "⚠️ 업데이트 결과 콜백이 없습니다")
        }
    }
} 