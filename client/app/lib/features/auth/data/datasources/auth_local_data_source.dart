import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> saveStatus(String status);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<String?> getStatus();
  Future<void> clearTokens();
  Future<void> clearStatus();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences prefs;

  AuthLocalDataSourceImpl({required this.secureStorage, required this.prefs});

  static const _accessTokenKey = 'ACCESS_TOKEN';
  static const _refreshTokenKey = 'REFRESH_TOKEN';
  static const _statusKey = 'AUTH_STATUS';

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await secureStorage.write(key: _accessTokenKey, value: accessToken);
    await secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<void> saveStatus(String status) async {
    await prefs.setString(_statusKey, status);
  }

  @override
  Future<String?> getAccessToken() => secureStorage.read(key: _accessTokenKey);

  @override
  Future<String?> getRefreshToken() =>
      secureStorage.read(key: _refreshTokenKey);

  @override
  Future<String?> getStatus() async => prefs.getString(_statusKey);

  @override
  Future<void> clearTokens() async {
    await secureStorage.delete(key: _accessTokenKey);
    await secureStorage.delete(key: _refreshTokenKey);
  }

  @override
  Future<void> clearStatus() async {
    await prefs.remove(_statusKey);
  }
}
