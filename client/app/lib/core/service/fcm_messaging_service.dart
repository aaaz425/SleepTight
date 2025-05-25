import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/main.dart';
import 'package:toastification/toastification.dart';

void handleNotification(RemoteMessage message) {
  final data = message.data;
  final title = message.notification?.title ?? '알림';
  final body = message.notification?.body ?? '';

  debugPrint('🧩 알림 데이터: $data');
  debugPrint('🧩 제목: $title');
  debugPrint('🧩 내용: $body');
}

class FcmService {
  static final _messaging = FirebaseMessaging.instance;

  static Future<void> initFCM() async {
    // 권한 요청 (Android 13 이상도 커버)
    await _messaging.requestPermission();

    // FCM 토큰 확인
    final token = await _messaging.getToken();
    debugPrint('✅ FCM Token: $token');

    // 수신 리스너 등록
    _setupListeners();
  }

  static void _setupListeners() {
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint("📥 포그라운드 알림 수신");
      handleNotification(message);

      final overlayContext = navigatorKey.currentState?.overlay?.context;

      toastification.show(
        context: overlayContext,
        type: ToastificationType.info,
        style: ToastificationStyle.fillColored,
        description: Text(message.notification?.body ?? '수면 코칭 생성이 완료되었습니다!'),
        alignment: Alignment.topCenter,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12.0),
        applyBlurEffect: true,
        showIcon: false,
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint("📥 백그라운드 알림 클릭");
      handleNotification(message);
      final context = navigatorKey.currentState?.context;
      if (context != null) {
        context.go(AppConfig.routes.sleepCoach);
      }
    });

    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        debugPrint("📥 종료 상태에서 알림 클릭");
        handleNotification(message);
      }

      final context = navigatorKey.currentState?.context;
      if (context != null) {
        context.go(AppConfig.routes.sleepCoach);
      }
    });
  }
}
