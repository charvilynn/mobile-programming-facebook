import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'storage_service.dart';

class ApiClient {
  // Ganti dengan IPv4 laptop Anda yang didapat dari ipconfig:
  static const String ipLaptop = '192.168.18.7';

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api/v1';
    return 'http://$ipLaptop:3000/api/v1';
  }

  late final Dio _dio;
  final StorageService _storage;

  ApiClient(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (err, handler) async {
        if (err.response?.statusCode == 401) {
          final refreshed = await _tryRefresh();
          if (refreshed) {
            final token = await _storage.getToken();
            err.requestOptions.headers['Authorization'] = 'Bearer $token';
            final response = await _dio.fetch(err.requestOptions);
            return handler.resolve(response);
          }
        }
        handler.next(err);
      },
    ));
  }

  Future<bool> _tryRefresh() async {
    try {
      final refresh = await _storage.getRefreshToken();
      if (refresh == null) return false;
      final res = await Dio().post('$baseUrl/auth/refresh', data: {
        'refresh_token': refresh,
      });
      await _storage.saveToken(res.data['token']);
      return true;
    } catch (_) {
      await _storage.clearTokens();
      return false;
    }
  }

  Future<Response> get(String path,
          {Map<String, dynamic>? params,
          Map<String, dynamic>? queryParameters}) =>
      _dio.get(path, queryParameters: queryParameters ?? params);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> patch(String path, {dynamic data}) =>
      _dio.patch(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);

  Future<Response> uploadFile(String path, FormData formData) =>
      _dio.post(path, data: formData);
}