import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OnboardingController extends GetxController {
  final RxInt currentPage = 0.obs;
  final _storage = const FlutterSecureStorage();

  void skip() {
    finishOnboarding();
  }

  Future<void> finishOnboarding() async {
    await _storage.write(key: 'has_seen_onboarding', value: 'true');
    Get.offAllNamed('/auth');
  }
}
