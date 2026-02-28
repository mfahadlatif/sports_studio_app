import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    required String message,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      message,
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
