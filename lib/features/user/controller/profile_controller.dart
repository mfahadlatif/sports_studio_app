import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_studio/core/network/api_client.dart';
import 'package:sport_studio/core/network/api_services.dart';
import 'package:sport_studio/core/models/models.dart' as models;
import 'package:sport_studio/core/utils/app_utils.dart';
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
  final RxString pickedAvatarPath = ''.obs;
  final RxInt pendingJoinRequestsCount = 0.obs;
  final RxInt managedEventsCount = 0.obs;
  final RxBool hasOrganizedEvents = false.obs;

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
    // fetchProfile() and fetchNotifications() are now called by AppInitializationService
    // to ensure they only happen when a valid session token exists.
  }

  Future<void> refreshProfileData() async {
    await Future.wait([
      fetchProfile(),
      fetchNotifications(),
      _fetchManagedEventsCount(),
    ]);
  }

  Future<void> _fetchManagedEventsCount() async {
    try {
      final res = await ApiClient().dio.get('/events/user/managed');
      final list = res.data is List
          ? res.data
          : (res.data['data'] as List? ?? []);
      managedEventsCount.value = list.length;
      hasOrganizedEvents.value = list.length > 0;
    } catch (_) {}
  }

  Future<void> fetchProfile() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');
    if (token == null) return;

    isLoadingProfile.value = true;

    try {
      final user = await _userApiService.getCurrentUser();
      userProfile.value = user.toJson();
      pendingJoinRequestsCount.value = user.pendingJoinRequestsCount ?? 0;
      if (pendingJoinRequestsCount.value > 0) hasOrganizedEvents.value = true;

      // Populate form controllers
      nameController.text = user.name;
      emailController.text = user.email;

      String rawPhone = user.phone ?? '';
      fullPhone.value = rawPhone;

      // Robust stripping: handle both "+92" and "92" (or other dial codes)
      String dCode = dialCode.value; // e.g. "+92"
      String dCodeNoPlus = dCode.replaceAll('+', ''); // e.g. "92"

      if (rawPhone.startsWith(dCode)) {
        phoneController.text = rawPhone.replaceFirst(dCode, '');
      } else if (rawPhone.startsWith(dCodeNoPlus)) {
        phoneController.text = rawPhone.replaceFirst(dCodeNoPlus, '');
      } else {
        phoneController.text = rawPhone;
      }
    } catch (e) {
      AppUtils.showError(message: e);
    } finally {
      isLoadingProfile.value = false;
    }
  }

  void updateUserData(Map<String, dynamic> data) {
    userProfile.addAll(data);
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
      print('🚀 [ProfileCtrl] Starting profile update...');
      final profileData = {
        'name': nameController.text.trim(),
        'phone': fullPhone.value.trim().isNotEmpty
            ? fullPhone.value.trim()
            : phoneController.text.trim(),
        'business_name': businessNameController.text.trim(),
      };

      print('🚀 [ProfileCtrl] Payload prepared (Email removed): $profileData');

      if (pickedAvatarPath.value.isNotEmpty) {
        profileData['avatar_file_path'] = pickedAvatarPath.value;
      }

      print('🛰️ [ProfileCtrl] Calling API...');
      final user = await _userApiService.updateProfile(profileData);
      print('✅ [ProfileCtrl] API success: ${user.name}');

      final userData = user.toJson();
      if (userData['avatar'] != null &&
          userData['avatar'].toString().isNotEmpty) {
        // Appending timestamp to blow cache if URL is same but content changed
        final sep = userData['avatar'].toString().contains('?') ? '&' : '?';
        userData['avatar'] =
            '${userData['avatar']}${sep}t=${DateTime.now().millisecondsSinceEpoch}';
      }
      userProfile.value = userData;
      pickedAvatarPath.value = ''; // Reset picked image

      print('🔄 [ProfileCtrl] State updated, going back and showing toast...');
      Get.back();
      AppUtils.showSuccess(message: 'Profile updated successfully');
    } catch (e) {
      print('❌ [ProfileCtrl] updateProfile error: $e');
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
      print('🚀 [ProfileCtrl] Changing password...');
      await _userApiService.changePassword(
        currentPasswordController.text,
        newPasswordController.text,
      );
      print('✅ [ProfileCtrl] Password change success');
      Get.back();
      AppUtils.showSuccess(message: 'Password changed successfully');
      clearPasswordFields();
    } catch (e) {
      print('❌ [ProfileCtrl] changePassword error: $e');
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

      pickedAvatarPath.value = image.path;
      print('📷 [ProfileCtrl] Picked and deferred image: ${image.path}');
    } catch (e) {
      print('❌ [ProfileCtrl] updateAvatar error: $e');
      AppUtils.showError(message: e);
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

      // Check for various success indicators in response
      if (response['phone_verified'] == true ||
          response['is_verified'] == true ||
          response['is_phone_verified'] == true ||
          response['user'] != null) {
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

    String rawPhone = user['phone']?.toString() ?? '';
    fullPhone.value = rawPhone;

    // Robust stripping: handle both "+92" and "92"
    String dCode = dialCode.value;
    String dCodeNoPlus = dCode.replaceAll('+', '');

    if (rawPhone.startsWith(dCode)) {
      phoneController.text = rawPhone.replaceFirst(dCode, '');
    } else if (rawPhone.startsWith(dCodeNoPlus)) {
      phoneController.text = rawPhone.replaceFirst(dCodeNoPlus, '');
    } else {
      phoneController.text = rawPhone;
    }

    businessNameController.text = user['business_name']?.toString() ?? '';
    pickedAvatarPath.value = ''; // Reset on populate
    clearPasswordFields(); // Ensure security fields are empty
  }

  bool get isPhoneVerified {
    // Rely exclusively on phone verification flags
    final status = userProfile['is_phone_verified'];
    if (status == true ||
        status == 1 ||
        status?.toString() == '1' ||
        status?.toString().toLowerCase() == 'true') {
      return true;
    }

    // Check for the timestamp as a robust fallback
    final verifiedAt = userProfile['phone_verified_at'];
    return verifiedAt != null && verifiedAt.toString().isNotEmpty;
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
    return userProfile['google_id'] != null || userProfile['apple_id'] != null;
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
