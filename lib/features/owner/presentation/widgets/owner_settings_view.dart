import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';

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
              onTap: () => Get.toNamed('/owner-reports'),
            ),
            _buildSettingsTile(
              Icons.corporate_fare_outlined,
              'Sports Complexes',
              'Manage your complexes & facilities',
              onTap: () => Get.toNamed('/sports-complexes'),
            ),
            _buildSettingsTile(
              Icons.local_offer_outlined,
              'Manage Deals',
              'Create & edit discount offers',
              onTap: () => Get.toNamed('/owner-deals'),
            ),
            _buildSettingsTile(
              Icons.rate_review_outlined,
              'Review Moderation',
              'Manage player feedback & ratings',
              onTap: () => Get.toNamed('/review-moderation'),
            ),
            _buildSettingsTile(
              Icons.business_outlined,
              'Business Profile',
              'Name, email, and phone number',
              onTap: () => Get.toNamed('/edit-profile'),
            ),
            _buildSettingsTile(
              Icons.lock_outline,
              'Change Password',
              'Update your password',
              onTap: () => Get.toNamed(
                '/setting-detail',
                arguments: {
                  'title': 'Change Password',
                  'description': 'Update your password',
                },
              ),
            ),
            _buildSettingsTile(
              Icons.payments_outlined,
              'Payment Methods',
              'Payouts and bank accounts',
              onTap: () => Get.toNamed(
                '/setting-detail',
                arguments: {
                  'title': 'Payment Methods',
                  'description': 'Payouts and bank accounts',
                },
              ),
            ),
            _buildSettingsTile(
              Icons.schedule_outlined,
              'Operating Hours',
              'Set when grounds are open',
              onTap: () => Get.toNamed(
                '/setting-detail',
                arguments: {
                  'title': 'Operating Hours',
                  'description': 'Set when grounds are open',
                },
              ),
            ),
          ]),
          const SizedBox(height: AppSpacing.l),
          _buildSettingsSection('App Settings', [
            _buildSettingsTile(
              Icons.notifications_outlined,
              'Notifications',
              'Push and email alerts',
              onTap: () => Get.toNamed('/notifications'),
            ),
            _buildSettingsTile(
              Icons.language_outlined,
              'Language',
              'Default app language',
              onTap: () => Get.toNamed(
                '/setting-detail',
                arguments: {
                  'title': 'Language',
                  'description': 'Default app language',
                },
              ),
            ),
            _buildSettingsTile(
              Icons.dark_mode_outlined,
              'Dark Mode',
              'Appearance settings',
              onTap: () => Get.toNamed(
                '/setting-detail',
                arguments: {
                  'title': 'Dark Mode',
                  'description': 'Appearance settings',
                },
              ),
            ),
          ]),
          const SizedBox(height: AppSpacing.l),
          _buildSettingsSection('Support', [
            _buildSettingsTile(
              Icons.help_outline,
              'Help Center',
              'FAQs and troubleshooting',
              onTap: () => Get.toNamed(
                '/setting-detail',
                arguments: {
                  'title': 'Help Center',
                  'description': 'FAQs and troubleshooting',
                },
              ),
            ),
            _buildSettingsTile(
              Icons.privacy_tip_outlined,
              'Privacy Policy',
              'Terms and conditions',
              onTap: () => Get.toNamed('/privacy-policy'),
            ),
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
