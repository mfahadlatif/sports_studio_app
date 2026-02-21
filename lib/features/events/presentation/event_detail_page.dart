import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final event = Get.arguments;
    final title = event?['title'] ?? 'Upcoming Tournament';
    final description =
        event?['description'] ??
        'Join us for an exciting sports event this weekend.';
    final date = event?['date'] ?? 'Jan 15, 2027';
    final location = event?['location'] ?? 'Main Stadium';

    String imageUrl =
        'https://images.unsplash.com/photo-1543326727-cf6c39e8f84c?q=80&w=800';
    if (event != null &&
        event['images'] != null &&
        (event['images'] as List).isNotEmpty) {
      imageUrl = event['images'][0];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details', style: AppTextStyles.h3),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'event_image_${event?['id'] ?? ''}',
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.h1),
                      const SizedBox(height: AppSpacing.m),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.s),
                          Text(date, style: AppTextStyles.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.s),
                          Text(location, style: AppTextStyles.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text('About this Event', style: AppTextStyles.h3),
                      const SizedBox(height: AppSpacing.m),
                      Text(description, style: AppTextStyles.bodyMedium),
                      const SizedBox(height: AppSpacing.xxl),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Register Now'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
