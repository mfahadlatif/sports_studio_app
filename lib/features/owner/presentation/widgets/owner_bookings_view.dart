import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/constants/user_roles.dart';
import 'package:sports_studio/features/landing/controller/landing_controller.dart';
import 'package:sports_studio/features/owner/controller/bookings_controller.dart';
import 'package:sports_studio/features/owner/controller/grounds_controller.dart';

class OwnerBookingsView extends StatelessWidget {
  const OwnerBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final landingController = Get.put(LandingController(), permanent: true);
    final isOwner = landingController.currentRole.value == UserRole.owner;
    final controller = Get.put(BookingsController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isOwner ? 'All Bookings' : 'My Bookings'),
          actions: [
            if (isOwner)
              TextButton.icon(
                onPressed: () => _showManualBookingSheet(context, controller),
                icon: const Icon(Icons.add, color: AppColors.primary),
                label: Text(
                  'Manual Entry',
                  style: AppTextStyles.label.copyWith(color: AppColors.primary),
                ),
              ),
          ],
          bottom: const TabBar(
            isScrollable: false,
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookingList('Upcoming', controller, isOwner),
            _buildBookingList('Past', controller, isOwner),
            _buildBookingList('Cancelled', controller, isOwner),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(
    String type,
    BookingsController controller,
    bool isOwner,
  ) {
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
              Icon(
                Icons.calendar_month_outlined,
                size: 64,
                color: AppColors.textMuted.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                'No $type bookings found.',
                style: AppTextStyles.bodyMedium.copyWith(
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
              return _buildBookingCard(
                context,
                list[index],
                type,
                controller,
                isOwner,
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildBookingCard(
    BuildContext context,
    dynamic booking,
    String type,
    BookingsController controller,
    bool isOwner,
  ) {
    final userName =
        booking['user']?['name'] ??
        booking['customer_name'] ??
        'Walk-in Customer';
    final groundName = booking['ground']?['name'] ?? 'Ground';
    final date = booking['date'] ?? '';
    final startTime = booking['start_time'] ?? '';
    final endTime = booking['end_time'] ?? '';
    final totalAmount = booking['total_amount'] ?? booking['total_price'] ?? 0;
    final status = booking['status'] ?? 'pending';
    final paymentStatus = booking['payment_status'] ?? 'unpaid';

    Color statusColor;
    switch (status) {
      case 'confirmed':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      case 'completed':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.orange;
    }

    return GestureDetector(
      onTap: isOwner
          ? () =>
                Get.toNamed('/booking-detail', arguments: {'booking': booking})
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.m),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      userName.toString().isNotEmpty
                          ? userName.toString().substring(0, 1).toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.toString(),
                          style: AppTextStyles.bodyLarge,
                        ),
                        Text(
                          groundName.toString(),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      status.capitalizeFirst ?? status,
                      style: AppTextStyles.label.copyWith(color: statusColor),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Details Row
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Row(
                children: [
                  Expanded(
                    child: _infoChip(Icons.calendar_month_outlined, date),
                  ),
                  Expanded(
                    child: _infoChip(
                      Icons.access_time_outlined,
                      '$startTime – $endTime',
                    ),
                  ),
                  Expanded(
                    child: _infoChip(
                      Icons.payment_outlined,
                      paymentStatus == 'paid' ? 'Paid' : 'Unpaid',
                      color: paymentStatus == 'paid'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: Text(
                'Rs. ${NumberFormat('#,###').format(totalAmount)}',
                style: AppTextStyles.h3.copyWith(color: AppColors.primary),
              ),
            ),

            // Action Buttons — Owner Only
            if (isOwner &&
                (status == 'pending' ||
                    paymentStatus == 'unpaid' ||
                    paymentStatus == 'pending')) ...[
              const SizedBox(height: AppSpacing.m),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.m,
                  0,
                  AppSpacing.m,
                  AppSpacing.m,
                ),
                child: Obx(
                  () => Row(
                    children: [
                      if (status == 'pending') ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.isActioning.value
                                ? null
                                : () => _confirmAction(context, 'Accept', () {
                                    controller.updateBookingStatus(
                                      booking,
                                      'confirmed',
                                    );
                                  }),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Icons.check_circle_outline,
                              size: 16,
                            ),
                            label: const Text('Accept'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.isActioning.value
                                ? null
                                : () => _showDeclineDialog(
                                    context,
                                    booking,
                                    controller,
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.cancel_outlined, size: 16),
                            label: const Text('Decline'),
                          ),
                        ),
                      ],
                      if ((paymentStatus == 'unpaid' ||
                              paymentStatus == 'pending') &&
                          status != 'cancelled') ...[
                        if (status == 'pending')
                          const SizedBox(width: AppSpacing.s),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: controller.isActioning.value
                                ? null
                                : () => _confirmAction(
                                    context,
                                    'Mark as Paid',
                                    () {
                                      controller.markAsPaid(booking);
                                    },
                                  ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Icons.attach_money,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            label: Text(
                              'Mark Paid',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ] else
              const SizedBox(height: AppSpacing.m),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _confirmAction(
    BuildContext context,
    String label,
    VoidCallback onConfirm,
  ) {
    Get.defaultDialog(
      title: label,
      middleText: 'Are you sure you want to $label this booking?',
      textConfirm: label,
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () {
        Get.back();
        onConfirm();
      },
    );
  }

  void _showDeclineDialog(
    BuildContext context,
    dynamic booking,
    BookingsController controller,
  ) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Decline Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please provide a reason for declining:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Facility under maintenance...',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              controller.updateBookingStatus(
                booking,
                'cancelled',
                reason: reasonController.text,
              );
            },
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }

  void _showManualBookingSheet(
    BuildContext context,
    BookingsController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ManualBookingSheet(controller: controller),
    );
  }
}

// ─── Manual Booking Bottom Sheet ─────────────────────────────────────────────
class _ManualBookingSheet extends StatefulWidget {
  final BookingsController controller;
  const _ManualBookingSheet({required this.controller});

  @override
  State<_ManualBookingSheet> createState() => _ManualBookingSheetState();
}

class _ManualBookingSheetState extends State<_ManualBookingSheet> {
  final _nameCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  int? _selectedGroundId;

  @override
  Widget build(BuildContext context) {
    final groundsController = Get.put(GroundsController());
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Manual Booking Entry',
                      style: AppTextStyles.h2,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Name
                    Text('Customer Name', style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.s),
                    _field(
                      _nameCtrl,
                      'e.g. Ahmed Khan',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Ground Selector
                    Text('Select Ground', style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.s),
                    Obx(
                      () => DropdownButtonFormField<int>(
                        value: _selectedGroundId,
                        hint: const Text('Choose a ground'),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.sports_cricket_outlined),
                        ),
                        items: groundsController.grounds
                            .map(
                              (g) => DropdownMenuItem<int>(
                                value: g.id,
                                child: Text(g.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedGroundId = val),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Date
                    Text('Date', style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.s),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 90),
                          ),
                        );
                        if (picked != null) {
                          _dateCtrl.text = DateFormat(
                            'yyyy-MM-dd',
                          ).format(picked);
                        }
                      },
                      child: AbsorbPointer(
                        child: _field(
                          _dateCtrl,
                          'YYYY-MM-DD',
                          icon: Icons.calendar_today_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Time Slots
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start Time', style: AppTextStyles.label),
                              const SizedBox(height: AppSpacing.s),
                              GestureDetector(
                                onTap: () => _pickTime(context, _startCtrl),
                                child: AbsorbPointer(
                                  child: _field(
                                    _startCtrl,
                                    '09:00',
                                    icon: Icons.access_time,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('End Time', style: AppTextStyles.label),
                              const SizedBox(height: AppSpacing.s),
                              GestureDetector(
                                onTap: () => _pickTime(context, _endCtrl),
                                child: AbsorbPointer(
                                  child: _field(
                                    _endCtrl,
                                    '11:00',
                                    icon: Icons.access_time,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Amount
                    Text('Total Amount (Rs.)', style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.s),
                    _field(
                      _amountCtrl,
                      'e.g. 3000',
                      icon: Icons.attach_money,
                      type: TextInputType.number,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Submit
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: widget.controller.isActioning.value
                              ? null
                              : () => _submit(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: widget.controller.isActioning.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'Create Booking',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    IconData? icon,
    TextInputType? type,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.background,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    TextEditingController ctrl,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  void _submit(BuildContext ctx) {
    if (_nameCtrl.text.isEmpty ||
        _selectedGroundId == null ||
        _dateCtrl.text.isEmpty ||
        _startCtrl.text.isEmpty ||
        _endCtrl.text.isEmpty ||
        _amountCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }
    Navigator.pop(ctx);
    widget.controller.createManualBooking(
      groundId: _selectedGroundId!,
      customerName: _nameCtrl.text,
      date: _dateCtrl.text,
      startTime: _startCtrl.text,
      endTime: _endCtrl.text,
      totalAmount: double.tryParse(_amountCtrl.text) ?? 0,
    );
  }
}
