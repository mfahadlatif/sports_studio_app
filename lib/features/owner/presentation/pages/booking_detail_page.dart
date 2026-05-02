import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/constants/app_constants.dart';
import 'package:sport_studio/core/network/api_client.dart';
import 'package:sport_studio/widgets/app_progress_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sport_studio/core/utils/url_helper.dart';
import 'package:sport_studio/core/utils/app_utils.dart';

import 'package:sport_studio/features/owner/controller/bookings_controller.dart';
import 'package:sport_studio/core/models/models.dart';

class BookingDetailPage extends StatefulWidget {
  const BookingDetailPage({super.key});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  Booking? _booking;
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    final args = Get.arguments;
    int? bookingId;

    if (args is Map && args['booking'] != null) {
      final bookingJson = args['booking'];
      setState(() {
        _booking = bookingJson is Booking
            ? bookingJson
            : Booking.fromJson(Map<String, dynamic>.from(bookingJson as Map));
        _isLoading = false;
      });
      bookingId = _booking?.id;
    } else {
      bookingId = args?['id'] ?? args;
    }

    if (bookingId == null) {
      if (_booking == null) Get.back();
      return;
    }

    try {
      final res = await ApiClient().dio.get('/bookings/$bookingId');
      if (res.statusCode == 200) {
        final data = res.data is Map && res.data['data'] != null
            ? res.data['data']
            : res.data;
        setState(() {
          _booking = Booking.fromJson(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching booking details: $e');
      if (_booking == null) {
        AppUtils.showError(message: 'Failed to load booking details');
        Get.back();
      }
    }
  }

  Future<void> _updateStatus(String newStatus, {String? reason}) async {
    if (_booking == null) return;
    setState(() => _isUpdating = true);
    try {
      final id = _booking!.id;
      final payload = <String, dynamic>{'status': newStatus};
      if (reason != null && reason.isNotEmpty) {
        payload['rejection_reason'] = reason;
      }
      if (newStatus == 'cancelled') payload['payment_status'] = 'refunded';

      final res = await ApiClient().dio.put('/bookings/$id', data: payload);
      if (res.statusCode == 200) {
        final data = res.data is Map && res.data['data'] != null
            ? res.data['data']
            : res.data;
        if (data is Map) {
          setState(
            () => _booking = Booking.fromJson(
              Map<String, dynamic>.from(data as Map),
            ),
          );
        } else {
          _loadBooking(); // fallback
        }

        if (Get.isRegistered<BookingsController>()) {
          Get.find<BookingsController>().fetchBookings(silent: true);
        }

        String successMsg = 'Booking status updated successfully';
        if (newStatus == 'confirmed')
          successMsg = 'Booking accepted successfully';
        if (newStatus == 'cancelled')
          successMsg = 'Booking declined successfully';
        if (newStatus == 'completed')
          successMsg = 'Booking marked as completed';

        AppUtils.showSuccess(message: successMsg);
      } else {
        // Explicitly handle failure if statusCode is not 200
        throw Exception('Server returned status ${res.statusCode}');
      }
    } catch (e) {
      print('❌ [BookingDetail] _updateStatus error: $e');
      AppUtils.showError(message: e);
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _markAsPaid() async {
    if (_booking == null) return;
    setState(() => _isUpdating = true);
    try {
      final id = _booking!.id;
      // Match website/backend: POST /bookings/:id/finalize-payment (cash/COD)
      final res = await ApiClient().dio.post('/bookings/$id/finalize-payment');
      if (res.statusCode == 200) {
        final Map<String, dynamic> responseMap = Map<String, dynamic>.from(
          res.data as Map,
        );
        final dynamic bookingData =
            responseMap['booking'] ?? responseMap['data'] ?? responseMap;

        setState(() {
          _booking = Booking.fromJson(
            Map<String, dynamic>.from(bookingData as Map),
          );
        });

        if (Get.isRegistered<BookingsController>()) {
          Get.find<BookingsController>().fetchBookings();
        }
        AppUtils.showSuccess(message: 'Booking has been confirmed as paid');
      }
    } catch (e) {
      print('❌ [BookingDetail] _markAsPaid error: $e');
      AppUtils.showError(message: e);
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
          _booking != null ? 'Booking #${_booking!.id}' : 'Booking Details',
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const AppProgressIndicator()
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
    final booking = _booking!;

    final bool isTimePassed = booking.endTime.isBefore(DateTime.now());
    String status = (booking.status).toString();

    if (isTimePassed && status == 'pending') {
      status = 'cancelled';
    }
    final String paymentStatus = (booking.paymentStatus).toString();

    final userName =
        booking.customerName ?? booking.user?.name ?? 'Walk-in Customer';

    final userEmail = (booking.customerEmail?.isNotEmpty == true)
        ? booking.customerEmail!
        : (booking.user?.email.isNotEmpty == true
              ? booking.user!.email
              : 'N/A');

    final userPhone = (booking.customerPhone?.isNotEmpty == true)
        ? booking.customerPhone!
        : (booking.user?.phone?.isNotEmpty == true
              ? booking.user!.phone!
              : 'N/A');

    final groundName = booking.ground?.name ?? 'Ground';
    final groundType = booking.ground?.type ?? '';
    final startTime = booking.startTime.toIso8601String();
    final endTime = booking.endTime.toIso8601String();
    final date = AppUtils.formatDate(
      booking.startTime.toIso8601String().substring(0, 10),
    );
    final totalPrice = booking.totalPrice;
    final createdAt = booking.createdAt?.toIso8601String() ?? '';
    final updatedAt = booking.updatedAt?.toIso8601String() ?? '';

    final statusColor = _statusColor(status);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ground Image Header
              if (booking.ground != null)
                Container(
                  height: 180,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: AppSpacing.l),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: UrlHelper.sanitizeUrl(
                        (booking.ground!.images != null &&
                                booking.ground!.images!.isNotEmpty)
                            ? booking.ground!.images![0].toString()
                            : booking.ground?.name ?? '',
                      ),
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.primaryLight,
                        child: const Icon(
                          Icons.sports_cricket,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

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
                          const SizedBox(height: 8),
                          if (booking.event != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.blueAccent, Colors.lightBlue],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "Event: ${booking.event!.name}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
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
                          '${AppConstants.currencySymbol} $totalPrice',
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
                childAspectRatio: 2,
                children: [
                  _infoCell(Icons.calendar_today_outlined, 'Date', date),
                  _infoCell(
                    Icons.access_time_outlined,
                    'Time',
                    AppUtils.formatTimeRange(startTime, endTime),
                  ),
                  _infoCell(
                    Icons.people_outline,
                    'Players',
                    '${booking.players} people',
                  ),
                  _infoCell(
                    Icons.payment_outlined,
                    'Payment',
                    paymentStatus.toUpperCase(),
                  ),
                  _infoCell(
                    Icons.payments_outlined,
                    'Method',
                    (booking.paymentMethod?.toLowerCase() == 'cash' ||
                            booking.paymentMethod?.toLowerCase() == 'cod')
                        ? 'CASH'
                        : (booking.paymentMethod ?? 'N/A').toUpperCase(),
                  ),
                  _infoCell(
                    null,
                    'Total',
                    '${AppConstants.currencySymbol} $totalPrice',
                  ),
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
                    Container(
                      height: 56,
                      width: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: (booking.user?.avatar != null)
                            ? CachedNetworkImage(
                                imageUrl: UrlHelper.sanitizeUrl(
                                  booking.user!.avatar.toString(),
                                ),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.person),
                              )
                            : Center(
                                child: Text(
                                  userName.isNotEmpty
                                      ? userName[0].toUpperCase()
                                      : 'W',
                                  style: AppTextStyles.h2.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
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
                              Expanded(
                                child: Text(
                                  userName,
                                  style: AppTextStyles.bodyLarge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (userPhone != 'N/A')
                                IconButton(
                                  onPressed: () =>
                                      AppUtils.launchUrl('tel:$userPhone'),
                                  icon: const Icon(
                                    Icons.call,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.primaryLight
                                        .withValues(alpha: 0.1),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.mail_outline,
                                size: 14,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  userEmail,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (userPhone != 'N/A') ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone_outlined,
                                  size: 14,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    userPhone,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              // Actions panel (if pending or unpaid)
              // Only show if there's actually something to do.
              () {
                final bool isOnlinePayment =
                    booking.paymentMethod?.toLowerCase() != 'cash' &&
                    booking.paymentMethod?.toLowerCase() != 'cod' &&
                    booking.paymentMethod != null;

                final bool isPending = status == 'pending';
                final bool isUnpaidCash =
                    (paymentStatus == 'unpaid' || paymentStatus == 'pending') &&
                    !isOnlinePayment;

                final canAcceptDecline = isPending && !isOnlinePayment;
                final canMarkPaid = isUnpaidCash;
                final canMarkCompleted =
                    status == 'confirmed' && paymentStatus == 'paid';

                if ((canAcceptDecline || canMarkPaid || canMarkCompleted) &&
                    !isTimePassed) {
                  return Column(
                    children: [
                      _sectionHeader(
                        'Booking Management',
                        Icons.settings_suggest_outlined,
                      ),
                      const SizedBox(height: AppSpacing.s),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        decoration: _cardDecoration(),
                        child: Column(
                          children: [
                            if (canAcceptDecline) ...[
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
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      icon: const Icon(
                                        Icons.check_circle_outline,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'Accept',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.m),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _isUpdating
                                          ? null
                                          : () => _showDeclineSheet(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade400,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      icon: const Icon(
                                        Icons.cancel_outlined,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'Decline',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (canMarkPaid)
                                const SizedBox(height: AppSpacing.s),
                            ],
                            if (canMarkPaid)
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    side: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: AppColors.primary
                                        .withValues(alpha: 0.05),
                                  ),
                                  icon: const Icon(
                                    Icons.payments_outlined,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  label: const Text(
                                    'Mark as Paid',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            if (canMarkCompleted)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _isUpdating
                                      ? null
                                      : () => _confirmDialog(
                                          'Mark this booking as Completed?',
                                          () => _updateStatus('completed'),
                                        ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.verified_outlined),
                                  label: const Text('Mark as Completed'),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.l),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }(),

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

  Widget _infoCell(IconData? icon, String label, String value) => Container(
    padding: const EdgeInsets.all(AppSpacing.m),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
        ] else ...[
          SizedBox(
            width: 18,
            child: Text(
              AppConstants.currencySymbol,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
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
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                maxLines: 2,
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
                      AppUtils.formatDateTime(time),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
    AppUtils.showConfirmDialog(
      title: 'Confirm Action',
      message: message,
      onConfirm: onConfirm,
      confirmText: 'Yes, Proceed',
      cancelText: 'Cancel',
      icon: Icons.help_outline_rounded,
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
              textCapitalization: TextCapitalization.sentences,
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
