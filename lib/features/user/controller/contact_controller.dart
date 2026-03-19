import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/core/utils/app_utils.dart';

class ContactController extends GetxController {
  final RxBool isLoading = false.obs;

  Future<bool> submitContactForm({
    required String name,
    required String email,
    required String message,
  }) async {
    if (name.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your name');
      return false;
    }

    if (email.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your email address');
      return false;
    }

    // Email validation regex
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email.trim())) {
      Get.snackbar('Error', 'Please enter a valid email address');
      return false;
    }

    if (message.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your message');
      return false;
    }

    isLoading.value = true;
    try {
      final response = await ApiClient().dio.post(
        '/contact',
        data: {'name': name, 'email': email, 'message': message},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppUtils.showSuccess(
          message: 'Your message has been sent successfully',
        );
        return true;
      }
    } catch (e) {
      print('❌ [ContactCtrl] submit error: $e');
      AppUtils.showError(message: e);
      return false;
    } finally {
      isLoading.value = false;
    }
    return false;
  }
}
