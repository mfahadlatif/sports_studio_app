import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/features/user/controller/profile_controller.dart';
import 'package:dio/dio.dart' as dio_lib;

class PhoneVerificationController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isVerified = false.obs;
  final RxString phoneNumber = ''.obs;

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
      final response = await ApiClient().dio.post(
        '/request-phone-verification',
        data: {'phone': phone},
      );
      if (response.statusCode == 200) {
        phoneNumber.value = phone;
        String msg = response.data['message'] ?? 'Verification code sent';

        // Show OTP in snackbar for easy testing if available in response
        // if (response.data['otp'] != null && response.data['otp'] != '****') {
        //   // msg += ". Code: ${response.data['otp']}";
        // }

        Get.snackbar(
          'Success',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          colorText: AppColors.primary,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Request Verification Error: $e');
      Get.snackbar(
        'Error',
        'Failed to request verification. Please try again later.',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyPhone(String phone, String code) async {
    if (code.isEmpty) {
      Get.snackbar('Error', 'Please enter the verification code');
      return false;
    }

    isLoading.value = true;
    try {
      final response = await ApiClient().dio.post(
        '/verify-phone',
        data: {'phone': phone, 'code': code},
      );

      if (response.statusCode == 200) {
        isVerified.value = true;
        // Refresh profile to reflect verification status
        final profileController = Get.find<ProfileController>();
        await profileController.fetchProfile();

        Get.snackbar(
          'Success',
          'Phone verified successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          colorText: AppColors.primary,
        );
        return true;
      }
      return false;
    } catch (e) {
      String errorMsg = 'Verification failed';
      if (e is dio_lib.DioException &&
          e.response != null &&
          e.response?.data != null) {
        errorMsg = e.response?.data['message'] ?? errorMsg;
      }
      Get.snackbar('Error', errorMsg);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
