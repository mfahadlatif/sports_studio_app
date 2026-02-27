import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/widgets/section_header.dart';
import 'package:sports_studio/widgets/app_shimmer.dart';
import 'package:sports_studio/features/admin/controller/admin_controller.dart';
import 'package:sports_studio/features/user/controller/profile_controller.dart';
import 'package:sports_studio/core/utils/url_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => controller.fetchAdminDashboard(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(profileController),
              const SizedBox(height: AppSpacing.m),

              _buildGlobalStatusBanner(controller),
              const SizedBox(height: AppSpacing.l),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                child: Text('Platform Statistics', style: AppTextStyles.h3),
              ),
              const SizedBox(height: AppSpacing.m),
              _buildStatGrid(controller),

              const SizedBox(height: AppSpacing.l),

              const SectionHeader(
                title: 'Quick Actions',
                subtitle: 'Manage platform resources',
              ),
              _buildQuickActions(),

              const SizedBox(height: AppSpacing.l),

              const SectionHeader(
                title: 'Performance & Maintenance',
                subtitle: 'System health tools',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                child: Column(
                  children: [
                    _maintenanceItem(
                      'Fix Image Storage Link',
                      'Repair broken symbolic links for media visibility',
                      Icons.link_off,
                      Colors.redAccent,
                      () => controller.fixStorage(),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _maintenanceItem(
                      'Cleanup Bookings',
                      'Purge cancelled/expired bookings older than 30 days',
                      Icons.cleaning_services,
                      Colors.blueAccent,
                      () => _confirmAction(
                        context,
                        'Run Bookings Cleanup?',
                        () => controller.cleanupData('bookings'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _maintenanceItem(
                      'Cleanup Events',
                      'Archive past matches and events older than 6 months',
                      Icons.archive_outlined,
                      Colors.orangeAccent,
                      () => _confirmAction(
                        context,
                        'Run Events Cleanup?',
                        () => controller.cleanupData('events'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.l),

              const SectionHeader(
                title: 'Pending Reviews',
                subtitle: 'Requires moderation',
              ),
              _buildPendingReviews(controller),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ProfileController profileController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppSpacing.m, 60, AppSpacing.m, 20),
      child: Obx(() {
        final user = profileController.userProfile;
        final name = user['name'] ?? 'Admin';
        final avatarUrl = UrlHelper.sanitizeUrl(user['avatar']?.toString());

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.admin_panel_settings,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Platform Admin',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  name,
                  style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: user['avatar'] != null
                  ? CachedNetworkImageProvider(avatarUrl)
                  : null,
              child: user['avatar'] == null
                  ? const Icon(Icons.person, color: AppColors.primary)
                  : null,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildGlobalStatusBanner(AdminController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _bannerItem(
                'Revenue',
                'Rs. ${(controller.totalRevenue.value / 1000).toStringAsFixed(1)}k',
              ),
              _bannerItem('Bookings', '${controller.totalBookings.value}'),
              _bannerItem('Users', '${controller.totalUsers.value}'),
              _bannerItem('Events', '${controller.totalActiveEvents.value}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bannerItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildStatGrid(AdminController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Obx(() {
        if (controller.isLoading.value) {
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: List.generate(
              4,
              (index) => AppShimmer.rectangular(height: 100),
            ),
          );
        }
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _statCard(
              'Total Users',
              controller.totalUsers.value.toString(),
              Icons.people,
              Colors.blue,
            ),
            _statCard(
              'Complexes',
              controller.totalComplexes.value.toString(),
              Icons.business,
              Colors.teal,
            ),
            _statCard(
              'Total Sales',
              'Rs. ${controller.totalRevenue.value.toInt()}',
              Icons.payments,
              Colors.green,
            ),
            _statCard(
              'Active Events',
              controller.totalActiveEvents.value.toString(),
              Icons.event,
              Colors.orange,
            ),
          ],
        );
      }),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.h3),
          Text(
            title,
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
        children: [
          _actionBtn(
            'User Mgmt',
            Icons.person_search,
            Colors.indigo,
            () => Get.toNamed('/admin/users'),
          ),
          _actionBtn(
            'Complexes',
            Icons.domain_verification,
            Colors.teal,
            () => Get.toNamed('/admin/complexes'),
          ),
          _actionBtn(
            'All Bookings',
            Icons.receipt_long,
            Colors.amber,
            () => Get.toNamed('/admin/bookings'),
          ),
          _actionBtn(
            'Review Log',
            Icons.thumbs_up_down,
            Colors.deepOrange,
            () => Get.toNamed('/admin/reviews'),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _maintenanceItem(
    String label,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.play_arrow, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _confirmAction(
    BuildContext context,
    String title,
    VoidCallback onConfirm,
  ) {
    Get.defaultDialog(
      title: 'Confirm Operation',
      middleText: title,
      textConfirm: 'Proceed',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () {
        Get.back();
        onConfirm();
      },
    );
  }

  Widget _buildPendingReviews(AdminController controller) {
    return Obx(() {
      if (controller.pendingReviews.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(AppSpacing.m),
          child: Text(
            'No pending reviews for moderation.',
            style: TextStyle(color: AppColors.textMuted),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.pendingReviews.length,
        itemBuilder: (context, index) {
          final review = controller.pendingReviews[index];
          return ListTile(
            title: Text(review['user']?['name'] ?? 'Anonymous'),
            subtitle: Text(review['comment'] ?? ''),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Get.toNamed('/admin/reviews'),
          );
        },
      );
    });
  }
}
