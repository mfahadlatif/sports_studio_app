import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';

class GroundDetailPage extends StatelessWidget {
  const GroundDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageHeader(Get.arguments),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleSection(Get.arguments),
                          const Divider(height: AppSpacing.xl),
                          _buildAmenities(Get.arguments),
                          const SizedBox(height: AppSpacing.l),
                          _buildDescription(Get.arguments),
                          const SizedBox(height: AppSpacing.l),
                          _buildReviewsSummary(Get.arguments),
                          const SizedBox(height: 100), // Spacer for bottom bar
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Custom App Bar (Back button)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.3),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ),

          // Bottom Action Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomBar(Get.arguments),
          ),
        ],
      ),
    );
  }

  Widget _buildImageHeader(dynamic ground) {
    String imageUrl =
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=800';
    if (ground != null &&
        ground['images'] != null &&
        (ground['images'] as List).isNotEmpty) {
      imageUrl = ground['images'][0];
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
    }

    return Hero(
      tag: 'ground_image_${ground?['id'] ?? ''}',
      child: Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(dynamic ground) {
    final type = ground?['type'] ?? 'Cricket';
    final name = ground?['name'] ?? 'Premium Cricket Arena';
    final complex = ground?['complex'] ?? {};
    final address = complex['address'] ?? 'Gulberg III, Lahore, Pakistan';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                type.toString().capitalizeFirst ?? type,
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '4.9',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(' (120 reviews)', style: AppTextStyles.bodySmall),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        Text(name, style: AppTextStyles.h1),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Expanded(child: Text(address, style: AppTextStyles.bodyMedium)),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenities(dynamic ground) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amenities', style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.m),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _amenityIcon(Icons.directions_car_outlined, 'Parking'),
            _amenityIcon(Icons.water_drop_outlined, 'Water'),
            _amenityIcon(Icons.restaurant_outlined, 'Cafe'),
            if (ground?['lighting'] == true)
              _amenityIcon(Icons.lightbulb_outline, 'Lighting'),
          ],
        ),
      ],
    );
  }

  Widget _amenityIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.label),
      ],
    );
  }

  Widget _buildDescription(dynamic ground) {
    final description =
        ground?['description'] ??
        'This premium cricket arena features a high-quality turf pitch, professional-grade floodlights, and a spacious outfield.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About this Ground', style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.m),
        Text(description, style: AppTextStyles.bodyMedium),
      ],
    );
  }

  Widget _buildReviewsSummary(dynamic ground) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Reviews', style: AppTextStyles.h3),
            TextButton(onPressed: () {}, child: const Text('See All')),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 2,
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(
                'Player ${index + 1}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Amazing experience, the pitch was in great condition!',
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar(dynamic ground) {
    final price = ground?['price_per_hour'] ?? '3,000';

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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price', style: AppTextStyles.label),
                    Text(
                      'Rs. $price/hr',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed('/book-slot', arguments: ground),
                  child: const Text('Book Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
