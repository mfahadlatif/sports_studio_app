import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/widgets/app_shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/widgets/section_header.dart';
import 'package:sports_studio/features/user/controller/home_controller.dart';
import 'package:sports_studio/features/landing/controller/landing_controller.dart'
    as sports_landing;
import 'package:sports_studio/core/utils/url_helper.dart';

class GroundsPreviewSection extends StatelessWidget {
  const GroundsPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Column(
      children: [
        Obx(
          () => SectionHeader(
            title: controller.selectedCategory.value == 'All'
                ? 'Premium Grounds'
                : '${controller.selectedCategory.value} Grounds',
            subtitle: 'Choose from our top-rated sports arenas',
            onActionPressed: () {
              final landingController =
                  Get.find<sports_landing.LandingController>();
              landingController.changeNavIndex(1); // switch to Grounds Tab
            },
          ),
        ),
        SizedBox(
          height: 280,
          child: Obx(() {
            if (controller.isLoading.value) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (_, __) => AppShimmer.groundCard(),
              );
            }

            if (controller.filteredGrounds.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sports_cricket_outlined,
                        size: 48,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No grounds available for ${controller.selectedCategory.value}.',
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              scrollDirection: Axis.horizontal,
              itemCount: controller.filteredGrounds.length,
              itemBuilder: (context, index) {
                final ground = controller.filteredGrounds[index];
                return GroundCard(ground: ground);
              },
            );
          }),
        ),
      ],
    );
  }
}

class GroundCard extends StatelessWidget {
  final dynamic ground;

  const GroundCard({super.key, required this.ground});

  @override
  Widget build(BuildContext context) {
    final name = ground['name'] ?? 'Arena Center';
    final price = ground['price_per_hour'] ?? '2,500';
    final complex = ground['complex'] ?? {};
    final address = complex['address'] ?? 'Lahore, Pakistan';

    final images = ground['images'] as List<dynamic>?;
    String? rawUrl;
    if (images != null && images.isNotEmpty) {
      rawUrl = images[0];
    } else if (ground['image_path'] != null) {
      rawUrl = ground['image_path'];
    }

    final imageUrl = UrlHelper.sanitizeUrl(rawUrl);

    return GestureDetector(
      onTap: () => Get.toNamed('/ground-detail', arguments: ground),
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(
          right: AppSpacing.m,
          bottom: AppSpacing.s,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  height: 140,
                  width: double.infinity,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: AppTextStyles.h3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '4.8',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
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
                          address,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rs. $price/hr',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
