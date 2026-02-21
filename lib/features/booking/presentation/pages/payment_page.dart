import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Timer? _timer;
  int _secondsRemaining = 20 * 60; // 20 minutes lock
  bool _isLoading = false;
  String _selectedMethod = 'card'; // Default to Safepay (card)

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        Get.defaultDialog(
          title: 'Session Expired',
          middleText: 'Your 20-minute reservation has expired.',
          textConfirm: 'Go Back',
          onConfirm: () => Get.offAllNamed('/'),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining / 60).floor().toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _handlePayment() async {
    if (_selectedMethod == 'cod') {
      _confirmBooking(paymentMethod: 'cash', paymentStatus: 'unpaid');
    } else {
      _startSafepayCheckout();
    }
  }

  Future<void> _startSafepayCheckout() async {
    setState(() => _isLoading = true);
    try {
      final args = Get.arguments;
      final double amount = (args != null && args is Map)
          ? (double.tryParse(args['totalPrice'].toString()) ?? 1000.0)
          : 1000.0;

      // 1. Initialize Safepay on Backend
      final response = await ApiClient().dio.post(
        '/safepay/init',
        data: {'amount': amount, 'currency': 'PKR'},
      );

      if (response.statusCode == 200) {
        final String tracker = response.data['tracker'];
        final String env = response.data['environment'] ?? 'sandbox';
        final String baseUrl = env == 'sandbox'
            ? 'https://sandbox.api.getsafepay.com/checkout/pay'
            : 'https://api.getsafepay.com/checkout/pay';

        // 2. Open WebView for Payment
        final checkoutUrl =
            '$baseUrl?tracker=$tracker&environment=$env&source=mobile';

        if (mounted) {
          final result = await Get.to(
            () => SafepayWebViewPage(url: checkoutUrl),
          );
          if (result == true) {
            _confirmBooking(paymentMethod: 'safepay', paymentStatus: 'paid');
          } else {
            setState(() => _isLoading = false);
            Get.snackbar(
              'Payment Cancelled',
              'You cancelled the checkout process.',
            );
          }
        }
      } else {
        throw 'Failed to initialize Safepay';
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('Error', 'Payment initiation failed: $e');
    }
  }

  Future<void> _confirmBooking({
    required String paymentMethod,
    required String paymentStatus,
  }) async {
    setState(() => _isLoading = true);
    try {
      final args = Get.arguments;
      final int? bookingId = (args != null && args is Map)
          ? args['bookingId']
          : null;

      if (bookingId == null) throw 'Invalid Booking ID';

      final response = await ApiClient().dio.put(
        '/bookings/$bookingId',
        data: {
          'status': 'pending',
          'payment_status': paymentStatus,
          'payment_method': paymentMethod,
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Booking confirmed successfully!',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        Get.offAllNamed('/');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('Error', 'Failed to confirm booking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpiringSoon = _secondsRemaining <= 5 * 60;

    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              children: [
                _buildTimerSection(isExpiringSoon),
                const SizedBox(height: AppSpacing.xxl),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Payment Method', style: AppTextStyles.h2),
                ),
                const SizedBox(height: AppSpacing.m),
                _buildOption(
                  'card',
                  Icons.credit_card,
                  'Safepay Checkout',
                  'Pay securely via Card',
                ),
                const SizedBox(height: AppSpacing.m),
                _buildOption(
                  'cod',
                  Icons.money,
                  'Cash at Venue',
                  'Pay directly when you arrive',
                ),
                const Spacer(),
                _buildPayButton(),
                const SizedBox(height: AppSpacing.l),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerSection(bool isExpiringSoon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: isExpiringSoon
            ? Colors.red.withOpacity(0.1)
            : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isExpiringSoon ? Colors.red : AppColors.primary,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                color: isExpiringSoon ? Colors.red : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                _formattedTime,
                style: AppTextStyles.h1.copyWith(
                  color: isExpiringSoon ? Colors.red : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Secure your slot before the timer runs out.',
            style: AppTextStyles.bodySmall.copyWith(
              color: isExpiringSoon ? Colors.red : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String id, IconData icon, String title, String sub) {
    final isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(sub, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handlePayment,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Proceed to Payment'),
      ),
    );
  }
}

class SafepayWebViewPage extends StatelessWidget {
  final String url;
  const SafepayWebViewPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safepay Payment'), centerTitle: true),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
        onUpdateVisitedHistory: (controller, url, isReload) {
          // Detect success based on 'sig' parameter or common success paths
          final urlStr = url.toString();
          if (urlStr.contains('sig=') ||
              urlStr.contains('success') ||
              urlStr.contains('complete')) {
            Get.back(result: true);
          }
        },
      ),
    );
  }
}
