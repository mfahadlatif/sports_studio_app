import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';

class AdminController extends GetxController {
  final RxBool isLoading = false.obs;

  // Global Analytics Data
  final RxInt totalUsers = 0.obs;
  final RxInt totalComplexes = 0.obs;
  final RxInt totalBookings = 0.obs;
  final RxDouble totalRevenue = 0.0.obs;
  final RxInt totalActiveEvents = 0.obs;

  final RxList<dynamic> recentUsers = <dynamic>[].obs;
  final RxList<dynamic> recentComplexes = <dynamic>[].obs;
  final RxList<dynamic> pendingReviews = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAdminDashboard();
  }

  Future<void> fetchAdminDashboard() async {
    isLoading.value = true;
    try {
      await Future.wait([fetchAdminStats(), fetchRecentData()]);
    } catch (e) {
      print('Failed to fetch admin dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAdminStats() async {
    try {
      final response = await ApiClient().dio.get('/admin/stats');
      if (response.statusCode == 200) {
        final data = response.data;
        totalUsers.value =
            int.tryParse(data['total_users']?.toString() ?? '0') ?? 0;
        totalComplexes.value =
            int.tryParse(data['total_complexes']?.toString() ?? '0') ?? 0;
        totalBookings.value =
            int.tryParse(data['total_bookings']?.toString() ?? '0') ?? 0;
        totalRevenue.value =
            double.tryParse(data['total_revenue']?.toString() ?? '0') ?? 0.0;
        totalActiveEvents.value =
            int.tryParse(data['total_events']?.toString() ?? '0') ?? 0;
      }
    } catch (e) {
      print('Failed to fetch admin stats: $e');
    }
  }

  Future<void> fetchRecentData() async {
    try {
      // Mocking or fetching actual recent data if available on backend
      final response = await ApiClient().dio.get('/admin/recent-activity');
      if (response.statusCode == 200) {
        final data = response.data;
        recentUsers.value = data['recent_users'] ?? [];
        recentComplexes.value = data['recent_complexes'] ?? [];
        pendingReviews.value = data['pending_reviews'] ?? [];
      }
    } catch (e) {
      print('Failed to fetch admin recent data: $e');
    }
  }

  Future<void> fixStorage() async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.post('/admin/fix-storage');
      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          response.data['message'] ?? 'Storage link fixed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFDCFCE7),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fix storage link');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cleanupData(String type) async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.post(
        '/admin/cleanup',
        data: {'type': type},
      );
      if (response.statusCode == 200) {
        Get.snackbar(
          'Cleanup Successful',
          response.data['message'] ?? 'Database optimized successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFDCFCE7),
        );
        fetchAdminDashboard();
      }
    } catch (e) {
      Get.snackbar('Error', 'Cleanup failed: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
