import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wear OS 통신을 위한 API 클래스
class WearAPI {
  // 메서드 채널 이름
  static const MethodChannel _channel = MethodChannel(
    'com.example.sleeptight/wear_os',
  );

  // 연결된 노드(Wear OS 기기) 목록 가져오기
  static Future<List<Map<String, dynamic>>> getConnectedNodes() async {
    try {
      final result = await _channel.invokeMethod('getConnectedNodes');
      return List<Map<String, dynamic>>.from(result ?? []);
    } catch (e) {
      debugPrint('연결된 노드 가져오기 실패: $e');
      return [];
    }
  }

  // 헬스 데이터 요청
  static Future<Map<String, dynamic>?> requestHealthData() async {
    try {
      final result = await _channel.invokeMethod('requestHealthData');
      if (result != null) {
        return jsonDecode(result as String) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('헬스 데이터 요청 실패: $e');
      return null;
    }
  }

  // 물 섭취량 업데이트
  static Future<bool> updateWaterIntake(double amount) async {
    try {
      final result = await _channel.invokeMethod('updateWaterIntake', {
        'amount': amount,
      });

      if (result != null) {
        final response = jsonDecode(result as String) as Map<String, dynamic>;
        return response['success'] as bool? ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('물 섭취량 업데이트 실패: $e');
      return false;
    }
  }

  // 카페인 섭취량 업데이트
  static Future<bool> updateCaffeineIntake(double amount) async {
    try {
      final result = await _channel.invokeMethod('updateCaffeineIntake', {
        'amount': amount,
      });

      if (result != null) {
        final response = jsonDecode(result as String) as Map<String, dynamic>;
        return response['success'] as bool? ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('카페인 섭취량 업데이트 실패: $e');
      return false;
    }
  }

  // 메시지 전송
  static Future<bool> sendMessage(
    String nodeId,
    String path,
    String message,
  ) async {
    try {
      await _channel.invokeMethod('sendMessage', {
        'nodeId': nodeId,
        'path': path,
        'message': message,
      });
      return true;
    } catch (e) {
      debugPrint('메시지 전송 실패: $e');
      return false;
    }
  }
}

/// Wear OS 통신 서비스
class WearCommunicationService {
  bool _isInitialized = false;

  // 워치 통신이 설정됐는지 확인
  bool get isInitialized => _isInitialized;

  // 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 연결 상태 확인
      final nodes = await WearAPI.getConnectedNodes();
      _isInitialized = true;
      debugPrint('WearCommunicationService: 초기화 완료 (연결된 기기: ${nodes.length}개)');
    } catch (e) {
      debugPrint('WearCommunicationService: 초기화 실패 - $e');
      _isInitialized = false;
    }
  }

  // 워치에서 헬스 데이터 가져오기
  Future<Map<String, dynamic>?> getHealthDataFromWatch() async {
    try {
      return await WearAPI.requestHealthData();
    } catch (e) {
      debugPrint('워치에서 헬스 데이터 가져오기 실패: $e');
      return null;
    }
  }

  // 워치에 물 섭취량 업데이트
  Future<bool> updateWaterIntakeToWatch(double amount) async {
    try {
      return await WearAPI.updateWaterIntake(amount);
    } catch (e) {
      debugPrint('워치에 물 섭취량 업데이트 실패: $e');
      return false;
    }
  }

  // 워치에 카페인 섭취량 업데이트
  Future<bool> updateCaffeineIntakeToWatch(double amount) async {
    try {
      return await WearAPI.updateCaffeineIntake(amount);
    } catch (e) {
      debugPrint('워치에 카페인 섭취량 업데이트 실패: $e');
      return false;
    }
  }

  // 연결된 워치 기기 목록 가져오기
  Future<List<Map<String, dynamic>>> getConnectedWatches() async {
    return await WearAPI.getConnectedNodes();
  }
}
