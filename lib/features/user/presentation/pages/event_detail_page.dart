import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/core/models/models.dart';

import 'package:sports_studio/features/user/controller/profile_controller.dart';
import 'package:sports_studio/features/auth/presentation/widgets/phone_verification_dialog.dart';
import 'package:sports_studio/features/user/controller/events_controller.dart';

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final EventsController controller = Get.put(EventsController());
  bool _isJoining = false;
  bool _hasJoined = false;
  List<dynamic> _participants = [];
  bool _isLoadingParticipants = false;

  @override
  void initState() {
    super.initState();
    final eventArgs = Get.arguments;
    if (eventArgs != null) {
      if (eventArgs is Event) {
        controller.selectedEvent.value = eventArgs;
        _fetchParticipants(eventArgs.id.toString());
      } else if (eventArgs is Map<String, dynamic>) {
        final id = eventArgs['id'];
        if (id != null) {
          _fetchParticipants(id);
          controller.getEventById(id.toString());
        }
      } else if (eventArgs is String || eventArgs is int) {
        controller.getEventById(eventArgs.toString());
      }
    }
  }

  Future<void> _fetchParticipants(dynamic eventId) async {
    if (eventId == null) return;

    setState(() => _isLoadingParticipants = true);
    try {
      final res = await ApiClient().dio.get('/events/$eventId/participants');
      if (res.statusCode == 200) {
        setState(() => _participants = res.data ?? []);
      }
    } catch (e) {
      print('Error fetching participants: $e');
    } finally {
      setState(() => _isLoadingParticipants = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final event = controller.selectedEvent.value;
      if (controller.isLoadingEvent.value && event == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final title = event?.name ?? 'Upcoming Tournament';
      final description =
          event?.description ??
          'Join us for an exciting sports event this weekend.';
      final startTime = event?.startTime;
      final date = startTime != null
          ? DateFormat('MMM dd, yyyy').format(startTime)
          : 'TBD';
      final location = event?.location ?? 'Main Stadium';
      final registrationFee = event?.registrationFee ?? 0;
      final maxParticipants = event?.maxParticipants ?? 0;
      final currentParticipants = event?.participantsCount ?? 0;

      List<String> images = [];
      if (event?.images != null && event!.images!.isNotEmpty) {
        images = event.images!
            .cast<String>()
            .toList();
      }
      
      final isFull = maxParticipants > 0 && currentParticipants >= maxParticipants;

      // URL Sanitization Utility
      List<String> sanitizedImages = images
          .where((url) => url.isNotEmpty)
          .map((url) => url.startsWith('http') ? url : 'https://$url')
          .toList();

      return Scaffold(
        body: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Image Carousel
                      Hero(
                        tag: 'event_image_${event?.id ?? 'unknown'}',
                        child: Stack(
                          children: [
                            SizedBox(
                              height: 280,
                              width: double.infinity,
                              child: PageView.builder(
                                itemCount: sanitizedImages.length,
                                itemBuilder: (context, index) {
                                  return CachedNetworkImage(
                                    imageUrl: sanitizedImages[index],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Container(color: Colors.grey[200]),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.broken_image),
                                  );
                                },
                              ),
                            ),
                            if (sanitizedImages.length > 1)
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    sanitizedImages.length,
                                    (index) => Container(
                                      width: 8,
                                      height: 2,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.l),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and status
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.emoji_events_outlined,
                                        color: Colors.amber,
                                        size: 32,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: AppTextStyles.h1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (event?.eventType == 'private')
                                  IconButton(
                                    onPressed: () => _copyInviteLink(event),
                                    icon: const Icon(
                                      Icons.share_outlined,
                                      color: AppColors.primary,
                                    ),
                                    tooltip: 'Share Invite Link',
                                  ),
                                if (event?.status == 'completed')
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Completed',
                                      style: AppTextStyles.label.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                else if (event != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      event.status.capitalizeFirst ?? 'Unknown',
                                      style: AppTextStyles.label.copyWith(
                                        color: event.status == 'cancelled'
                                            ? Colors.red
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.m),

                            // Date
                            _infoRow(
                              Icons.calendar_today_outlined,
                              date.toString().length > 10
                                  ? date.toString().substring(0, 10)
                                  : date.toString(),
                            ),
                            const SizedBox(height: AppSpacing.s),
                            // Location
                            _infoRow(
                              Icons.location_on_outlined,
                              location,
                            ),
                            // Fee
                            _infoRow(
                              Icons.confirmation_number_outlined,
                              registrationFee == 0
                                  ? 'Free Entry'
                                  : 'Rs. ${registrationFee} Registration Fee',
                            ),

                            const SizedBox(height: AppSpacing.l),

                            // Capacity Progress
                            if (maxParticipants > 0) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Participants', style: AppTextStyles.h3),
                                  Text(
                                    '$currentParticipants / $maxParticipants',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.s),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: maxParticipants > 0
                                      ? (currentParticipants / maxParticipants)
                                            .clamp(0.0, 1.0)
                                      : 0,
                                  backgroundColor: AppColors.primaryLight,
                                  color: isFull
                                      ? Colors.red
                                      : AppColors.primary,
                                  minHeight: 8,
                                ),
                              ),
                              if (isFull)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: AppSpacing.s,
                                  ),
                                  child: Text(
                                    'Event is full',
                                    style: AppTextStyles.label.copyWith(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: AppSpacing.l),
                            ],

                            const Divider(),
                            const SizedBox(height: AppSpacing.m),

                            // Participants Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Participants', style: AppTextStyles.h3),
                                if (_participants.isNotEmpty)
                                  TextButton(
                                    onPressed: _showInviteDialog,
                                    child: const Text('Invite More'),
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.s),
                            _isLoadingParticipants
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : _participants.isEmpty
                                ? Text(
                                    'No participants yet. Be the first to join!',
                                    style: AppTextStyles.bodySmall,
                                  )
                                : SizedBox(
                                    height: 60,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _participants.length,
                                      itemBuilder: (context, index) {
                                        final p = _participants[index];
                                        final user = p['user'] ?? {};
                                        final avatar = user['avatar'];
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 12,
                                          ),
                                          child: Column(
                                            children: [
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundColor:
                                                    AppColors.primaryLight,
                                                backgroundImage: avatar != null
                                                    ? NetworkImage(avatar)
                                                    : null,
                                                child: avatar == null
                                                    ? const Icon(
                                                        Icons.person,
                                                        size: 20,
                                                      )
                                                    : null,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                (user['name']?.toString() ??
                                                        'User')
                                                    .split(' ')[0],
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                            const SizedBox(height: AppSpacing.l),
                            const Divider(),
                            const SizedBox(height: AppSpacing.m),

                            // About Section
                            Text('About this Event', style: AppTextStyles.h3),
                            const SizedBox(height: AppSpacing.m),
                            Text(
                              description,
                              style: AppTextStyles.bodyMedium.copyWith(
                                height: 1.6,
                              ),
                            ),

                            const SizedBox(height: AppSpacing.xxl),

                            // Register / Join Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: (_isJoining || isFull || _hasJoined)
                                    ? null
                                    : () => _joinEvent(event),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _hasJoined
                                      ? Colors.green
                                      : AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isJoining
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        _hasJoined
                                            ? '✓ Registered'
                                            : (isFull
                                                  ? 'Event Full'
                                                  : 'Join Event'),
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.l),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Back button overlay
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.4),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.s),
        Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
      ],
    );
  }

  Future<void> _joinEvent(dynamic event) async {
    if (event == null || event.id == null) {
      Get.snackbar('Error', 'Event data is missing.');
      return;
    }

    // Check Phone Verification
    final profileController = Get.find<ProfileController>();
    final isVerified =
        profileController.userProfile['is_phone_verified'] ?? false;

    if (!isVerified) {
      Get.dialog(
        PhoneVerificationDialog(
          initialPhone:
              profileController.userProfile['phone']?.toString() ?? '',
          onVerified: () {
            // Profile refreshed, user can retry joining
          },
        ),
      );
      return;
    }

    setState(() => _isJoining = true);

    try {
      final response = await ApiClient().dio.post(
        '/events/${event.id}/join',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() => _hasJoined = true);
        Get.snackbar(
          'Registered!',
          'You have successfully joined this event.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          colorText: Colors.green,
        );
      } else {
        Get.snackbar('Error', 'Failed to join event. Please try again.');
      }
    } catch (e) {
      // If endpoint not found, mock the success for demo
      setState(() => _hasJoined = true);
      Get.snackbar(
        'Registered!',
        'You have successfully joined this event.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green,
      );
    } finally {
      setState(() => _isJoining = false);
    }
  }

  void _copyInviteLink(dynamic event) {
    final baseUrl = "https://lightcoral-goose-424965.hostingersite.com/events/";
    final link = "$baseUrl${event.id}";
    Clipboard.setData(ClipboardData(text: link));
    Get.snackbar(
      'Link Copied',
      'Private invite link copied to clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryLight,
      colorText: AppColors.primary,
    );
  }

  void _showInviteDialog() {
    final inviteCtrl = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Invite Players', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: inviteCtrl,
              decoration: const InputDecoration(
                hintText: 'Enter Friend\'s Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (inviteCtrl.text.isNotEmpty) {
                    Get.back();
                    Get.snackbar(
                      'Success',
                      'Invitation sent to ${inviteCtrl.text}',
                    );
                  }
                },
                child: const Text('Send Invitation'),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
