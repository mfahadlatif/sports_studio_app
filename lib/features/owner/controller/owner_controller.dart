import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';

class OwnerController extends GetxController {
  final RxBool isLoading = false.obs;

  // Analytics Data
  final RxDouble totalRevenue = 0.0.obs;
  final RxInt totalBookings = 0.obs;
  final RxInt totalGrounds = 0.obs;
  final RxDouble monthlyRevenue = 0.0.obs;

  final RxList<dynamic> recentBookings = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  Future<void> fetchStats() async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.get('/owner/stats');
      if (response.statusCode == 200) {
        final data = response.data;
        totalRevenue.value =
            double.tryParse(data['total_revenue']?.toString() ?? '0') ?? 0.0;
        totalBookings.value =
            int.tryParse(data['total_bookings']?.toString() ?? '0') ?? 0;
        totalGrounds.value =
            int.tryParse(data['total_grounds']?.toString() ?? '0') ?? 0;
        monthlyRevenue.value =
            double.tryParse(data['monthly_revenue']?.toString() ?? '0') ?? 0.0;
        if (data['recent_bookings'] != null) {
          recentBookings.value = data['recent_bookings'];
        }
      }
    } catch (e) {
      print('Failed to fetch owner stats: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
