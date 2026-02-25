import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/core/theme/app_colors.dart';

class ContactController extends GetxController {
  final RxBool isLoading = false.obs;

  Future<bool> submitContactForm({
    required String name,
    required String email,
    required String message,
  }) async {
    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return false;
    }

    isLoading.value = true;
    try {
      final response = await ApiClient().dio.post(
        '/contact',
        data: {'name': name, 'email': email, 'message': message},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Your message has been sent successfully',
          backgroundColor: AppColors.primary.withOpacity(0.1),
          colorText: AppColors.primary,
        );
        return true;
      }
    } catch (e) {
      print('Contact submit error: $e');
      Get.snackbar(
        'Error',
        'Failed to send message. Please try again later.',
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
    return false;
  }
}
