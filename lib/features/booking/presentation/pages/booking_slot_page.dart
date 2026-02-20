import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/booking/controller/booking_controller.dart';

class BookingSlotPage extends StatelessWidget {
  const BookingSlotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookingController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Time Slot'),
      ),
      body: Column(
        children: [
          _buildDateSelector(controller),
          const SizedBox(height: AppSpacing.l),
          Expanded(child: _buildSlotGrid(controller)),
          _buildPriceSummary(controller),
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
                  final isSelected = DateFormat('yyyy-MM-dd').format(controller.selectedDate.value) ==
                      DateFormat('yyyy-MM-dd').format(date);
                  return GestureDetector(
                    onTap: () => controller.selectDate(date),
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('EEE').format(date),
                            style: AppTextStyles.label.copyWith(
                              color: isSelected ? Colors.white70 : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd').format(date),
                            style: AppTextStyles.h3.copyWith(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
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

  Widget _buildSlotGrid(BookingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Available Slots', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.m),
          Expanded(
            child: Obx(() => GridView.builder(
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
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      slot,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            )),
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
        child: Obx(() => Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text('${controller.selectedSlots.length} Slots Selected', style: AppTextStyles.label),
                   Text('Total: Rs. ${NumberFormat('#,###').format(controller.totalPrice)}', 
                        style: AppTextStyles.h2.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: ElevatedButton(
                onPressed: controller.selectedSlots.isEmpty ? null : () {},
                child: const Text('Proceed to Pay'),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
