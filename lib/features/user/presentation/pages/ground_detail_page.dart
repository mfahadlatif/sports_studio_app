import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:sports_studio/features/user/controller/favorites_controller.dart';
import 'package:sports_studio/core/utils/url_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:sports_studio/features/user/controller/ground_controller.dart';
import 'package:sports_studio/features/user/controller/profile_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sports_studio/widgets/app_progress_indicator.dart';
import 'package:sports_studio/features/user/presentation/pages/booking_slot_page.dart';
import 'package:sports_studio/widgets/full_screen_image_viewer.dart';

class GroundDetailPage extends StatefulWidget {
  const GroundDetailPage({super.key});

  @override
  State<GroundDetailPage> createState() => _GroundDetailPageState();
}

class _GroundDetailPageState extends State<GroundDetailPage> {
  final controller = Get.put(GroundController());
  final RxInt _currentPage = 0.obs;
  final PageController _pageController = PageController();
  Timer? _carouselTimer;
  final arguments = Get.arguments as Map<String, dynamic>?;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null) {
      if (args is Map<String, dynamic>) {
        final groundData = args['ground'] ?? args;
        if (groundData is Map<String, dynamic>) {
          controller.groundDetails.value = groundData;
          final id = groundData['id'];
          if (id != null) {
            controller.fetchReviews(id is int ? id : int.parse(id.toString()));
          }

          final slug = groundData['slug'];
          if (slug != null) controller.fetchGroundBySlug(slug.toString());
        }
      } else if (args is String) {
        // Assume slug
        controller.fetchGroundBySlug(args);
      }
    }

    _startAutoScroll();
  }

  void _startAutoScroll() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(milliseconds: 3500), (
      timer,
    ) {
      if (controller.groundDetails.isNotEmpty) {
        int next = _currentPage.value + 1;
        final images = UrlHelper.getParsedImages(
          controller.groundDetails['images'],
        );
        if (next >= (images.isEmpty ? 1 : images.length)) {
          next = 0;
        }

        if (_pageController.hasClients) {
          _pageController.animateToPage(
            next,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
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
    return Obx(() {
      final ground = controller.groundDetails;
      if (controller.isLoadingGround.value && ground.isEmpty) {
        return const Scaffold(body: AppProgressIndicator());
      }

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
                        const SizedBox(height: 120),
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
    });
  }

  Widget _buildSliverAppBar(dynamic ground) {
    List<String> images = UrlHelper.getParsedImages(ground?['images']);
    if (images.isEmpty && ground?['image_path'] != null) {
      images.add(ground!['image_path'].toString());
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
              controller: _pageController,
              itemCount: sanitizedImages.length,
              onPageChanged: (index) => _currentPage.value = index,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Get.to(
                    () => FullScreenImageViewer(
                      images: sanitizedImages,
                      initialIndex: index,
                    ),
                  ),
                  child: CachedNetworkImage(
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
                  ),
                );
              },
            ),
            // Page Indicator overlay
            if (sanitizedImages.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    sanitizedImages.length,
                    (index) => Obx(
                      () => Container(
                        width: _currentPage.value == index ? 12 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage.value == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // Gradient Overlay
            const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black26,
                      Colors.transparent,
                      Colors.black54,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(dynamic ground) {
    final name = ground?['name'] ?? '—';
    final type = ground?['type'] ?? '—';
    final complex = ground?['complex'] ?? {};
    final location = ground?['location'] ?? complex['address'] ?? '—';

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
                Text(
                  ground?['avg_rating']?.toString() ?? '0.0',
                  style: AppTextStyles.h3,
                ),
                Text(
                  ' (${ground?['reviews_count'] ?? 0} reviews)',
                  style: AppTextStyles.bodySmall,
                ),
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
    final dimensions = ground?['dimensions']?.toString();
    final areaText = (dimensions != null && dimensions.isNotEmpty)
        ? dimensions
        : (ground?['length'] != null && ground?['width'] != null)
        ? '${ground!['length']}m x ${ground['width']}m'
        : '—';
    final capacity =
        ground?['max_participants'] ??
        ground?['capacity'] ??
        ground?['max_players'];
    final capacityText =
        (capacity != null &&
            capacity.toString().isNotEmpty &&
            capacity.toString() != '0')
        ? '$capacity Players'
        : '—';
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
          _statItem(Icons.aspect_ratio, 'Area', areaText),
          _statItem(Icons.people_outline, 'Capacity', capacityText),
          _statItem(
            Icons.lightbulb_outline,
            'Lights',
            (ground?['has_lighting'] == 1 ||
                    ground?['has_lighting'] == true ||
                    (ground?['amenities']?.toString().toLowerCase().contains(
                          'lighting',
                        ) ??
                        false))
                ? 'Available'
                : 'No',
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
    final dynamic groundAmenitiesRaw = ground?['amenities'] ?? [];

    // Normalize string representation if it's a JSON string
    List<String> amenities = [];
    if (groundAmenitiesRaw is String) {
      try {
        amenities = List<String>.from(jsonDecode(groundAmenitiesRaw));
      } catch (_) {
        amenities = groundAmenitiesRaw
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } else if (groundAmenitiesRaw is List) {
      amenities = groundAmenitiesRaw.map((e) => e.toString()).toList();
    }

    // Standard Mapping from AppConstants
    final Map<String, Map<String, String>> amenityMap = {
      'parking': {
        'name': 'Free Parking',
        'icon': '🚗',
        'asset': 'assets/Icons/FreeParking.png',
      },
      'washrooms': {
        'name': 'Washrooms',
        'icon': '🚻',
        'asset': 'assets/Icons/Washrooms.png',
      },
      'changing-rooms': {
        'name': 'Changing Rooms',
        'icon': '👕',
        'asset': 'assets/Icons/ChangingRooms.png',
      },
      'seating': {
        'name': 'Seating Area',
        'icon': '💺',
        'asset': 'assets/Icons/Seating.png',
      },
      'lighting': {
        'name': 'Floodlights',
        'icon': '💡',
        'asset': 'assets/Icons/Floodlights.png',
      },
      'cafe': {
        'name': 'Cafeteria',
        'icon': '☕',
        'asset': 'assets/Icons/Cafe.png',
      },
      'first-aid': {
        'name': 'First Aid',
        'icon': '🏥',
        'asset': 'assets/Icons/FirstAid.png',
      },
      'wifi': {
        'name': 'Free WiFi',
        'icon': '📶',
        'asset': 'assets/Icons/FreeWiFi.png',
      },
      'lockers': {
        'name': 'Lockers',
        'icon': '🔐',
        'asset': 'assets/Icons/Lockers.png',
      },
      'equipment': {
        'name': 'Equipment',
        'icon': '🎯',
        'asset': 'assets/Icons/Equipment.png',
      },

      // Legacy/Alternate support
      'washroom': {
        'name': 'Washrooms',
        'icon': '🚻',
        'asset': 'assets/Icons/Washrooms.png',
      },
      'changing': {
        'name': 'Changing Rooms',
        'icon': '👕',
        'asset': 'assets/Icons/ChangingRooms.png',
      },
      'first_aid': {
        'name': 'First Aid',
        'icon': '🏥',
        'asset': 'assets/Icons/FirstAid.png',
      },
      'Lighting': {
        'name': 'Floodlights',
        'icon': '💡',
        'asset': 'assets/Icons/Floodlights.png',
      },
      'Floodlights': {
        'name': 'Floodlights',
        'icon': '💡',
        'asset': 'assets/Icons/Floodlights.png',
      },
      'Wifi': {
        'name': 'Free WiFi',
        'icon': '📶',
        'asset': 'assets/Icons/FreeWiFi.png',
      },
      'Parking': {
        'name': 'Free Parking',
        'icon': '🚗',
        'asset': 'assets/Icons/FreeParking.png',
      },
    };

    if (amenities.isEmpty) {
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
          children: amenities.map((id) {
            final data = amenityMap[id] ?? {'name': id, 'icon': '✨'};
            return _amenityChip(
              data['icon']!,
              data['name']!,
              assetPath: data['asset'],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _amenityChip(String icon, String label, {String? assetPath}) {
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
          if (assetPath != null)
            Image.asset(assetPath, width: 18, height: 18, fit: BoxFit.contain)
          else
            Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
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
          (ground?['description'] ?? '').toString().isNotEmpty
              ? (ground!['description'] ?? '').toString()
              : 'No description provided.',
          style: AppTextStyles.bodyMedium.copyWith(
            height: 1.6,
            color: Colors.grey[700],
          ),
        ),
        if (ground?['rules'] != null &&
            ground!['rules'].toString().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.l),
          Text('Ground Rules', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.s),
          Text(
            ground!['rules'].toString(),
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
        if (ground?['cancellation_policy'] != null &&
            ground!['cancellation_policy'].toString().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.l),
          Text('Cancellation Policy', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.s),
          Text(
            ground!['cancellation_policy'].toString(),
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationMap(dynamic ground) {
    final complex = ground?['complex'] ?? {};
    final lat = double.tryParse(complex['latitude']?.toString() ?? '');
    final lng = double.tryParse(complex['longitude']?.toString() ?? '');
    final hasValidCoords = lat != null && lng != null && lat != 0 && lng != 0;

    if (!hasValidCoords) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Location', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.m),
          Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_off_outlined,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    complex['address']?.toString() ?? 'Location not set',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

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
            if (!_isOwnerOfGround(ground))
              TextButton.icon(
                onPressed: () => _showReviewSheet(ground),
                icon: const Icon(Icons.rate_review_outlined, size: 18),
                label: const Text('Write a Review'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
        Obx(
          () => Text(
            '${controller.reviews.length} total',
            style: AppTextStyles.bodySmall,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Obx(() {
          if (controller.isLoadingReviews.value) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: AppProgressIndicator(strokeWidth: 2),
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
              final name = r.userName ?? r.user?.name ?? 'User';
              final comment = r.comment ?? '';
              return _reviewCard(
                name,
                r.rating.toString(),
                comment,
                r.createdAt,
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  String _formatTimeAgo(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  Widget _reviewCard(
    String name,
    String rating,
    String text,
    DateTime? createdAt,
  ) {
    final displayName = name.isNotEmpty ? name : 'User';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: Text(initial),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _starRating(rating),
                  ],
                ),
              ),
              Text(
                _formatTimeAgo(createdAt),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (text.isNotEmpty)
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
          color: index < (double.tryParse(r) ?? 0.0)
              ? Colors.amber
              : Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildBottomBar(dynamic ground) {
    final price = ground?['price_per_hour'] ?? '0';
    final isOwner = _isOwnerOfGround(ground);

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
                  isOwner ? 'Your Pricing' : 'Total Price',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  '${AppConstants.currencySymbol} $price/hr',
                  style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(width: 32),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (isOwner) {
                      Get.toNamed(
                        '/add-ground',
                        arguments: {
                          'isEdit': true,
                          'ground': ground,
                          'complexId': ground['complex_id'],
                          'complexName': ground['complex']?['name'] ?? '',
                        },
                      );
                    } else {
                      Get.to(() => const BookingSlotPage(), arguments: ground);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                  ),
                  child: Text(
                    isOwner ? 'Edit Ground' : 'Book Now',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewSheet(dynamic ground) {
    final commentCtrl = TextEditingController();
    final RxDouble rating = 5.0.obs;
    final groundId = int.tryParse(ground['id'].toString()) ?? 0;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rate your Experience', style: AppTextStyles.h2),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              Center(
                child: Column(
                  children: [
                    Obx(
                      () => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          final starRating = index + 1.0;
                          return IconButton(
                            onPressed: () => rating.value = starRating,
                            icon: Icon(
                              starRating <= rating.value
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 42,
                              color: Colors.amber,
                            ),
                          );
                        }),
                      ),
                    ),
                    Obx(
                      () => Text(
                        '${rating.value.toInt()} stars',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              Text('Your Review', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.s),
              TextField(
                controller: commentCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tell others about the field, lighting, etc...',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    if (commentCtrl.text.trim().isEmpty) {
                      AppUtils.showWarning(message: 'Please enter a comment');
                      return;
                    }
                    await controller.submitReview(
                      groundId: groundId,
                      rating: rating.value,
                      comment: commentCtrl.text.trim(),
                    );
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Submit Review',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  bool _isOwnerOfGround(dynamic ground) {
    try {
      if (ground == null) return false;
      final profileCtrl = Get.find<ProfileController>();
      final myId = profileCtrl.userProfile['id'];
      final ownerId = ground['user_id'] ?? ground['owner_id'];
      if (myId == null || ownerId == null) return false;
      return myId.toString() == ownerId.toString();
    } catch (_) {
      return false;
    }
  }
}

class _FavoriteButtonDetail extends StatelessWidget {
  final dynamic ground;
  const _FavoriteButtonDetail({required this.ground});

  bool _isMyGround() {
    try {
      if (ground == null) return false;
      final profileCtrl = Get.find<ProfileController>();
      final myId = profileCtrl.userProfile['id']?.toString();
      if (myId == null) return false;

      // List of possible fields for ground owner ID
      final List<dynamic> possibleOwnerIds = [
        ground['user_id'],
        ground['owner_id'],
        ground['complex']?['owner_id'],
        ground['complex']?['user_id'],
        ground['complex']?['owner']?['id'],
      ];

      return possibleOwnerIds.any((id) => id != null && id.toString() == myId);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ground == null) return const SizedBox.shrink();

    return Obx(() {
      if (_isMyGround()) {
        return CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.3),
          child: IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => Get.toNamed(
              '/add-ground',
              arguments: {
                'isEdit': true,
                'ground': ground,
                'complexId': ground['complex_id'],
                'complexName': ground['complex']?['name'] ?? '',
              },
            ),
          ),
        );
      }

      final controller = Get.put(FavoritesController()); // Ensure it exists
      final id = int.tryParse(ground['id'].toString()) ?? 0;
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
