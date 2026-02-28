import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/widgets/app_loading_overlay.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sports_studio/widgets/app_button.dart';
import 'package:sports_studio/core/utils/app_utils.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Timer? _timer;
  int _secondsRemaining = 20 * 60; // 20 minutes lock
  // bool _isLoading = false; // Removed as per instruction
  String _selectedMethod = 'card'; // Default to Safepay (card)

  final _promoCtrl = TextEditingController();
  dynamic _appliedPromo;
  double _discountPercentage = 0;
  bool _isPromoLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Initialize from arguments if provided from BookingSlotPage
    final args = Get.arguments;
    if (args != null && args is Map) {
      if (args['deal'] != null) {
        _appliedPromo = args['deal'];
        _discountPercentage =
            double.tryParse(_appliedPromo['discount_percentage'].toString()) ??
            0;
        _promoCtrl.text = _appliedPromo['code'] ?? '';
      }
    }
  }

  Future<void> _applyPromo() async {
    if (_promoCtrl.text.isEmpty) return;

    setState(() => _isPromoLoading = true);
    try {
      final res = await ApiClient().dio.get('/public/deals');
      if (res.statusCode == 200) {
        final deals = res.data ?? [];
        final deal = (deals as List).firstWhereOrNull(
          (d) =>
              d['code'].toString().toLowerCase() ==
              _promoCtrl.text.toLowerCase(),
        );

        if (deal != null) {
          setState(() {
            _appliedPromo = deal;
            _discountPercentage =
                double.tryParse(deal['discount_percentage'].toString()) ?? 0;
          });
          AppUtils.showSuccess(message: 'Promo code applied: ${deal['title']}');
        } else {
          AppUtils.showError(message: 'Invalid promo code');
        }
      }
    } catch (e) {
      AppUtils.showError(message: 'Failed to validate promo code');
    } finally {
      setState(() => _isPromoLoading = false);
    }
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
    final args = Get.arguments;
    double subtotal = 0.0;
    double discountAmount = 0.0;

    if (args != null && args is Map) {
      subtotal =
          double.tryParse(
            args['subtotal']?.toString() ??
                args['totalPrice']?.toString() ??
                '0',
          ) ??
          0.0;
      if (_discountPercentage > 0) {
        discountAmount = subtotal * (_discountPercentage / 100);
      }
    }
    final amount = subtotal - discountAmount;

    if (_selectedMethod == 'cod') {
      _confirmBooking(
        paymentMethod: 'cash',
        paymentStatus: 'unpaid',
        totalPaid: amount, // Pass the calculated total amount
      );
      return;
    }

    // Safepay logic
    AppLoadingOverlay.show(context, message: 'Redirecting to Safepay...');
    try {
      final response = await ApiClient().dio.post(
        '/safepay/init', // Corrected endpoint based on original code
        data: {'amount': amount, 'currency': 'PKR'},
      );

      AppLoadingOverlay.hide(context);

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
            _confirmBooking(
              paymentMethod: 'safepay',
              paymentStatus: 'paid',
              totalPaid: amount,
            );
          } else {
            AppUtils.showInfo(
              title: 'Payment Cancelled',
              message: 'You cancelled the checkout process.',
            );
          }
        }
      } else {
        throw 'Failed to initialize Safepay';
      }
    } catch (e) {
      AppLoadingOverlay.hide(context);
      AppUtils.showError(message: 'Payment failed: $e');
    }
  }

  Future<void> _confirmBooking({
    required String paymentMethod,
    required String paymentStatus,
    required double totalPaid,
  }) async {
    AppLoadingOverlay.show(context, message: 'Confirming your booking...');
    try {
      final args = Get.arguments;
      final int? bookingId = (args != null && args is Map)
          ? args['bookingId']
          : null;

      if (bookingId == null) throw 'Invalid Booking ID';

      await ApiClient().dio.put(
        '/bookings/$bookingId',
        data: {
          'status': 'pending',
          'payment_status': paymentStatus,
          'payment_method': paymentMethod,
          'total_price': totalPaid,
          'coupon_id': _appliedPromo != null ? _appliedPromo['id'] : null,
        },
      );

      AppLoadingOverlay.hide(context);
      Get.offAllNamed('/landing');
      AppUtils.showSuccess(message: 'Booking confirmed! Enjoy your match.');
    } catch (e) {
      AppLoadingOverlay.hide(context);
      AppUtils.showError(message: 'Failed to confirm booking: $e');
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
                const SizedBox(height: AppSpacing.l),

                // Promo Code Section
                _buildPromoSection(),

                const SizedBox(height: AppSpacing.l),
                _buildPriceSummary(),

                const SizedBox(height: AppSpacing.l),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.l),
          decoration: BoxDecoration(
            color: isExpiringSoon
                ? Colors.red.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isExpiringSoon
                  ? Colors.red.withOpacity(0.5)
                  : AppColors.primary.withOpacity(0.2),
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
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Complete payment to secure your booking',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isExpiringSoon ? Colors.red : AppColors.textSecondary,
                  fontWeight: isExpiringSoon
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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

  Widget _buildPromoSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _promoCtrl,
              decoration: const InputDecoration(
                hintText: 'Enter Promo Code',
                border: InputBorder.none,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isPromoLoading ? null : _applyPromo,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: _isPromoLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    final args = Get.arguments;
    double subtotal = 1000.0;
    double discount = 0.0;
    double total = 1000.0;

    if (args != null && args is Map) {
      if (_appliedPromo != null) {
        // Recalculate if user changed promo on this page
        subtotal =
            double.tryParse(
              args['subtotal']?.toString() ??
                  args['totalPrice']?.toString() ??
                  '1000',
            ) ??
            1000.0;
        discount = subtotal * (_discountPercentage / 100);
        total = subtotal - discount;
      } else {
        total =
            double.tryParse(args['totalPrice']?.toString() ?? '1000') ?? 1000.0;
        subtotal =
            double.tryParse(args['subtotal']?.toString() ?? total.toString()) ??
            total;
        discount = double.tryParse(args['discount']?.toString() ?? '0') ?? 0;
      }
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', 'Rs. ${subtotal.toStringAsFixed(0)}'),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _summaryRow(
              'Discount (${_discountPercentage > 0 ? _discountPercentage.toStringAsFixed(0) : ((discount / subtotal) * 100).toStringAsFixed(0)}%)',
              '- Rs. ${discount.toStringAsFixed(0)}',
              isDiscount: true,
            ),
          ],
          const Divider(height: 24),
          _summaryRow(
            'Total Amount',
            'Rs. ${total.toStringAsFixed(0)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)
              : AppTextStyles.bodyMedium,
        ),
        Text(
          value,
          style: TextStyle(
            color: isDiscount ? Colors.green : AppColors.textPrimary,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton() {
    return AppButton(label: 'Proceed to Payment', onPressed: _handlePayment);
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
