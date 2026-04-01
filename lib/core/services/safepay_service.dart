import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_services.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SafepayService extends GetxService {
  late String environment;
  final PaymentApiService _paymentApiService = PaymentApiService();

  Future<SafepayService> init() async {
    environment = dotenv.get('SAFEPAY_ENVIRONMENT', fallback: 'sandbox');
    return this;
  }

  /// Initiates a payment process with Safepay via the BACKEND.
  /// This returns the full response containing the tracker and the transaction token (TBT).
  Future<Map<String, dynamic>?> initiateCheckout({
    required double amount,
    String? reference,
    String currency = 'PKR',
  }) async {
    try {
      final response = await _paymentApiService.initiateSafepayPayment({
        'amount': amount,
        'currency': currency,
        'reference': ?reference,
      });
      return response;
    } catch (e) {
      AppUtils.showError(message: 'Payment initiation failed: $e');
      return null;
    }
  }

  /// Verifies a payment with Safepay using the tracker/token via the BACKEND.
  Future<bool> verifyPayment(String token) async {
    try {
      final response = await _paymentApiService.verifySafepayPayment(token);
      return response['status'] == 'valid';
    } catch (e) {
      print('❌ [SafepayService] Payment verification error: $e');
      return false;
    }
  }

  /// Extracts the tracker ID from a full Safepay checkout URL if needed.
  String getTrackerFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters['tracker'] ?? '';
    } catch (e) {
      return '';
    }
  }
}
