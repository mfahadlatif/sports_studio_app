import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_studio/widgets/app_shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/constants/app_constants.dart';
import 'package:sport_studio/features/user/controller/events_controller.dart';
import 'package:sport_studio/core/utils/url_helper.dart';
import 'package:sport_studio/core/models/models.dart';
import 'package:sport_studio/core/utils/app_utils.dart';
import 'package:sport_studio/features/user/presentation/pages/create_match_page.dart';
import 'package:sport_studio/features/user/presentation/pages/event_detail_page.dart';
import 'package:sport_studio/features/user/controller/profile_controller.dart';

class EventsPage extends StatelessWidget {
  final bool isTab;
  const EventsPage({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventsController());
    
    // Ensure events are fetched when first coming to the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.events.isEmpty && !controller.isLoadingPublicEvents.value) {
        controller.fetchPublicEvents();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Events'),
        centerTitle: true,
        automaticallyImplyLeading: !isTab,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final profileController = Get.find<ProfileController>();
          if (!profileController.isPhoneVerified) {
            AppUtils.showPhoneVerificationRequiredDialog(
              title: 'Phone Verification Required',
              message: 'To organize a match, your phone number must be verified for safety and coordination.',
            );
            return;
          }
          final result = await Get.to(() => const CreateMatchPage());
          if (result == true) {
            controller.fetchPublicEvents();
          }
        },
        label: const Text('Organize Match'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchPublicEvents(),
        color: AppColors.primary,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Obx(() {
              if (controller.isLoadingPublicEvents.value) {
                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.m),
                  itemCount: 4,
                  itemBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.m),
                    child:
                        AppShimmer.groundCard(), // using groundCard as it matches event card layout
                  ),
                );
              }

              if (controller.filteredEvents.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: AppColors.textMuted.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: AppSpacing.m),
                          const Text(
                            'No events available at the moment.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.m),
                itemCount: controller.filteredEvents.length,
                itemBuilder: (context, index) {
                  final event = controller.filteredEvents[index];
                  return _buildEventCard(event);
                },
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    final title = event.name;
    final date = AppUtils.formatDateTime(event.startTime);
    final location = event.booking?.ground?.complex?.address ?? 
                     event.booking?.ground?.complex?.name ?? 
                     event.location ?? '—';

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
              color: Colors.black.withValues(alpha: 0.05),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.h3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(event.status),
                    ],
                  ),
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

  Widget _buildStatusBadge(String statusStr) {
    final status = statusStr.toLowerCase();
    
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
