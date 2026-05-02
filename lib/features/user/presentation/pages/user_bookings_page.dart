import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sport_studio/core/constants/user_roles.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/constants/app_constants.dart';
import 'package:sport_studio/features/landing/controller/landing_controller.dart';
import 'package:sport_studio/features/owner/controller/bookings_controller.dart';
import 'package:sport_studio/features/user/presentation/pages/payment_page.dart';
import 'package:sport_studio/widgets/app_progress_indicator.dart';
import 'package:sport_studio/core/utils/app_utils.dart';
import 'package:sport_studio/features/user/presentation/pages/user_booking_detail_page.dart';
import 'package:sport_studio/core/utils/url_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserBookingsPage extends StatefulWidget {
  const UserBookingsPage({super.key});

  @override
  State<UserBookingsPage> createState() => _UserBookingsPageState();
}

class _UserBookingsPageState extends State<UserBookingsPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookingsController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(Get.find<LandingController>().currentRole.value == UserRole.owner ? 'Ground Bookings' : 'My Match Bookings'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          actions: [
            IconButton(
              onPressed: () => setState(() => _isSearching = !_isSearching),
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              color: _isSearching ? Colors.red : null,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(_isSearching ? 100 : 50),
            child: Column(
              children: [
                if (_isSearching)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        onChanged: (val) => controller.searchQuery.value = val,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Search by ID, ground, status...',
                          border: InputBorder.none,
                          hintStyle: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.primary,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    controller.searchQuery.value = '';
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.clear, size: 20),
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                Container(
                  height: 42,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    padding: const EdgeInsets.all(0),
                    indicatorSize: TabBarIndicatorSize.tab,
                    isScrollable: false,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: AppColors.surface,
                    unselectedLabelColor: AppColors.textMuted,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    indicatorPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    tabs: const [
                      Tab(text: 'Upcoming'),
                      Tab(text: 'History'),
                      Tab(text: 'Cancelled'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookingList(context, 'Upcoming', controller),
            _buildBookingList(context, 'Past', controller),
            _buildBookingList(context, 'Cancelled', controller),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(
    BuildContext context,
    String type,
    BookingsController controller,
  ) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const AppProgressIndicator();
      }

      final list = type == 'Upcoming'
          ? controller.upcomingBookings
          : type == 'Past'
          ? controller.pastBookings
          : controller.cancelledBookings;

      if (list.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => controller.fetchBookings(),
          color: AppColors.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Icon(
                        type == 'Upcoming'
                            ? Icons.calendar_today_outlined
                            : type == 'Past'
                            ? Icons.history_outlined
                            : Icons.cancel_outlined,
                        size: 64,
                        color: AppColors.textMuted.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Text('No $type bookings found', style: AppTextStyles.h3),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      Get.find<LandingController>().currentRole.value == UserRole.owner 
                          ? 'Ground bookings will appear here' 
                          : 'Matches you book will appear here',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchBookings(),
        color: AppColors.primary,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.m),
              itemCount: list.length,
              itemBuilder: (context, index) {
                return _BookingCard(
                  booking: list[index],
                  controller: controller,
                );
              },
            ),
          ),
        ),
      );
    });
  }
}

class _BookingCard extends StatelessWidget {
  final dynamic booking;
  final BookingsController controller;

