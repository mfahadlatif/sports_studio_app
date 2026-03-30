import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/owner/presentation/widgets/owner_bookings_view.dart';
import 'package:sports_studio/features/owner/presentation/pages/owner_reports_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/sports_complexes_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/owner_deals_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/review_moderation_page.dart';
import 'package:sports_studio/features/user/presentation/pages/edit_profile_page.dart';
import 'package:sports_studio/features/user/presentation/pages/setting_detail_page.dart';
import 'package:sports_studio/features/user/presentation/pages/transactions_page.dart';

class OwnerSettingsView extends StatelessWidget {
  const OwnerSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Owner Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          _buildSettingsSection('Business Settings', [
            _buildSettingsTile(
              Icons.analytics_outlined,
              'Reports & Analytics',
              'Revenue, bookings and performance',
              onTap: () => Get.to(() => const OwnerReportsPage()),
            ),
            _buildSettingsTile(
              Icons.corporate_fare_outlined,
              'Sports Complexes',
              'Manage your complexes & facilities',
              onTap: () => Get.to(() => const SportsComplexesPage()),
            ),
            _buildSettingsTile(
              Icons.local_offer_outlined,
              'Manage Deals',
              'Create & edit discount offers',
              onTap: () => Get.to(() => const OwnerDealsPage()),
            ),
            _buildSettingsTile(
              Icons.calendar_month_outlined,
              'All Bookings',
              'View and manage all bookings',
              onTap: () => Get.to(() => const OwnerBookingsView()),
            ),
            _buildSettingsTile(
              Icons.rate_review_outlined,
              'Review Moderation',
              'Manage player feedback & ratings',
              onTap: () => Get.to(() => const ReviewModerationPage()),
            ),
            _buildSettingsTile(
              Icons.business_outlined,
              'Business Profile',
              'Name, email, and phone number',
              onTap: () => Get.to(() => const EditProfilePage()),
            ),
            _buildSettingsTile(
              Icons.lock_outline,
              'Change Password',
              'Update your password',
              onTap: () => Get.to(
                () => const SettingDetailPage(),
                arguments: const {
                  'title': 'Change Password',
                  'description': 'Update your password',
                },
              ),
            ),
            _buildSettingsTile(
              Icons.payments_outlined,
              'Payment History',
              'See all completed and pending payments',
              onTap: () => Get.to(() => const TransactionsPage()),
            ),
            // _buildSettingsTile(
            //   Icons.schedule_outlined,
            //   'Operating Hours',
            //   'Set when grounds are open',
            //   onTap: () => Get.to(
            //     () => const SettingDetailPage(),
            //     arguments: const {
            //       'title': 'Operating Hours',
            //       'description': 'Set when grounds are open',
            //     },
            //   ),
            // ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: AppTextStyles.h3.copyWith(color: AppColors.primary),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap:
          onTap ??
          () => Get.toNamed(
            '/setting-detail',
            arguments: {'title': title, 'description': subtitle},
          ),
    );
  }
}
