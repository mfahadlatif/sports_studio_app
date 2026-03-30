import 'dart:async';
import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/features/user/controller/profile_controller.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:dio/dio.dart';

class PhoneVerificationController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isVerified = false.obs;
  final RxString phoneNumber = ''.obs;
  final countryCode = 'PK'.obs;
  final dialCode = '+92'.obs;

  String formatPhone(String? dCode, String? p) {
    if (dCode == null || p == null) return '';
    String cleaned = p.replaceAll(RegExp(r'\D'), '');
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }
    String d = dCode.replaceAll('+', '');
    return '+$d$cleaned';
  }

  @override
  void onInit() {
    super.onInit();
    checkStatus();
  }

  Future<void> checkStatus() async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.get('/phone-verification-status');
      if (response.statusCode == 200) {
        isVerified.value = response.data['is_verified'] ?? false;
        phoneNumber.value = response.data['phone'] ?? '';
        
        // Sync with ProfileController
        try {
          final profileController = Get.find<ProfileController>();
          profileController.updateUserData({
            'is_phone_verified': isVerified.value,
            'phone': phoneNumber.value,
          });
        } catch (_) {}
      }
    } catch (e) {
      print('Error checking phone status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> requestVerification(String phone) async {
    if (phone.isEmpty) {
      Get.snackbar('Error', 'Please enter a valid phone number');
      return false;
    }

    isLoading.value = true;
    try {
      print('🌐 [PhoneVerification] Requesting OTP from backend for: $phone');
      final response = await ApiClient().dio.post(
        '/request-phone-verification',
        data: {'phone': phone},
      );

      if (response.statusCode == 200) {
        isLoading.value = false;
        final msg = response.data['message'] ?? 'Verification code sent';
        AppUtils.showSuccess(title: 'Code Sent', message: msg);
        
        // Return true to indicate we can proceed to OTP input
        return true;
      }
      return false;
    } catch (e) {
      isLoading.value = false;
      print('❌ [PhoneVerification] Backend Request Error: $e');
      String errorMsg = 'Failed to send code';
      if (e is DioException) {
        errorMsg = e.response?.data?['message'] ?? errorMsg;
      }
      AppUtils.showError(title: 'Error', message: errorMsg);
      return false;
    }
  }

  Future<bool> verifyPhone(String phone, String code) async {
    if (code.isEmpty) {
      AppUtils.showError(message: 'Please enter verification code');
      return false;
    }

    isLoading.value = true;
    try {
      print('🌐 [PhoneVerification] Verifying OTP with backend: $phone | $code');
      // Directly call the backend verify endpoint. 
      // The backend handles both standard and magic code (123456) checks.
      final response = await ApiClient().dio.post(
        '/verify-phone',
        data: {'phone': phone, 'code': code},
      );

      if (response.statusCode == 200) {
        isVerified.value = true;
        phoneNumber.value = phone;
        
        final backendMessage = response.data['message'] ?? 'Phone verified successfully';
        
        // Refresh profile to update UI flags
        try {
          final profileController = Get.find<ProfileController>();
          await profileController.fetchProfile();
        } catch (_) {}

        AppUtils.showSuccess(title: 'Success', message: backendMessage);
        return true;
      }
      return false;
    } catch (e) {
      String msg = 'Verification failed';
      if (e is DioException) {
        msg = e.response?.data?['message'] ?? msg;
      }
      AppUtils.showError(title: 'Failed', message: msg);
      print('❌ [PhoneVerification] Verify Error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
