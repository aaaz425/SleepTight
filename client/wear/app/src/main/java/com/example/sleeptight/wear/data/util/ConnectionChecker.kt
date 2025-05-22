package com.example.sleeptight.wear.data.util

import android.content.Context
import android.util.Log
import com.google.android.gms.wearable.CapabilityClient
import com.google.android.gms.wearable.Node
import com.google.android.gms.wearable.Wearable
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await

/**
 * 모바일 앱과의 연결 상태를 체크하는 유틸리티 클래스
 */
class ConnectionChecker(private val context: Context) {
    private val TAG = "ConnectionChecker"
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    
    // 모바일 앱 패키지명
    private val MOBILE_APP_PACKAGE = "com.example.sleeptight"
    
    // 연결 상태를 나타내는 StateFlow
    private val _connectedState = MutableStateFlow(false)
    val connectedState: StateFlow<Boolean> = _connectedState.asStateFlow()
    
    // 연결된 모바일 노드 ID
    private val _connectedNodeId = MutableStateFlow<String?>(null)
    val connectedNodeId: StateFlow<String?> = _connectedNodeId.asStateFlow()
    
    /**
     * 앱 시작 시 호출하여 모바일 연결 상태 확인 및 감시 시작
     */
    fun initialize() {
        startConnectionMonitoring()
    }
    
    /**
     * 연결 상태 모니터링 시작
     */
    private fun startConnectionMonitoring() {
        scope.launch {
            try {
                checkConnection()
                
                // 노드 변경 리스너 등록
                val nodeClient = Wearable.getNodeClient(context)
                
                // 노드 상태 변경 감지를 위해 주기적으로 체크
                scope.launch {
                    while(true) {
                        checkConnection()
                        kotlinx.coroutines.delay(30000) // 30초마다 체크
                    }
                }
                
                Log.d(TAG, "💡 연결 모니터링 시작됨")
            } catch (e: Exception) {
                Log.e(TAG, "연결 모니터링 실패", e)
            }
        }
    }
    
    /**
     * 모바일 앱과의 연결 상태 확인
     */
    suspend fun checkConnection() {
        try {
            val nodeClient = Wearable.getNodeClient(context)
            val connectedNodes = nodeClient.connectedNodes.await()
            
            // 모바일 노드 찾기
            val mobileNode = findMobileNode(connectedNodes)
            
            if (mobileNode != null) {
                _connectedState.value = true
                _connectedNodeId.value = mobileNode.id
                Log.d(TAG, "💡 모바일 앱과 연결됨: ${mobileNode.displayName} (${mobileNode.id})")
            } else {
                _connectedState.value = false
                _connectedNodeId.value = null
                Log.d(TAG, "💡 모바일 앱과 연결되지 않음")
            }
        } catch (e: Exception) {
            _connectedState.value = false
            _connectedNodeId.value = null
            Log.e(TAG, "연결 상태 확인 중 오류 발생", e)
        }
    }
    
    /**
     * 모바일 노드 찾기
     */
    private fun findMobileNode(nodes: List<Node>): Node? {
        // 모든 연결된 노드 중 모바일 앱 패키지가 설치된 노드를 찾음
        val filteredNodes = nodes.filter { it.id != "local-node" }
        
        if (filteredNodes.isEmpty()) {
            return null
        }
        
        Log.d(TAG, "💡 연결된 노드: ${filteredNodes.joinToString { "${it.displayName} (${it.id})" }}")
        
        // 일단 첫 번째 모바일 노드 반환 (필요 시 추가 검증 로직 구현)
        return filteredNodes.firstOrNull()
    }
    
    companion object {
        @Volatile
        private var INSTANCE: ConnectionChecker? = null
        
        fun getInstance(context: Context): ConnectionChecker {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: ConnectionChecker(context.applicationContext).also { INSTANCE = it }
            }
        }
    }
} 