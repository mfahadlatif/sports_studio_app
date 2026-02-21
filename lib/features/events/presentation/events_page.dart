import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/events/controller/events_controller.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventsController());

    return Scaffold(
      appBar: AppBar(title: const Text('All Events'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.eventsList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 64,
                      color: AppColors.textMuted.withOpacity(0.5),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    const Text(
                      'No events available at the moment.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.m),
              itemCount: controller.eventsList.length,
              itemBuilder: (context, index) {
                final event = controller.eventsList[index];
                return _buildEventCard(event);
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEventCard(dynamic event) {
    final title = event['title'] ?? 'Sports Event';
    final date = event['date'] ?? 'Upcoming';
    final location = event['location'] ?? 'Stadium';

    String imageUrl =
        'https://images.unsplash.com/photo-1543326727-cf6c39e8f84c?q=80&w=800';
    if (event['images'] != null && (event['images'] as List).isNotEmpty) {
      imageUrl = event['images'][0];
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
      onTap: () => Get.toNamed('/event-detail', arguments: event),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.m),
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
              child: Hero(
                tag: 'event_image_${event['id'] ?? ''}',
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    height: 160,
                    width: double.infinity,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.s),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(date, style: AppTextStyles.bodySmall),
                      const SizedBox(width: AppSpacing.m),
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
