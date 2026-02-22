import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/features/profile/controller/profile_controller.dart';

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

  Future<void> requestVerification(String phone) async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.post(
        '/request-phone-verification',
        data: {'phone': phone},
      );
      if (response.statusCode == 200) {
        phoneNumber.value = phone;
        // In a real app, this would trigger an SMS
        Get.snackbar('Success', 'Verification code sent to $phone (Mocked)');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to request verification');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyPhone(String phone, String code) async {
    isLoading.value = true;
    try {
      // For MVP/Demo, we just send a success flag
      final response = await ApiClient().dio.post(
        '/verify-phone',
        data: {
          'phone': phone,
          'verified': true, // Mocked verification success
        },
      );

      if (response.statusCode == 200) {
        isVerified.value = true;
        // Refresh profile to reflect verification status
        final profileController = Get.find<ProfileController>();
        await profileController.fetchProfile();

        Get.snackbar('Success', 'Phone verified successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Verification failed');
    } finally {
      isLoading.value = false;
    }
  }
}
