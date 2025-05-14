import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:sleep_tight/core/storage/secure_storage_provider.dart';
import 'package:sleep_tight/core/storage/shared_preferences_provider.dart';

class AppInit extends ConsumerStatefulWidget {
  const AppInit({super.key});

  @override
  ConsumerState<AppInit> createState() => _AppInitState();
}

class _AppInitState extends ConsumerState<AppInit> {
  late final AuthLocalDataSource _authLocalDataSource;

  @override
  void initState() {
    super.initState();
    // initState에서는 ref를 바로 쓸 수 없으므로, addPostFrameCallback에서 사용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final secureStorage = ref.read(secureStorageProvider);
      final prefs = ref.read(sharedPreferencesProvider);
      _authLocalDataSource = AuthLocalDataSourceImpl(
        secureStorage: secureStorage,
        prefs: prefs,
      );
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    final accessToken = await _authLocalDataSource.getAccessToken();

    if (accessToken == null) {
      if (!mounted) return;
      GoRouter.of(context).go(AppConfig.routes.welcome);
      return;
    }

    // 2. 토큰 있으면 회원정보 요청 (예: getUserInfo API)
    final userInfo = await fetchUserInfo(accessToken); // 이 부분은 실제 API에 맞게 구현
    if (userInfo != null) {
      // 회원정보 정상 → 홈으로 이동 (혹은 원하는 경로로)
      await Future.delayed(const Duration(milliseconds: 800)); // 살짝 딜레이(로딩)
      if (!mounted) return;
      GoRouter.of(context).go(AppConfig.routes.home);
    } else {
      // 토큰 만료/회원정보 못 가져옴 → 로그인/웰컴 등으로 이동
      if (!mounted) return;
      GoRouter.of(context).go(AppConfig.routes.welcome);
    }
  }

  // 예시: 실제 API 클라이언트로 대체
  Future<dynamic> fetchUserInfo(String accessToken) async {
    // 예: http 패키지로 직접 요청하거나, Provider/Repository 사용
    // 성공 시 userInfo 리턴, 실패 시 null 리턴
    // 아래는 더미 코드
    try {
      // final response = await http.get(...);
      // if (response.statusCode == 200) return response.body;
      // else return null;
      return {}; // 성공 시 더미
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 간단한 로딩 화면 또는 스플래시
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
