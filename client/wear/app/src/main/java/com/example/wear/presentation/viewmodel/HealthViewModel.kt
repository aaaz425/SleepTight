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
        wearableRepository.initialize()
        
        // 앱 시작 시 헬스 데이터 요청
        refreshHealthData()
    }
    
    // 데이터 갱신
    fun refreshHealthData() {
        viewModelScope.launch {
            wearableRepository.requestHealthData()
        }
    }
    
    // 물 섭취량 업데이트
    fun updateWaterIntake(amount: Int) {
        viewModelScope.launch {
            // 1. 로컬 상태 즉시 업데이트 (UI 반영) 후 모바일에 업데이트 요청
            // 2. 모바일 응답은 비동기적으로 WearableRepository에서 처리
            // 3. 모바일에서 받은 최신 데이터가 최종적으로 반영됨
            wearableRepository.updateWaterIntake(amount)
        }
    }
    
    // 카페인 섭취량 업데이트
    fun updateCaffeineIntake(amount: Int) {
        viewModelScope.launch {
            // 1. 로컬 상태 즉시 업데이트 (UI 반영) 후 모바일에 업데이트 요청
            // 2. 모바일 응답은 비동기적으로 WearableRepository에서 처리
            // 3. 모바일에서 받은 최신 데이터가 최종적으로 반영됨
            wearableRepository.updateCaffeineIntake(amount)
        }
    }
    
    // ViewModel 정리
    override fun onCleared() {
        super.onCleared()
        wearableRepository.destroy()
    }
} 