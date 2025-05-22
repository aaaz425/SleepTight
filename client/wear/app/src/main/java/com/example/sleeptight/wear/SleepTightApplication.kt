package com.example.sleeptight.wear

import android.app.Application
import android.util.Log
import com.example.sleeptight.wear.data.util.ConnectionChecker

/**
 * 워치 앱의 Application 클래스
 * 앱 시작 시 전역 초기화 작업을 수행합니다.
 */
class SleepTightApplication : Application() {
    
    private val TAG = "SleepTightApp"
    
    // 연결 상태 체커
    lateinit var connectionChecker: ConnectionChecker
        private set
    
    override fun onCreate() {
        super.onCreate()
        
        // 연결 체커 초기화
        connectionChecker = ConnectionChecker.getInstance(this)
        connectionChecker.initialize()
        
        Log.d(TAG, "👕 워치 앱 시작됨 (독립형 모드 지원)")
    }
} 