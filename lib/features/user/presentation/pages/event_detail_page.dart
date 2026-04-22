import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/constants/app_constants.dart';
import 'package:sport_studio/core/network/api_client.dart';
import 'package:sport_studio/core/models/models.dart';
import 'package:sport_studio/core/utils/app_utils.dart';
import 'package:sport_studio/widgets/app_progress_indicator.dart';
import 'package:sport_studio/core/utils/url_helper.dart';

import 'package:sport_studio/features/user/controller/profile_controller.dart';
import 'package:sport_studio/features/auth/presentation/widgets/phone_verification_dialog.dart';
import 'package:sport_studio/features/user/controller/events_controller.dart';
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
        // Freshly fetch to get newest userJoined / participantsCount status
        controller.getEventById(eventArgs.id.toString());
      } else if (eventArgs is Map<String, dynamic>) {
        final id = eventArgs['id'];
        if (id != null) {
          _fetchParticipants(id);
          controller.getEventById(id.toString());
        }
      } else if (eventArgs is String || eventArgs is int) {
        _fetchParticipants(eventArgs.toString());
        controller.getEventById(eventArgs.toString());
      }
    }
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(milliseconds: 4000), (
      timer,
    ) {
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
      final res = await ApiClient().dio.get(
        '/event-participants',
        queryParameters: {'event_id': eventId, 'include_past': 1, 'per_page': 100},
      );
      if (res.statusCode == 200) {
        final raw = res.data;
        final List data = raw is List ? raw : (raw['data'] as List? ?? []);
        setState(() => _participants = data);
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
          ? AppUtils.formatDateTime(startTime)
          : 'TBD';
      final location = event?.location ?? '—';
      final registrationFee = (event?.registrationFee ?? 0).toDouble();
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

      List<String> sanitizedImages = images
          .where((url) => url.isNotEmpty)
          .map((url) => UrlHelper.sanitizeUrl(url))
          .toList();

      final profileController = Get.find<ProfileController>();

      return Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 340,
                  pinned: true,
                  leading: const SizedBox.shrink(),
                  backgroundColor: AppColors.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: sanitizedImages.isEmpty
                              ? 1
                              : sanitizedImages.length,
                          onPageChanged: (index) => _currentPage.value = index,
                          itemBuilder: (context, index) {
                            if (sanitizedImages.isEmpty) {
                              return Container(color: AppColors.primary);
                            }
                            return CachedNetworkImage(
                              imageUrl: sanitizedImages[index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: AppProgressIndicator(size: 30),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[100],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                        // Premium Subtle Gradient Overlay
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.3),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.2),
                                ],
                                stops: const [0.0, 0.4, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Content Sections (Clean separation with space)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Info Card
                        _buildMainDetailCard(title, date, location, event),

                        const SizedBox(height: 16),

                        // Dynamic Action Chips
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionChip(
                                Icons.people_outline_rounded,
                                '$currentParticipants / $maxParticipants',
                                'Players Booked',
                                isFull ? Colors.red : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionChip(
                                Icons.payments_outlined,
                                registrationFee == 0
                                    ? 'FREE'
                                    : '${AppConstants.currencySymbol} $registrationFee',
                                'Entry Fee',
                                AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                        if (maxParticipants > 0) ...[
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Booking Progress',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    '${((currentParticipants / maxParticipants) * 100).toInt()}% Booked',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: currentParticipants / maxParticipants,
                                  backgroundColor: Colors.grey[100],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isFull ? Colors.red : AppColors.primary,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Management Center (ALWAYS for organizer)
                        if (event?.organizerId.toString() ==
                            profileController.userProfile['id'].toString()) ...[
                          _buildOrganizerPanel(),
                          const SizedBox(height: 16),
                        ] else ...[
                          // Public Participants Section (only for others)
                          _buildParticipantsSection(event, profileController),
                          const SizedBox(height: 16),
                        ],

                        // 2. Content Sections (Clean separation with space)
                        _buildSectionContainer(
                          title: 'About the Event',
                          icon: Icons.info_outline_rounded,
                          iconColor: Colors.blueAccent,
                          child: Text(
                            description,
                            style: AppTextStyles.bodyMedium.copyWith(
                              height: 1.6,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),

                        // Map Section
                        _buildLocationMap(event),

                        const SizedBox(height: 140), // Footer spacer
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 3. Floating Overlay Navigation
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleIconBtn(
                    Icons.arrow_back_ios_new_rounded,
                    onTap: () => Get.back(),
                  ),
                  _circleIconBtn(
                    Icons.share_rounded,
                    onTap: () => _copyInviteLink(event),
                  ),
                ],
              ),
            ),

            // 4. Fixed Professional Footer
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomActionBar(
                event,
                profileController,
                isFull,
                registrationFee,
              ),
            ),
          ],
        ),
      );
    });
  }

  // --- UI Components ---

  Widget _buildMainDetailCard(
    String title,
    String date,
    String location,
    Event? event,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildModernStatusChip(event),
                  if (event?.isVip ?? false) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'VIP EVENT',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              if ((event?.avgRating ?? 0) > 0)
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${event?.avgRating}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.h1.copyWith(fontSize: 24, height: 1.2),
          ),
          const SizedBox(height: 16),
          _detailRow(Icons.calendar_month_rounded, date, Colors.indigoAccent),
          const SizedBox(height: 12),
          _detailRow(Icons.location_on_rounded, location, Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildActionChip(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Text(title, style: AppTextStyles.h2.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildParticipantsSection(Event? event, ProfileController profile) {
    return _buildSectionContainer(
      title: 'Participants',
      icon: Icons.groups_rounded,
      iconColor: AppColors.primary,
      child: Row(
        children: [
          Expanded(
            child: _isLoadingParticipants
                ? const AppProgressIndicator(size: 20)
                : _participants.isEmpty
                ? Text('No participants yet', style: AppTextStyles.bodySmall)
                : SizedBox(
                    height: 40,
                    child: Stack(
                      children: [
                        ...List.generate(
                          _participants.length > 5 ? 6 : _participants.length,
                          (i) {
                            if (i == 5) {
                              return Positioned(
                                left: i * 28.0,
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primaryLight,
                                  child: Text(
                                    '+${_participants.length - 5}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }
                            final avatar = _participants[i]['user']?['avatar'];
                            return Positioned(
                              left: i * 28.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      (avatar != null && avatar.isNotEmpty)
                                      ? NetworkImage(avatar)
                                      : null,
                                  child: (avatar == null || avatar.isEmpty)
                                      ? const Icon(Icons.person, size: 18)
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
          ),
          if (event?.organizerId == profile.userProfile['id'])
            IconButton.filledTonal(
              onPressed: _showInviteDialog,
              icon: const Icon(Icons.person_add_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                foregroundColor: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModernStatusChip(Event? event) {
    if (event == null) return const SizedBox.shrink();
    final status = event.status.toLowerCase();

    String label = status.toUpperCase();
    Color color = AppColors.primary;

    if (status == 'published' || status == 'upcoming') {
      label = '✨ BOOKING OPEN';
      color = Colors.green;
    } else if (status == 'completed') {
      color = Colors.green;
    } else if (status == 'cancelled') {
      color = Colors.red;
    } else if (status == 'ongoing') {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _circleIconBtn(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildOrganizerPanel() {
    return _buildSectionContainer(
      title: 'Management Center',
      icon: Icons.admin_panel_settings_rounded,
      iconColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Registered Participants',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddPlayerDialog(),
                icon: const Icon(Icons.person_add_alt_1, size: 14),
                label: const Text('Add Player'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981), // Website's green
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  visualDensity: VisualDensity.compact,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Administrative Note (Website Sync)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Note: Event cancellation is restricted to Administrators. If you need to terminate this event, please contact Sport Studio support.',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.amber[900],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoadingParticipants)
            const Center(child: AppProgressIndicator())
          else if (_participants.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'No players registered yet.',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ),
            )
          else ...[
            // Pending section if any
            if (_participants.any((p) => p['status'] == 'pending')) ...[
              const Text(
                'JOIN REQUESTS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.orange,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              ..._participants
                  .where((p) => p['status'] == 'pending')
                  .map((p) => _buildParticipantManagementCard(p)),
              const SizedBox(height: 12),
            ],

            // Confirmed section
            if (_participants.any((p) => p['status'] != 'pending')) ...[
              const Text(
                'CONFIRMED PLAYERS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textMuted,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              ..._participants
                  .where((p) => p['status'] != 'pending')
                  .map((p) => _buildParticipantManagementCard(p)),
            ],
          ],
        ],
      ),
    );
  }

  void _showAddPlayerDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final isAdding = false.obs;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Player',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                Text(
                  'Manually add a participant',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.close, size: 20),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Full Name',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Player name',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Email Address',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                hintText: 'player@example.com',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          Obx(
            () => ElevatedButton(
              onPressed:
                  isAdding.value
                      ? null
                      : () async {
                        if (nameCtrl.text.trim().isEmpty) {
                          AppUtils.showError(message: 'Name is required');
                          return;
                        }
                        isAdding.value = true;
                        try {
                          final eventId =
                              controller.selectedEvent.value?.id;
                          final res = await ApiClient().dio.post(
                            '/event-participants',
                            data: {
                              'event_id': eventId,
                              'is_manual_add': true,
                              'user_info': {
                                'name': nameCtrl.text.trim(),
                                'email': emailCtrl.text.trim(),
                              },
                              'status': 'confirmed',
                              'payment_status': 'paid',
                            },
                          );
                          if (res.statusCode == 200 || res.statusCode == 201) {
                            Get.back();
                            AppUtils.showSuccess(
                              message: 'Player added successfully (Marked as Paid)',
                            );
                            _fetchParticipants(eventId.toString());
                          }
                        } catch (e) {
                          AppUtils.showError(message: 'Failed to add player');
                        } finally {
                          isAdding.value = false;
                        }
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:
                  isAdding.value
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text(
                        'Add Player',
                        style: TextStyle(color: Colors.white),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(
    Event? event,
    ProfileController profile,
    bool isFull,
    double fee,
  ) {
    // Hide bottom bar for the organizer
    if (event?.organizerId.toString() == profile.userProfile['id'].toString()) {
      return const SizedBox.shrink();
    }
    final userId = profile.userProfile['id']?.toString();
    final isJoined = (event?.userJoined == true) || 
                     _hasJoined || 
                     _participants.any((p) => p['user_id']?.toString() == userId);
                     
    final isPaid = _participants.any(
      (p) =>
          p['user_id']?.toString() == userId &&
          (p['payment_status']?.toString().toLowerCase() == 'paid' || 
           p['status']?.toString().toLowerCase() == 'confirmed'),
    );

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            if (_isJoining) return;

            if (!isJoined) {
              if (!isFull) _joinEvent(event);
            } else if (!isPaid && fee > 0) {
              final userIdStr = profile.userProfile['id']?.toString();
              final p = _participants.firstWhere(
                (p) => p['user_id']?.toString() == userIdStr,
                orElse: () => null,
              );
              if (p != null) {
                Get.toNamed(
                  '/payment',
                  arguments: {
                    'totalPrice': fee,
                    'type': 'event_participant',
                    'participantId': p['id'],
                  },
                );
              }
            }
          },
          style:
              ElevatedButton.styleFrom(
                backgroundColor: isJoined
                    ? (isPaid || fee <= 0 ? Colors.green : AppColors.accent)
                    : (isFull ? Colors.grey[400] : AppColors.primary),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ).copyWith(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (isJoined) {
                    return (isPaid || fee <= 0)
                        ? Colors.green
                        : AppColors.accent;
                  }
                  return (isFull) ? Colors.grey[300] : AppColors.primary;
                }),
              ),
          child: _isJoining
              ? const AppProgressIndicator(size: 24, color: Colors.white)
              : Text(
                  !isJoined
                      ? (isFull ? 'Sold Out' : 'Book Event')
                      : (!isPaid && fee > 0
                            ? 'Complete Payment'
                            : 'Booking Confirmed'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLocationMap(Event? event) {
    if (event == null) return const SizedBox.shrink();
    double? lat = event.latitude;
    double? lng = event.longitude;

    if ((lat == null || lat == 0) && event.booking?.ground?.complex != null) {
      lat = event.booking!.ground!.complex!.latitude;
      lng = event.booking!.ground!.complex!.longitude;
    }

    final hasValidCoords = lat != null && lng != null && lat != 0 && lng != 0;

    return _buildSectionContainer(
      title: 'Location',
      icon: Icons.map_outlined,
      iconColor: Colors.orange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasValidCoords)
            Container(
              height: 180,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(lat, lng),
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('ev'),
                      position: LatLng(lat, lng),
                    ),
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  scrollGesturesEnabled: false,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                event.location ?? 'Coordinate location not set',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.location ?? 'No location details',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
          if (hasValidCoords)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Center(
                child: TextButton.icon(
                  onPressed: () => _openMaps(lat!, lng!),
                  icon: const Icon(Icons.directions_rounded),
                  label: const Text(
                    'Navigate to Field',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildParticipantManagementCard(dynamic participant) {
    final user = participant['user'] ?? {};
    final id = participant['id'];
    final status = participant['status'] ?? 'pending';
    final isPaid = (participant['payment_status'] ?? 'unpaid') == 'paid';
    final avatar = user['avatar'];
    
    // Correct fallback for manual vs user participants
    final displayName = user['name'] ?? participant['name'] ?? participant['full_name'] ?? 'Guest Player';
    final email = user['email'] ?? participant['email'] ?? 'N/A';
    
    final joinedAt = participant['created_at'];
    String joinedDate = 'N/A';
    if (joinedAt != null) {
      try {
        DateTime dt = DateTime.parse(joinedAt.toString());
        joinedDate = DateFormat('MM/dd/yyyy').format(dt);
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage:
                    (avatar != null && avatar.toString().isNotEmpty)
                        ? NetworkImage(avatar)
                        : null,
                child:
                    (avatar == null || avatar.toString().isEmpty)
                        ? Text(
                          (displayName)[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (status == 'pending')
                Row(
                  children: [
                    _actionBtn(
                      Icons.check_circle_rounded,
                      const Color(0xFF10B981),
                      () => _updateParticipantStatus(id, 'accepted'),
                    ),
                    const SizedBox(width: 10),
                    _actionBtn(
                      Icons.cancel_rounded,
                      const Color(0xFFEF4444),
                      () => _updateParticipantStatus(id, 'rejected'),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'accepted' || status == 'confirmed' 
                        ? const Color(0xFFD1FAE5) 
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: status == 'accepted' || status == 'confirmed' 
                          ? const Color(0xFF065F46) 
                          : const Color(0xFF991B1B),
                    ),
                  ),
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFE2E8F0)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'JOINED DATE',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    joinedDate,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'PAYMENT',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isPaid
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color:
                                isPaid
                                    ? const Color(0xFF86EFAC)
                                    : const Color(0xFFFCD34D),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          isPaid ? 'PAID' : 'UNPAID',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color:
                                isPaid
                                    ? const Color(0xFF166534)
                                    : const Color(0xFF92400E),
                          ),
                        ),
                      ),
                      if (!isPaid) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap:
                              () => _updateParticipantStatus(
                                id,
                                status,
                                paymentStatus: 'paid',
                              ),
                          child: Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Mark Paid',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: color, size: 28),
    );
  }

  Future<void> _updateParticipantStatus(
    int id,
    String status, {
    String? paymentStatus,
  }) async {
    try {
      final Map<String, dynamic> data = {'status': status};
      if (paymentStatus != null) data['payment_status'] = paymentStatus;

      final res = await ApiClient().dio.put(
        '/event-participants/$id',
        data: data,
      );
      if (res.statusCode == 200) {
        AppUtils.showSuccess(
          message: paymentStatus != null
              ? 'Payment status updated'
              : 'Participant $status',
        );
        _fetchParticipants(controller.selectedEvent.value?.id.toString());
        if (controller.selectedEvent.value?.id != null) {
          controller.getEventById(
            controller.selectedEvent.value!.id.toString(),
          );
        }
      }
    } catch (e) {
      AppUtils.showError(message: 'Update failed');
    }
  }

  Future<void> _joinEvent(dynamic event) async {
    if (event == null || event.id == null) return;
    final profileController = Get.find<ProfileController>();
    if (!profileController.isPhoneVerified) {
      Get.dialog(
        PhoneVerificationDialog(
          initialPhone:
              profileController.userProfile['phone']?.toString() ?? '',
          onVerified: () {},
        ),
      );
      return;
    }

    setState(() => _isJoining = true);
    try {
      final fee = (event.registrationFee ?? 0);
      final response = await ApiClient().dio.post(
        '/event-participants',
        data: {
          'event_id': event.id,
          'status': 'pending',
          'payment_status': fee > 0 ? 'unpaid' : 'paid',
          'payment_method': 'cash',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() => _hasJoined = true);
        AppUtils.showSuccess(message: 'Booking request sent!');
        _fetchParticipants(event.id.toString());
      }
    } catch (e) {
      AppUtils.showError(message: 'Failed to join event');
    } finally {
      setState(() => _isJoining = false);
    }
  }

  void _copyInviteLink(dynamic event) {
    final link = "https://sportstudio.squarenex.com/events/${event.id}";
    Clipboard.setData(ClipboardData(text: link));
    AppUtils.showSuccess(message: 'Invite link copied!');
  }

  void _showInviteDialog() {
    final inviteCtrl = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Invite Players', style: AppTextStyles.h2),
            const SizedBox(height: 20),
            TextField(
              controller: inviteCtrl,
              decoration: InputDecoration(
                hintText: 'Enter email address',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (inviteCtrl.text.isNotEmpty) {
                    Get.back();
                    AppUtils.showSuccess(message: 'Invitation sent!');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Send Invitation',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
