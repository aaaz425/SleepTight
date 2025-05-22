import 'package:sleep_tight/features/auth/data/models/requests/refresh_token_request.dart';
import 'package:sleep_tight/features/auth/data/models/responses/refresh_token_response.dart';
import 'package:sleep_tight/features/auth/domain/repositories/auth_repository.dart';
import 'package:sleep_tight/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:sleep_tight/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:sleep_tight/features/auth/data/models/requests/kakao_login_request.dart';
import 'package:sleep_tight/features/auth/data/models/responses/kakao_login_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<KakaoLoginResponseModel> loginWithKakao(
    KakaoLoginRequestModel request,
  ) async {
    final response = await remoteDataSource.loginWithKakao(request);
    await saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    return response;
  }

  @override
  Future<RefreshTokenResponseModel> refreshAccessToken() async {
    final refreshToken = await localDataSource.getRefreshToken();
    if (refreshToken == null) throw Exception('No refresh token');
    final newAccessToken = await remoteDataSource.refreshAccessToken(
      RefreshTokenRequestModel(refreshToken: refreshToken),
    );
    await saveTokens(
      accessToken: newAccessToken.accessToken,
      refreshToken: refreshToken,
    );
    return RefreshTokenResponseModel(accessToken: newAccessToken.accessToken);
  }

  // savetoken
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
  }

  @override
  Future<void> saveAccessToken(String accessToken) async {
    await localDataSource.saveAccessToken(accessToken);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await localDataSource.saveRefreshToken(refreshToken);
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
