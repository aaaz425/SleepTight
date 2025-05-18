abstract class AuthRepository {
  // 인증/로그인 관련
  Future<void> loginWithKakao(String authorizationCode);
  Future<void> refreshAccessToken();

  // 토큰 관리
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearToken();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
}
