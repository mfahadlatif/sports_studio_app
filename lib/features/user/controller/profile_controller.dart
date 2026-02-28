import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio_form;

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
        updateUserData(response.data['user'] ?? response.data);
      }
    } catch (e) {
      print('Failed to fetch profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateUserData(Map<String, dynamic> data) {
    userProfile.value = data;
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
        updateUserData(response.data['user'] ?? response.data);
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

  Future<void> updateAvatar() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 500,
      );

      if (image == null) return;

      isLoading.value = true;
      dio_form.FormData formData = dio_form.FormData.fromMap({
        'avatar': await dio_form.MultipartFile.fromFile(
          image.path,
          filename: 'avatar.jpg',
        ),
      });

      final response = await ApiClient().dio.post('/profile', data: formData);

      if (response.statusCode == 200) {
        userProfile.value = response.data['user'] ?? response.data;
        AppUtils.showSuccess(message: 'Profile picture updated');
      }
    } catch (e) {
      print('Avatar update error: $e');
      AppUtils.showError(message: 'Failed to update profile picture');
    } finally {
      isLoading.value = false;
    }
  }
}
