import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/widgets/section_header.dart';
import 'package:get/get.dart';
import 'package:sports_studio/widgets/app_shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sports_studio/features/owner/controller/owner_controller.dart';
import 'package:sports_studio/core/utils/url_helper.dart';
import 'package:sports_studio/features/owner/presentation/pages/owner_reports_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/sports_complexes_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/owner_deals_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/review_moderation_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/add_complex_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/add_edit_ground_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/sports_grounds_page.dart';
import 'package:sports_studio/features/owner/presentation/widgets/owner_bookings_view.dart';
import 'package:sports_studio/features/user/presentation/pages/wallet_page.dart';
import 'package:sports_studio/features/user/presentation/pages/edit_profile_page.dart';

class OwnerDashboardView extends StatelessWidget {
  const OwnerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OwnerController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => controller.fetchDashboard(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Section (Header + Banner) ───────────────────
              _buildTopSection(controller),

              const SizedBox(height: AppSpacing.l),

              // ── Management Grid ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Business Control',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const EditProfilePage()),
                      child: const Text('Settings'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              _buildManagementGrid(controller),

              const SizedBox(height: AppSpacing.l),

              // ── My Complexes ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Complexes',
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Active sports facilities',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Get.to(() => const AddComplexPage()),
                      icon: const Icon(
                        Icons.add_circle,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Obx(() {
                if (controller.isLoading.value) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                    ),
                    child: Column(
                      children: List.generate(3, (index) => AppShimmer.card()),
                    ),
                  );
                }
                if (controller.complexes.isEmpty) {
                  return _buildEmptyState(
                    'No complexes listed yet.',
                    Icons.business_outlined,
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  itemCount: controller.complexes.length > 3
                      ? 3
                      : controller.complexes.length,
                  itemBuilder: (context, index) {
                    final complex = controller.complexes[index];
                    return _buildComplexCard(complex);
                  },
                );
              }),

              const SizedBox(height: AppSpacing.l),

              // ── Recent Bookings ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Activity',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Latest player venue bookings',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Obx(() {
                if (controller.isLoading.value) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                    ),
                    child: Column(
                      children: List.generate(
                        3,
                        (index) => AppShimmer.card(height: 80),
                      ),
                    ),
                  );
                }
                if (controller.recentBookings.isEmpty) {
                  return _buildEmptyState('No recent activity.', Icons.history);
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  itemCount: controller.recentBookings.length,
                  itemBuilder: (context, index) {
                    final booking = controller.recentBookings[index];
                    return _buildBookingItem(booking);
                  },
                );
              }),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(OwnerController controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildVisualBanner(controller),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildVisualBanner(OwnerController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monthly Revenue',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Obx(
                      () => Text(
                        '${AppConstants.currencySymbol}${NumberFormat('#,###').format(controller.monthlyRevenue.value)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.trending_up,
                        color: Colors.greenAccent,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '+12%',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBannerStatItem(
                    'Total Bookings',
                    '${controller.totalBookings.value}',
                    Icons.calendar_today,
                  ),
                  Container(height: 30, width: 1, color: Colors.white24),
                  _buildBannerStatItem(
                    'Active Grounds',
                    '${controller.totalGrounds.value}',
                    Icons.map_outlined,
                  ),
                  Container(height: 30, width: 1, color: Colors.white24),
                  _buildBannerStatItem(
                    'Reviews',
                    '${controller.pendingReviewsCount.value}',
                    Icons.star_outline,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
      ],
    );
  }

  Widget _buildManagementGrid(OwnerController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        crossAxisSpacing: AppSpacing.m,
        mainAxisSpacing: AppSpacing.m,
        children: [
          _buildNewManagementCard(
            'Complex',
            Icons.business,
            Colors.blue,
            () => Get.to(() => const SportsComplexesPage()),
          ),
          _buildNewManagementCard(
            'Grounds',
            Icons.sports_soccer,
            Colors.indigo,
            () => Get.to(() => const SportsGroundsPage()),
          ),
          _buildNewManagementCard(
            'Bookings',
            Icons.calendar_month,
            Colors.green,
            () => Get.to(() => const OwnerBookingsView()),
          ),
          _buildNewManagementCard(
            'Reports',
            Icons.analytics,
            Colors.deepOrange,
            () => Get.to(() => const OwnerReportsPage()),
          ),
          _buildNewManagementCard(
            'Deals',
            Icons.local_offer,
            Colors.amber,
            () => Get.to(() => const OwnerDealsPage()),
          ),
          _buildNewManagementCard(
            'Reviews',
            Icons.rate_review,
            Colors.purple,
            () => Get.to(() => const ReviewModerationPage()),
            badge: controller.pendingReviewsCount.value > 0
                ? controller.pendingReviewsCount.value.toString()
                : null,
          ),
          _buildNewManagementCard(
            'Wallet',
            Icons.account_balance_wallet,
            Colors.teal,
            () => Get.to(() => const WalletPage()),
          ),
          _buildNewManagementCard(
            'Support',
            Icons.contact_support,
            Colors.blueGrey,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildNewManagementCard(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    String? badge,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              if (badge != null)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppSpacing.m, 60, AppSpacing.m, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(AppConstants.appIcon, height: 20, width: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Welcome Back,',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                'Owner Dashboard',
                style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryLight,
              child: const Icon(Icons.person, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplexCard(dynamic complex) {
    final images = complex['images'] as List<dynamic>?;
    String? rawUrl;
    if (images != null && images.isNotEmpty) {
      rawUrl = images[0];
    } else if (complex['image_path'] != null) {
      rawUrl = complex['image_path'];
    }

    final imageUrl = UrlHelper.sanitizeUrl(rawUrl);

    return GestureDetector(
      onTap: () =>
          Get.toNamed('/complex-detail', arguments: {'id': complex['id']}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: AppColors.primaryLight),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.primaryLight,
                  child: const Icon(Icons.business, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        complex['name'] ?? 'Unnamed',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (complex['status'] == 'active')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    complex['address'] ?? 'No Address',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.layers_outlined,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${complex['grounds_count'] ?? 0} Arenas',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingItem(dynamic booking) {
    final userName = booking['user'] != null
        ? booking['user']['name']
        : 'Customer';
    final groundName = booking['ground'] != null
        ? booking['ground']['name']
        : 'Arena';
    final startTime = booking['start_time'] ?? '';
    final totalAmount = booking['total_price'] ?? '0';
    final paymentStatus = (booking['payment_status'] ?? 'unpaid')
        .toString()
        .toLowerCase();

    return GestureDetector(
      onTap: () =>
          Get.toNamed('/booking-detail', arguments: {'booking': booking}),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.m),
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withValues(alpha: 0.5),
                border: Border.all(
                  color: (paymentStatus == 'paid' ? Colors.green : Colors.orange)
                      .withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: (booking['user'] != null &&
                        booking['user']['avatar'] != null)
                    ? CachedNetworkImage(
                        imageUrl: UrlHelper.sanitizeUrl(
                          booking['user']['avatar'].toString(),
                        ),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Text(
                            userName.isNotEmpty
                                ? userName.substring(0, 1).toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: paymentStatus == 'paid'
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          userName.isNotEmpty
                              ? userName.substring(0, 1).toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: paymentStatus == 'paid'
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          userName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${AppConstants.currencySymbol} ${NumberFormat('#,###').format(double.tryParse(totalAmount.toString()) ?? 0)}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.sports_cricket_outlined,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        groundName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (paymentStatus == 'paid'
                                  ? Colors.green
                                  : Colors.orange)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          paymentStatus.toUpperCase(),
                          style: TextStyle(
                            color: paymentStatus == 'paid'
                                ? Colors.green
                                : Colors.orange,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 10,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
