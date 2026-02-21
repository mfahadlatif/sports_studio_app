import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/widgets/section_header.dart';
import 'package:sports_studio/features/landing/controller/home_controller.dart';
import 'package:sports_studio/features/landing/controller/landing_controller.dart'
    as sports_landing;

class GroundsPreviewSection extends StatelessWidget {
  const GroundsPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Column(
      children: [
        SectionHeader(
          title: 'Premium Grounds',
          subtitle: 'Choose from our top-rated sports arenas',
          onActionPressed: () {
            final landingController =
                Get.find<sports_landing.LandingController>();
            landingController.changeNavIndex(1); // switch to Grounds Tab
          },
        ),
        SizedBox(
          height: 280,
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.premiumGrounds.isEmpty) {
              return const Center(child: Text('No grounds available.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              scrollDirection: Axis.horizontal,
              itemCount: controller.premiumGrounds.length,
              itemBuilder: (context, index) {
                final ground = controller.premiumGrounds[index];
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

    // Default placeholder
    String imageUrl =
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=800';
    final images = ground['images'] as List<dynamic>?;
    if (images != null && images.isNotEmpty) {
      imageUrl = images[0];
    }

    // Fix localhost urls from backend if testing
    if (imageUrl.contains('localhost')) {
      imageUrl = imageUrl.replaceAll(
        'localhost/cricket-oasis-bookings/backend/public',
        'lightcoral-goose-424965.hostingersite.com/backend/public',
      );
      // Just basic fix in case we have http://localhost/... instead of real hostinger server
      imageUrl = imageUrl.replaceAll(
        'http://localhost',
        'https://lightcoral-goose-424965.hostingersite.com',
      );
    }

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
