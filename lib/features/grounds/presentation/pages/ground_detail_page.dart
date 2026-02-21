import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/favorites/controller/favorites_controller.dart';

class GroundDetailPage extends StatelessWidget {
  const GroundDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ground = Get.arguments;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Scrollable Content
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(ground),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(ground),
                      const SizedBox(height: AppSpacing.xl),
                      _buildQuickStats(ground),
                      const SizedBox(height: AppSpacing.xl),
                      _buildAmenities(ground),
                      const SizedBox(height: AppSpacing.xl),
                      _buildDescription(ground),
                      const SizedBox(height: AppSpacing.xl),
                      _buildLocationMap(ground),
                      const SizedBox(height: AppSpacing.xl),
                      _buildReviewsSection(ground),
                      const SizedBox(
                        height: 120,
                      ), // Bottom padding for action bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Custom Floating Top Buttons
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.3),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ),
                _FavoriteButtonDetail(ground: ground),
              ],
            ),
          ),

          // Bottom Booking Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomBar(ground),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(dynamic ground) {
    String imageUrl =
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=800';
    if (ground != null &&
        ground['images'] != null &&
        (ground['images'] as List).isNotEmpty) {
      imageUrl = ground['images'][0];
      if (imageUrl.contains('localhost')) {
        imageUrl = imageUrl
            .replaceAll(
              'localhost/cricket-oasis-bookings/backend/public',
              'lightcoral-goose-424965.hostingersite.com/backend/public',
            )
            .replaceAll(
              'http://localhost',
              'https://lightcoral-goose-424965.hostingersite.com',
            );
      }
    }

    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[200]),
            ),
            // Gradient Overlay
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black26, Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(dynamic ground) {
    final name = ground?['name'] ?? 'Premium Arena';
    final type = ground?['type'] ?? 'Cricket';
    final location = ground?['location'] ?? 'Lahore, Pakistan';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                type.toString().toUpperCase(),
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text('4.9', style: AppTextStyles.h3),
                Text(' (120 reviews)', style: AppTextStyles.bodySmall),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(name, style: AppTextStyles.h1),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, size: 18, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              location,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats(dynamic ground) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(Icons.aspect_ratio, 'Area', '80x80 ft'),
          _statItem(
            Icons.people_outline,
            'Capacity',
            ground?['type'] == 'Cricket' ? '22 Players' : '14 Players',
          ),
          _statItem(
            Icons.lightbulb_outline,
            'Lights',
            ground?['has_lighting'] == 1 ? 'Available' : 'No',
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildAmenities(dynamic ground) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Field Amenities', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.m),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _amenityIcon(Icons.directions_car, 'Free Parking'),
            _amenityIcon(Icons.water_drop, 'Chilled Water'),
            _amenityIcon(Icons.restaurant, 'Refreshments'),
            _amenityIcon(Icons.medical_services, 'First Aid'),
            if (ground?['has_lighting'] == 1)
              _amenityIcon(Icons.flood, 'Flood Lights'),
            _amenityIcon(Icons.meeting_room, 'Changing Room'),
          ],
        ),
      ],
    );
  }

  Widget _amenityIcon(IconData icon, String label) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: AppTextStyles.label),
        ],
      ),
    );
  }

  Widget _buildDescription(dynamic ground) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About Arena', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.m),
        Text(
          ground?['description'] ??
              'This international standard sports facility offers a high-performance surface, professional measurement, and top-tier floodlighting. Perfectly suited for both competitive tournaments and casual practice sessions.',
          style: AppTextStyles.bodyMedium.copyWith(
            height: 1.6,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationMap(dynamic ground) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.m),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image: CachedNetworkImageProvider(
                'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?q=80&w=800',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.directions,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Get Directions',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(dynamic ground) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Player Reviews', style: AppTextStyles.h2),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        _reviewCard(
          'Hamza Khan',
          '5.0',
          'Best turf in the city! The bounce is very consistent.',
        ),
        _reviewCard(
          'Zain Ahmed',
          '4.0',
          'Great lighting for night matches, but parking was a bit tight.',
        ),
      ],
    );
  }

  Widget _reviewCard(String name, String rating, String text) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: Text(name[0]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _starRating(rating),
                  ],
                ),
              ),
              Text(
                '2 days ago',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _starRating(String r) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          Icons.star,
          size: 14,
          color: index < double.parse(r) ? Colors.amber : Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildBottomBar(dynamic ground) {
    final price = ground?['price_per_hour'] ?? '3,500';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Price',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  'Rs. $price/hr',
                  style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(width: 32),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed('/book-slot', arguments: ground),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                  ),
                  child: const Text(
                    'Check Availability',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteButtonDetail extends StatelessWidget {
  final dynamic ground;
  const _FavoriteButtonDetail({required this.ground});

  @override
  Widget build(BuildContext context) {
    if (ground == null) return const SizedBox.shrink();
    final controller = Get.put(FavoritesController()); // Ensure it exists
    final id = int.tryParse(ground['id'].toString()) ?? 0;

    return Obx(() {
      final isFav = controller.isFavorite(id);
      return CircleAvatar(
        backgroundColor: Colors.black.withOpacity(0.3),
        child: IconButton(
          icon: Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            color: isFav ? Colors.red : Colors.white,
          ),
          onPressed: () => controller.toggleFavorite(ground),
        ),
      );
    });
  }
}
