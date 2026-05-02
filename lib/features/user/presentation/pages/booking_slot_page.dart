import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/constants/app_constants.dart';
import 'package:sport_studio/features/user/controller/booking_controller.dart';
import 'package:sport_studio/widgets/app_button.dart';
import 'package:sport_studio/widgets/app_progress_indicator.dart';
import 'package:sport_studio/core/utils/app_utils.dart';
import 'package:sport_studio/core/utils/url_helper.dart';

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
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildGroundHeader(controller)),
                    SliverToBoxAdapter(child: _buildDateSelector(controller)),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.m),
                    ),
                    SliverToBoxAdapter(
                      child: _buildPlayersSelector(controller),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.m),
                    ),
                    SliverToBoxAdapter(
                      child: _buildPromoCodeSection(controller),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.m),
                    ),
                    _buildSlotGridSliver(controller),
                  ],
                ),
              ),
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
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: () {
              final String imageUrl = UrlHelper.getFirstImage(
                ground['images'], 
                fallbackPath: ground['image_path'] ?? ground['image'] ?? ground['image_url']
              );

              return CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[100],
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(
                  AppUtils.getSportIcon(ground['type']),
                  color: AppColors.primary,
                  size: 30,
                ),
              );
            }(),
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
                    Expanded(
                      child: Text(
                        ground['location'] ??
                            (ground['complex']?['address'] ?? 'Location TBD'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
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
    final ground = Get.arguments;
    final int maxCapacity = int.tryParse(ground?['capacity']?.toString() ?? ground?['max_players']?.toString() ?? '30') ?? 30;

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
                Text('Players (Max $maxCapacity)', style: AppTextStyles.bodyLarge),
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
                      controller.incrementPlayers(maxCapacity),
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
                () => controller.discount > 0
                    ? Text(
                        '- ${AppConstants.currencySymbol} ${controller.discount}',
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
          Obx(() {
            final hasPromo = controller.promoCode.value.isNotEmpty;
            if (hasPromo) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[100]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tag, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.promoCode.value,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'Discount applied',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        promoCtrl.clear();
                        controller.removePromoCode();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                      ),
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: promoCtrl,
                        textCapitalization: TextCapitalization.none,
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
                    ElevatedButton(
                      onPressed: controller.isCheckingPromo.value
                          ? null
                          : () => controller.applyPromoCode(promoCtrl.text),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        minimumSize: const Size(0, 42),
                      ),
                      child: controller.isCheckingPromo.value
                          ? const AppProgressIndicator(size: 16, strokeWidth: 2)
                          : const Text('Apply'),
                    ),
                  ],
                ),
                if (controller.availableDeals.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Available Offers',
                    style: AppTextStyles.label.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.availableDeals.length,
                      itemBuilder: (context, index) {
                        final deal = controller.availableDeals[index];
                        return GestureDetector(
                          onTap: () {
                            promoCtrl.text = deal.code ?? '';
                            controller.applyPromoCode(deal.code ?? '');
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.local_offer_outlined,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      deal.code ?? '',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${deal.discountPercentage.toInt()}% OFF',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  String _getSlotDisplay(String slot) {
    try {
      final slotTime = DateFormat('hh:mm a').parse(slot);
      final endTime = slotTime.add(const Duration(hours: 1));
      return '$slot - ${DateFormat('hh:mm a').format(endTime)}';
    } catch (e) {
      return slot;
    }
  }

  Widget _buildSlotGridSliver(BookingController controller) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Available Slots', style: AppTextStyles.h3),
                Obx(
                  () => controller.isLoadingSlots.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Obx(() {
              if (controller.isLoadingSlots.value) {
                return _buildShimmerSlots();
              }

              if (controller.allSlots.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Text(
                      'No slots available for this date.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3.5,
                ),
                itemCount: controller.allSlots.length,
                itemBuilder: (context, index) {
                  final slot = controller.allSlots[index];
                  return Obx(() {
                    final isSelected = controller.selectedSlots.contains(slot);
                    final isBooked = controller.bookedSlots.contains(slot);
                    final isPassed = controller.isSlotPassed(slot);
                    final isUnavailable = isBooked || isPassed;

                    return GestureDetector(
                      onTap: isUnavailable
                          ? null
                          : () => controller.toggleSlot(slot),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isUnavailable
                              ? (isBooked ? Colors.red[50] : Colors.grey[200])
                              : (isSelected ? AppColors.primary : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isUnavailable
                                ? (isBooked
                                      ? Colors.red[100]!
                                      : Colors.transparent)
                                : (isSelected
                                      ? AppColors.primary
                                      : AppColors.border),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isBooked
                              ? 'TAKEN'
                              : (isPassed ? 'PASSED' : _getSlotDisplay(slot)),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isUnavailable
                                ? (isBooked
                                      ? Colors.red[400]
                                      : AppColors.textMuted)
                                : (isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary),
                            fontWeight: FontWeight.bold,
                            fontSize: isUnavailable ? 10 : 12,
                          ),
                        ),
                      ),
                    );
                  });
                },
              );
            }),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerSlots() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 3.5,
        ),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
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
            color: Colors.black.withValues(alpha: 0.05),
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
                            '${AppConstants.currencySymbol} ${NumberFormat('#,###').format(controller.subtotal)}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                      if (controller.discount > 0)
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
                              '- ${AppConstants.currencySymbol} ${NumberFormat('#,###').format(controller.discount)}',
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
                          '${AppConstants.currencySymbol} ${NumberFormat('#,###').format(controller.totalPrice)}',
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
                        : () => _showPaymentMethodSheet(controller),
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

  void _showPaymentMethodSheet(BookingController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose Payment Method', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.m),
              AppButton(
                label: 'Pay with Safepay (Card)',
                onPressed: () {
                  Get.back();
                  controller.createBooking(paymentMethod: 'card');
                },
              ),
              const SizedBox(height: AppSpacing.s),
              AppButton(
                label: 'Pay with Wallet',
                onPressed: () {
                  Get.back();
                  controller.createBooking(paymentMethod: 'wallet');
                },
              ),
              const SizedBox(height: AppSpacing.s),
              AppButton(
                label: 'Cash at Venue',
                onPressed: () {
                  Get.back();
                  controller.createBooking(paymentMethod: 'cash');
                },
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Wallet/Cash bookings are confirmed instantly (no 20-minute timer).',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
