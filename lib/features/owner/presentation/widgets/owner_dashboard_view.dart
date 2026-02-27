import 'package:flutter/material.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/widgets/section_header.dart';
import 'package:get/get.dart';
import 'package:sports_studio/widgets/app_shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sports_studio/features/owner/controller/owner_controller.dart';
import 'package:sports_studio/core/utils/url_helper.dart';

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
              _buildHeader(),
              const SizedBox(height: AppSpacing.m),

              // ── Current Status Banner ───────────────────────────
              _buildStatusBanner(controller),

              const SizedBox(height: AppSpacing.l),

              // ── Analytics Stat Grid ─────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.m,
                      mainAxisSpacing: AppSpacing.m,
                      childAspectRatio: 1.4,
                      children: List.generate(
                        4,
                        (index) => const AppShimmer.rectangular(
                          height: 100,
                          shapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                    );
                  }
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.m,
                    mainAxisSpacing: AppSpacing.m,
                    childAspectRatio: 1.4,
                    children: [
                      _buildStatCard(
                        'Total Complexes',
                        '${controller.totalComplexes.value}',
                        Icons.business_outlined,
                        AppColors.primary,
                      ),
                      _buildStatCard(
                        'Total Grounds',
                        '${controller.totalGrounds.value}',
                        Icons.map_outlined,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Total Bookings',
                        '${controller.totalBookings.value}',
                        Icons.calendar_today_outlined,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Total Revenue',
                        'Rs. ${(controller.totalRevenue.value / 1000).toStringAsFixed(1)}k',
                        Icons.payments_outlined,
                        Colors.green,
                      ),
                    ],
                  );
                }),
              ),

              const SizedBox(height: AppSpacing.l),

              // ── Quick Management Grid ──────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                child: Text('Management', style: AppTextStyles.h3),
              ),
              const SizedBox(height: AppSpacing.m),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.m,
                  mainAxisSpacing: AppSpacing.m,
                  childAspectRatio: 2.2,
                  children: [
                    _buildManagementCard(
                      'Reports',
                      Icons.analytics_outlined,
                      Colors.indigo,
                      () => Get.toNamed('/owner-reports'),
                    ),
                    _buildManagementCard(
                      'Complexes',
                      Icons.corporate_fare_outlined,
                      Colors.teal,
                      () => Get.toNamed('/sports-complexes'),
                    ),
                    _buildManagementCard(
                      'Deals',
                      Icons.local_offer_outlined,
                      Colors.deepOrange,
                      () => Get.toNamed('/owner-deals'),
                    ),
                    _buildManagementCard(
                      'Reviews',
                      Icons.rate_review_outlined,
                      Colors.amber,
                      () => Get.toNamed('/review-moderation'),
                    ),
                    _buildManagementCard(
                      'Add Complex',
                      Icons.add_business_outlined,
                      AppColors.primary,
                      () => Get.toNamed(
                        '/add-complex',
                      ), // Assuming this route exists
                    ),
                    _buildManagementCard(
                      'Add Ground',
                      Icons.add_location_alt_outlined,
                      Colors.orange,
                      () => Get.toNamed('/add-ground'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.l),

              const SectionHeader(
                title: 'My Complexes',
                subtitle: 'Active sports facilities',
              ),
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
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.m),
                    child: Text(
                      'No complexes listed yet.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
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
              const SectionHeader(
                title: 'Recent Bookings',
                subtitle: 'Latest player activity',
              ),
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
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.m),
                    child: Text(
                      'No recent bookings.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  );
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

  Widget _buildStatusBanner(OwnerController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Status',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBannerStat(
                    'Bookings',
                    '${controller.totalBookings.value}',
                  ),
                  _buildBannerStat(
                    'Revenue',
                    '${(controller.monthlyRevenue.value / 1000).toStringAsFixed(1)}K',
                  ),
                  _buildBannerStat(
                    'Complexes',
                    '${controller.totalComplexes.value}',
                  ),
                  _buildBannerStat(
                    'Grounds',
                    '${controller.totalGrounds.value}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
                color: AppColors.primary.withOpacity(0.2),
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

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900),
          ),
          Text(
            title,
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementCard(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
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
          Get.toNamed('/complex-detail', arguments: {'complex': complex}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
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
                  Text(
                    complex['name'] ?? 'Unnamed',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: paymentStatus == 'paid'
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.sports_cricket,
              color: paymentStatus == 'paid' ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      'Rs. $totalAmount',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      groundName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      startTime.toString().split(' ').last.substring(0, 5),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
