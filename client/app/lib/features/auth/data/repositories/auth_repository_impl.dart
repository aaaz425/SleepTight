import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:app/features/auth/data/models/requests/kakao_login_request.dart';

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
    await localDataSource.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    await localDataSource.saveStatus(response.status);
  }

  @override
  Future<void> refreshAccessToken() async {
    final refreshToken = await localDataSource.getRefreshToken();
    if (refreshToken == null) throw Exception('No refresh token');
    final newAccessToken = await remoteDataSource.refreshAccessToken(
      refreshToken,
    );
    await localDataSource.saveTokens(
      accessToken: newAccessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearTokens();
    await localDataSource.clearStatus();
    // remoteDataSource logout
  }

  @override
  Future<String?> getAccessToken() => localDataSource.getAccessToken();

  @override
  Future<String?> getRefreshToken() => localDataSource.getRefreshToken();

  @override
  Future<String?> getStatus() => localDataSource.getStatus();

  @override
  Future<void> saveStatus(String status) async {
    await localDataSource.saveStatus(status);
  }
}
