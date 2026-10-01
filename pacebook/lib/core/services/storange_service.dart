import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _tokenKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userIdKey = 'user_id';

  // Web uses IndexedDB-backed storage via flutter_secure_storage
  // Mobile uses Keychain (iOS) / EncryptedSharedPreferences (Android)
  final FlutterSecureStorage _storage;

  StorageService()
    : _storage = kIsWeb
          ? const FlutterSecureStorage(
              webOptions: WebOptions(
                wrapKey: 'pacebook_wrap_key_2026',
                wrapKeyIv: 'pacebook_iv_2026!',
              ),
            )
          : const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  static const _userDataKey = 'user_data';

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshKey, value: token);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> saveUserId(int id) =>
      _storage.write(key: _userIdKey, value: id.toString());

  Future<int?> getUserId() async {
    final val = await _storage.read(key: _userIdKey);
    return val != null ? int.tryParse(val) : null;
  }

  Future<void> saveUserData(String jsonStr) =>
      _storage.write(key: _userDataKey, value: jsonStr);

  Future<String?> getUserData() => _storage.read(key: _userDataKey);

  static const _themeModeKey = 'theme_mode';
  static const _profileVisibilityKey = 'profile_visibility';

  Future<void> saveThemeMode(String mode) =>
      _storage.write(key: _themeModeKey, value: mode);

  Future<String?> getThemeMode() => _storage.read(key: _themeModeKey);

  Future<void> saveProfileVisibility(String val) =>
      _storage.write(key: _profileVisibilityKey, value: val);

  Future<String?> getProfileVisibility() =>
      _storage.read(key: _profileVisibilityKey);

  Future<void> clearTokens() => _storage.deleteAll();

  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (_) {
      // Storage can fail on web without HTTPS context — treat as logged out
      return false;
    }
  }
}