  const _BookingCard({required this.booking, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isEvent = booking['type'] == 'event';
    final displayName = booking['display_name'] ?? 'Booking';
    final sportType = (booking['sport_type'] ?? 'Sports')
        .toString()
        .toUpperCase();

    // Extract date/time from start/end
    String dateStr = '';
    String timeRange = '';

    try {
      if (booking['start'] != null) {
        final startDt = DateTime.parse(booking['start']);
        dateStr = DateFormat('MMM dd, yyyy').format(startDt);

        final startTime = DateFormat('hh:mm a').format(startDt);
        if (booking['end'] != null) {
          final endDt = DateTime.parse(booking['end']);
          final endTime = DateFormat('hh:mm a').format(endDt);
          timeRange = '$startTime - $endTime';
        } else {
          timeRange = startTime;
        }
      }
    } catch (e) {
      dateStr = booking['date'] ?? 'TBD';
      timeRange = '${booking['start_time']} - ${booking['end_time']}';
    }

    final totalAmount =
        double.tryParse((booking['price'] ?? 0).toString()) ?? 0.0;
    String status = (booking['status'] ?? 'pending').toString();
    final paymentStatus = booking['payment_status'] ?? 'unpaid';

    final String rawEnd = (booking['end'] ?? booking['end_time'] ?? '').toString();
    bool isTimePassed = false;
    try {
      if (rawEnd.isNotEmpty) {
        final endDt = DateTime.parse(
          rawEnd.contains(' ') ? rawEnd.replaceFirst(' ', 'T') : rawEnd,
        );
        isTimePassed = endDt.isBefore(DateTime.now());
      }
    } catch (e) {}

    if (isTimePassed && status == 'pending') {
      status = 'cancelled';
    }

    final ground = booking['ground'] is Map ? booking['ground'] as Map : null;
    final groundImage = UrlHelper.getFirstImage(ground?['images']);

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel_outlined;
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusIcon = Icons.task_alt_outlined;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.access_time_rounded;
    }

    final expiresRaw = booking['payment_expires_at'];
    final expiresAt = expiresRaw != null
        ? DateTime.tryParse(expiresRaw.toString())
        : null;
    final isExpired = expiresAt != null && DateTime.now().isAfter(expiresAt);
    final canPay =
        paymentStatus == 'unpaid' &&
        (status == 'pending' || status == 'confirmed') &&
        !isExpired &&
        !isTimePassed;

    return GestureDetector(
      onTap: () =>
          Get.to(() => const UserBookingDetailPage(), arguments: booking),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              // Ticket Top: Match Discovery
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Hero(
                      tag: 'booking_img_${booking['id']}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: groundImage,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 90,
                            height: 90,
                            color: Colors.grey[100],
                            child: const Center(
                              child: AppProgressIndicator(size: 20),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 90,
                            height: 90,
                            color: AppColors.primaryLight,
                            child: Icon(
                              AppUtils.getSportIcon(sportType),
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                sportType,
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                ),
                              ),
                              const Spacer(),
                              _StatusTag(status: status, color: statusColor),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            displayName,
                            style: AppTextStyles.h3.copyWith(fontSize: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Booking ID: #${booking['id']}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Dotted Ticket Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: List.generate(
                    20,
                    (index) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 1,
                        color: Colors.grey[200],
                      ),
                    ),
                  ),
                ),
              ),

              // Match Schedule Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _DetailPill(Icons.calendar_month_rounded, dateStr),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DetailPill(
                        Icons.history_toggle_off_rounded,
                        timeRange,
                      ),
                    ),
                  ],
                ),
              ),

              // Footer: Price & Actions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  border: Border(
                    top: BorderSide(color: Colors.grey.withValues(alpha: 0.05)),
                  ),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL PAYABLE',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 9,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '${AppConstants.currencySymbol} ${NumberFormat('#,###').format(totalAmount)}',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.primary,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (canPay && Get.find<LandingController>().currentRole.value != UserRole.owner) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (expiresAt != null && status == 'pending') ...[
                            _BookingCountdown(expiresAt: expiresAt),
                            const SizedBox(height: 6),
                          ],
                          ElevatedButton(
                            onPressed: () => Get.to(
                              () => const PaymentPage(),
                              arguments: isEvent
                                  ? {
                                      'participantId': booking['id'],
                                      'totalPrice': totalAmount,
                                      'type': 'event_participant',
                                    }
                                  : {
                                      'bookingId': booking['id'],
                                      'totalPrice': totalAmount,
                                      'type': 'booking',
                                    },
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Pay Now',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else if ((status == 'pending' || status == 'confirmed') &&
                        booking['is_event_linked'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Event Locked',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if ((status == 'pending' || status == 'confirmed') && Get.find<LandingController>().currentRole.value != UserRole.owner)
                      _CancelButton(
                        onPressed: () => _confirmCancel(context, booking),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, dynamic booking) {
    Get.defaultDialog(
      title: 'Cancel Booking',
      middleText: 'Are you sure you want to cancel this booking?',
      textConfirm: 'Yes, Cancel',
      textCancel: 'No, Keep',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.updateBookingStatus(booking, 'cancelled');
      },
    );
  }
}

class _StatusTag extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusTag({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailPill(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCountdown extends StatefulWidget {
  final DateTime expiresAt;
  const _BookingCountdown({required this.expiresAt});

  @override
  State<_BookingCountdown> createState() => _BookingCountdownState();
}

class _BookingCountdownState extends State<_BookingCountdown> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  void _update() {
    final diff = widget.expiresAt.difference(DateTime.now());
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
    if (_remaining.isNegative || _remaining == Duration.zero) {
      return const SizedBox.shrink();
    }
    final mins = _remaining.inMinutes.toString().padLeft(2, '0');
    final secs = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 10, color: Colors.red),
          const SizedBox(width: 4),
          Text(
            'Expires in $mins:$secs',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  final IconData icon;

  const _StatusBadge({
    required this.status,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          status.toUpperCase(),
          style: AppTextStyles.label.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _InfoItem(this.icon, this.text, {this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CancelButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _CancelButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.cancel_outlined, size: 18, color: Colors.red),
      label: const Text(
        'Cancel',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: Colors.red.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
