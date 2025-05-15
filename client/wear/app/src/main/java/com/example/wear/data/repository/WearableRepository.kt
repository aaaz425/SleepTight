package com.example.wear.data.repository

import android.content.Context
import com.example.wear.data.model.HealthData
import com.google.android.gms.wearable.*
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * 웨어러블 통신 리포지토리
 * 스마트폰 앱과 데이터를 주고받는 역할을 합니다.
 */
class WearableRepository(private val context: Context) : DataClient.OnDataChangedListener {
    private val dataClient = Wearable.getDataClient(context)
    private val messageClient = Wearable.getMessageClient(context)
    
    private val _healthData = MutableStateFlow(HealthData())
    val healthData: StateFlow<HealthData> = _healthData.asStateFlow()
    
    // 데이터 리스너 등록
    fun registerListeners() {
        dataClient.addListener(this)
    }
    
    // 데이터 리스너 해제
    fun unregisterListeners() {
        dataClient.removeListener(this)
    }
    
    // 스마트폰에 헬스 데이터 요청
    suspend fun requestHealthData() {
        try {
            val nodes = Wearable.getNodeClient(context).connectedNodes.await()
            
            // 연결된 모든 노드(스마트폰)에 메시지 전송
            nodes.forEach { node ->
                messageClient.sendMessage(
                    node.id,
                    "/request_health_data",
                    byteArrayOf()
                ).await()
            }
        } catch (e: Exception) {
            // 오류 처리
            e.printStackTrace()
        }
    }
    
    // 물 섭취량 업데이트 (스마트폰으로 전송)
    suspend fun updateWaterIntake(ml: Int) {
        val dataMap = PutDataMapRequest.create("/update_water").run {
            dataMap.apply {
                putInt("water_amount", ml)
            }
            asPutDataRequest()
        }
        dataClient.putDataItem(dataMap).await()
    }
    
    // 카페인 섭취량 업데이트 (스마트폰으로 전송)
    suspend fun updateCaffeineIntake(mg: Int) {
        val dataMap = PutDataMapRequest.create("/update_caffeine").run {
            dataMap.apply {
                putInt("caffeine_amount", mg)
            }
            asPutDataRequest()
        }
        dataClient.putDataItem(dataMap).await()
    }
    
    // 스마트폰에서 데이터 수신 처리
    override fun onDataChanged(dataEvents: DataEventBuffer) {
        dataEvents.forEach { event ->
            if (event.type == DataEvent.TYPE_CHANGED) {
                val dataItem = event.dataItem
                
                when (dataItem.uri.path) {
                    "/health_data" -> {
                        val dataMap = DataMapItem.fromDataItem(dataItem).dataMap
                        val steps = dataMap.getInt("steps", 0)
                        val calories = dataMap.getInt("calories", 0)
                        val water = dataMap.getInt("water", 0)
                        val caffeine = dataMap.getInt("caffeine", 0)
                        
                        val stepsGoal = dataMap.getInt("steps_goal", 10000)
                        val caloriesGoal = dataMap.getInt("calories_goal", 2000)
                        val waterGoal = dataMap.getInt("water_goal", 2000)
                        val caffeineGoal = dataMap.getInt("caffeine_goal", 400)
                        
                        _healthData.value = HealthData(
                            steps, calories, water, caffeine,
                            stepsGoal, caloriesGoal, waterGoal, caffeineGoal
                        )
                    }
                }
            }
        }
    }
} 