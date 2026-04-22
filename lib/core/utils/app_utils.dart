import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:sport_studio/core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class AppUtils {
  static String formatCurrency(dynamic amount) {
    if (amount == null) return '${AppConstants.currencySymbol} 0';
    final formatter = NumberFormat('#,###');
    final val = double.tryParse(amount.toString()) ?? 0.0;
    return '${AppConstants.currencySymbol} ${formatter.format(val)}';
  }

  static String formatTime(dynamic time) {
    if (time == null) return '—';
    if (time is DateTime) return DateFormat('hh:mm a').format(time);
    if (time is TimeOfDay) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      return DateFormat('hh:mm a').format(dt);
    }
    if (time is String) {
      try {
        // Try parsing as full datetime first
        final dt = DateTime.parse(time.replaceFirst(' ', 'T'));
        return DateFormat('hh:mm a').format(dt);
      } catch (_) {
        try {
          // Try parsing as HH:mm
          final parts = time.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          final now = DateTime.now();
          final dt = DateTime(now.year, now.month, now.day, hour, minute);
          return DateFormat('hh:mm a').format(dt);
        } catch (_) {
          return time;
        }
      }
    }
    return time.toString();
  }

  static String formatDateTime(dynamic dateTime) {
    if (dateTime == null) return '—';
    if (dateTime is DateTime)
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
    if (dateTime is String) {
      try {
        final dt = DateTime.parse(dateTime.replaceFirst(' ', 'T'));
        return DateFormat('MMM dd, yyyy • hh:mm a').format(dt);
      } catch (_) {
        return dateTime;
      }
    }
    return dateTime.toString();
  }

  static String formatDate(dynamic date) {
    if (date == null) return '—';
    if (date is DateTime) return DateFormat('MMM dd, yyyy').format(date);
    if (date is String) {
      try {
        final dt = DateTime.parse(date.replaceFirst(' ', 'T'));
        return DateFormat('MMM dd, yyyy').format(dt);
      } catch (_) {
        return date;
      }
    }
    return date.toString();
  }

  static String formatTimeRange(dynamic start, dynamic end) {
    return '${formatTime(start)} - ${formatTime(end)}';
  }

  static void showSuccess({
    String title = 'Success',
    required String message,
    Duration? duration,
  }) {
    Get.closeAllSnackbars();
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
          color: AppColors.primary.withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static void showConfirmDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    IconData? icon,
    Color? confirmColor,
  }) {
    Get.dialog(
      Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: (confirmColor ?? AppColors.primary).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: confirmColor ?? AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        cancelText,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor ?? AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        confirmText,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionCurve: Curves.easeOutBack,
    );
  }

  static void showError({
    String title = 'Error',
    required dynamic message,
    Duration? duration,
  }) {
    String errorMessage = extractErrorMessage(message);

    if (errorMessage.isEmpty) return; // Handled globally or nothing to show

    Get.closeAllSnackbars();
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
          color: AppColors.error.withValues(alpha: 0.3),
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
            return errors.values.first
                .toString()
                .replaceAll('[', '')
                .replaceAll(']', '');
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
    if (msgStr.contains('401') ||
        msgStr.toLowerCase().contains('unauthorized')) {
      return '';
    }

    if (msgStr.contains('status code of 422') ||
        msgStr.contains('DioException [bad response]')) {
      // DioException bad response with 422 should ideally be caught by
      // error is DioException block. If it falls through, it might be a wrapped exception.
      // But we'll provide a hint if possible or let the raw message through.
      if (msgStr.contains('Exception:')) {
        return msgStr.replaceFirst('Exception: ', '').trim();
      }
      return 'Validation failed. Please verify your details.';
    }

    if (msgStr.contains('timeout')) {
      return 'Connection timed out. Please check your internet.';
    } else if (msgStr.contains('connection')) {
      return 'Network error. Please check your connection.';
    }

    return msgStr
        .replaceFirst('Exception: ', '')
        .replaceFirst('Exception', '')
        .trim();
  }

  static void showInfo({
    String title = 'Info',
    required String message,
    Duration? duration,
  }) {
    Get.closeAllSnackbars();
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
          color: AppColors.secondary.withValues(alpha: 0.3),
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
    Get.closeAllSnackbars();
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
          color: AppColors.accent.withValues(alpha: 0.3),
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
    if (s.contains('football') || s.contains('soccer'))
      return Icons.sports_soccer_outlined;
    if (s.contains('tennis')) return Icons.sports_tennis_outlined;
    if (s.contains('basketball')) return Icons.sports_basketball_outlined;
    if (s.contains('badminton')) return Icons.sports_tennis;
    if (s.contains('hockey')) return Icons.sports_hockey_outlined;
    if (s.contains('volleyball')) return Icons.sports_volleyball_outlined;
    if (s.contains('table tennis') || s.contains('tt'))
      return Icons.table_restaurant_outlined;
    if (s.contains('swimming')) return Icons.pool;
    if (s.contains('padel')) return Icons.sports_tennis;
    return Icons.sports_soccer_outlined;
  }

  static void showDeactivatedDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock_outline, color: AppColors.error),
            const SizedBox(width: 10),
            const Text(
              'Account Deactivated',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Your account has been deactivated by the administrator. Please contact support to regain access to your profile and bookings.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'OK',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  static void showSuccessDialog({
    required String title,
    required String message,
    String confirmText = 'Got it',
    VoidCallback? onConfirm,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    if (onConfirm != null) onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    confirmText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static Future<bool?> showDeleteConfirmation({
    required String title,
    required String message,
  }) {
    return Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(result: false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Colors.grey.shade200,
                            width: 2,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  static void showActionDialog({
    required String title,
    required String message,
    required String actionText,
    required VoidCallback onAction,
    IconData icon = Icons.info_outline_rounded,
    Color iconColor = AppColors.primary,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 44),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Colors.grey.shade200,
                            width: 2,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        onAction();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: iconColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        actionText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  static Future<void> launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await launcher.canLaunchUrl(uri)) {
        await launcher.launchUrl(uri, mode: launcher.LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Launch error: $e');
    }
  }
}
