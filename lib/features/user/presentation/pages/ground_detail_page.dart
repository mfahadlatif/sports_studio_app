import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/user/controller/favorites_controller.dart';
import 'package:sports_studio/core/utils/url_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:sports_studio/features/user/controller/ground_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class GroundDetailPage extends StatefulWidget {
  const GroundDetailPage({super.key});

  @override
  State<GroundDetailPage> createState() => _GroundDetailPageState();
}

class _GroundDetailPageState extends State<GroundDetailPage> {
  final controller = Get.put(GroundController());
  final arguments = Get.arguments as Map<String, dynamic>?;

  @override
  void initState() {
    super.initState();
    final ground = arguments?['ground'] as Map<String, dynamic>?;
    if (ground != null && ground['id'] != null) {
      controller.fetchReviews(ground['id']);
    }
  }

  void _openMaps(double lat, double lng) async {
    final url = 'google.navigation:q=$lat,$lng';
    final appleUrl = 'http://maps.apple.com/?daddr=$lat,$lng';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else if (await canLaunchUrl(Uri.parse(appleUrl))) {
      await launchUrl(Uri.parse(appleUrl));
    } else {
      Get.snackbar('Error', 'Could not open maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Re-use existing local variables from widget access
    final ground = arguments?['ground'] as Map<String, dynamic>?;

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
    List<String> images = [];
    if (ground != null &&
        ground['images'] != null &&
        (ground['images'] as List).isNotEmpty) {
      images = List<String>.from(ground['images']);
    }

    // Default image if no gallery
    if (images.isEmpty) {
      images.add(
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=800',
      );
    }

    // URL Sanitization Utility
    List<String> sanitizedImages = images
        .map((url) => UrlHelper.sanitizeUrl(url))
        .toList();

    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: sanitizedImages.length,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: sanitizedImages[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
            // Carousel Indicator Layer (Optional but nice)
            if (sanitizedImages.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    sanitizedImages.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
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
    final complex = ground?['complex'] ?? {};
    final location =
        ground?['location'] ?? complex['address'] ?? 'Lahore, Pakistan';

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
            Expanded(
              child: Text(
                location,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats(dynamic ground) {
    final dimensions = ground?['dimensions'] ?? 'Standard';
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
          _statItem(Icons.aspect_ratio, 'Area', dimensions),
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
    final List<dynamic> groundAmenities = ground?['amenities'] ?? [];

    // Config matching owner side
    final Map<String, Map<String, String>> config = {
      'water': {'name': 'Water', 'icon': '🚰'},
      'washroom': {'name': 'Washroom', 'icon': '🚻'},
      'changing': {'name': 'Changing', 'icon': '👕'},
      'dugout': {'name': 'Dugout', 'icon': '⛺'},
      'balls': {'name': 'Balls', 'icon': '🎾'},
      'bats': {'name': 'Bats', 'icon': '🏏'},
      'parking': {'name': 'Parking', 'icon': '🚗'},
      'first_aid': {'name': 'First Aid', 'icon': '🏥'},
      'lighting': {'name': 'Lights', 'icon': '💡'},
    };

    if (groundAmenities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Field Amenities', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.m),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: groundAmenities.map((id) {
            final item =
                config[id.toString()] ?? {'name': id.toString(), 'icon': '✨'};
            return _amenityChip(item['icon']!, item['name']!);
          }).toList(),
        ),
      ],
    );
  }

  Widget _amenityChip(String icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold),
          ),
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
    final complex = ground?['complex'] ?? {};
    final lat =
        double.tryParse(complex['latitude']?.toString() ?? '') ?? 31.5204;
    final lng =
        double.tryParse(complex['longitude']?.toString() ?? '') ?? 74.3587;
    final position = LatLng(lat, lng);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.m),
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: position, zoom: 15),
              markers: {
                Marker(
                  markerId: const MarkerId('ground_location'),
                  position: position,
                  infoWindow: InfoWindow(
                    title: ground?['name'] ?? 'Sports Arena',
                    snippet: complex['address'] ?? '',
                  ),
                ),
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              scrollGesturesEnabled: false, // Static-like but interactive tap
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: () {
              if (lat != 0 && lng != 0) {
                _openMaps(lat, lng);
              }
            },
            icon: const Icon(Icons.directions_outlined, size: 20),
            label: const Text('Get Directions'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
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
            Obx(
              () => Text(
                '${controller.reviews.length} total',
                style: AppTextStyles.bodySmall,
              ),
            ),
          ],
        ),
        Obx(() {
          if (controller.isLoadingReviews.value) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }

          if (controller.reviews.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No reviews yet. Be the first to rate!',
                style: AppTextStyles.bodySmall,
              ),
            );
          }

          return Column(
            children: controller.reviews.take(3).map((r) {
              return _reviewCard(
                r['user']?['name'] ?? 'User',
                r['rating']?.toString() ?? '5.0',
                r['comment'] ?? '',
              );
            }).toList(),
          );
        }),
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
