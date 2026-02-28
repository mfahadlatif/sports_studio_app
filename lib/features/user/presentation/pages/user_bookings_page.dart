import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/owner/controller/bookings_controller.dart';

class UserBookingsPage extends StatelessWidget {
  const UserBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookingsController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('My Match Bookings'),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: false,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookingList('Upcoming', controller),
            _buildBookingList('Past', controller),
            _buildBookingList('Cancelled', controller),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(String type, BookingsController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final list = type == 'Upcoming'
          ? controller.upcomingBookings
          : type == 'Past'
          ? controller.pastBookings
          : controller.cancelledBookings;

      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
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
                  color: AppColors.textMuted.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              Text('No $type matches found', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Matches you book will appear here',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        );
      }

      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.m),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return _BookingCard(booking: list[index], controller: controller);
            },
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

    final totalAmount = booking['price'] ?? 0;
    final status = booking['status'] ?? 'pending';
    final paymentStatus = booking['payment_status'] ?? 'unpaid';

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
        statusIcon = Icons.access_time;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sport Icon / Ground Image Placeholder (Web Sync Emojis)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      isEvent ? '🎟️' : _getSportEmoji(sportType),
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isEvent ? 'EVENT' : sportType,
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _StatusBadge(
                            status: status,
                            color: statusColor,
                            icon: statusIcon,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(displayName, style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        'Booking ID: #${booking['id']}',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Row(
              children: [
                _InfoItem(Icons.calendar_today_outlined, dateStr),
                const SizedBox(width: AppSpacing.l),
                _InfoItem(Icons.access_time, timeRange),
                const SizedBox(width: AppSpacing.l),
                if (!isEvent)
                  _InfoItem(
                    Icons.payment_outlined,
                    paymentStatus.toString().toUpperCase(),
                    color: paymentStatus == 'paid'
                        ? Colors.green
                        : Colors.orange,
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.03),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL AMOUNT',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'Rs. ${NumberFormat('#,###').format(totalAmount)}',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (!isEvent && (status == 'pending' || status == 'confirmed'))
                  _CancelButton(
                    onPressed: () => _confirmCancel(context, booking),
                  ),
              ],
            ),
          ),
        ],
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

  String _getSportEmoji(String type) {
    final t = type.toLowerCase();
    if (t.contains('cricket')) return '🏏';
    if (t.contains('football')) return '⚽';
    if (t.contains('soccer')) return '⚽';
    if (t.contains('tennis')) return '🎾';
    if (t.contains('padel')) return '🎾';
    if (t.contains('volleyball')) return '🏐';
    if (t.contains('hockey')) return '🏑';
    if (t.contains('basketball')) return '🏀';
    if (t.contains('badminton')) return '🏸';
    return '🏆';
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
      children: [
        Icon(icon, size: 16, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(text, style: AppTextStyles.bodySmall.copyWith(color: color)),
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
        backgroundColor: Colors.red.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
