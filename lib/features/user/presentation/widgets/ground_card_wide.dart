import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sports_studio/core/models/models.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/user/controller/favorites_controller.dart';
import 'package:sports_studio/core/utils/url_helper.dart';
import 'package:sports_studio/features/user/presentation/pages/ground_detail_page.dart';

class GroundCardWide extends StatelessWidget {
  final dynamic ground;

  const GroundCardWide({super.key, required this.ground});

  @override
  Widget build(BuildContext context) {
    // Safely handle both Ground model and Map
    final isModel = ground is Ground;
    
    final name = (isModel ? ground.name : ground['name']) ?? 'Premium Cricket Arena';
    final price = (isModel ? ground.pricePerHour.toString() : ground['price_per_hour']?.toString()) ?? '3,000';
    
    // Complex might be a model or a Map
    final complexData = isModel ? ground.complex : ground['complex'];
    final bool isComplexModel = complexData is Complex;
    final address = (isComplexModel ? complexData.address : complexData?['address']) ?? '—';

    final imageUrl = UrlHelper.getFirstImage(
      isModel ? ground.images : ground['images'],
      fallbackPath: isModel ? null : ground['image_path'],
    );

    return GestureDetector(
      onTap: () => Get.to(() => const GroundDetailPage(), arguments: ground),
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
                    placeholder: (context, url) => Container(
                      color: Colors.grey[100],
                      height: 180,
                      width: double.infinity,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      print('❌ [Image] Failed to load: $url | error: $error');
                      return Container(
                        color: Colors.grey[100],
                        height: 180,
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sports_cricket,
                              color: Colors.grey[400],
                              size: 40,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'No Image',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
                        '${AppConstants.currencySymbol} $price/hr',
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
                      Text(
                        (isModel 
                          ? (ground.avgRating?.toString() ?? '0.0')
                          : (ground['rating'] ?? ground['avg_rating'] ?? '0.0').toString()
                        ),
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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

class _FavoriteButton extends StatelessWidget {
  final dynamic ground;
  const _FavoriteButton({required this.ground});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FavoritesController>();
    final isModel = ground is Ground;
    final id = isModel ? ground.id : (int.tryParse(ground['id']?.toString() ?? '0') ?? 0);

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
