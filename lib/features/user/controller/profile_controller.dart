import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/models/models.dart';
import 'package:sports_studio/core/network/api_services.dart';
import 'package:sports_studio/core/models/models.dart' as models;
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileController extends GetxController {
  final RxBool isLoadingProfile = false.obs;
  final RxBool isUpdatingProfile = false.obs;
  final RxBool isChangingPassword = false.obs;
  final RxBool isUploadingAvatar = false.obs;
  final RxMap<String, dynamic> userProfile = <String, dynamic>{}.obs;
  final RxList<models.Notification> notifications = <models.Notification>[].obs;
  final RxInt unreadCount = 0.obs;

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final fullPhone = ''.obs;
  final countryCode = 'PK'.obs;
  final dialCode = '+92'.obs;
  final businessNameController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final UserApiService _userApiService = UserApiService();
  final NotificationApiService _notificationApiService =
      NotificationApiService();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    fetchNotifications();
  }

  Future<void> fetchProfile() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');
    if (token == null) return;

    isLoadingProfile.value = true;

    try {
      final user = await _userApiService.getCurrentUser();
      userProfile.value = user.toJson();

      // Populate form controllers
      nameController.text = user.name;
      emailController.text = user.email;
      phoneController.text = user.phone ?? '';
    } catch (e) {
      AppUtils.showError(message: e);
    } finally {
      isLoadingProfile.value = false;
    }
  }

  void updateUserData(Map<String, dynamic> data) {
    userProfile.value = data;
  }

  Future<void> updateProfile() async {
    if (nameController.text.trim().isEmpty) {
      AppUtils.showError(message: 'Name is required');
      return;
    }

    if (emailController.text.trim().isEmpty) {
      AppUtils.showError(message: 'Email is required');
      return;
    }

    isUpdatingProfile.value = true;
    try {
      final profileData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': fullPhone.value.trim().isNotEmpty
            ? fullPhone.value.trim()
            : phoneController.text.trim(),
        'business_name': businessNameController.text.trim(),
      };

      final user = await _userApiService.updateProfile(profileData);
      userProfile.value = user.toJson();
      AppUtils.showSuccess(message: 'Profile updated successfully');
      Get.back();
    } catch (e) {
      AppUtils.showError(message: e);
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  Future<void> changePassword() async {
    if (currentPasswordController.text.isEmpty) {
      AppUtils.showError(message: 'Current password is required');
      return;
    }

    if (newPasswordController.text.isEmpty) {
      AppUtils.showError(message: 'New password is required');
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      AppUtils.showError(message: 'Passwords do not match');
      return;
    }

    isChangingPassword.value = true;
    try {
      await _userApiService.changePassword(
        currentPasswordController.text,
        newPasswordController.text,
      );
      AppUtils.showSuccess(message: 'Password changed successfully');
      Get.back();
      clearPasswordFields();
    } catch (e) {
      AppUtils.showError(message: e);
    } finally {
      isChangingPassword.value = false;
    }
  }

  Future<void> updateAvatar() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
      );

      if (image == null) return;

      isUploadingAvatar.value = true;
      print('📷 [ProfileCtrl] Picked image: ${image.path}');

      // Send avatar directly to /profile endpoint as multipart file
      // The key 'avatar_file_path' signals UserApiService to use multipart
      final User user = await _userApiService.updateProfile({
        'avatar_file_path': image.path,
      });
      userProfile.value = user.toJson();
      print('✅ [ProfileCtrl] Avatar updated. New avatar: ${user.avatar}');
      AppUtils.showSuccess(message: 'Profile picture updated');
    } catch (e) {
      print('❌ [ProfileCtrl] updateAvatar error: $e');
      AppUtils.showError(message: e);
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  Future<void> fetchNotifications() async {
    final token = await const FlutterSecureStorage().read(key: 'auth_token');
    if (token == null) return;

    try {
      final notificationList = await _notificationApiService
          .getUserNotifications();
      notifications.value = notificationList;
      unreadCount.value = notificationList
          .where((n) => n.readAt == null)
          .length;
    } catch (e) {
      AppUtils.showError(message: e);
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _notificationApiService.markAsRead(notificationId);

      // Update local notification
      final notification = notifications.firstWhereOrNull(
        (n) => n.id == notificationId,
      );
      if (notification != null) {
        final index = notifications.indexOf(notification);
        notifications[index] = models.Notification(
          id: notification.id,
          userId: notification.userId,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          link: notification.link,
          readAt: DateTime.now(),
          createdAt: notification.createdAt,
        );

        // Update unread count
        unreadCount.value = notifications.where((n) => n.readAt == null).length;
      }

      AppUtils.showSuccess(message: 'Marked as read');
    } catch (e) {
      AppUtils.showError(message: e);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationApiService.markAllAsRead();

      // Update local notifications
      final updatedNotifications = notifications.map((notification) {
        return models.Notification(
          id: notification.id,
          userId: notification.userId,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          link: notification.link,
          readAt: DateTime.now(),
          createdAt: notification.createdAt,
        );
      }).toList();

      notifications.value = updatedNotifications;
      unreadCount.value = 0;

      AppUtils.showSuccess(message: 'All notifications marked as read');
    } catch (e) {
      AppUtils.showError(message: e);
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationApiService.deleteNotification(notificationId);

      // Remove from local list
      notifications.removeWhere((n) => n.id == notificationId);

      // Update unread count
      unreadCount.value = notifications.where((n) => n.readAt == null).length;

      AppUtils.showSuccess(message: 'Notification deleted');
    } catch (e) {
      AppUtils.showError(message: e);
    }
  }

  Future<void> requestPhoneVerification(String phone) async {
    try {
      await _userApiService.requestPhoneVerification(phone);
      AppUtils.showSuccess(message: 'Verification code sent to $phone');
    } catch (e) {
      AppUtils.showError(message: e);
    }
  }

  Future<Map<String, dynamic>> verifyPhone(String phone, String code) async {
    try {
      final response = await _userApiService.verifyPhone(phone, code);

      if (response['phone_verified'] == true) {
        AppUtils.showSuccess(message: 'Phone verified successfully!');
        await fetchProfile(); // Refresh profile to update verification status
      } else {
        AppUtils.showError(message: 'Invalid verification code');
      }

      return response;
    } catch (e) {
      AppUtils.showError(message: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkPhoneVerificationStatus() async {
    try {
      return await _userApiService.checkPhoneVerificationStatus();
    } catch (e) {
      AppUtils.showError(message: e);
      rethrow;
    }
  }

  void clearPasswordFields() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  void populateProfileForm() {
    final user = userProfile;
    nameController.text = user['name']?.toString() ?? '';
    emailController.text = user['email']?.toString() ?? '';
    phoneController.text = user['phone']?.toString() ?? '';
    fullPhone.value = user['phone']?.toString() ?? '';
    businessNameController.text = user['business_name']?.toString() ?? '';
  }

  bool get isPhoneVerified {
    return userProfile['is_phone_verified'] == 1 || 
           userProfile['is_phone_verified'] == true ||
           userProfile['phone_verified'] == true;
  }

  bool get hasUnreadNotifications {
    return unreadCount.value > 0;
  }

  String get userName {
    return userProfile['name']?.toString() ?? 'User';
  }

  String get userEmail {
    return userProfile['email']?.toString() ?? '';
  }

  String? get userPhone {
    return userProfile['phone']?.toString();
  }

  String? get userAvatar {
    return userProfile['avatar']?.toString();
  }

  bool get isSocialUser {
    return userProfile['google_id'] != null ||
        userProfile['apple_id'] != null;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
