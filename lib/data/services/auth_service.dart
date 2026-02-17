import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

class AuthService {
  final ApiService _apiService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService({required ApiService apiService}) : _apiService = apiService;

  Future<User?> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['user'] != null) {
        final token = response.data['access_token'];
        final user = User.fromJson(response.data['user']);

        await _storage.write(key: 'auth_token', value: token);

        return user;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid credentials');
      }
      throw Exception('Login failed: ${e.message}');
    }
  }

  Future<User?> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    File? image, // Added image parameter
  }) async {
    try {
      dynamic data;
      Options? options;

      if (image != null) {
        data = FormData.fromMap({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'phone': phone,
          'avatar': await MultipartFile.fromFile(
            image.path,
          ), // Assuming 'avatar' is the key
        });
        // Dio handles content-type for FormData automatically
      } else {
        data = {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'phone': phone,
        };
      }

      final response = await _apiService.post(
        ApiConstants.register,
        data: data,
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Typically returns user + token
        final token = response.data['access_token'];
        if (response.data['user'] != null) {
          final user = User.fromJson(response.data['user']);
          await _storage.write(key: 'auth_token', value: token);
          return user;
        }
        // Handle case where user might be null but token exists?
        // Assuming user is always returned
      }
      return null;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<User?> updateProfile({
    String? name,
    String? phone,
    File? image,
  }) async {
    try {
      dynamic data;
      Options? options;

      if (image != null) {
        data = FormData.fromMap({
          'name': name,
          'phone': phone,
          'avatar': await MultipartFile.fromFile(image.path),
          '_method': 'PUT',
        });
      } else {
        data = {'name': name, 'phone': phone, '_method': 'PUT'};
      }

      final response = await _apiService.post(
        ApiConstants.profile,
        data: data,
        options: options,
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data['user']);
      }
      return null;
    } catch (e) {
      throw Exception('Update profile failed: $e');
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstants.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Change password failed: $e');
    }
  }

  Future<User?> googleLogin(String idToken) async {
    try {
      final response = await _apiService.post(
        ApiConstants.googleLogin,
        data: {'id_token': idToken},
      );

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        final user = User.fromJson(response.data['user']);
        await _storage.write(key: 'auth_token', value: token);
        return user;
      }
      return null;
    } catch (e) {
      throw Exception('Google login failed: $e');
    }
  }

  Future<User?> appleLogin(String idToken, {String? name}) async {
    try {
      final response = await _apiService.post(
        ApiConstants.appleLogin,
        data: {'id_token': idToken, 'name': name},
      );

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        final user = User.fromJson(response.data['user']);
        await _storage.write(key: 'auth_token', value: token);
        return user;
      }
      return null;
    } catch (e) {
      throw Exception('Apple login failed: $e');
    }
  }
}
