import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class ApiClient {
  static const String baseUrl =
      'https://sportstudio.squarenex.com/backend/public/api';

  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  FlutterSecureStorage get storage => _storage;

  ApiClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: {'Accept': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            print('⚠️ [API] 401 Unauthorized detected. Clearing session.');
            // Unauthorized - probably means token expired or was cleared
            await _storage.delete(key: 'auth_token');
            await _storage.delete(key: 'user_role');

            print('🔒 [API] Session cleared. Redirecting to auth.');
            // Navigate to auth screen if not already there
            if (Get.currentRoute != '/auth' && Get.currentRoute != '/login') {
              Get.offAllNamed('/auth');
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
