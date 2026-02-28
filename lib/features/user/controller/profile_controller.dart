import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/core/utils/app_utils.dart';

class ProfileController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> userProfile = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.get('/me');
      if (response.statusCode == 200) {
        userProfile.value = response.data['user'] ?? response.data;
      }
    } catch (e) {
      print('Failed to fetch profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? businessName,
  }) async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.post(
        '/profile',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'business_name': businessName,
        },
      );

      if (response.statusCode == 200) {
        userProfile.value = response.data['user'];
        Get.back();
        AppUtils.showSuccess(message: 'Profile updated successfully');
      }
    } catch (e) {
      AppUtils.showError(message: 'Failed to update profile');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.post(
        '/profile/password',
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        Get.back();
        AppUtils.showSuccess(message: 'Password changed successfully');
      }
    } catch (e) {
      AppUtils.showError(
        message:
            'Failed to change password. Ensure current password is correct.',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
