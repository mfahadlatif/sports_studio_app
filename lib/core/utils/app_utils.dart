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
    String errorMessage = extractErrorMessage(message);

    if (errorMessage.isEmpty) return; // Handled globally or nothing to show

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

  static String extractErrorMessage(dynamic error) {
    if (error == null) return 'Unknown error occurred';
    
    if (error is DioException) {
      if (error.response?.statusCode == 401) return ''; // Handled globally
      
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please check your internet and try again.';
        case DioExceptionType.badResponse:
          final data = error.response?.data;
          if (data != null && data is Map && data.containsKey('message')) {
            return data['message'].toString();
          }
          if (data != null && data is Map && data.containsKey('errors')) {
             // Handle Laravel validation errors
             final errors = data['errors'] as Map;
             return errors.values.first.toString().replaceAll('[', '').replaceAll(']', '');
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

    final msgStr = error.toString();
    if (msgStr.contains('401') || msgStr.toLowerCase().contains('unauthorized')) return '';
    
    if (msgStr.contains('DioException [bad response]') || msgStr.contains('status code of 422')) {
      return 'Validation failed. Please check your inputs.';
    } else if (msgStr.contains('timeout')) {
      return 'Connection timed out. Please check your internet.';
    } else if (msgStr.contains('connection')) {
      return 'Network error. Please check your connection.';
    }
    
    return msgStr.replaceFirst('Exception: ', '').replaceFirst('Exception', '').trim();
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
  static IconData getSportIcon(String? sport) {
    if (sport == null) return Icons.sports_soccer_outlined;
    final s = sport.toLowerCase();
    if (s.contains('cricket')) return Icons.sports_cricket_outlined;
    if (s.contains('football') || s.contains('soccer')) return Icons.sports_soccer_outlined;
    if (s.contains('tennis')) return Icons.sports_tennis_outlined;
    if (s.contains('basketball')) return Icons.sports_basketball_outlined;
    if (s.contains('badminton')) return Icons.sports_tennis; 
    if (s.contains('hockey')) return Icons.sports_hockey_outlined;
    if (s.contains('volleyball')) return Icons.sports_volleyball_outlined;
    if (s.contains('table tennis') || s.contains('tt')) return Icons.table_restaurant_outlined;
    if (s.contains('swimming')) return Icons.pool;
    if (s.contains('padel')) return Icons.sports_tennis;
    return Icons.sports_soccer_outlined;
  }
}
