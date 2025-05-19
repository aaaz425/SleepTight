package com.example.sleeptight

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity: FlutterActivity() {
    private val WEAR_CHANNEL = "com.example.sleeptight/wear_os"
    private lateinit var wearableService: WearableDataLayerService
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Wear OS 통신 서비스 초기화
        wearableService = WearableDataLayerService(context)
        wearableService.initialize()
        
        // 메서드 채널 설정
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WEAR_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getConnectedNodes" -> {
                    wearableService.getConnectedNodes(result)
                }
                
                "requestHealthData" -> {
                    wearableService.requestHealthData(result)
                }
                
                "updateWaterIntake" -> {
                    val amount = call.argument<Double>("amount") ?: 0.0
                    wearableService.updateWaterIntake(amount, result)
                }
                
                "updateCaffeineIntake" -> {
                    val amount = call.argument<Double>("amount") ?: 0.0
                    wearableService.updateCaffeineIntake(amount, result)
                }
                
                "sendMessage" -> {
                    val nodeId = call.argument<String>("nodeId") ?: ""
                    val path = call.argument<String>("path") ?: ""
                    val message = call.argument<String>("message") ?: ""
                    
                    wearableService.sendMessage(nodeId, path, message.toByteArray(), result)
                }
                
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    override fun onDestroy() {
        // 리소스 해제
        wearableService.dispose()
        super.onDestroy()
    }
}
