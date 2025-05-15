package com.example.wear.presentation.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.wear.data.model.HealthData
import com.example.wear.data.repository.WearableRepository
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

/**
 * 헬스 데이터 관리를 위한 ViewModel
 */
class HealthViewModel(application: Application) : AndroidViewModel(application) {
    
    private val wearableRepository = WearableRepository(application)
    
    // 헬스 데이터 상태
    val healthData: StateFlow<HealthData> = wearableRepository.healthData
    
    // 초기화
    init {
        // 데이터 리스너 등록
        wearableRepository.registerListeners()
        
        // 앱 시작 시 헬스 데이터 요청
        refreshHealthData()
    }
    
    // 화면이 다시 표시될 때 데이터 갱신
    fun refreshHealthData() {
        viewModelScope.launch {
            wearableRepository.requestHealthData()
        }
    }
    
    // 물 섭취량 업데이트
    fun updateWaterIntake(amount: Int) {
        viewModelScope.launch {
            wearableRepository.updateWaterIntake(amount)
            
            // 약간의 딜레이 후 데이터 새로고침
            kotlinx.coroutines.delay(500)
            refreshHealthData()
        }
    }
    
    // 카페인 섭취량 업데이트
    fun updateCaffeineIntake(amount: Int) {
        viewModelScope.launch {
            wearableRepository.updateCaffeineIntake(amount)
            
            // 약간의 딜레이 후 데이터 새로고침
            kotlinx.coroutines.delay(500)
            refreshHealthData()
        }
    }
    
    // ViewModel 정리
    override fun onCleared() {
        super.onCleared()
        wearableRepository.unregisterListeners()
    }
} 