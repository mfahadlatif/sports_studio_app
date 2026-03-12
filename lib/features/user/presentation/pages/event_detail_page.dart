import 'dart:async';
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
import 'package:sports_studio/widgets/app_progress_indicator.dart';
import 'package:sports_studio/core/utils/url_helper.dart';

import 'package:sports_studio/features/user/controller/profile_controller.dart';
import 'package:sports_studio/features/auth/presentation/widgets/phone_verification_dialog.dart';
import 'package:sports_studio/features/user/controller/events_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final RxInt _currentPage = 0.obs;
  final PageController _pageController = PageController();
  Timer? _carouselTimer;

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
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(milliseconds: 4000), (timer) {
      if (controller.selectedEvent.value != null) {
        final event = controller.selectedEvent.value!;
        List<String> images = event.images;
        if (images.isEmpty && event.image != null) images = [event.image!];
        
        if (images.length > 1) {
          int next = _currentPage.value + 1;
          if (next >= images.length) next = 0;
          
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              next,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
          }
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
      final event = controller.selectedEvent.value;
      if (controller.isLoadingEvent.value && event == null) {
        return const Scaffold(body: AppProgressIndicator());
      }

      final title = event?.name ?? 'Upcoming Tournament';
      final description =
          event?.description ??
          'Join us for an exciting sports event this weekend.';
      final startTime = event?.startTime;
      final date = startTime != null
          ? DateFormat('MMM dd, yyyy').format(startTime)
          : 'TBD';
      final location = event?.location ?? '—';
      final registrationFee = event?.registrationFee ?? 0;
      final maxParticipants = event?.maxParticipants ?? 0;
      final currentParticipants = event?.participantsCount ?? 0;

      List<String> images = [];
      if (event != null) {
        if (event.images.isNotEmpty) {
          images = event.images;
        } else if (event.image != null) {
          images = [event.image!];
        }
      }

      final isFull =
          maxParticipants > 0 && currentParticipants >= maxParticipants;

      // URL Sanitization Utility
      List<String> sanitizedImages = images
          .where((url) => url.isNotEmpty)
          .map((url) => UrlHelper.sanitizeUrl(url))
          .toList();

      final profileController = Get.find<ProfileController>();

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
                                controller: _pageController,
                                itemCount: sanitizedImages.length,
                                onPageChanged: (index) => _currentPage.value = index,
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
                                    (index) => Obx(() => Container(
                                      width: _currentPage.value == index ? 16 : 8,
                                      height: 4,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _currentPage.value == index 
                                          ? Colors.white 
                                          : Colors.white.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 2,
                                          )
                                        ]
                                      ),
                                    )),
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
                            _infoRow(Icons.location_on_outlined, location),
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
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '$currentParticipants / $maxParticipants',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${event?.playersLeft} left',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: (event?.playersLeft ?? 0) == 0 ? Colors.red : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
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
                                ? const AppProgressIndicator(size: 30)
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
                            const SizedBox(height: AppSpacing.xl),

                            // Organizer Management Section
                            if (event?.organizerId == profileController.userProfile['id'] && _participants.any((p) => p['status'] == 'pending')) ...[
                              Text('Pending Requests', style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
                              const SizedBox(height: AppSpacing.m),
                              ..._participants.where((p) => p['status'] == 'pending').map((p) => _buildRequestCard(p)),
                              const SizedBox(height: AppSpacing.xl),
                            ],

                            _buildLocationMap(event),

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
                                    ? const AppProgressIndicator(
                                        size: 24,
                                        color: Colors.white,
                                      )
                                    : Text(
                                        _hasJoined
                                            ? '✓ Requested'
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

                            // Pay Registration Fee Button (If accepted but unpaid)
                            if (_hasJoined && _participants.any((p) => p['user_id'] == profileController.userProfile['id'] && p['status'] == 'accepted' && p['payment_status'] == 'unpaid')) ...[
                              const SizedBox(height: AppSpacing.m),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    final p = _participants.firstWhere((p) => p['user_id'] == profileController.userProfile['id']);
                                    Get.toNamed('/payment', arguments: {
                                      'bookingId': event?.id, // Using event ID as reference for payment tracker in some logic
                                      'totalPrice': event?.registrationFee ?? 0.0,
                                      'type': 'event_participant',
                                      'participantId': p['id'],
                                    });
                                  },
                                  icon: const Icon(Icons.payment),
                                  label: const Text('Pay Registration Fee Online'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.green,
                                    side: const BorderSide(color: Colors.green),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                ),
                              ),
                            ],
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
    final isVerified = profileController.userProfile['phone_verified'] ??
        profileController.userProfile['is_phone_verified'] ??
        false;

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
      final registrationFee = (event.registrationFee ?? 0);
      
      final response = await ApiClient().dio.post(
        '/event-participants',
        data: {
          'event_id': event.id,
          'status': 'pending', // All joins require organizer approval now
          'payment_status': registrationFee > 0 ? 'unpaid' : 'paid',
          'payment_method': 'cash', // Default to cash/manual until they pay online
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() => _hasJoined = true);
        Get.snackbar(
          'Request Sent!',
          'Your request to join was sent. Wait for organizer approval.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          colorText: Colors.green,
        );
        _fetchParticipants(event.id.toString()); // Refresh list
      } else {
        Get.snackbar('Error', 'Failed to join event. Please try again.');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to join event. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
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

  Widget _buildLocationMap(Event? event) {
    if (event == null) return const SizedBox.shrink();

    // Strategy: Use event lat/lng OR fallback to ground/complex lat/lng from booking
    double? lat = event.latitude;
    double? lng = event.longitude;

    if ((lat == null || lat == 0) && event.booking?.ground?.complex != null) {
      lat = event.booking!.ground!.complex!.latitude;
      lng = event.booking!.ground!.complex!.longitude;
    }

    final hasValidCoords = lat != null && lng != null && lat != 0 && lng != 0;

    if (!hasValidCoords) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Location', style: AppTextStyles.h3),
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
                    event.location ?? 'Coordinate location not set',
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
        Text('Location', style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.m),
        Container(
          height: 180,
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
                  markerId: const MarkerId('event_location'),
                  position: position,
                  infoWindow: InfoWindow(
                    title: event.name,
                    snippet: event.location ?? '',
                  ),
                ),
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              scrollGesturesEnabled: false,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: () => _openMaps(lat!, lng!),
            icon: const Icon(Icons.directions_outlined, size: 20),
            label: const Text('Get Directions'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(dynamic participant) {
    final user = participant['user'] ?? {};
    final id = participant['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryLight,
            backgroundImage: (user['avatar'] != null && user['avatar'].toString().isNotEmpty)
                ? NetworkImage(user['avatar'])
                : null,
            child: (user['avatar'] == null || user['avatar'].toString().isEmpty)
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['name'] ?? 'User',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  participant['payment_status'] == 'paid'
                      ? 'Paid'
                      : 'Unpaid (Cash/Manual)',
                  style: TextStyle(
                    fontSize: 11,
                    color: participant['payment_status'] == 'paid'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _updateParticipantStatus(id, 'accepted'),
            icon: const Icon(Icons.check_circle, color: Colors.green),
          ),
          IconButton(
            onPressed: () => _updateParticipantStatus(id, 'rejected'),
            icon: const Icon(Icons.cancel, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> _updateParticipantStatus(int id, String status) async {
    try {
      final res = await ApiClient().dio.put(
        '/event-participants/$id',
        data: {'status': status},
      );
      if (res.statusCode == 200) {
        Get.snackbar('Success', 'Request $status successfully');
        final eventId = controller.selectedEvent.value?.id.toString();
        _fetchParticipants(eventId);
        if (eventId != null) {
          controller.getEventById(eventId);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status');
    }
  }
}
