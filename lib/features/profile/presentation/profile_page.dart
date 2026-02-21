import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/landing/controller/landing_controller.dart';
import 'package:sports_studio/features/profile/controller/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final landingController = Get.find<LandingController>();
    final profileController = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildModernHeader(profileController),
                const SizedBox(height: AppSpacing.l),

                // Content Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.m),
                      _buildSectionTitle('ACTIVITY'),
                      _buildOption(
                        icon: Icons.calendar_today_outlined,
                        title: 'My Match Bookings',
                        subtitle: 'View your upcoming and past games',
                        onTap: () => Get.toNamed('/user-bookings'),
                        color: Colors.blue,
                      ),
                      _buildOption(
                        icon: Icons.favorite_border,
                        title: 'Saved Grounds',
                        subtitle: 'Quick access to your favorite arenas',
                        onTap: () => Get.toNamed('/favorites'),
                        color: Colors.red,
                      ),
                      _buildOption(
                        icon: Icons.local_offer_outlined,
                        title: 'Active Promo Codes',
                        subtitle: 'Exclusive deals just for you',
                        onTap: () => Get.toNamed('/deals'),
                        color: Colors.orange,
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.l),
                        child: Divider(height: 32),
                      ),

                      _buildSectionTitle('SETTINGS'),
                      _buildOption(
                        icon: Icons.person_outline,
                        title: 'Personal Information',
                        subtitle: 'Update your name, email and details',
                        onTap: () => Get.toNamed(
                          '/setting-detail',
                          arguments: {'title': 'Edit Profile'},
                        ),
                        color: Colors.teal,
                      ),
                      _buildOption(
                        icon: Icons.security_outlined,
                        title: 'Account Security',
                        subtitle: 'Manage password and privacy',
                        onTap: () => Get.toNamed(
                          '/setting-detail',
                          arguments: {'title': 'Security & Privacy'},
                        ),
                        color: Colors.indigo,
                      ),
                      _buildOption(
                        icon: Icons.notifications_none_outlined,
                        title: 'Notifications',
                        subtitle: 'Manage alerts and push notifications',
                        onTap: () => Get.toNamed('/notifications'),
                        color: Colors.amber,
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.l),
                        child: Divider(height: 32),
                      ),

                      _buildSectionTitle('SUPPORT'),
                      _buildOption(
                        icon: Icons.help_outline,
                        title: 'Help & FAQ',
                        subtitle: 'Find answers and contact support',
                        onTap: () => Get.toNamed('/contact'),
                        color: Colors.deepPurple,
                      ),

                      const SizedBox(height: AppSpacing.l),
                      _buildLogoutButton(landingController),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(ProfileController profileController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 60, AppSpacing.xl, 40),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Obx(() {
        if (profileController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final user = profileController.userProfile;
        final name = user['name'] ?? 'Sports Lover';
        final email = user['email'] ?? 'Welcome to Sports Studio';

        return Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 54,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: user['avatar'] != null
                        ? NetworkImage(
                            user['avatar'].toString().contains('localhost')
                                ? user['avatar'].toString().replaceAll(
                                    'localhost',
                                    'lightcoral-goose-424965.hostingersite.com',
                                  )
                                : user['avatar'].toString(),
                          )
                        : null,
                    child: user['avatar'] == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Text(name, style: AppTextStyles.h2.copyWith(color: Colors.white)),
            Text(
              email,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.l, 0, AppSpacing.l, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: AppTextStyles.label.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: 4,
      ),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 20,
        color: AppColors.border,
      ),
    );
  }

  Widget _buildLogoutButton(LandingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: TextButton(
          onPressed: () => controller.logout(),
          style: TextButton.styleFrom(
            backgroundColor: Colors.red.withOpacity(0.05),
            foregroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, size: 20),
              const SizedBox(width: 8),
              Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
