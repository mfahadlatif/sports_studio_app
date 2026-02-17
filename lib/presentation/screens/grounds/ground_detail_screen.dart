import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sports_studio/data/models/ground_model.dart';
import 'package:sports_studio/domain/providers/ground_provider.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/presentation/widgets/primary_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sports_studio/presentation/screens/bookings/create_booking_screen.dart';
import 'package:sports_studio/presentation/widgets/review_item.dart';
import 'package:sports_studio/presentation/screens/grounds/add_review_screen.dart';
import 'package:sports_studio/presentation/widgets/map_preview.dart';

class GroundDetailScreen extends StatefulWidget {
  final Ground ground;

  const GroundDetailScreen({super.key, required this.ground});

  @override
  State<GroundDetailScreen> createState() => _GroundDetailScreenState();
}

class _GroundDetailScreenState extends State<GroundDetailScreen> {
  // In a real app we might fetch more details (like reviews, available slots) using provider
  // For now we use the passed ground object.

  @override
  void initState() {
    super.initState();
    // Optional: Fetch full details if only partial data passed
    // context.read<GroundProvider>().fetchGroundBySlug(widget.ground.slug);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.ground.mainImage != null
                  ? CachedNetworkImage(
                      imageUrl: widget.ground.mainImage!,
                      fit: BoxFit.cover,
                    )
                  : Container(color: AppColors.surface),
              title: Text(
                widget.ground.name,
                style: AppTextStyles.heading2.copyWith(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(0, 1),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.ground.locationString,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Price
                    Row(
                      children: [
                        Text(
                          widget.ground.priceDisplay,
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'per hour', // Simplified
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Amenities
                    if (widget.ground.amenities.isNotEmpty) ...[
                      Text('Amenities', style: AppTextStyles.heading3),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: widget.ground.amenities.map((amenity) {
                          return _buildAmenityChip(amenity);
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Description (Backend data or simplified placeholder)
                    if (widget.ground.slug.isNotEmpty) ...[
                      Text('About Venue', style: AppTextStyles.heading3),
                      const SizedBox(height: 12),
                      Text(
                        'Experience top-tier sports facilities at ${widget.ground.name}. Perfect for tournaments, practice, and casual games. Book your slot now!',
                        style: AppTextStyles.bodyLarge.copyWith(
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Map Section
                    Text('Location', style: AppTextStyles.heading3),
                    const SizedBox(height: 12),
                    MapPreview(
                      latitude: widget.ground.latitude,
                      longitude: widget.ground.longitude,
                      title: widget.ground.name,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Reviews (4.5)', style: AppTextStyles.heading3),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddReviewScreen(groundId: widget.ground.id),
                              ),
                            );
                          },
                          child: const Text(
                            'Write Review',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Mock Reviews
                    const ReviewItem(
                      author: 'John Doe',
                      rating: 5,
                      comment: 'Great ground! Clean and well maintained.',
                      date: '2 days ago',
                    ),
                    const ReviewItem(
                      author: 'Jane Smith',
                      rating: 4,
                      comment: 'Good lighting but turf needs work.',
                      date: '1 week ago',
                    ),

                    const SizedBox(height: 100), // Bottom padding
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.glassBorder)),
        ),
        child: SafeArea(
          child: PrimaryButton(
            text: 'Book Now',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateBookingScreen(ground: widget.ground),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAmenityChip(String amenity) {
    IconData icon;
    switch (amenity.toLowerCase()) {
      case 'parking':
        icon = Icons.local_parking_rounded;
        break;
      case 'washroom':
        icon = Icons.wc_rounded;
        break;
      case 'canteen':
        icon = Icons.restaurant_rounded;
        break;
      case 'first aid':
        icon = Icons.medical_services_rounded;
        break;
      case 'locker':
        icon = Icons.lock_rounded;
        break;
      default:
        icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Text(
            amenity,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
