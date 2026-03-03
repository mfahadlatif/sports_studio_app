import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/models/models.dart';
import 'package:sports_studio/core/network/api_services.dart';
import 'package:sports_studio/core/models/models.dart' as models;
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:image_picker/image_picker.dart';

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
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final UserApiService _userApiService = UserApiService();
  final NotificationApiService _notificationApiService =
      NotificationApiService();
  final MediaApiService _mediaApiService = MediaApiService();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    fetchNotifications();
  }

  Future<void> fetchProfile() async {
    isLoadingProfile.value = true;
    try {
      final user = await _userApiService.getCurrentUser();
      userProfile.value = user.toJson();

      // Populate form controllers
      nameController.text = user.name;
      emailController.text = user.email;
      phoneController.text = user.phone ?? '';
    } catch (e) {
      AppUtils.showError(message: 'Failed to fetch profile: $e');
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
        'phone': phoneController.text.trim(),
      };

      final user = await _userApiService.updateProfile(profileData);
      userProfile.value = user.toJson();
      AppUtils.showSuccess(message: 'Profile updated successfully');
      Get.back();
    } catch (e) {
      AppUtils.showError(message: 'Failed to update profile: $e');
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
      AppUtils.showError(message: 'Failed to change password: $e');
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
        maxWidth: 500,
      );

      if (image == null) return;

      isUploadingAvatar.value = true;

      // Upload image using media service
      final uploadResponse = await _mediaApiService.uploadFile(image.path);
      final avatarPath = uploadResponse['path'];

      // Update profile with new avatar
      final profileData = {'avatar': avatarPath};
      User user = await _userApiService.updateProfile(profileData);
      userProfile.value = user.toJson();

      AppUtils.showSuccess(message: 'Profile picture updated');
    } catch (e) {
      AppUtils.showError(message: 'Failed to update profile picture: $e');
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  Future<void> fetchNotifications() async {
    try {
      final notificationList = await _notificationApiService
          .getUserNotifications();
      notifications.value = notificationList;
      unreadCount.value = notificationList
          .where((n) => n.readAt == null)
          .length;
    } catch (e) {
      AppUtils.showError(message: 'Failed to fetch notifications: $e');
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
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
          readAt: DateTime.now(),
          createdAt: notification.createdAt,
        );

        // Update unread count
        unreadCount.value = notifications.where((n) => n.readAt == null).length;
      }

      AppUtils.showSuccess(message: 'Marked as read');
    } catch (e) {
      AppUtils.showError(message: 'Failed to mark as read: $e');
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
          readAt: DateTime.now(),
          createdAt: notification.createdAt,
        );
      }).toList();

      notifications.value = updatedNotifications;
      unreadCount.value = 0;

      AppUtils.showSuccess(message: 'All notifications marked as read');
    } catch (e) {
      AppUtils.showError(message: 'Failed to mark all as read: $e');
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      await _notificationApiService.deleteNotification(notificationId);

      // Remove from local list
      notifications.removeWhere((n) => n.id == notificationId);

      // Update unread count
      unreadCount.value = notifications.where((n) => n.readAt == null).length;

      AppUtils.showSuccess(message: 'Notification deleted');
    } catch (e) {
      AppUtils.showError(message: 'Failed to delete notification: $e');
    }
  }

  Future<void> requestPhoneVerification(String phone) async {
    try {
      await _userApiService.requestPhoneVerification(phone);
      AppUtils.showSuccess(message: 'Verification code sent to $phone');
    } catch (e) {
      AppUtils.showError(message: 'Failed to send verification code: $e');
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
      AppUtils.showError(message: 'Failed to verify phone: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkPhoneVerificationStatus() async {
    try {
      return await _userApiService.checkPhoneVerificationStatus();
    } catch (e) {
      AppUtils.showError(message: 'Failed to check verification status: $e');
      rethrow;
    }
  }

  void clearPasswordFields() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  void populateProfileForm() {
    final user = userProfile.value;
    nameController.text = user['name'] ?? '';
    emailController.text = user['email'] ?? '';
    phoneController.text = user['phone'] ?? '';
  }

  bool get isPhoneVerified {
    return userProfile.value['phone_verified'] ?? false;
  }

  bool get hasUnreadNotifications {
    return unreadCount.value > 0;
  }

  String get userName {
    return userProfile.value['name'] ?? 'User';
  }

  String get userEmail {
    return userProfile.value['email'] ?? '';
  }

  String? get userPhone {
    return userProfile.value['phone'];
  }

  String? get userAvatar {
    return userProfile.value['avatar'];
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
