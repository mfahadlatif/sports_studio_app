import 'package:get/get.dart';

import 'package:sports_studio/core/constants/user_roles.dart';

class LandingController extends GetxController {
  final RxInt currentNavIndex = 0.obs;
  final Rx<UserRole> currentRole = UserRole.user.obs;

  void changeNavIndex(int index) {
    currentNavIndex.value = index;
  }

  void toggleRole() {
    currentRole.value = currentRole.value == UserRole.user ? UserRole.owner : UserRole.user;
    currentNavIndex.value = 0; // Reset index on role change
  }

  void logout() {
    currentRole.value = UserRole.user;
    currentNavIndex.value = 0;
    Get.offAllNamed('/auth');
  }
}
