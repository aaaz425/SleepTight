package com.example.wear.presentation

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.runtime.Composable
import androidx.wear.compose.material.MaterialTheme
import com.example.wear.presentation.components.MainScreen
import com.example.wear.presentation.viewmodel.HealthViewModel

class MainActivity : ComponentActivity() {
    
    // ViewModel 초기화
    private val viewModel: HealthViewModel by viewModels()
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        setContent {
            WearApp(viewModel)
        }
    }
}

@Composable
fun WearApp(viewModel: HealthViewModel) {
    MaterialTheme {
        MainScreen(viewModel)
    }
}