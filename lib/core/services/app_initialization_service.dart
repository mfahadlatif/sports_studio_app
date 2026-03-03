import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/features/user/controller/profile_controller.dart';
import 'package:sports_studio/core/utils/app_utils.dart';

/// Service to handle app initialization and data fetching on startup
class AppInitializationService extends GetxService {
  final _storage = const FlutterSecureStorage();
  final RxBool isInitialized = false.obs;
  final RxString initializationStatus = 'Initializing...'.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await initializeApp();
  }

  /// Initialize app data and fetch necessary information
  Future<void> initializeApp() async {
    try {
      initializationStatus.value = 'Checking authentication...';

      // Check if user is authenticated
      final authToken = await _storage.read(key: 'auth_token');
      if (authToken != null && authToken.isNotEmpty) {
        initializationStatus.value = 'Loading user profile...';
        await _initializeUserData();

        initializationStatus.value = 'Loading notifications...';
        await _fetchNotifications();

        initializationStatus.value = 'Finalizing setup...';
        await _performAdditionalInitialization();
      }

      isInitialized.value = true;
      initializationStatus.value = 'Ready';
    } catch (e) {
      AppUtils.showError(message: 'Initialization failed: $e');
      initializationStatus.value = 'Initialization failed';
      // Still mark as initialized to avoid blocking the app
      isInitialized.value = true;
    }
  }

  /// Initialize user-specific data
  Future<void> _initializeUserData() async {
    try {
      final profileController = Get.find<ProfileController>();
      await profileController.fetchProfile();
    } catch (e) {
      print('Failed to initialize user data: $e');
    }
  }

  /// Fetch notifications on app start
  Future<void> _fetchNotifications() async {
    try {
      final response = await ApiClient().dio.get('/notifications');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data ?? [];
        // Store notifications in a global service if needed
        print('Fetched ${data.length} notifications');
      }
    } catch (e) {
      print('Failed to fetch notifications: $e');
      // Don't show error to user on startup, just log it
    }
  }

  /// Perform any additional initialization
  Future<void> _performAdditionalInitialization() async {
    try {
      // Preload frequently used data
      // Cache user preferences
      // Initialize other services
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate work
    } catch (e) {
      print('Failed to perform additional initialization: $e');
    }
  }

  /// Reinitialize app data (useful after login/logout)
  Future<void> reinitialize() async {
    isInitialized.value = false;
    initializationStatus.value = 'Reinitializing...';
    await initializeApp();
  }
}
