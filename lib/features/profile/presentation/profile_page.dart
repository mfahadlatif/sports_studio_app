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
    final controller = Get.find<LandingController>();
    final profileController = Get.put(ProfileController());

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.l),
              Obx(() => _buildProfileHeader(profileController)),
              const SizedBox(height: AppSpacing.xl),
              _buildProfileOption(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.security_outlined,
                title: 'Security',
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.help_outline,
                title: 'Help Center',
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildLogoutButton(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileController profileController) {
    if (profileController.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = profileController.userProfile;
    final name = user['name'] ?? 'John Doe';
    final email = user['email'] ?? 'johndoe@example.com';
    final avatar = user['avatar'];

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: avatar != null
                  ? NetworkImage(
                      avatar.toString().replaceAll(
                        'localhost',
                        'lightcoral-goose-424965.hostingersite.com',
                      ),
                    )
                  : null,
              child: avatar == null
                  ? const Icon(Icons.person, size: 50, color: AppColors.primary)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        Text(name, style: AppTextStyles.h2),
        Text(email, style: AppTextStyles.bodyMedium),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(title, style: AppTextStyles.bodyLarge),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap:
          onTap ??
          () => Get.toNamed('/setting-detail', arguments: {'title': title}),
    );
  }

  Widget _buildLogoutButton(LandingController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => controller.logout(),
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          elevation: 0,
        ),
      ),
    );
  }
}
