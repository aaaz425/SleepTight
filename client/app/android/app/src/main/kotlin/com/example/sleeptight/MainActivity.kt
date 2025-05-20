package com.example.sleeptight

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import android.util.Log
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.Context.RECEIVER_NOT_EXPORTED
import com.google.android.gms.wearable.DataMap
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity: FlutterActivity() {
    private val WEAR_CHANNEL = "com.example.sleeptight/wear_os"
    private val TAG = "MainActivity"
    private lateinit var wearableService: WearableDataLayerService
    private val scope = CoroutineScope(Dispatchers.Main)
    
    // WearableListenerService로부터 데이터를 수신하는 BroadcastReceiver
    private val wearableDataReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val path = intent.getStringExtra("path") ?: return
            
            Log.d(TAG, "브로드캐스트 수신: path=$path")
            
            // 데이터맵 생성
            val dataMap = DataMap()
            val extras = intent.extras
            if (extras != null) {
                for (key in extras.keySet()) {
                    if (key == "path") continue // path는 이미 사용됨
                    
                    when (val value = extras.get(key)) {
                        is String -> dataMap.putString(key, value)
                        is Int -> dataMap.putInt(key, value)
                        is Double -> dataMap.putDouble(key, value)
                        is Long -> dataMap.putLong(key, value)
                        is Boolean -> dataMap.putBoolean(key, value)
                        is Float -> dataMap.putFloat(key, value)
                    }
                }
            }
            
            // WearableDataLayerService에 데이터 전달
            if (::wearableService.isInitialized) {
                wearableService.handleReceivedData(path, dataMap)
            }
        }
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 명시적으로 WearableListenerService 시작
        try {
            val serviceIntent = Intent(this, WearableListenerService::class.java)
            startService(serviceIntent)
            Log.d(TAG, "WearableListenerService 시작 요청함")
        } catch (e: Exception) {
            Log.e(TAG, "WearableListenerService 시작 실패", e)
        }
        
        // Wear OS 통신 서비스 초기화
        Log.d(TAG, "MainActivity: Wear OS 통신 서비스 초기화 시작")
        wearableService = WearableDataLayerService(context)
        
        // 초기화에 충분한 시간을 주기 위해 지연 후 초기화
        scope.launch {
            try {
                wearableService.initialize()
                Log.d(TAG, "MainActivity: Wear OS 통신 서비스 초기화 완료")
                
                // 연결 확인을 위한 노드 조회
                val nodes = wearableService.getConnectedNodesSync()
                Log.d(TAG, "연결된 노드 수: ${nodes.size}")
                nodes.forEach { node ->
                    Log.d(TAG, "노드 정보: ID=${node.id}, 이름=${node.displayName}, 근접=${node.isNearby}")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Wear OS 서비스 초기화 중 오류", e)
            }
        }
        
        // WearableListenerService로부터 브로드캐스트 수신 등록
        val filter = IntentFilter("com.example.sleeptight.WEARABLE_DATA")
        registerReceiver(wearableDataReceiver, filter, RECEIVER_NOT_EXPORTED)
        
        // 메서드 채널 설정
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WEAR_CHANNEL).setMethodCallHandler { call, result ->
            Log.d(TAG, "메서드 채널 호출: ${call.method}")
            
            when (call.method) {
                "getConnectedNodes" -> {
                    Log.d(TAG, "getConnectedNodes 메서드 호출됨")
                    wearableService.getConnectedNodes(result)
                }
                
                "requestHealthData" -> {
                    Log.d(TAG, "requestHealthData 메서드 호출됨")
                    wearableService.requestHealthData(result)
                }
                
                "updateWaterIntake" -> {
                    val amount = call.argument<Double>("amount") ?: 0.0
                    Log.d(TAG, "updateWaterIntake 메서드 호출됨: $amount ml")
                    wearableService.updateWaterIntake(amount, result)
                }
                
                "updateCaffeineIntake" -> {
                    val amount = call.argument<Double>("amount") ?: 0.0
                    Log.d(TAG, "updateCaffeineIntake 메서드 호출됨: $amount mg")
                    wearableService.updateCaffeineIntake(amount, result)
                }
                
                "sendData" -> {
                    val path = call.argument<String>("path") ?: ""
                    val message = call.argument<String>("message") ?: ""
                    
                    Log.d(TAG, "sendData 메서드 호출됨: path=$path")
                    val jsonData = JSONObject(message)
                    wearableService.sendData(path, jsonData, result)
                }
                
                else -> {
                    Log.w(TAG, "지원하지 않는 메서드 호출: ${call.method}")
                    result.notImplemented()
                }
            }
        }
    }
    
    override fun onResume() {
        super.onResume()
        Log.d(TAG, "MainActivity: onResume()")
        
        // onResume에서 리스너 재등록
        if (::wearableService.isInitialized) {
            wearableService.reRegisterListeners()
        }
    }
    
    override fun onPause() {
        super.onPause()
        Log.d(TAG, "MainActivity: onPause()")
    }
    
    override fun onDestroy() {
        // 리소스 해제
        Log.d(TAG, "MainActivity: onDestroy()")
        
        // 브로드캐스트 리시버 해제
        try {
            unregisterReceiver(wearableDataReceiver)
        } catch (e: Exception) {
            Log.e(TAG, "브로드캐스트 리시버 해제 중 오류", e)
        }
        
        if (::wearableService.isInitialized) {
            wearableService.dispose()
        }
        super.onDestroy()
    }
}
