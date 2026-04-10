import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/widgets/app_loading_overlay.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/widgets/app_button.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:sports_studio/widgets/app_progress_indicator.dart';
import 'package:sports_studio/core/services/safepay_service.dart';
import 'package:sports_studio/widgets/safepay_payment_widget.dart';
import 'package:sports_studio/core/models/models.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Timer? _timer;
  int _secondsRemaining = 20 * 60; // fallback (server provides payment_expires_at)
  // bool _isLoading = false; // Removed as per instruction
  String _selectedMethod = 'card'; // Default to Safepay (card)

  final _promoCtrl = TextEditingController();
  dynamic _appliedPromo;
  double _discountPercentage = 0;
  bool _isPromoLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize from arguments if provided from BookingSlotPage
    final args = Get.arguments;
    if (args != null && args is Map) {
      if (args['deal'] != null) {
        _appliedPromo = args['deal'];
        if (_appliedPromo is Deal) {
          _discountPercentage = _appliedPromo.discountPercentage;
          _promoCtrl.text = _appliedPromo.code ?? '';
        } else if (_appliedPromo is Map) {
          _discountPercentage =
              double.tryParse(_appliedPromo['discount_percentage'].toString()) ?? 0;
          _promoCtrl.text = _appliedPromo['code'] ?? '';
        }
      }
    }

    _bootstrapTimerFromServer();
  }

  Future<void> _bootstrapTimerFromServer() async {
    try {
      final args = Get.arguments;
      final String? type = (args != null && args is Map)
          ? args['type']?.toString()
          : null;

      // Event participant payments don't use booking payment expiry.
      if (type == 'event_participant') {
        _startTimer();
        return;
      }

      final int? bookingId = (args != null && args is Map)
          ? args['bookingId'] as int?
          : null;
      if (bookingId == null) {
        _startTimer();
        return;
      }

      final res = await ApiClient().dio.get('/bookings/$bookingId');
      if (res.statusCode == 200) {
        final data = res.data;
        final expiresRaw = data['payment_expires_at'];
        final expiresAt = expiresRaw != null
            ? DateTime.tryParse(expiresRaw.toString())
            : null;

        if (expiresAt != null) {
          final remaining = expiresAt.difference(DateTime.now()).inSeconds;
          if (mounted) {
            setState(() {
              _secondsRemaining = remaining.clamp(0, 20 * 60);
            });
          } else {
            _secondsRemaining = remaining.clamp(0, 20 * 60);
          }
        }
      }
    } catch (_) {
      // If server read fails, fall back to 20:00.
    } finally {
      _startTimer();
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
          final dealObj = Deal.fromJson(deal);
          setState(() {
            _appliedPromo = dealObj;
            _discountPercentage = dealObj.discountPercentage;
          });
          AppUtils.showSuccess(message: 'Promo code applied: ${dealObj.title}');
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
    return '$minutes:$seconds minutes';
  }

  Future<void> _handlePayment() async {
    final args = Get.arguments;
    double subtotal = 0.0;
    double discountAmount = 0.0;

    // ── Extract IDs NOW (while PaymentPage is active and Get.arguments is valid)
    final String? paymentType = (args != null && args is Map) ? args['type']?.toString() : null;
    final int? bookingId = (args != null && args is Map)
        ? (args['bookingId'] is int ? args['bookingId'] : int.tryParse(args['bookingId']?.toString() ?? ''))
        : null;
    final int? participantId = (args != null && args is Map)
        ? (args['participantId'] is int ? args['participantId'] : int.tryParse(args['participantId']?.toString() ?? ''))
        : null;

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
      if (paymentType == 'event_participant') {
        await _confirmEventParticipantCash(participantId);
      } else {
        _confirmBooking(
          paymentMethod: 'cash',
          paymentStatus: 'unpaid',
          totalPaid: amount,
        );
      }
      return;
    }

    if (_selectedMethod == 'wallet') {
      await _payWithWallet(amount);
      return;
    }

    // Safepay logic
    AppLoadingOverlay.show(context, message: 'Redirecting to Safepay...');
    try {
      final safepayService = Get.find<SafepayService>();
      
      // Determine the reference for the backend webhook to identify the entity
      String? reference;
      if (paymentType == 'event_participant' && participantId != null) {
        reference = 'event_participant:$participantId';
      } else if (bookingId != null) {
        reference = 'booking:$bookingId';
      }

      print('🌐 [PaymentPage] Initiating Safepay with reference: $reference');

      final response = await safepayService.initiateCheckout(
        amount: amount,
        reference: reference,
      );

      final tracker = response?['tracker'];
      final token = response?['tbt'] ?? response?['token'];

      AppLoadingOverlay.hide(context);

      if (tracker != null) {
        if (mounted) {
          await Get.to(
            () => SafepayPaymentWidget(
              amount: amount,
              tracker: tracker,
              token: token,
              onSuccess: () async {
                // Poll for status update (webhook may take a second)
                await _pollForPaymentSuccess(
                  type: paymentType ?? 'booking',
                  id: (paymentType == 'event_participant' ? participantId : bookingId) ?? 0,
                );
              },
              onFailed: () {
                AppUtils.showError(message: 'Payment verification failed.');
              },
            ),
          );
        }
      }
    } catch (e) {
      AppLoadingOverlay.hide(context);
      AppUtils.showError(message: 'Payment failed: $e');
    }
  }

  Future<void> _payWithWallet(double amount) async {
    AppLoadingOverlay.show(context, message: 'Paying with wallet...');
    try {
      final args = Get.arguments;
      final String? type = (args != null && args is Map)
          ? args['type']?.toString()
          : null;

      if (type == 'event_participant') {
        final int? participantId =
            (args is Map) ? args['participantId'] as int? : null;
        if (participantId == null) throw 'Invalid Participant ID';

        await ApiClient().dio.post(
          '/event-participants/$participantId/pay-with-wallet',
        );

        AppLoadingOverlay.hide(context);
        Get.offAllNamed('/');
        AppUtils.showSuccess(message: 'Payment successful! Registration confirmed.');
        return;
      }

      final int? bookingId = (args != null && args is Map)
          ? args['bookingId'] as int?
          : null;
      if (bookingId == null) throw 'Invalid Booking ID';

      // Securely pay via wallet endpoint (handles balance check & split)
      await ApiClient().dio.post('/bookings/$bookingId/pay-with-wallet');

      AppLoadingOverlay.hide(context);
      Get.offAllNamed('/');
      AppUtils.showSuccess(message: 'Payment successful! Booking confirmed.');
    } catch (e) {
      AppLoadingOverlay.hide(context);
      AppUtils.showError(message: 'Wallet payment failed: $e');
    }
  }

  Future<void> _confirmEventParticipantCash(int? participantId) async {
    if (participantId == null) {
      AppUtils.showError(message: 'Invalid Participant ID');
      return;
    }
    AppLoadingOverlay.show(context, message: 'Confirming registration...');
    try {
      await ApiClient().dio.put(
        '/event-participants/$participantId',
        data: {
          'payment_status': 'unpaid',
          'payment_method': 'cash',
        },
      );
      AppLoadingOverlay.hide(context);
      Get.offAllNamed('/');
      AppUtils.showSuccess(message: 'Registration confirmed. Pay at venue.');
    } catch (e) {
      AppLoadingOverlay.hide(context);
      AppUtils.showError(message: 'Failed to confirm registration: $e');
    }
  }

  Future<void> _pollForPaymentSuccess({required String type, required int id}) async {
    if (id == 0) {
      Get.offAllNamed('/');
      AppUtils.showSuccess(message: 'Payment completed!');
      return;
    }

    AppLoadingOverlay.show(context, message: 'Verifying payment status...');
    
    int attempts = 0;
    const maxAttempts = 5;
    
    while (attempts < maxAttempts) {
      try {
        final endpoint = type == 'event_participant' ? '/event-participants/$id' : '/bookings/$id';
        final res = await ApiClient().dio.get(endpoint);
        
        if (res.statusCode == 200) {
          final data = res.data;
          final paymentStatus = (data['payment_status'] ?? '').toString().toLowerCase();
          
          if (paymentStatus == 'paid') {
            AppLoadingOverlay.hide(context);
            Get.offAllNamed('/');
            AppUtils.showSuccess(message: 'Payment successful! Booking confirmed.');
            return;
          }
        }
      } catch (e) {
        print('⚠️ [PaymentPage] Polling error: $e');
      }
      
      attempts++;
      if (attempts < maxAttempts) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    
    AppLoadingOverlay.hide(context);
    // Final fallback if polling doesn't see "paid" yet (webhook might be slow)
    Get.offAllNamed('/');
    AppUtils.showInfo(
      title: 'Payment Processing',
      message: 'Your payment is being processed. Your status will update shortly.',
    );
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
        },
      );

      AppLoadingOverlay.hide(context);
      Get.offAllNamed('/');
      AppUtils.showSuccess(message: 'Booking confirmed! Enjoy your match.');
    } catch (e) {
      AppLoadingOverlay.hide(context);
      AppUtils.showError(message: 'Failed to confirm booking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpiringSoon = _secondsRemaining <= 5 * 60;
    final args = Get.arguments;
    final String? type =
        (args != null && args is Map) ? args['type']?.toString() : null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.m),
                        _buildTimerSection(isExpiringSoon),
                        const SizedBox(height: AppSpacing.xl),

                        Text('Booking Summary', style: AppTextStyles.h3),
                        const SizedBox(height: AppSpacing.m),
                        _buildPriceSummary(),

                        const SizedBox(height: AppSpacing.xl),
                        Text('Promo Code', style: AppTextStyles.h3),
                        const SizedBox(height: AppSpacing.m),
                        _buildPromoSection(),

                        const SizedBox(height: AppSpacing.xl),
                        Text('Payment Method', style: AppTextStyles.h3),
                        const SizedBox(height: AppSpacing.m),
                        _buildOption(
                          'card',
                          Icons.credit_card_rounded,
                          'Safepay Checkout',
                          'Credit / Debit Card secure payment',
                          Colors.indigo,
                        ),
                        const SizedBox(height: AppSpacing.m),
                        if (type == 'event_participant') ...[
                          _buildOption(
                            'wallet',
                            Icons.account_balance_wallet_rounded,
                            'Wallet Balance',
                            'Pay using your remaining balance',
                            Colors.teal,
                          ),
                          const SizedBox(height: AppSpacing.m),
                        ],
                        _buildOption(
                          'cod',
                          Icons.payments_rounded,
                          'Cash at Venue',
                          'Pay directly at the sports complex',
                          Colors.orange,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
                _buildBottomActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: _selectedMethod == 'card' 
                  ? 'Proceed to Safepay' 
                  : _selectedMethod == 'wallet' 
                    ? 'Pay with Wallet' 
                    : 'Confirm Booking',
              onPressed: _handlePayment,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Securing your booking globally',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
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

  Widget _buildOption(String id, IconData icon, String title, String sub, Color color) {
    final isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.02) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon, 
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    sub, 
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected ? color.withOpacity(0.7) : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
               Icon(Icons.check_circle_rounded, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoSection() {
    final args = Get.arguments;
    final String? type = (args != null && args is Map) ? args['type']?.toString() : null;
    
    // Hide promo section for events as they have fixed registration fees
    if (type == 'event_participant') return const SizedBox.shrink();

    final bool isAlreadyApplied = _appliedPromo != null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: isAlreadyApplied ? Colors.green[50] : AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: isAlreadyApplied ? Border.all(color: Colors.green[100]!) : null,
      ),
      child: Row(
        children: [
          const Icon(Icons.tag, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: isAlreadyApplied 
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _promoCtrl.text,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const Text(
                      'Already Applied',
                      style: TextStyle(fontSize: 10, color: Colors.green),
                    ),
                  ],
                )
              : TextField(
                  controller: _promoCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Enter Promo Code',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
          ),
          if (isAlreadyApplied)
            TextButton(
              onPressed: () {
                setState(() {
                  _appliedPromo = null;
                  _discountPercentage = 0;
                  _promoCtrl.clear();
                });
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            )
          else
            ElevatedButton(
              onPressed: _isPromoLoading ? null : _applyPromo,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                minimumSize: const Size(0, 36),
              ),
              child: _isPromoLoading
                  ? const AppProgressIndicator(
                      size: 16,
                      strokeWidth: 2,
                      color: Colors.white,
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
          _summaryRow('Subtotal', '${AppConstants.currencySymbol} ${subtotal.toStringAsFixed(0)}'),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _summaryRow(
              'Discount (${_discountPercentage > 0 ? _discountPercentage.toStringAsFixed(0) : ((discount / subtotal) * 100).toStringAsFixed(0)}%)',
              '- ${AppConstants.currencySymbol} ${discount.toStringAsFixed(0)}',
              isDiscount: true,
            ),
          ],
          const Divider(height: 24),
          _summaryRow(
            'Total Amount',
            '${AppConstants.currencySymbol} ${total.toStringAsFixed(0)}',
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

