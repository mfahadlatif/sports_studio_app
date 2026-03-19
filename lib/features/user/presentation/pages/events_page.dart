import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/widgets/app_shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/user/controller/events_controller.dart';
import 'package:sports_studio/core/utils/url_helper.dart';
import 'package:sports_studio/core/models/models.dart';
import 'package:intl/intl.dart';
import 'package:sports_studio/features/user/presentation/pages/create_match_page.dart';
import 'package:sports_studio/features/user/presentation/pages/event_detail_page.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventsController());

    return Scaffold(
      appBar: AppBar(title: const Text('All Events'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.to(() => const CreateMatchPage());
          if (result == true) {
            controller.fetchPublicEvents();
          }
        },
        label: const Text('Organize Match'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Obx(() {
            if (controller.isLoadingEvents.value) {
              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.m),
                itemCount: 4,
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.m),
                  child:
                      AppShimmer.groundCard(), // using groundCard as it matches event card layout
                ),
              );
            }

            if (controller.events.isEmpty) {
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
              itemCount: controller.events.length,
              itemBuilder: (context, index) {
                final event = controller.events[index];
                return _buildEventCard(event);
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    final title = event.name;
    final date = DateFormat('MMM dd, yyyy • hh:mm a').format(event.startTime);
    final location = event.location ?? '—';

    // Get images - checking the 'images' property of the model
    final imageUrl = UrlHelper.getFirstImage(
      event.images,
      fallbackPath: event.image,
    );

    return GestureDetector(
      onTap: () =>
          Get.to(() => const EventDetailPage(), arguments: event),
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
                tag: 'event_image_${event.id}',
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(date, style: AppTextStyles.bodySmall),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${event.playersLeft} left',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: event.playersLeft == 0
                                  ? Colors.red
                                  : AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
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
