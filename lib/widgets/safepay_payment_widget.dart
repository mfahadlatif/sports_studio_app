import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safepay_checkout/safepay_payment_gateway.dart';
import 'package:sports_studio/core/services/safepay_service.dart';

class SafepayPaymentWidget extends StatelessWidget {
  final double amount;
  final String tracker;
  final String? token; // This is the TBT (optional if provided by backend)
  final Function()? onSuccess;
  final Function()? onFailed;

  const SafepayPaymentWidget({
    super.key,
    required this.amount,
    required this.tracker,
    this.token,
    this.onSuccess,
    this.onFailed,
  });

  @override
  Widget build(BuildContext context) {
    final safepayService = Get.find<SafepayService>();
    final isSandbox = safepayService.environment == 'sandbox';

    if (token == null || token!.isEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security_update_warning, color: Colors.orange, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Insecure Session',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'The payment session is missing a secure transaction token from the server. Please try again.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SafepayCheckout(
      tracker: tracker,
      tbt: token!, // Strictly use the TBT token from backend
      environment: isSandbox
          ? SafePayEnvironment.sandbox
          : SafePayEnvironment.production,
      successUrl: 'https://sportsstudio.com/success',
      failUrl: 'https://sportsstudio.com/fail',
      onPaymentCompleted: () {
        print("✅ [SafepayWidget] onPaymentCompleted fired");
        if (onSuccess != null) {
          onSuccess!();
        } else {
          Get.back(result: true);
        }
      },
      onPaymentFailed: () {
        print("❌ [SafepayWidget] onPaymentFailed fired");
        if (onFailed != null) {
          onFailed!();
        } else {
          Get.back(result: false);
        }
      },
    );
  }
}
