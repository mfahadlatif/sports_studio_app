import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/features/owner/controller/bookings_controller.dart';

class BookingDetailPage extends StatefulWidget {
  const BookingDetailPage({super.key});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  dynamic _booking;
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    // Booking can be passed via arguments or fetched by id
    final args = Get.arguments;
    if (args is Map && args['booking'] != null) {
      setState(() {
        _booking = args['booking'];
        _isLoading = false;
      });
      return;
    }

    final id = args?['id'] ?? args;
    if (id == null) {
      Get.back();
      return;
    }

    try {
      final res = await ApiClient().dio.get('/bookings/$id');
      if (res.statusCode == 200) {
        setState(() => _booking = res.data);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not load booking');
      Get.back();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String newStatus, {String? reason}) async {
    setState(() => _isUpdating = true);
    try {
      final id = _booking['id'];
      final payload = <String, dynamic>{'status': newStatus};
      if (reason != null) payload['rejection_reason'] = reason;
      if (newStatus == 'cancelled') payload['payment_status'] = 'refunded';

      final res = await ApiClient().dio.put('/bookings/$id', data: payload);
      if (res.statusCode == 200) {
        setState(() => _booking = {..._booking, 'status': newStatus});
        // Refresh parent list if controller is active
        if (Get.isRegistered<BookingsController>()) {
          Get.find<BookingsController>().fetchBookings();
        }
        Get.snackbar(
          'Success',
          'Booking ${newStatus == 'confirmed' ? 'accepted' : 'declined'}',
          backgroundColor: newStatus == 'confirmed'
              ? const Color(0xFFDCFCE7)
              : const Color(0xFFFEE2E2),
        );
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to update booking');
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _markAsPaid() async {
    setState(() => _isUpdating = true);
    try {
      final id = _booking['id'];
      final res = await ApiClient().dio.put(
        '/bookings/$id',
        data: {'payment_status': 'paid', 'status': 'confirmed'},
      );
      if (res.statusCode == 200) {
        setState(
          () => _booking = {
            ..._booking,
            'payment_status': 'paid',
            'status': 'confirmed',
          },
        );
        if (Get.isRegistered<BookingsController>()) {
          Get.find<BookingsController>().fetchBookings();
        }
        Get.snackbar(
          'Paid',
          'Booking marked as paid',
          backgroundColor: const Color(0xFFDCFCE7),
        );
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to mark as paid');
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _booking != null ? 'Booking #${_booking['id']}' : 'Booking Details',
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _booking == null
          ? _notFound()
          : _buildBody(),
    );
  }

  Widget _notFound() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.calendar_month_outlined,
          size: 72,
          color: AppColors.textMuted.withValues(alpha: 0.4),
        ),
        const SizedBox(height: AppSpacing.m),
        Text('Booking not found', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.l),
        ElevatedButton(onPressed: Get.back, child: const Text('Go Back')),
      ],
    ),
  );

  Widget _buildBody() {
    final status = _booking['status'] ?? 'pending';
    final paymentStatus = _booking['payment_status'] ?? 'unpaid';
    final userName =
        _booking['user']?['name'] ??
        _booking['customer_name'] ??
        'Walk-in Customer';
    final userEmail =
        _booking['user']?['email'] ?? _booking['customer_email'] ?? 'N/A';
    final groundName = _booking['ground']?['name'] ?? 'Ground';
    final groundType = _booking['ground']?['type'] ?? '';
    final startTime = _booking['start_time'] ?? '';
    final endTime = _booking['end_time'] ?? '';
    final date = _booking['date'] ?? startTime.toString().substring(0, 10);
    final totalPrice = _booking['total_price'] ?? _booking['total_amount'] ?? 0;
    final createdAt = _booking['created_at'] ?? '';
    final updatedAt = _booking['updated_at'] ?? '';

    final statusColor = _statusColor(status);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status hero card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STATUS: ${status.toUpperCase()}',
                            style: AppTextStyles.label.copyWith(
                              color: statusColor,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(groundName, style: AppTextStyles.h2),
                          if (groundType.isNotEmpty)
                            Text(
                              groundType.toUpperCase(),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rs. $totalPrice',
                          style: AppTextStyles.h2.copyWith(color: statusColor),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: paymentStatus == 'paid'
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            paymentStatus == 'paid' ? 'PAID' : 'UNPAID',
                            style: AppTextStyles.label.copyWith(
                              color: paymentStatus == 'paid'
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              // Booking info grid
              _sectionHeader(
                'Booking Information',
                Icons.calendar_month_outlined,
              ),
              const SizedBox(height: AppSpacing.s),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.m,
                crossAxisSpacing: AppSpacing.m,
                childAspectRatio: 2.8,
                children: [
                  _infoCell(
                    Icons.calendar_today_outlined,
                    'Date',
                    date.toString().length > 10
                        ? date.toString().substring(0, 10)
                        : date.toString(),
                  ),
                  _infoCell(
                    Icons.access_time_outlined,
                    'Time',
                    startTime.length > 5
                        ? '${startTime.substring(0, 5)} – ${endTime.length > 5 ? endTime.substring(0, 5) : endTime}'
                        : startTime,
                  ),
                  _infoCell(
                    Icons.people_outline,
                    'Players',
                    '${_booking['players'] ?? 1} people',
                  ),
                  _infoCell(Icons.attach_money, 'Total', 'Rs. $totalPrice'),
                ],
              ),
              const SizedBox(height: AppSpacing.l),

              // Customer details
              _sectionHeader('Customer Details', Icons.person_outline),
              const SizedBox(height: AppSpacing.s),
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: _cardDecoration(),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'W',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName, style: AppTextStyles.bodyLarge),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.mail_outline,
                                size: 14,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                userEmail,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              // Actions panel (if pending or unpaid)
              if (status == 'pending' ||
                  paymentStatus == 'unpaid' ||
                  paymentStatus == 'pending') ...[
                _sectionHeader(
                  'Pending Actions',
                  Icons.pending_actions_outlined,
                ),
                const SizedBox(height: AppSpacing.s),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: _cardDecoration(),
                  child: Column(
                    children: [
                      if (status == 'pending') ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isUpdating
                                    ? null
                                    : () => _confirmDialog(
                                        'Accept this booking?',
                                        () => _updateStatus('confirmed'),
                                      ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text('Accept'),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isUpdating
                                    ? null
                                    : () => _showDeclineSheet(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text('Decline'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                      ],
                      if (paymentStatus != 'paid' && status != 'cancelled')
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isUpdating
                                ? null
                                : () => _confirmDialog(
                                    'Mark as Paid (cash received)?',
                                    _markAsPaid,
                                  ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Icons.attach_money,
                              color: AppColors.primary,
                            ),
                            label: const Text(
                              'Mark as Paid',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
              ],

              // Activity timeline
              _sectionHeader('Activity Timeline', Icons.timeline_outlined),
              const SizedBox(height: AppSpacing.s),
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _timelineItem('Booking Created', createdAt, isFirst: true),
                    if (status != 'pending')
                      _timelineItem(
                        'Status set to ${status.capitalizeFirst}',
                        updatedAt,
                      ),
                    if (paymentStatus == 'paid')
                      _timelineItem('Payment received', updatedAt),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) => Row(
    children: [
      Icon(icon, color: AppColors.primary, size: 18),
      const SizedBox(width: 8),
      Text(title, style: AppTextStyles.h3),
    ],
  );

  Widget _infoCell(IconData icon, String label, String value) => Container(
    padding: const EdgeInsets.all(AppSpacing.m),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _timelineItem(String title, String time, {bool isFirst = false}) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isFirst)
                Container(width: 2, height: 32, color: AppColors.primaryLight),
            ],
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (time.isNotEmpty)
                    Text(
                      time.length > 16 ? time.substring(0, 16) : time,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
    ],
  );

  void _confirmDialog(String message, VoidCallback onConfirm) {
    Get.defaultDialog(
      title: 'Confirm',
      middleText: message,
      textConfirm: 'Yes',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () {
        Get.back();
        onConfirm();
      },
    );
  }

  void _showDeclineSheet() {
    final reasonCtrl = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Decline Booking', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Reason for declining...',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Get.back();
                  _updateStatus('cancelled', reason: reasonCtrl.text);
                },
                child: const Text('Decline Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
