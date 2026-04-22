import 'package:get/get.dart';
import 'package:sport_studio/core/constants/user_roles.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sport_studio/features/user/controller/profile_controller.dart';
import 'package:sport_studio/core/services/notification_service.dart';

class LandingController extends GetxController {
  final RxInt currentNavIndex = 0.obs;
  final Rx<UserRole> currentRole = UserRole.user.obs;
  final _storage = const FlutterSecureStorage();
  DateTime? lastPressedTime;

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
    try {
      // 1. Clear FCM token from backend first while we still have the local auth_token
      if (Get.isRegistered<NotificationService>()) {
        try {
          await Get.find<NotificationService>().clearToken();
        } catch (e) {
          print('Error clearing FCM token during logout: $e');
        }
      }

      // 2. Clear token and role locally
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'user_role');

      // 3. Clear profile data
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().userProfile.value = {};
      }

      currentRole.value = UserRole.user;
      currentNavIndex.value = 0;
      
      // Clear all routes and go to auth
      Get.offAllNamed('/auth');
    } catch (e) {
      print('Logout Error: $e');
      // Emergency redirect in case of storage failure
      Get.offAllNamed('/auth');
    }
  }
}
