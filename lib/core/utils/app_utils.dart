import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:sports_studio/core/theme/app_colors.dart';

class AppUtils {
  static void showSuccess({
    String title = 'Success',
    required String message,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: const EdgeInsets.all(20),
      borderRadius: 15,
      duration: duration ?? const Duration(seconds: 3),
      boxShadows: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static void showError({
    String title = 'Error',
    required dynamic message,
    Duration? duration,
  }) {
    String errorMessage = '';

    if (message is DioException) {
      errorMessage = _handleDioError(message);
    } else {
      final msgStr = message.toString();
      // If the string contains technical Dio error info, clean it up
      if (msgStr.contains('DioException') || msgStr.contains('timeout')) {
        if (msgStr.contains('timeout')) {
          errorMessage = 'Connection timed out. Please check your internet.';
        } else if (msgStr.contains('connection')) {
          errorMessage = 'Network error. Please check your connection.';
        } else {
          errorMessage = 'Something went wrong. Please try again later.';
        }
      } else {
        errorMessage = msgStr;
      }
    }

    Get.snackbar(
      title,
      errorMessage,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: const EdgeInsets.all(20),
      borderRadius: 15,
      duration: duration ?? const Duration(seconds: 4),
      boxShadows: [
        BoxShadow(
          color: AppColors.error.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet and try again.';
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        if (data != null && data is Map && data.containsKey('message')) {
          return data['message'];
        }
        return 'Server error (${error.response?.statusCode}). Please try again later.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection found. Please check your WiFi or mobile data.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  static void showInfo({
    String title = 'Info',
    required String message,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.secondary,
      colorText: Colors.white,
      icon: const Icon(Icons.info_outline, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: const EdgeInsets.all(20),
      borderRadius: 15,
      duration: duration ?? const Duration(seconds: 3),
      boxShadows: [
        BoxShadow(
          color: AppColors.secondary.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static void showWarning({
    String title = 'Warning',
    required String message,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.accent,
      colorText: Colors.white,
      icon: const Icon(Icons.warning_amber_outlined, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: const EdgeInsets.all(20),
      borderRadius: 15,
      duration: duration ?? const Duration(seconds: 4),
      boxShadows: [
        BoxShadow(
          color: AppColors.accent.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
