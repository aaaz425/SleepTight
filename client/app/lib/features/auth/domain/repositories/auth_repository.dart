abstract class AuthRepository {
  // 인증/로그인 관련
  Future<void> loginWithKakao(String authorizationCode);
  Future<void> refreshAccessToken();

  // 토큰 및 상태 관리
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokenAndStatus();

  // 인증 상태 관련
  Future<String?> getStatus();
  Future<void> saveStatus(String status);
}
