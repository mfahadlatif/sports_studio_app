import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // Production URL (Hostinger) - Active for physical devices & real testing
  static const String baseUrl =
      'https://lightcoral-goose-424965.hostingersite.com/backend/public/api';

  // Localhost only - Android Emulator (10.0.2.2) or iOS Simulator (localhost/127.0.0.1)
  // static const String baseUrl = 'http://10.0.2.2/cricket-oasis-bookings/backend/public/api';
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  FlutterSecureStorage get storage => _storage;

  ApiClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
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
      ),
    );
  }

  Dio get dio => _dio;
}
