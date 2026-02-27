import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/user/controller/booking_controller.dart';
import 'package:sports_studio/widgets/app_button.dart';

class BookingSlotPage extends StatelessWidget {
  const BookingSlotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookingController());

    return Scaffold(
      appBar: AppBar(title: const Text('Select Time Slot')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              _buildGroundHeader(controller),
              _buildDateSelector(controller),
              const SizedBox(height: AppSpacing.m),
              _buildPlayersSelector(controller),
              const SizedBox(height: AppSpacing.m),
              _buildPromoCodeSection(controller),
              const SizedBox(height: AppSpacing.m),
              Expanded(child: _buildSlotGrid(controller)),
              _buildPriceSummary(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroundHeader(BookingController controller) {
    final ground = Get.arguments;
    if (ground == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      margin: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.sports_soccer_outlined,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ground['name'] ?? 'Ground', style: AppTextStyles.h3),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ground['location'] ?? 'Location TBD',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(BookingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Text('Select Date', style: AppTextStyles.h3),
          ),
          const SizedBox(height: AppSpacing.m),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              itemCount: 14, // 2 weeks
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index));
                return Obx(() {
                  final isSelected =
                      DateFormat(
                        'yyyy-MM-dd',
                      ).format(controller.selectedDate.value) ==
                      DateFormat('yyyy-MM-dd').format(date);
                  return GestureDetector(
                    onTap: () => controller.selectDate(date),
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('EEE').format(date),
                            style: AppTextStyles.label.copyWith(
                              color: isSelected
                                  ? Colors.white70
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd').format(date),
                            style: AppTextStyles.h3.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersSelector(BookingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.groups_outlined, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Number of Players', style: AppTextStyles.bodyLarge),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => controller.decrementPlayers(),
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppColors.textSecondary,
                ),
                Obx(
                  () => Text(
                    '${controller.players.value}',
                    style: AppTextStyles.h3,
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      controller.incrementPlayers(30), // Max 30 for now
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCodeSection(BookingController controller) {
    final promoCtrl = TextEditingController();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Promo Code',
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(
                () => controller.discount.value > 0
                    ? Text(
                        '- Rs. ${controller.discount.value}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: promoCtrl,
                  decoration: InputDecoration(
                    hintText: 'Enter code',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isCheckingPromo.value
                      ? null
                      : () => controller.applyPromoCode(promoCtrl.text),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: const Size(0, 42),
                  ),
                  child: controller.isCheckingPromo.value
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlotGrid(BookingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Available Slots', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.m),
          Expanded(
            child: Obx(
              () => GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.2,
                ),
                itemCount: controller.availableSlots.length,
                itemBuilder: (context, index) {
                  final slot = controller.availableSlots[index];
                  final isSelected = controller.selectedSlots.contains(slot);
                  return GestureDetector(
                    onTap: () => controller.toggleSlot(slot),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        slot,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(BookingController controller) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
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
      child: SafeArea(
        child: Obx(
          () => Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.selectedSlots.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Slot Price:', style: AppTextStyles.bodySmall),
                          Text(
                            'Rs. ${NumberFormat('#,###').format(controller.subtotal)}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Service Fee:', style: AppTextStyles.bodySmall),
                          Text(
                            'Rs. ${NumberFormat('#,###').format(controller.serviceFee)}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                      if (controller.discount.value > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Discount:',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              '- Rs. ${NumberFormat('#,###').format(controller.discount.value)}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),
                      Container(height: 1, color: AppColors.border),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rs. ${NumberFormat('#,###').format(controller.totalPrice)}',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Obx(
                  () => AppButton(
                    label: 'Confirm Booking',
                    onPressed: controller.selectedSlots.isEmpty
                        ? null
                        : () => controller.createBooking(),
                    isLoading: controller.isBooking.value,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
