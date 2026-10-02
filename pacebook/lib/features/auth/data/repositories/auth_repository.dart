import 'dart:convert';
import '../../../../core/services/api_client.dart';
import '../../../../core/services/storage_service.dart';

class AuthRepository {
  final ApiClient _api;
  final StorageService _storage;

  AuthRepository(this._api, this._storage);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    await _storage.saveToken(res.data['token'] as String);
    await _storage.saveRefreshToken(res.data['refresh_token'] as String);
    if (res.data['user'] != null) {
      if (res.data['user']['id'] != null) {
        await _storage.saveUserId(res.data['user']['id'] as int);
      }
      await _storage.saveUserData(jsonEncode(res.data['user']));
    }
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    final res = await _api.post('/auth/register', data: {
      'username': username,
      'email': email,
      'password': password,
      'full_name': fullName,
    });
    await _storage.saveToken(res.data['token'] as String);
    await _storage.saveRefreshToken(res.data['refresh_token'] as String);
    if (res.data['user'] != null) {
      if (res.data['user']['id'] != null) {
        await _storage.saveUserId(res.data['user']['id'] as int);
      }
      await _storage.saveUserData(jsonEncode(res.data['user']));
    }
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}
    await _storage.clearTokens();
  }
}