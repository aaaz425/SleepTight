import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'package:app/features/health/services/health_service.dart';

/// Wear OS와의 통신을 관리하는 서비스
class WearCommunicationService {
  final HealthService _healthService = HealthService();
  bool _isInitialized = false;

  // 워치 통신이 설정됐는지 확인
  bool get isInitialized => _isInitialized;

  // 서비스 초기화 및 메시지 리스너 설정
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _setupMessageListeners();
      _isInitialized = true;
      debugPrint('WearCommunicationService: 초기화 완료');
    } catch (e) {
      debugPrint('WearCommunicationService: 초기화 실패 - $e');
      _isInitialized = false;
    }
  }

  // 메시지 리스너 설정
  void _setupMessageListeners() {
    Wear().onMessageReceived.listen((message) async {
      debugPrint('메시지 수신: ${message.path}');
      
      if (message.path == '/request_health_data') {
        await _handleHealthDataRequest();
      } else if (message.path == '/update_water_intake') {
        await _handleWaterIntakeUpdate(message.data);
      } else if (message.path == '/update_caffeine_intake') {
        await _handleCaffeineIntakeUpdate(message.data);
      }
    });
  }

  // 헬스 데이터 요청 처리
  Future<void> _handleHealthDataRequest() async {
    try {
      final healthData = await _healthService.fetchDataForWatch();
      
      // 워치에 응답 전송
      await Wear().sendMessage(
        '/health_data_response',
        jsonEncode(healthData),
      );
      
      debugPrint('헬스 데이터 응답 전송 완료: $healthData');
    } catch (e) {
      debugPrint('헬스 데이터 요청 처리 실패: $e');
      
      // 에러 응답 전송
      await Wear().sendMessage(
        '/health_data_response',
        jsonEncode({'error': '데이터 조회 실패: $e'}),
      );
    }
  }

  // 물 섭취량 업데이트 처리
  Future<void> _handleWaterIntakeUpdate(String? messageData) async {
    if (messageData == null) {
      debugPrint('물 섭취량 업데이트 실패: 메시지 데이터 없음');
      return;
    }
    
    try {
      final data = jsonDecode(messageData);
      final amount = data['amount'] as double;
      final dateTime = DateTime.parse(data['dateTime']);
      
      final success = await _healthService.writeWaterIntake(amount, dateTime);
      
      // 결과 응답 전송
      await Wear().sendMessage(
        '/update_water_intake_result',
        jsonEncode({'success': success}),
      );
      
      debugPrint('물 섭취량 업데이트 처리 완료: $success');
    } catch (e) {
      debugPrint('물 섭취량 업데이트 처리 실패: $e');
      
      // 에러 응답 전송
      await Wear().sendMessage(
        '/update_water_intake_result',
        jsonEncode({'success': false, 'error': '$e'}),
      );
    }
  }

  // 카페인 섭취량 업데이트 처리
  Future<void> _handleCaffeineIntakeUpdate(String? messageData) async {
    if (messageData == null) {
      debugPrint('카페인 섭취량 업데이트 실패: 메시지 데이터 없음');
      return;
    }
    
    try {
      final data = jsonDecode(messageData);
      final amount = data['amount'] as double;
      final dateTime = DateTime.parse(data['dateTime']);
      
      final success = await _healthService.writeCaffeineIntake(amount, dateTime);
      
      // 결과 응답 전송
      await Wear().sendMessage(
        '/update_caffeine_intake_result',
        jsonEncode({'success': success}),
      );
      
      debugPrint('카페인 섭취량 업데이트 처리 완료: $success');
    } catch (e) {
      debugPrint('카페인 섭취량 업데이트 처리 실패: $e');
      
      // 에러 응답 전송
      await Wear().sendMessage(
        '/update_caffeine_intake_result',
        jsonEncode({'success': false, 'error': '$e'}),
      );
    }
  }
} 