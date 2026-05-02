import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_studio/widgets/app_shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/constants/app_constants.dart';
import 'package:sport_studio/widgets/section_header.dart';
import 'package:sport_studio/features/user/controller/home_controller.dart';
import 'package:sport_studio/features/landing/controller/landing_controller.dart'
    as sports_landing;
import 'package:sport_studio/core/utils/url_helper.dart';
import 'package:sport_studio/features/user/presentation/pages/event_detail_page.dart';
import 'package:intl/intl.dart';

class EventsPreviewSection extends StatelessWidget {
  const EventsPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Column(
      children: [
        SectionHeader(
          title: 'Upcoming Events',
          subtitle: 'Join matches being hosted near you',
          onActionPressed: () {
            final landingController =
                Get.find<sports_landing.LandingController>();
            landingController.changeNavIndex(2); // switch to Events Tab
          },
        ),
        SizedBox(
          height: 330,
          child: Obx(() {
            if (controller.isLoadingEvents.value) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (_, __) =>
                    AppShimmer.groundCard(), // Reuse ground shimmer
              );
            }

            if (controller.filteredEvents.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy_outlined,
                        size: 48,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No upcoming events found for this filter.',
                        style: TextStyle(color: Colors.grey),
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
              itemCount: controller.filteredEvents.length,
              itemBuilder: (context, index) {
                final event = controller.filteredEvents[index];
                return EventPreviewCard(event: event);
              },
            );
          }),
        ),
      ],
    );
  }
}

class EventPreviewCard extends StatelessWidget {
  final dynamic event;

  const EventPreviewCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final name = event['name'] ?? 'Tournament Match';

    final dynamic rawFee = event['registration_fee'];
    final num fee = (rawFee is num)
        ? rawFee
        : (double.tryParse(rawFee?.toString() ?? '0') ?? 0);

    final isVip =
        event['is_vip'] == 1 ||
        event['is_vip'] == true ||
        event['is_vip']?.toString().toLowerCase() == 'true';
    final location = event['location'] ?? 'Venue —';
    final startTime = event['start_time'];

    DateTime? eventDate;
    String formattedDate = 'Set Date —';
    String day = '??';
    String month = 'MMM';

    if (startTime != null) {
      try {
        eventDate = DateTime.parse(startTime.toString());
        formattedDate = DateFormat('EEE, MMM d • h:mm a').format(eventDate);
        day = DateFormat('dd').format(eventDate);
        month = DateFormat('MMM').format(eventDate).toUpperCase();
      } catch (_) {}
    }

    final imageUrl = UrlHelper.getFirstImage(
      event['images'],
      fallbackPath: event['image_path'] ?? event['image'],
    );

    return GestureDetector(
      onTap: () => Get.to(() => const EventDetailPage(), arguments: event),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(
          right: AppSpacing.m,
          bottom: AppSpacing.m,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Overlays
            Stack(
              children: [
                Hero(
                  tag: 'event_img_${event['id']}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[100],
                        height: 160,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        height: 160,
                        child: const Icon(
                          Icons.sports_soccer,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ),
                // Glassmorphic Date Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              day,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                height: 1,
                              ),
                            ),
                            Text(
                              month,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // VIP Badge
                if (isVip)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.stars, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'PREMIUM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Details Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: AppTextStyles.h3.copyWith(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(event['status']?.toString()),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: AppColors.primary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Entry Fee',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            fee > 0
                                ? '${AppConstants.currencySymbol}${fee.toStringAsFixed(0)}'
                                : 'FREE',
                            style: TextStyle(
                              color: fee > 0 ? AppColors.accent : Colors.green,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.primary,
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

  Widget _buildStatusBadge(String? statusStr) {
    final status = (statusStr ?? 'upcoming').toLowerCase();
    
    Color bgColor;
    String label = status.toUpperCase();

    if (status == 'published' || status == 'upcoming') {
      bgColor = Colors.blue;
      label = 'UPCOMING';
    } else if (status == 'completed') {
      bgColor = Colors.green;
    } else if (status == 'cancelled') {
      bgColor = Colors.red;
    } else if (status == 'ongoing') {
      bgColor = Colors.orange;
    } else {
      bgColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: bgColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: bgColor,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
