package com.example.sleeptight.wear.presentation.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.sleeptight.wear.data.model.HealthData
import com.example.sleeptight.wear.data.repository.WearableRepository
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

/**
 * 건강 데이터 관리 뷰모델
 */
class HealthViewModel(val wearableRepository: WearableRepository) : ViewModel() {
    // 헬스 데이터 상태
    val healthData: StateFlow<HealthData> = wearableRepository.healthData

    /**
     * 헬스 데이터 새로고침
     */
    fun refreshHealthData() {
        wearableRepository.requestHealthData()
    }

    /**
     * 물 섭취량 업데이트
     */
    fun updateWaterIntake(amount: Int) {
        viewModelScope.launch {
            wearableRepository.updateWaterIntake(amount)
        }
    }

    /**
     * 카페인 섭취량 업데이트
     */
    fun updateCaffeineIntake(amount: Int) {
        viewModelScope.launch {
            wearableRepository.updateCaffeineIntake(amount)
        }
    }
}

/**
 * HealthViewModel 팩토리
 */
class HealthViewModelFactory(private val wearableRepository: WearableRepository) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(HealthViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return HealthViewModel(wearableRepository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
} 