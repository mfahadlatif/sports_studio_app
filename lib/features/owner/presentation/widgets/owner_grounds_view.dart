import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/owner/controller/grounds_controller.dart';
import 'package:sports_studio/core/models/models.dart';

class OwnerGroundsView extends StatelessWidget {
  const OwnerGroundsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroundsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          slivers: [
            // ─── Header ─────────────────────────────────────────
            SliverAppBar(
              pinned: false,
              floating: true,
              backgroundColor: AppColors.background,
              title: const Text('My Grounds'),
              actions: [
                IconButton(
                  onPressed: () async {
                    final result = await Get.toNamed('/add-ground');
                    if (result == true) controller.fetchComplexesAndGrounds();
                  },
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primary,
                  ),
                  tooltip: 'Add Ground',
                ),
              ],
            ),

            // ─── Stats strip ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.m,
                  0,
                  AppSpacing.m,
                  AppSpacing.m,
                ),
                child: Row(
                  children: [
                    _statChip(
                      '${controller.grounds.length}',
                      'Total Grounds',
                      Icons.sports_cricket_outlined,
                      AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.s),
                    _statChip(
                      '${controller.grounds.where((g) => g.status == 'active').length}',
                      'Active',
                      Icons.check_circle_outline,
                      Colors.green,
                    ),
                    const SizedBox(width: AppSpacing.s),
                    _statChip(
                      '${controller.complexes.length}',
                      'Complexes',
                      Icons.business_outlined,
                      Colors.indigo,
                    ),
                  ],
                ),
              ),
            ),

            // ─── Complexes section ────────────────────────────────
            if (controller.complexes.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.business_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text('Sports Complexes', style: AppTextStyles.h3),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _buildComplexTile(controller.complexes[i]),
                  childCount: controller.complexes.length,
                ),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.l)),
            ],

            // ─── Grounds list ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                child: Row(
                  children: [
                    const Icon(
                      Icons.sports_cricket_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text('All Grounds', style: AppTextStyles.h3),
                  ],
                ),
              ),
            ),

            if (controller.grounds.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sports_cricket_outlined,
                        size: 64,
                        color: AppColors.textMuted.withOpacity(0.4),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Text('No grounds yet', style: AppTextStyles.h3),
                      const SizedBox(height: AppSpacing.l),
                      ElevatedButton.icon(
                        onPressed: () => Get.toNamed('/add-ground'),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Ground'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.m),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) =>
                        _buildGroundCard(controller.grounds[i], controller),
                    childCount: controller.grounds.length,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _statChip(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.h3.copyWith(color: color, fontSize: 18),
            ),
            Text(
              label,
              style: AppTextStyles.label.copyWith(color: color, fontSize: 9),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplexTile(Complex complex) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed('/complex-detail', arguments: {'id': complex.id}),
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.s,
          AppSpacing.m,
          0,
        ),
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.business_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(complex.name, style: AppTextStyles.bodyLarge),
                  Text(
                    complex.address,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildGroundCard(Ground ground, GroundsController controller) {
    String imageUrl = '';
    if (ground.images != null && ground.images!.isNotEmpty) {
      imageUrl = ground.images![0].toString();
      if (imageUrl.contains('localhost')) {
        imageUrl = imageUrl.replaceAll(
          'localhost/cricket-oasis-bookings/backend/public',
          'lightcoral-goose-424965.hostingersite.com/backend/public',
        );
      }
    }

    final isActive = ground.status == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _placeholder(ground.type),
              ),
            )
          else
            _placeholder(ground.type),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ground.type.capitalizeFirst ?? ground.type,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: AppTextStyles.label.copyWith(
                          color: isActive ? Colors.green : Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Rs. ${ground.pricePerHour.toStringAsFixed(0)}/hr',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(ground.name, style: AppTextStyles.h3),
                if (ground.location.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        ground.location,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: AppSpacing.s),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.s),
                // Action row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _actionBtn(
                      Icons.visibility_outlined,
                      'View',
                      () => Get.toNamed(
                        '/owner-ground-detail',
                        arguments: {
                          'id': ground.id,
                          'name': ground.name,
                          'price_per_hour': ground.pricePerHour,
                          'description': ground.description,
                          'location': ground.location,
                          'type': ground.type,
                          'images': ground.images,
                          'status': ground.status,
                        },
                      ),
                    ),
                    _actionBtn(Icons.edit_outlined, 'Edit', () async {
                      final result = await Get.toNamed(
                        '/add-ground',
                        arguments: {
                          'isEdit': true,
                          'ground': {
                            'id': ground.id,
                            'name': ground.name,
                            'location': ground.location,
                            'price_per_hour': ground.pricePerHour,
                            'description': ground.description,
                            'type': ground.type,
                            'status': ground.status,
                          },
                        },
                      );
                      if (result == true) {
                        controller.fetchComplexesAndGrounds();
                      }
                    }),
                    _actionBtn(
                      Icons.calendar_month_outlined,
                      'Bookings',
                      () => Get.toNamed('/user-bookings'),
                    ),
                    _actionBtn(
                      Icons.delete_outline,
                      'Delete',
                      () => Get.defaultDialog(
                        title: 'Delete Ground',
                        middleText: 'Remove "${ground.name}" permanently?',
                        textConfirm: 'Delete',
                        confirmTextColor: Colors.white,
                        buttonColor: Colors.red,
                        onConfirm: () {
                          Get.back();
                          controller.deleteGround(ground.id);
                        },
                        textCancel: 'Cancel',
                      ),
                      color: Colors.red,
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

  Widget _placeholder(String type) {
    final icons = {
      'cricket': Icons.sports_cricket,
      'football': Icons.sports_soccer,
      'tennis': Icons.sports_tennis,
      'badminton': Icons.sports,
      'basketball': Icons.sports_basketball,
    };
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Icon(
        icons[type.toLowerCase()] ?? Icons.sports,
        size: 36,
        color: AppColors.primary.withOpacity(0.4),
      ),
    );
  }

  Widget _actionBtn(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                fontSize: 10,
                color: color ?? AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
