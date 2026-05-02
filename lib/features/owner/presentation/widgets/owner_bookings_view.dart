import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/constants/app_constants.dart';
import 'package:sport_studio/core/utils/app_utils.dart';
import 'package:sport_studio/core/constants/user_roles.dart';
import 'package:sport_studio/features/landing/controller/landing_controller.dart';
import 'package:sport_studio/features/owner/controller/bookings_controller.dart';
import 'package:sport_studio/features/owner/controller/grounds_controller.dart';
import 'package:sport_studio/features/user/controller/profile_controller.dart';
import 'package:sport_studio/widgets/app_button.dart';
import 'package:sport_studio/widgets/app_progress_indicator.dart';
import 'package:sport_studio/features/owner/presentation/pages/booking_detail_page.dart';
import 'package:sport_studio/features/user/presentation/pages/user_booking_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sport_studio/core/utils/url_helper.dart';

class OwnerBookingsView extends StatefulWidget {
  final bool isTab;
  const OwnerBookingsView({super.key, this.isTab = false});

  @override
  State<OwnerBookingsView> createState() => _OwnerBookingsViewState();
}

class _OwnerBookingsViewState extends State<OwnerBookingsView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _handleArguments();
  }

  void _handleArguments() {
    final BookingsController controller = Get.isRegistered<BookingsController>()
        ? Get.find<BookingsController>()
        : Get.put(BookingsController());
    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('groundId')) {
      final gId = int.tryParse(args['groundId'].toString());
      if (gId != null) {
        controller.selectedGroundId.value = gId;
        controller.selectedGroundName.value = args['groundName']?.toString();
        controller.fetchBookings();
      }
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<BookingsController>()) {
      final controller = Get.find<BookingsController>();
      if (controller.selectedGroundId.value != null) {
        controller.selectedGroundId.value = null;
        controller.selectedGroundName.value = null;
        controller.fetchBookings(silent: true);
      }
    }
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final landingController = Get.put(LandingController(), permanent: true);
    final currentRole = landingController.currentRole.value;
    final isOwnerOrAdmin =
        currentRole == UserRole.owner || currentRole == UserRole.admin;
    final controller = Get.put(BookingsController());

    return DefaultTabController(
      length: 3,
      child: Obx(() => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !widget.isTab,
          title: const Text('Ground Bookings'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => setState(() => _isSearching = !_isSearching),
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              color: _isSearching ? Colors.red : null,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(
              (_isSearching ? 60 : 0) +
                  (Get.find<BookingsController>().selectedGroundId.value != null
                      ? 50
                      : 0) +
                  60,
            ),
            child: Column(
              children: [
                if (_isSearching)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        onChanged: (val) => controller.searchQuery.value = val,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Search by client, ID, ground...',
                          border: InputBorder.none,
                          hintStyle: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.primary,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    controller.searchQuery.value = '';
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.clear, size: 20),
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                Obx(() {
                  if (controller.selectedGroundId.value == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.filter_alt, size: 14, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            'Filtered: ${controller.selectedGroundName.value ?? controller.selectedGroundId.value}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              controller.selectedGroundId.value = null;
                              controller.selectedGroundName.value = null;
                              controller.fetchBookings();
                            },
                            child: const Icon(Icons.cancel, size: 18, color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                Container(
                  height: 42,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    padding: const EdgeInsets.all(0),
                    indicatorSize: TabBarIndicatorSize.tab,
                    isScrollable: false,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: AppColors.surface,
                    unselectedLabelColor: AppColors.textMuted,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    indicatorPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Past'),
                      Tab(text: 'Cancelled'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: isOwnerOrAdmin
            ? FloatingActionButton.extended(
                onPressed: () => _showManualBookingSheet(context, controller),
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Manual Entry',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        body: TabBarView(
          children: [
            _buildBookingList('Upcoming', controller, isOwnerOrAdmin),
            _buildBookingList('Past', controller, isOwnerOrAdmin),
            _buildBookingList('Cancelled', controller, isOwnerOrAdmin),
          ],
        ),
      )),
    );
  }

  Widget _buildBookingList(
    String type,
    BookingsController controller,
    bool isOwnerOrAdmin,
  ) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchBookings(),
      color: AppColors.primary,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: 500,
              child: Center(child: AppProgressIndicator()),
            ),
          );
        }

        final profileController = Get.find<ProfileController>();
        final userId = profileController.userProfile['id']?.toString();

        final rawList = type == 'Upcoming'
            ? controller.upcomingBookings
            : type == 'Past'
            ? controller.pastBookings
            : controller.cancelledBookings;

        // Filter: If owner/admin, only show events they organize.
        // User joined events (not organized by them) should be in JoinedEventsPage.
        final list = rawList.where((b) {
          if (isOwnerOrAdmin && b['type'] == 'event') {
            return b['organizer_id']?.toString() == userId;
          }
          return true;
        }).toList();

        if (list.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 64,
                      color: AppColors.textMuted.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'No $type bookings found.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.m),
              itemCount: list.length,
              itemBuilder: (context, index) {
                return _buildBookingCard(
                  context,
                  list[index],
                  type,
                  controller,
                  isOwnerOrAdmin,
                );
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    dynamic booking,
    String type,
    BookingsController controller,
    bool isOwnerOrAdmin,
  ) {
    final ground = booking['ground'] is Map ? booking['ground'] as Map : null;
    final complex = (ground != null && ground['complex'] is Map)
        ? ground['complex'] as Map
        : null;

    final displayTitle = isOwnerOrAdmin
        ? (booking['user']?['name'] ??
              booking['customer_name'] ??
              'Walk-in Customer')
        : (ground?['name'] ?? 'Ground');

    final displaySubtitle = isOwnerOrAdmin
        ? (ground?['name'] ?? 'Ground')
        : (complex?['name'] ?? 'Sports Complex');

    final displayPhone = isOwnerOrAdmin
        ? (booking['user']?['phone'] ?? booking['customer_phone'] ?? 'N/A')
        : (complex?['phone'] ?? ground?['owner_phone'] ?? 'N/A');

    final String dateStr = (booking['date'] ?? '').toString();
    final String rawStart = (booking['start_time'] ?? '').toString();
    final String rawEnd = (booking['end_time'] ?? '').toString();

    // Extract date correctly
    String displayDate = dateStr;
    if (displayDate.isEmpty && rawStart.isNotEmpty) {
      displayDate = rawStart.contains(' ')
          ? rawStart.split(' ')[0]
          : (rawStart.contains('T') ? rawStart.split('T')[0] : rawStart);
    }
    final formattedDate = AppUtils.formatDate(displayDate);

    String startTime = rawStart;
    String endTime = rawEnd;

    try {
      if (rawStart.isNotEmpty) {
        final startDt = DateTime.parse(
          rawStart.contains(' ') ? rawStart.replaceFirst(' ', 'T') : rawStart,
        );
        startTime = DateFormat('hh:mm a').format(startDt);
      }
      if (rawEnd.isNotEmpty) {
        final endDt = DateTime.parse(
          rawEnd.contains(' ') ? rawEnd.replaceFirst(' ', 'T') : rawEnd,
        );
        endTime = DateFormat('hh:mm a').format(endDt);
      }
    } catch (e) {
      // Fallback to raw if parsing fails
    }

    final totalAmount =
        double.tryParse(
          (booking['total_amount'] ?? booking['total_price'] ?? 0).toString(),
        ) ??
        0.0;
    String status = (booking['status'] ?? 'pending').toString();
    final String paymentStatus = (booking['payment_status'] ?? 'unpaid')
        .toString();

    bool isExpired = false;
    try {
      if (rawEnd.isNotEmpty) {
        final endDt = DateTime.parse(
          rawEnd.contains(' ') ? rawEnd.replaceFirst(' ', 'T') : rawEnd,
        );
        isExpired = endDt.isBefore(DateTime.now());
      }
    } catch (e) {
      // Ignore parsing errors
    }

    if (isExpired && status == 'pending') {
      status = 'cancelled';
    }

    Color statusColor;
    switch (status) {
      case 'confirmed':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      case 'completed':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.orange;
    }
    return GestureDetector(
      onTap: () {
        if (isOwnerOrAdmin) {
          Get.to(
            () => const BookingDetailPage(),
            arguments: {'booking': booking},
          );
        } else {
          Get.to(
            () => const UserBookingDetailPage(),
            arguments: {'booking': booking},
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s,
          vertical: AppSpacing.s,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Main Content
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Details Header & Info
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile & Main Info Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryLight.withValues(
                                    alpha: 0.5,
                                  ),
                                  border: Border.all(
                                    color: statusColor.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child:
                                      (booking['user'] != null &&
                                          booking['user']['avatar'] != null)
                                      ? CachedNetworkImage(
                                          imageUrl: UrlHelper.sanitizeUrl(
                                            booking['user']['avatar']
                                                .toString(),
                                          ),
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              _buildFallbackAvatar(
                                                displayTitle.toString(),
                                              ),
                                        )
                                      : _buildFallbackAvatar(
                                          displayTitle.toString(),
                                        ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.m),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            displayTitle.toString(),
                                            style: AppTextStyles.h2.copyWith(
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -0.5,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            status.toUpperCase(),
                                            style: TextStyle(
                                              color: statusColor,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 10,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_rounded,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            displaySubtitle.toString(),
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  color: Colors.grey.shade700,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.phone_rounded,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          displayPhone.toString(),
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                color: Colors.grey.shade700,
                                              ),
                                        ),
                                        if (booking['event'] != null) ...[
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Colors.blueAccent,
                                                  Colors.lightBlue,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'EVENT',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.m),

                          // Ticket Style Divider
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.horizontal(
                                    right: Radius.circular(8),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Flex(
                                      direction: Axis.horizontal,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: List.generate(
                                        (constraints.constrainWidth() / 8)
                                            .floor(),
                                        (index) => SizedBox(
                                          width: 4,
                                          height: 1.5,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s),

                          // Time, Date & Price Information
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.1,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.calendar_today_rounded,
                                            size: 14,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withValues(
                                              alpha: 0.1,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.schedule_rounded,
                                            size: 14,
                                            color: Colors.orange,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '$startTime – $endTime',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${AppConstants.currencySymbol} ${NumberFormat('#,###').format(totalAmount)}',
                                      style: AppTextStyles.h2.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: paymentStatus == 'paid'
                                            ? Colors.green.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.red.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: paymentStatus == 'paid'
                                              ? Colors.green.withValues(
                                                  alpha: 0.2,
                                                )
                                              : Colors.red.withValues(
                                                  alpha: 0.2,
                                                ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            paymentStatus == 'paid'
                                                ? Icons.check_circle_rounded
                                                : Icons.cancel_rounded,
                                            size: 12,
                                            color: paymentStatus == 'paid'
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          const SizedBox(width: 4),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                paymentStatus == 'paid'
                                                    ? 'PAID'
                                                    : 'UNPAID',
                                                style: TextStyle(
                                                  color: paymentStatus == 'paid'
                                                      ? Colors.green
                                                      : Colors.red,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 10,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              Text(
                                                (booking['payment_method'] ?? 'N/A').toString().toUpperCase(),
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 7,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
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

                    // Action Buttons — Owner Only
                    if (isOwnerOrAdmin && status != 'cancelled' && !isExpired) ...[
                      // Logic: 
                      // 1. If Pending -> Show Accept/Decline
                      // 2. If Unpaid & Cash -> Show Mark as Paid
                      () {
                        final bool isPending = status == 'pending';
                        final bool isUnpaidCash = (paymentStatus == 'unpaid' || paymentStatus == 'pending') && 
                                                 (booking['payment_method']?.toString().toLowerCase() == 'cash' || 
                                                  booking['payment_method'] == null);

                        if (!isPending && !isUnpaidCash) return const SizedBox.shrink();

                        return Obx(
                          () => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.l,
                            ),
                            child: Column(
                              children: [
                                // Accept / Decline Row
                                if (isPending)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: controller.isActioning.value
                                              ? null
                                              : () => _confirmAction(
                                                  context,
                                                  'Accept',
                                                  () {
                                                    controller.updateBookingStatus(
                                                      booking,
                                                      'confirmed',
                                                    );
                                                  },
                                                ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          icon: const Icon(Icons.check_circle_outline, size: 18),
                                          label: const Text(
                                            'Accept',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.m),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: controller.isActioning.value
                                              ? null
                                              : () => _showDeclineDialog(
                                                  context,
                                                  booking,
                                                  controller,
                                                ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red.shade400,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          icon: const Icon(Icons.cancel_outlined, size: 18),
                                          label: const Text(
                                            'Decline',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                
                                // Mark Paid Row
                                if (isUnpaidCash && status != 'cancelled') ...[
                                  if (isPending) const SizedBox(height: AppSpacing.s),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: controller.isActioning.value
                                          ? null
                                          : () => _confirmAction(
                                              context,
                                              'Mark as Paid',
                                              () {
                                                controller.markAsPaid(booking);
                                              },
                                            ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                                      ),
                                      icon: const Icon(Icons.payments_outlined, size: 18, color: AppColors.primary),
                                      label: const Text(
                                        'Mark as Paid',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }(),
                    ],
                    const SizedBox(height: AppSpacing.m),
                  ],
                ),
              ),
              // Left Accent Strip
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: statusColor,
                    gradient: LinearGradient(
                      colors: [statusColor.withValues(alpha: 0.8), statusColor],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _confirmAction(
    BuildContext context,
    String label,
    VoidCallback onConfirm,
  ) {
    AppUtils.showConfirmDialog(
      title: 'Confirm $label',
      message: 'Are you sure you want to $label this booking?',
      onConfirm: onConfirm,
      confirmText: label,
      cancelText: 'Cancel',
      icon: Icons.help_outline_rounded,
    );
  }

  void _showDeclineDialog(
    BuildContext context,
    dynamic booking,
    BookingsController controller,
  ) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Decline Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please provide a reason for declining:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,

              decoration: InputDecoration(
                hintText: 'e.g. Facility under maintenance...',
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              controller.updateBookingStatus(
                booking,
                'rejected',
                reason: reasonController.text,
              );
            },
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }

  void _showManualBookingSheet(
    BuildContext context,
    BookingsController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ManualBookingSheet(controller: controller),
    );
  }
}

class _ManualBookingSheet extends StatefulWidget {
  final BookingsController controller;
  const _ManualBookingSheet({required this.controller});

  @override
  State<_ManualBookingSheet> createState() => _ManualBookingSheetState();
}

class _ManualBookingSheetState extends State<_ManualBookingSheet> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _dateCtrl = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );
  final _amountCtrl = TextEditingController(text: '0');
  final _playersCtrl = TextEditingController(text: '1');
  int? _selectedGroundId;
  List<int> _selectedSlots = [];
  List<dynamic> _existingBookings = [];
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    // Refresh grounds to ensure updated operating hours are shown
    Future.microtask(() {
      try {
        Get.find<GroundsController>().fetchComplexesAndGrounds();
      } catch (_) {}
    });
  }

  Future<void> _fetchAvailability() async {
    if (_selectedGroundId == null || _dateCtrl.text.isEmpty) return;
    setState(() => _isChecking = true);
    final bookings = await widget.controller.fetchGroundBookings(
      _selectedGroundId!,
      _dateCtrl.text,
    );
    if (mounted) {
      setState(() {
        _existingBookings = bookings;
        _isChecking = false;
      });
    }
  }

  void _updatePrice() {
    if (_selectedGroundId == null) return;
    final groundsController = Get.find<GroundsController>();
    final ground = groundsController.grounds.firstWhereOrNull(
      (g) => g.id.toString() == _selectedGroundId.toString(),
    );
    if (ground != null) {
      final price = ground.pricePerHour * _selectedSlots.length;
      _amountCtrl.text = price.toInt().toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final groundsController = Get.put(GroundsController());
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Manual Booking Entry',
                      style: AppTextStyles.h2,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ground Selector (Improved with Complex Name)
                    Text('Select Ground', style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.s),
                    Obx(
                      () => DropdownButtonFormField<int>(
                        isExpanded: true,
                        value: _selectedGroundId,
                        hint: const Text('Choose a ground'),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.sports_cricket_outlined),
                        ),
                        items: groundsController.grounds
                            .map(
                              (g) => DropdownMenuItem<int>(
                                value: g.id,
                                child: Text(
                                  '${g.name} (${g.complexName ?? "Complex"})',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedGroundId = val;
                            _selectedSlots.clear();
                          });
                          _fetchAvailability();
                          _updatePrice();
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Customer Name
                    Text('Customer Name', style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.s),
                    _field(
                      _nameCtrl,
                      'e.g. Ahmed Khan',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Phone & Email (Column layout)
                    Text('Phone (optional)', style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.s),
                    _field(
                      _phoneCtrl,
                      '03XXXXXXXX',
                      icon: Icons.phone_outlined,
                      type: TextInputType.phone,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text('Email (optional)', style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.s),
                    _field(
                      _emailCtrl,
                      'customer@email.com',
                      icon: Icons.mail_outline,
                      type: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Date
                    Text('Date', style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.s),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 30),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 90),
                          ),
                        );
                        if (picked != null) {
                          _dateCtrl.text = DateFormat(
                            'yyyy-MM-dd',
                          ).format(picked);
                          _selectedSlots.clear();
                          _fetchAvailability();
                          _updatePrice();
                        }
                      },
                      child: AbsorbPointer(
                        child: _field(
                          _dateCtrl,
                          'YYYY-MM-DD',
                          icon: Icons.calendar_today_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Time Slots Grid
                    Text('Select Time Slots', style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.s),
                    Obx(() => _buildSlotsGrid()),
                    const SizedBox(height: AppSpacing.m),

                    // Players & Amount
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Players',
                                style: AppTextStyles.label,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: AppSpacing.s),
                              _field(
                                _playersCtrl,
                                'e.g. 1',
                                icon: Icons.people_outline,
                                type: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Amount (${AppConstants.currencySymbol})',
                                style: AppTextStyles.label,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: AppSpacing.s),
                              _field(
                                _amountCtrl,
                                'e.g. 3000',
                                icon: Icons.payments_outlined,
                                type: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Submit
                    Obx(
                      () => AppButton(
                        label: 'Create Booking',
                        onPressed: () => _submit(ctx),
                        isLoading: widget.controller.isActioning.value,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotsGrid() {
    final groundsController = Get.find<GroundsController>();
    // Touch reactive variable to prevent Obx error when no ground is selected
    groundsController.grounds.length;

    if (_selectedGroundId == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.sports_cricket_outlined,
              size: 40,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'Select a ground to see available slots',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    if (_isChecking) {
      return const Center(child: AppProgressIndicator(size: 24));
    }

    // Generate 24 slots
    final ground = groundsController.grounds.firstWhereOrNull(
      (g) => g.id.toString() == _selectedGroundId.toString(),
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(24, (index) {
        final hour = index;
        final startTimeStr = '${hour.toString().padLeft(2, '0')}:00';
        final endTimeStr = '${(hour + 1).toString().padLeft(2, '0')}:00';

        final bool isWithinOperatingHours = () {
          final ohStart =
              int.tryParse(ground?.openingTime?.split(':')[0] ?? '06') ?? 6;
          final ohEnd =
              int.tryParse(ground?.closingTime?.split(':')[0] ?? '23') ?? 23;
          if (ohStart <= ohEnd) {
            return hour >= ohStart && hour < (ohEnd == 0 ? 24 : ohEnd);
          } else {
            return hour >= ohStart || hour < (ohEnd == 0 ? 24 : ohEnd);
          }
        }();

        // New: Check if slot is in the past
        final bool isPastSlot = () {
          final now = DateTime.now();
          final today = DateFormat('yyyy-MM-dd').format(now);
          if (_dateCtrl.text == today) {
            return hour < now.hour;
          }
          return false;
        }();

        // Check if booked
        final isBooked = _existingBookings.any((b) {
          String sStart = b['start_time']
              .toString()
              .replaceAll(' ', 'T')
              .split('.')[0]
              .replaceFirst('Z', '');
          String sEnd = b['end_time']
              .toString()
              .replaceAll(' ', 'T')
              .split('.')[0]
              .replaceFirst('Z', '');

          final bStart = DateTime.parse(sStart);
          final bEnd = DateTime.parse(sEnd);
          final slotStart = DateTime.parse('${_dateCtrl.text}T$startTimeStr');
          final slotEnd = DateTime.parse('${_dateCtrl.text}T$endTimeStr');
          return (slotStart.isBefore(bEnd) && slotEnd.isAfter(bStart));
        });

        final isSelected = _selectedSlots.contains(hour);

        return InkWell(
          onTap: (isBooked || !isWithinOperatingHours || isPastSlot)
              ? null
              : () {
                  setState(() {
                    if (isSelected) {
                      _selectedSlots.remove(hour);
                    } else {
                      _selectedSlots.add(hour);
                    }
                  });
                  _updatePrice();
                },
          child: Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: (!isWithinOperatingHours || isPastSlot)
                  ? Colors.grey.withValues(alpha: 0.1)
                  : isBooked
                  ? Colors.red.withValues(alpha: 0.1)
                  : isSelected
                  ? AppColors.primary
                  : AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
            ),
            child: Column(
              children: [
                Text(
                  AppUtils.formatTime(startTimeStr),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: (!isWithinOperatingHours || isPastSlot)
                        ? Colors.grey
                        : isBooked
                        ? Colors.red
                        : isSelected
                        ? Colors.white
                        : AppColors.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                Text(
                  (!isWithinOperatingHours || isPastSlot)
                      ? 'Closed'
                      : (isBooked ? 'Booked' : 'Available'),
                  style: TextStyle(
                    fontSize: 8,
                    color: (!isWithinOperatingHours || isPastSlot)
                        ? Colors.grey
                        : isBooked
                        ? Colors.red
                        : isSelected
                        ? Colors.white70
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    IconData? icon,
    TextInputType? type,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      textCapitalization: type == TextInputType.emailAddress
          ? TextCapitalization.none
          : TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.background,
        prefixIcon:
            icon == Icons.attach_money || icon == Icons.payments_outlined
            ? Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  AppConstants.currencySymbol,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : (icon != null ? Icon(icon) : null),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _submit(BuildContext ctx) {
    if (_nameCtrl.text.isEmpty ||
        _selectedGroundId == null ||
        _dateCtrl.text.isEmpty ||
        _selectedSlots.isEmpty ||
        _amountCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all required fields');
      return;
    }

    // Group slots into consecutive ranges
    _selectedSlots.sort();
    List<List<int>> groups = [];
    if (_selectedSlots.isNotEmpty) {
      List<int> currentGroup = [_selectedSlots[0]];
      for (int i = 1; i < _selectedSlots.length; i++) {
        if (_selectedSlots[i] == _selectedSlots[i - 1] + 1) {
          currentGroup.add(_selectedSlots[i]);
        } else {
          groups.add(currentGroup);
          currentGroup = [_selectedSlots[i]];
        }
      }
      groups.add(currentGroup);
    }

    final List<Map<String, String>> timeSlots = groups.map((g) {
      final start = '${g[0].toString().padLeft(2, '0')}:00';
      final end = '${(g.last + 1).toString().padLeft(2, '0')}:00';
      return {
        'start_time': '${_dateCtrl.text} $start',
        'end_time': '${_dateCtrl.text} $end',
      };
    }).toList();

    Navigator.pop(ctx);
    widget.controller.createManualBooking(
      groundId: _selectedGroundId!,
      customerName: _nameCtrl.text,
      timeSlots: timeSlots,
      totalAmount: double.tryParse(_amountCtrl.text) ?? 0,
      customerPhone: _phoneCtrl.text.isEmpty ? null : _phoneCtrl.text,
      customerEmail: _emailCtrl.text.isEmpty ? null : _emailCtrl.text,
      players: int.tryParse(_playersCtrl.text) ?? 1,
    );
  }
}
