import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OnboardingController extends GetxController {
  final RxInt currentPage = 0.obs;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  void nextPage(int totalPages) {
    if (currentPage.value < totalPages - 1) {
      currentPage.value++;
    } else {
      finishOnboarding();
    }
  }

  Future<void> finishOnboarding() async {
    await _storage.write(key: 'has_seen_onboarding', value: 'true');
    Get.offAllNamed('/auth');
  }

  void skip() {
    finishOnboarding();
  }
}
