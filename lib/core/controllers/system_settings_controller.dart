import 'package:get/get.dart';
import 'package:sport_studio/core/network/api_client.dart';

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
      // Try multiple common settings endpoints
      final endpoints = ['/settings', '/admin/settings', '/public/settings'];
      dynamic body;

      for (final path in endpoints) {
        try {
          final res = await ApiClient().dio.get(path);
          if (res.statusCode == 200 && res.data != null) {
            body = res.data;
            break; // Stop at first successful response
          }
        } catch (_) {}
      }

      if (body != null) {
        final map = <String, dynamic>{};

        if (body is Map && body['data'] is List) {
          for (final item in body['data']) {
            if (item is Map) map[item['key']?.toString() ?? ''] = item['value'];
          }
        } else if (body is List) {
          for (final item in body) {
            if (item is Map) map[item['key']?.toString() ?? ''] = item['value'];
          }
        } else if (body is Map) {
          // Check for data key first
          final data = body['data'];
          if (data is Map) {
            data.forEach((k, v) => map[k] = v);
          } else {
            body.forEach((k, v) => map[k] = v);
          }
        }

        if (map.isNotEmpty) {
          settings.assignAll(map);
        }
      }
    } catch (e) {
      print('Failed to fetch system settings: $e');
    } finally {
      // Ensure basic defaults if settings are still empty
      if (settings.isEmpty) {
        settings.addAll({
          'commission_fee': '3',
          'service_fee': '2.0',
          'minimum_withdrawal': '400',
        });
      }
      isLoading.value = false;
    }
  }

  double get commissionRate {
    // Exact keys from AdminSettings.tsx in the website codebase
    final val = settings['ground_booking_commission_fee']?.toString() ??
        settings['ground_commission']?.toString() ??
        settings['GROUND COMMISSION']?.toString() ??
        settings['commission_fee']?.toString() ??
        '3';
    return double.tryParse(val) ?? 3.0;
  }

  double get eventCommissionRate {
    // Exact keys from AdminSettings.tsx in the website codebase
    final val = settings['event_booking_commission_fee']?.toString() ??
        settings['event_commission']?.toString() ??
        settings['EVENT COMMISSION']?.toString() ??
        '5';
    return double.tryParse(val) ?? 5.0;
  }

  double get bookingServiceFee {
    final val = settings['service_fee']?.toString() ?? '2.0';
    return double.tryParse(val) ?? 2.0;
  }

  double get minWithdrawalAmount {
    // Exact keys from AdminSettings.tsx in the website codebase
    final val = settings['min_withdrawal']?.toString() ??
        settings['minimum_withdrawal']?.toString() ??
        settings['MIN PAYOUT']?.toString() ??
        settings['min_payout']?.toString() ??
        settings['payout_min']?.toString() ??
        '400'; // Default to 400 as per admin setting
    return double.tryParse(val) ?? 400.0;
  }
}
