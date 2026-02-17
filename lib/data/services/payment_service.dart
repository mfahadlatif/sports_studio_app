import 'package:sports_studio/data/services/api_service.dart';

class PaymentService {
  final ApiService _apiService = ApiService();

  Future<String?> initializePayment({
    required double amount,
    required String currency,
  }) async {
    try {
      final response = await _apiService.post(
        '/safepay/init',
        data: {'amount': amount, 'currency': currency},
      );

      if (response.statusCode == 200) {
        return response.data['tracker'];
      }
      return null;
    } catch (e) {
      // Log error or handle securely
      return null;
    }
  }

  Future<bool> verifyPayment(String reference) async {
    // In a real flow, you might verify signature or status
    try {
      final response = await _apiService.post(
        '/safepay/verify',
        data: {'reference': reference},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
