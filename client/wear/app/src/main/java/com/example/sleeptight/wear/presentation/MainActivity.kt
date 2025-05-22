package com.example.sleeptight.wear.presentation

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.runtime.Composable
import androidx.wear.compose.material.MaterialTheme
import com.example.sleeptight.wear.data.repository.WearableRepository
import com.example.sleeptight.wear.presentation.components.MainScreen
import com.example.sleeptight.wear.presentation.theme.WearTheme
import com.example.sleeptight.wear.presentation.viewmodel.HealthViewModel
import com.example.sleeptight.wear.presentation.viewmodel.HealthViewModelFactory

class MainActivity : ComponentActivity() {
    
    private lateinit var wearableRepository: WearableRepository
    private lateinit var healthViewModel: HealthViewModel
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 웨어러블 저장소 초기화
        wearableRepository = WearableRepository(applicationContext)
        
        // 뷰모델 초기화
        healthViewModel = HealthViewModel(wearableRepository)
        
        setContent {
            WearApp(healthViewModel)
        }
    }
    
    override fun onResume() {
        super.onResume()
        wearableRepository.registerReceiver()
        healthViewModel.refreshHealthData()
    }
    
    override fun onPause() {
        super.onPause()
        wearableRepository.unregisterReceiver()
    }
    
    override fun onDestroy() {
        super.onDestroy()
        wearableRepository.cleanup()
    }
}

@Composable
fun WearApp(viewModel: HealthViewModel) {
    WearTheme {
        MainScreen(viewModel)
    }
} 