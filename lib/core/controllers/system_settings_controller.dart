import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';

class SystemSettingsController extends GetxController {
  final RxMap<String, dynamic> settings = <String, dynamic>{}.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    isLoading.value = true;
    try {
      // Trying public endpoint first, fallback to admin-shared if needed
      // Most production apps have a /public/settings or /config endpoint
      final res = await ApiClient().dio.get('/public/settings');
      if (res.statusCode == 200) {
        final body = res.data;
        final list = body is List ? body : (body is Map && body['data'] is List ? body['data'] as List : const []);

        final map = <String, dynamic>{};
        for (final item in list) {
          final m = item as Map? ?? {};
          final key = m['key']?.toString();
          if (key == null) continue;
          map[key] = m['value'];
        }
        settings.assignAll(map);
      }
    } catch (e) {
      print('Failed to fetch system settings: $e');
      // Fallback defaults if API fails
      if (settings.isEmpty) {
        settings.addAll({
          'commission_fee': '3',
          'service_fee': '2.0',
        });
      }
    } finally {
      isLoading.value = false;
    }
  }

  double get commissionRate {
    final val = settings['commission_fee']?.toString() ?? '3';
    return double.tryParse(val) ?? 3.0;
  }

  double get bookingServiceFee {
    final val = settings['service_fee']?.toString() ?? '2.0';
    return double.tryParse(val) ?? 2.0;
  }

  double get minWithdrawalAmount {
    // Default to 10 if not set
    final val = settings['minimum_withdrawal']?.toString() ?? '10';
    return double.tryParse(val) ?? 10.0;
  }
}
