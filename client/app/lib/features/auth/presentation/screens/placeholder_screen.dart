import 'package:sleep_tight/features/auth/data/models/enums/auth_status.dart';
import 'package:sleep_tight/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/features/health/services/health_service.dart';
// authStateProvider, AuthState import 필요

class PlaceholderScreen extends ConsumerWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthService = HealthService();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title),
            ElevatedButton(
              onPressed: () {
                GoRouter.of(context).go(AppConfig.routes.home);
              },
              child: Text('Go to Home'),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(authRepositoryProvider)
                    .saveStatus(AuthStatus.guest.value);
                ref.read(authStateProvider.notifier).refreshAuthStatus();
              },
              child: Text('auth guest'),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(authRepositoryProvider)
                    .saveStatus(AuthStatus.incompleteRegistration.value);
                ref.read(authStateProvider.notifier).refreshAuthStatus();
              },
              child: Text('auth incomplete'),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(authRepositoryProvider)
                    .saveStatus(AuthStatus.pendingWithdraw.value);
                ref.read(authStateProvider.notifier).refreshAuthStatus();
              },
              child: Text('auth pending'),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(authRepositoryProvider)
                    .saveStatus(AuthStatus.active.value);
                ref.read(authStateProvider.notifier).refreshAuthStatus();
              },
              child: Text('auth active'),
            ),
            ElevatedButton(
              onPressed: () async {
                // authRepositoryProvider를 사용하여 loginWithKakao 호출
                // API 에러 발생 시 CustomApiInterceptor와 ErrorToastNotifier가 처리할 것으로 예상
                try {
                  await ref
                      .read(authRepositoryProvider)
                      .loginWithKakao('invalid_auth_code_for_test');
                } catch (e) {
                  // 일반적으로 인터셉터에서 처리되므로 별도 처리는 필요 없을 수 있으나,
                  // 확인을 위해 로그를 남길 수 있습니다.
                  debugPrint('API 테스트 중 에러 발생 (버튼 핸들러): $e');
                }
              },
              child: Text('api 에러 토스트 테스트'),
            ),
            ElevatedButton(
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
                try {
                  await healthService.exportHealthDataAsTxt();
                } catch (e) {
                  scaffoldMessenger?.showSnackBar(
                    SnackBar(
                      content: Text('파일 공유 중 오류가 발생했습니다: ${e.toString()}'),
                    ),
                  );
                }
              },
              child: Text('활동데이터 및 수면데이터 파일 공유'),
            ),
          ],
        ),
      ),
    );
  }
}
