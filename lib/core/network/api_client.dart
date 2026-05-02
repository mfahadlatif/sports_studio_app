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
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'SportStudioMobile/1.0.0',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('🚀 [API Request] ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ [API Response] ${response.statusCode} ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          print('❌ [API Error] ${e.type} | ${e.message} | ${e.requestOptions.uri}');
          
          if (e.response?.statusCode == 401) {
            print('⚠️ [API] 401 Unauthorized detected. Clearing session.');
            await _storage.delete(key: 'auth_token');
            await _storage.delete(key: 'user_role');

            if (Get.currentRoute != '/auth' && Get.currentRoute != '/login') {
              Get.offAllNamed('/auth');
            }
            return handler.next(e);
          }

          // Retry logic for transient errors
          if (_shouldRetry(e)) {
            final int retryCount = e.requestOptions.extra['retryCount'] ?? 0;
            if (retryCount < 2) {
              print('🔄 [API] Retrying request... (Attempt ${retryCount + 1})');
              e.requestOptions.extra['retryCount'] = retryCount + 1;
              
              // Exponential backoff
              await Future.delayed(Duration(seconds: 1 * (retryCount + 1)));
              
              try {
                final response = await _dio.request(
                  e.requestOptions.path,
                  data: e.requestOptions.data,
                  queryParameters: e.requestOptions.queryParameters,
                  options: Options(
                    method: e.requestOptions.method,
                    headers: e.requestOptions.headers,
                    extra: e.requestOptions.extra,
                  ),
                );
                return handler.resolve(response);
              } catch (retryError) {
                print('❌ [API] Retry failed: $retryError');
              }
            }
          }

          return handler.next(e);
        },
      ),
    );
  }

  bool _shouldRetry(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
           e.type == DioExceptionType.receiveTimeout ||
           e.type == DioExceptionType.sendTimeout ||
           e.type == DioExceptionType.connectionError;
  }

  Dio get dio => _dio;
}
