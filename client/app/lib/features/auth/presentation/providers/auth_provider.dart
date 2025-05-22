import 'package:sleep_tight/core/network/dio_provider.dart';
import 'package:sleep_tight/core/storage/secure_storage_provider.dart';
import 'package:sleep_tight/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:sleep_tight/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:sleep_tight/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sleep_tight/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/features/auth/data/models/requests/kakao_login_request.dart';
import 'package:sleep_tight/features/auth/data/models/responses/kakao_login_response.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);

  final remote = AuthRemoteDataSourceImpl(dio: dioClient.dio);
  final local = AuthLocalDataSourceImpl(secureStorage: secureStorage);
  return AuthRepositoryImpl(remoteDataSource: remote, localDataSource: local);
});

// AuthModel StateNotifierProvider
final authModelProvider =
    StateNotifierProvider<AuthModelNotifier, KakaoLoginResponseModel?>((ref) {
      final repo = ref.watch(authRepositoryProvider);
      return AuthModelNotifier(ref, repo);
    });

class AuthModelNotifier extends StateNotifier<KakaoLoginResponseModel?> {
  final Ref ref;
  final AuthRepository repo;
  AuthModelNotifier(this.ref, this.repo) : super(null);

  // 카카오 로그인 처리
  Future<void> loginWithKakao(KakaoLoginRequestModel request) async {
    final response = await repo.loginWithKakao(request);
    await repo.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    state = response;
  }

  // 토큰 리프레시
  Future<void> refreshAccessToken() async {
    final response = await repo.refreshAccessToken();
    await repo.saveAccessToken(response.accessToken);
    // Optionally update state or notify listeners
  }

  // 로그아웃 및 토큰 삭제
  Future<void> clear() async {
    await repo.clearToken();
    state = null;
  }
}
