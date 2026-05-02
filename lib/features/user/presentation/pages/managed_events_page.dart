import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sport_studio/core/controllers/system_settings_controller.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/constants/app_constants.dart';
import 'package:sport_studio/features/user/controller/events_controller.dart';
import 'package:sport_studio/widgets/app_progress_indicator.dart';
import 'package:sport_studio/core/models/models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sport_studio/core/utils/url_helper.dart';
import 'package:sport_studio/features/user/presentation/pages/create_match_page.dart';
import 'package:sport_studio/features/user/presentation/pages/event_detail_page.dart';

class ManagedEventsPage extends StatelessWidget {
  const ManagedEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventsController());

    // Fetch user events when the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchUserEvents();
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('My Managed Events'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Obx(() {
            if (controller.isLoadingUserEvents.value) {
              return const Center(child: AppProgressIndicator());
            }

            if (controller.userEvents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy_outlined,
                      size: 80,
                      color: AppColors.textMuted.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'No events organized yet',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      'Organize your first match to see it here!',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Get.to(
                          () => const CreateMatchPage(),
                        );
                        if (result == true) {
                          controller.fetchUserEvents();
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Organize Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.m),
              itemCount: controller.userEvents.length,
              itemBuilder: (context, index) {
                final event = controller.userEvents[index];
                return _buildEventCard(context, event, controller);
              },
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.to(() => const CreateMatchPage());
          if (result == true) {
            controller.fetchUserEvents();
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Organize Event',
          style: TextStyle(color: Colors.white),
        ),
        heroTag: 'managed_events_fab',
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    Event event,
    EventsController controller,
  ) {
    String? rawImage;
    if (event.images.isNotEmpty) {
      rawImage = event.images.first;
    } else {
      rawImage = event.image;
    }
    final imageUrl = UrlHelper.sanitizeUrl(rawImage);
    final dateStr = DateFormat('EEE, MMM dd').format(event.startTime);
    final timeStr = DateFormat('hh:mm a').format(event.startTime);

    return InkWell(
      onTap: () => Get.to(() => const EventDetailPage(), arguments: event),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.m),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[100],
                      child: const Center(child: AppProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_outlined, size: 40),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            event.name,
                            style: AppTextStyles.h3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditEventDialog(context, event, controller);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit Event'),
                                ],
                              ),
                            ),
                            // Delete option removed for organizers - restricted to Admin only
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _infoChip(Icons.calendar_month_outlined, dateStr),
                        const SizedBox(width: 16),
                        _infoChip(Icons.schedule_outlined, timeStr),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location ?? 'Location TBD',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.people_outline,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${event.participantsCount ?? 0} Players',
                                  style: AppTextStyles.label.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${event.playersLeft} Slots Left',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: event.playersLeft == 0
                                        ? Colors.red
                                        : AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          event.registrationFee == 0
                              ? 'FREE'
                              : '${AppConstants.currencySymbol} ${event.registrationFee}',
                          style: AppTextStyles.h3.copyWith(
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
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showEditEventDialog(
    BuildContext context,
    Event event,
    EventsController controller,
  ) {
    // We can reuse the CreateMatchPage logic but in "Edit Mode"
    // For simplicity, we'll just navigate to a modified version or use the current controller
    controller.populateEventForm(event);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Edit Event', style: AppTextStyles.h2),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              _buildField('Event Name', controller.eventNameController),
              const SizedBox(height: AppSpacing.m),
              _buildField(
                'Description',
                controller.eventDescriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      'Player Limit',
                      controller.eventMaxParticipantsController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Fee',
                              style: AppTextStyles.label.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Obx(() {
                              final settings =
                                  Get.find<SystemSettingsController>();
                              return Text(
                                '${settings.eventCommissionRate.toStringAsFixed(0)}% comm.',
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller.eventRegistrationFeeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              _buildField(
                'Rules',
                controller.eventRulesController,
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.m),
              _buildField(
                'Safety Policy',
                controller.eventSafetyPolicyController,
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.m),
              const Text(
                'Date & Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: controller.eventStartDate.value,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 90),
                          ),
                        );
                        if (picked != null)
                          controller.eventStartDate.value = picked;
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Obx(
                        () => Text(
                          DateFormat(
                            'MMM dd',
                          ).format(controller.eventStartDate.value),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                            controller.eventStartDate.value,
                          ),
                          builder: (context, child) {
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          final current = controller.eventStartDate.value;
                          controller.eventStartDate.value = DateTime(
                            current.year,
                            current.month,
                            current.day,
                            picked.hour,
                            picked.minute,
                          );
                        }
                      },
                      icon: const Icon(Icons.access_time, size: 16),
                      label: Obx(
                        () => Text(
                          DateFormat(
                            'hh:mm a',
                          ).format(controller.eventStartDate.value),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isCreatingEvent.value
                        ? null
                        : () => controller.updateEvent(
                            event.id,
                            event.slug ?? '',
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isCreatingEvent.value
                        ? const AppProgressIndicator(
                            color: Colors.white,
                            size: 20,
                          )
                        : const Text(
                            'Update Event',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
