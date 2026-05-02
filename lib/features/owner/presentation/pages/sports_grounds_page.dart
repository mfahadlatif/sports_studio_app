import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/constants/app_constants.dart';
import 'package:sport_studio/core/models/models.dart';
import 'package:sport_studio/core/utils/app_utils.dart';
import 'package:sport_studio/core/utils/url_helper.dart';
import 'package:sport_studio/features/owner/controller/grounds_controller.dart';
import 'package:sport_studio/features/owner/presentation/pages/add_edit_ground_page.dart';
import 'package:sport_studio/features/owner/presentation/pages/owner_ground_detail_page.dart';
import 'package:sport_studio/widgets/app_shimmer.dart';

class SportsGroundsPage extends StatelessWidget {
  const SportsGroundsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroundsController());
    final RxString searchQuery = ''.obs;

    // Ensure data is fetched when first coming to the screen if it's empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.grounds.isEmpty && !controller.isLoading.value) {
        controller.fetchComplexesAndGrounds();
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Grounds'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () async {
              final res = await Get.to(() => const AddEditGroundPage());
              if (res == true) controller.fetchComplexesAndGrounds();
            },
            icon: const Icon(Icons.add, color: AppColors.primary),
            label: Text(
              'Add',
              style: AppTextStyles.label.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: TextField(
              onChanged: (v) => searchQuery.value = v,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Search grounds by name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.grounds.isEmpty) {
                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  itemCount: 5,
                  itemBuilder: (_, __) => AppShimmer.card(),
                );
              }

              final filtered = controller.grounds
                  .where(
                    (g) => g.name.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ),
                  )
                  .toList();

              if (filtered.isEmpty) {
                return _buildEmptyState(controller);
              }

              return RefreshIndicator(
                onRefresh: controller.fetchComplexesAndGrounds,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final ground = filtered[index];
                    return _buildGroundCard(context, ground, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGroundCard(
    BuildContext context,
    Ground ground,
    GroundsController controller,
  ) {
    final images = UrlHelper.getParsedImages(ground.images);
    final firstImage = images.isNotEmpty ? images.first : null;
    final complexName = ground.complexName ?? 'Main Complex';

    return GestureDetector(
      onTap: () => Get.to(
        () => const OwnerGroundDetailPage(),
        arguments: ground.toJson(),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.m),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section
              Container(
                width: 100,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(20),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(20),
                  ),
                  child: firstImage != null
                      ? CachedNetworkImage(
                          imageUrl: UrlHelper.sanitizeUrl(firstImage),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.primaryLight,
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.primaryLight,
                          child: const Icon(
                            Icons.sports_soccer,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                ),
              ),

              // Details Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ground.name,
                                  style: AppTextStyles.h3.copyWith(
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  complexName,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ground.status == 'active'
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: ground.status == 'active'
                                    ? Colors.green.withValues(alpha: 0.2)
                                    : Colors.red.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              ground.status.toUpperCase(),
                              style: TextStyle(
                                color: ground.status == 'active'
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.sports_bar_outlined,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ground.type.capitalizeFirst ?? 'General',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${AppConstants.currencySymbol}${ground.pricePerHour}/hr',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _IconButton(
                            icon: Icons.edit_outlined,
                            color: AppColors.primary,
                            onTap: () async {
                              final res = await Get.to(
                                () => const AddEditGroundPage(),
                                arguments: {
                                  'isEdit': true,
                                  'ground': ground.toJson(),
                                },
                              );
                              if (res == true) {
                                controller.fetchComplexesAndGrounds();
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          _IconButton(
                            icon: Icons.delete_outline,
                            color: Colors.red,
                            onTap: () async {
                              final confirmed =
                                  await AppUtils.showDeleteConfirmation(
                                    title: 'Delete Ground?',
                                    message:
                                        'Are you sure you want to delete "${ground.name}"? This action cannot be undone.',
                                  );
                              if (confirmed == true) {
                                controller.deleteGround(ground.id);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(GroundsController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.layers_outlined,
            size: 72,
            color: AppColors.textMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            'No grounds found',
            style: AppTextStyles.h2.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.s),
          const Text('Start by adding your first sports arena'),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: () async {
              final res = await Get.to(() => const AddEditGroundPage());
              if (res == true) controller.fetchComplexesAndGrounds();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Ground'),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}
