abstract class AuthRepository {
  Future<void> loginWithKakao(String authorizationCode);
  Future<void> refreshAccessToken();
  Future<void> logout();

  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<String?> getStatus();

  Future<void> saveStatus(String status);
}
