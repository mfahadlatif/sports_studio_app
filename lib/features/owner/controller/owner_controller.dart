import 'package:get/get.dart';
import 'package:sport_studio/core/network/api_client.dart';

class OwnerController extends GetxController {
  final RxBool isLoading = false.obs;

  // Analytics Data
  final RxDouble totalRevenue = 0.0.obs;
  final RxInt totalComplexes = 0.obs;
  final RxInt totalBookings = 0.obs;
  final RxInt totalGrounds = 0.obs;
  final RxDouble monthlyRevenue = 0.0.obs;
  final RxDouble revenueGrowth = 0.0.obs;
  final RxInt pendingReviewsCount = 0.obs;
  final RxInt totalReviewsCount = 0.obs;

  final RxList<dynamic> recentBookings = <dynamic>[].obs;
  final RxList<dynamic> complexes = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    isLoading.value = true;
    try {
      await Future.wait([fetchStats(silent: true), fetchComplexes()]);
    } catch (e) {
      print('Error fetching dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStats({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    try {
      final response = await ApiClient().dio.get('/owner/stats');
      if (response.statusCode == 200) {
        final data = response.data;
        totalRevenue.value =
            double.tryParse(data['total_revenue']?.toString() ?? '0') ?? 0.0;
        totalComplexes.value =
            int.tryParse(data['total_complexes']?.toString() ?? '0') ?? 0;
        totalBookings.value =
            int.tryParse(data['total_bookings']?.toString() ?? '0') ?? 0;
        totalGrounds.value =
            int.tryParse(data['total_grounds']?.toString() ?? '0') ?? 0;
        monthlyRevenue.value =
            double.tryParse(data['monthly_revenue']?.toString() ?? '0') ?? 0.0;
        revenueGrowth.value =
            double.tryParse(data['revenue_growth']?.toString() ?? '0') ?? 0.0;
        pendingReviewsCount.value =
            int.tryParse(data['pending_reviews_count']?.toString() ?? '0') ?? 0;
        totalReviewsCount.value =
            int.tryParse(data['total_reviews_count']?.toString() ?? '0') ?? 0;
        if (data['recent_bookings'] != null && data['recent_bookings'] is List) {
          recentBookings.assignAll(data['recent_bookings']);
        }
      }
    } catch (e) {
      print('Failed to fetch owner stats: $e');
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  Future<void> fetchComplexes() async {
    try {
      final response = await ApiClient().dio.get('/complexes');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        complexes.assignAll(data);
      }
    } catch (e) {
      print('Failed to fetch owner complexes: $e');
    }
  }
}
