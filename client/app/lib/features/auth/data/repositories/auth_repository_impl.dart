import 'package:sleep_tight/features/auth/domain/repositories/auth_repository.dart';
import 'package:sleep_tight/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:sleep_tight/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:sleep_tight/features/auth/data/models/requests/kakao_login_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<void> loginWithKakao(String authorizationCode) async {
    final response = await remoteDataSource.loginWithKakao(
      KakaoLoginRequestModel(authorizationCode: authorizationCode),
    );
    await saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
  }

  @override
  Future<void> refreshAccessToken() async {
    final refreshToken = await localDataSource.getRefreshToken();
    if (refreshToken == null) throw Exception('No refresh token');
    final newAccessToken = await remoteDataSource.refreshAccessToken(
      refreshToken,
    );
    await saveTokens(accessToken: newAccessToken, refreshToken: refreshToken);
  }

  // savetoken
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await localDataSource.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<void> clearToken() async {
    await localDataSource.clearTokens();
  }

  @override
  Future<String?> getAccessToken() => localDataSource.getAccessToken();

  @override
  Future<String?> getRefreshToken() => localDataSource.getRefreshToken();
}
