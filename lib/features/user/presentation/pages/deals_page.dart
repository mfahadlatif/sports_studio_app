import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/constants/app_constants.dart';
import 'package:sport_studio/core/network/api_client.dart';
import 'package:sport_studio/widgets/app_progress_indicator.dart';
import 'package:sport_studio/features/landing/controller/landing_controller.dart';
import 'package:sport_studio/features/user/controller/booking_controller.dart';
import 'package:sport_studio/core/models/models.dart';
import 'package:sport_studio/core/utils/app_utils.dart';

class DealsPage extends StatefulWidget {
  const DealsPage({super.key});

  @override
  State<DealsPage> createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPage> {
  bool _isLoading = true;
  List<dynamic> _deals = [];

  @override
  void initState() {
    super.initState();
    _fetchDeals();
  }

  Future<void> _fetchDeals() async {
    try {
      final res = await ApiClient().dio.get('/public/deals');
      if (res.statusCode == 200) {
        final raw = res.data;
        final List data = raw is List ? raw : (raw['data'] as List? ?? []);
        setState(() => _deals = data);
      }
    } catch (e) {
      print('❌ [Deals] Fetch error: $e');
      // Show demo deals if API not available
      setState(() {
        _deals = [
          {
            'title': 'Morning Special',
            'description': 'Book before 10 AM on any weekday and save big!',
            'discount_percentage': '30',
            'applicable_sports': 'Cricket, Football',
            'valid_until': DateTime.now()
                .add(const Duration(days: 7))
                .toIso8601String(),
            'code': 'MORNING30',
          },
          {
            'title': 'Weekend Warrior',
            'description':
                'Exclusive discount for weekend tournament bookings.',
            'discount_percentage': '25',
            'applicable_sports': 'All Sports',
            'valid_until': DateTime.now()
                .add(const Duration(days: 14))
                .toIso8601String(),
            'code': 'WEEKENDWARRIOR',
          },
          {
            'title': 'First Booking Offer',
            'description':
                '${AppConstants.currencySymbol} 500 off on your very first ground booking with us!',
            'discount_percentage': '0',
            'applicable_sports': 'All Sports',
            'valid_until': DateTime.now()
                .add(const Duration(days: 30))
                .toIso8601String(),
            'code': 'FIRSTBOOK',
          },
        ];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hot Deals'), centerTitle: true),
      body: _isLoading
          ? const AppProgressIndicator()
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: _deals.isEmpty
                    ? _emptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        itemCount: _deals.length,
                        itemBuilder: (ctx, i) => _buildDealCard(_deals[i], i),
                      ),
              ),
            ),
    );
  }

  Widget _buildDealCard(dynamic deal, int index) {
    final code = deal['code']?.toString() ?? '';
    final discount = deal['discount_percentage']?.toString() ?? '0';
    final title = deal['title']?.toString() ?? 'Special Offer';
    final desc = deal['description']?.toString() ?? '';
    final sport = deal['applicable_sports']?.toString() ?? 'All Sports';
    final validUntil = deal['valid_until'] != null
        ? DateTime.tryParse(deal['valid_until'].toString())
        : null;

    final List<List<Color>> gradientsList = [
      [Colors.orange.shade400, Colors.deepOrange.shade700],
      [AppColors.primary, const Color(0xFF0F172A)],
      [Colors.teal.shade400, Colors.teal.shade900],
      [Colors.purple.shade400, Colors.purple.shade900],
      [Colors.blue.shade400, Colors.blue.shade900],
      [Colors.pink.shade400, Colors.pink.shade900],
    ];

    List<Color> grad = gradientsList[index % gradientsList.length];
    
    // Handle API provided color themes
    if (deal['color_theme'] == 'orange') {
      grad = [Colors.orange.shade400, Colors.deepOrange.shade700];
    } else if (deal['color_theme'] == 'teal') {
      grad = [Colors.teal.shade400, Colors.teal.shade900];
    } else if (deal['color_theme'] == 'blue') {
      grad = [Colors.blue.shade400, Colors.blue.shade900];
    } else if (deal['color_theme'] == 'purple') {
      grad = [Colors.purple.shade400, Colors.purple.shade900];
    } else if (deal['color_theme'] == 'pink') {
      grad = [Colors.pink.shade400, Colors.pink.shade900];
    } else if (deal['color_theme'] == 'green') {
      grad = [Colors.green.shade400, Colors.green.shade900];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: grad,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: grad[1].withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Discount badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        discount == '0' ? 'FLAT DISCOUNT' : '$discount% OFF',
                        style: AppTextStyles.label.copyWith(
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.local_offer,
                      color: Colors.white70,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),

                // Title
                Text(
                  title,
                  style: AppTextStyles.h2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white70,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.s),

                // Valid for
                Text(
                  'Valid for: $sport',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white60,
                  ),
                ),

                if (validUntil != null) ...[
                  const SizedBox(height: AppSpacing.m),
                  _CountdownTimer(targetDate: validUntil),
                ],

                const SizedBox(height: AppSpacing.m),

                // Promo code
                if (code.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: code));
                      Get.snackbar(
                        'Copied!',
                        'Promo code "$code" copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.m,
                        vertical: AppSpacing.s,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Promo Code',
                                  style: AppTextStyles.label.copyWith(
                                    color: Colors.white60,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  code,
                                  style: AppTextStyles.h3.copyWith(
                                    color: Colors.white,
                                    letterSpacing: 3,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.copy,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: AppSpacing.m),

                // CTA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final landing = Get.find<LandingController>();
                      final booking = Get.isRegistered<BookingController>()
                          ? Get.find<BookingController>()
                          : Get.put(BookingController());

                      // Reset previous booking state to avoid conflicts
                      booking.selectedSlots.clear();
                      
                      // Set the promo from the deal
                      booking.promoCode.value = code;
                      try {
                        booking.selectedDeal.value = Deal.fromJson(deal);
                      } catch (e) {
                         debugPrint('❌ [Deals] Error parsing deal: $e');
                      }

                      // Navigate to grounds tab (index 1)
                      landing.changeNavIndex(1);
                      
                      // If this page was pushed, go back to the shell (landing page)
                      if (Navigator.of(context).canPop()) {
                        Get.back();
                      }
                      
                      AppUtils.showSuccess(
                        title: 'Promo Applied',
                        message: 'Pick a ground to use your "${deal['title']}" discount!',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: grad[0],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Book Now →',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 72,
            color: AppColors.textMuted.withValues(alpha: 0.4),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            'No active deals right now.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Check back later for exclusive offers!',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// Countdown timer widget
class _CountdownTimer extends StatefulWidget {
  final DateTime targetDate;
  const _CountdownTimer({required this.targetDate});

  @override
  State<_CountdownTimer> createState() => __CountdownTimerState();
}

class __CountdownTimerState extends State<_CountdownTimer> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  void _update() {
    final diff = widget.targetDate.difference(DateTime.now());
    if (mounted) {
      setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    return Row(
      children: [
        const Icon(Icons.timer_outlined, size: 14, color: Colors.white60),
        const SizedBox(width: 6),
        Text(
          'Ends in: ',
          style: TextStyle(color: Colors.white60, fontSize: 12),
        ),
        ...[
          _unit('${days}d'),
          _unit('${hours.toString().padLeft(2, '0')}h'),
          _unit('${minutes.toString().padLeft(2, '0')}m'),
          _unit('${seconds.toString().padLeft(2, '0')}s'),
        ],
      ],
    );
  }

  Widget _unit(String val) => Container(
    margin: const EdgeInsets.only(left: 4),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      val,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
