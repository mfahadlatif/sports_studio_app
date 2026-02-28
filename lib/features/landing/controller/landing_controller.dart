import 'package:get/get.dart';
import 'package:sports_studio/core/constants/user_roles.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sports_studio/features/user/controller/profile_controller.dart';

class LandingController extends GetxController {
  final RxInt currentNavIndex = 0.obs;
  final Rx<UserRole> currentRole = UserRole.user.obs;
  final _storage = const FlutterSecureStorage();

  void changeNavIndex(int index) {
    currentNavIndex.value = index;
  }

  void toggleRole() {
    currentRole.value = currentRole.value == UserRole.user
        ? UserRole.owner
        : UserRole.user;
    currentNavIndex.value = 0; // Reset index on role change
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_role');

    // Clear profile data
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().userProfile.value = {};
    }

    currentRole.value = UserRole.user;
    currentNavIndex.value = 0;
    Get.offAllNamed('/auth');
  }
}
