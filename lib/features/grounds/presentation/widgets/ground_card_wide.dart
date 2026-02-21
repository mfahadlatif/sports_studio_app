import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/favorites/controller/favorites_controller.dart';

class GroundCardWide extends StatelessWidget {
  final dynamic ground;

  const GroundCardWide({super.key, required this.ground});

  @override
  Widget build(BuildContext context) {
    final name = ground['name'] ?? 'Premium Cricket Arena';
    final price = ground['price_per_hour'] ?? '3,000';
    final complex = ground['complex'] ?? {};
    final address = complex['address'] ?? 'Main Boulevard, Gulberg, Lahore';

    String imageUrl =
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=800';
    final images = ground['images'] as List<dynamic>?;
    if (images != null && images.isNotEmpty) {
      imageUrl = images[0];
    }

    if (imageUrl.contains('localhost')) {
      imageUrl = imageUrl.replaceAll(
        'localhost/cricket-oasis-bookings/backend/public',
        'lightcoral-goose-424965.hostingersite.com/backend/public',
      );
      imageUrl = imageUrl.replaceAll(
        'http://localhost',
        'https://lightcoral-goose-424965.hostingersite.com',
      );
    }

    return GestureDetector(
      onTap: () => Get.toNamed('/ground-detail', arguments: ground),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.m),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      height: 180,
                      width: double.infinity,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Available',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _FavoriteButton(ground: ground),
                    ],
                  ),
                ),
              ],
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
                      Text(
                        'Rs. $price/hr',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
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
                      const SizedBox(width: AppSpacing.m),
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('4.9', style: AppTextStyles.bodySmall),
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

class _FavoriteButton extends StatelessWidget {
  final dynamic ground;
  const _FavoriteButton({required this.ground});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FavoritesController>();
    final id = int.tryParse(ground['id'].toString()) ?? 0;

    return Obx(() {
      final isFav = controller.isFavorite(id);
      return GestureDetector(
        onTap: () => controller.toggleFavorite(ground),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
            ],
          ),
          child: Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            color: isFav ? Colors.red : AppColors.textSecondary,
            size: 20,
          ),
        ),
      );
    });
  }
}
