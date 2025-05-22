package com.example.sleeptight.wear.presentation

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.activity.ComponentActivity
import com.example.sleeptight.wear.R

class SplashActivity : ComponentActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_splash)
        
        // 2초 후 메인 액티비티로 이동
        Handler(Looper.getMainLooper()).postDelayed({
            val intent = Intent(this, MainActivity::class.java)
            startActivity(intent)
            finish() // 스플래시 액티비티 종료
        }, 2000) // 2초 딜레이
    }
} 