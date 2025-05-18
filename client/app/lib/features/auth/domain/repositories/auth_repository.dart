import 'package:sleep_tight/features/auth/data/models/requests/kakao_login_request.dart';
import 'package:sleep_tight/features/auth/data/models/responses/kakao_login_response.dart';
import 'package:sleep_tight/features/auth/data/models/responses/refresh_token_response.dart';

abstract class AuthRepository {
  // 인증/로그인 관련
  Future<KakaoLoginResponseModel> loginWithKakao(
    KakaoLoginRequestModel request,
  );
  Future<RefreshTokenResponseModel> refreshAccessToken();

  // 토큰 관리
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearToken();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> saveAccessToken(String accessToken);
}
