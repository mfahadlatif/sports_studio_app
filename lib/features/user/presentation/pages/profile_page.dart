import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/constants/app_constants.dart';
import 'package:sport_studio/features/landing/controller/landing_controller.dart';
import 'package:sport_studio/features/user/controller/profile_controller.dart';
import 'package:sport_studio/features/auth/presentation/widgets/phone_verification_dialog.dart';
import 'package:sport_studio/features/user/presentation/pages/wallet_page.dart';
import 'package:sport_studio/features/user/presentation/pages/user_bookings_page.dart';
import 'package:sport_studio/features/user/presentation/pages/favorites_page.dart';
import 'package:sport_studio/features/user/presentation/pages/managed_events_page.dart';
import 'package:sport_studio/features/user/presentation/pages/deals_page.dart';
import 'package:sport_studio/features/user/presentation/pages/edit_profile_page.dart';
import 'package:sport_studio/features/user/presentation/pages/notifications_page.dart';
import 'package:sport_studio/features/user/presentation/pages/contact_page.dart';
import 'package:sport_studio/features/user/presentation/pages/joined_events_page.dart';
import 'package:sport_studio/core/utils/url_helper.dart';
import 'package:sport_studio/features/user/presentation/pages/join_requests_page.dart';
import 'package:sport_studio/features/user/controller/join_requests_controller.dart';
import 'package:sport_studio/widgets/app_progress_indicator.dart';
import 'package:sport_studio/core/constants/user_roles.dart';

// Owner Features
import 'package:sport_studio/features/owner/presentation/pages/owner_reports_page.dart';
import 'package:sport_studio/features/owner/presentation/pages/sports_complexes_page.dart';
import 'package:sport_studio/features/owner/presentation/pages/owner_deals_page.dart';
import 'package:sport_studio/features/owner/presentation/pages/review_moderation_page.dart';
import 'package:sport_studio/features/user/presentation/pages/setting_detail_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final landingController = Get.find<LandingController>();
    final profileController = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: () => profileController.refreshProfileData(),
        displacement: 40,
        color: AppColors.primary,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildModernHeader(profileController),
                  const SizedBox(height: AppSpacing.l),

                  // Content Card
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Obx(() {
                      final role = landingController.currentRole.value;
                      final isOwner = role == UserRole.owner;

                      return Column(
                        children: [
                          const SizedBox(height: AppSpacing.m),

                          // BUSINESS MANAGEMENT (For Owners)
                          if (isOwner) ...[
                            _buildSectionTitle('BUSINESS MANAGEMENT'),
                            _buildOption(
                              icon: Icons.dashboard_outlined,
                              title: 'Dashboard',
                              subtitle: 'Overview and analytics',
                              onTap: () => landingController.changeNavIndex(0),
                              color: Colors.blue,
                            ),
                            _buildOption(
                              icon: Icons.corporate_fare_outlined,
                              title: 'Sports Complexes',
                              subtitle: 'Manage all complexes',
                              onTap: () =>
                                  Get.to(() => const SportsComplexesPage()),
                              color: Colors.indigo,
                            ),
                            _buildOption(
                              icon: Icons.layers_outlined,
                              title: 'My Grounds',
                              subtitle: 'Manage all arenas',
                              onTap: () => landingController.changeNavIndex(1),
                              color: Colors.teal,
                            ),
                            _buildOption(
                              icon: Icons.calendar_month_outlined,
                              title: 'Bookings',
                              subtitle: 'View all bookings',
                              onTap: () => landingController.changeNavIndex(2),
                              color: Colors.green,
                            ),
                            _buildOption(
                              icon: Icons.analytics_outlined,
                              title: 'Reports',
                              subtitle: 'Analytics and revenue',
                              onTap: () =>
                                  Get.to(() => const OwnerReportsPage()),
                              color: Colors.blueGrey,
                            ),
                            _buildOption(
                              icon: Icons.settings_outlined,
                              title: 'Settings',
                              subtitle: 'Profile & preferences',
                              onTap: () =>
                                  Get.to(() => const EditProfilePage()),
                              color: Colors.grey,
                            ),
                            _buildOption(
                              icon: Icons.local_offer_outlined,
                              title: 'Hot Deals',
                              subtitle: 'Manage offers',
                              onTap: () => Get.to(() => const OwnerDealsPage()),
                              color: Colors.orange,
                            ),
                            _buildOption(
                              icon: Icons.rate_review_outlined,
                              title: 'Reviews',
                              subtitle: 'Moderate feedback',
                              onTap: () =>
                                  Get.to(() => const ReviewModerationPage()),
                              color: Colors.purple,
                            ),
                            _buildOption(
                              icon: Icons.account_balance_wallet_outlined,
                              title: 'My Wallet',
                              subtitle: 'Track earnings & payouts',
                              onTap: () => Get.to(() => const WalletPage()),
                              color: Colors.green,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.l,
                              ),
                              child: Divider(height: 32),
                            ),
                          ],

                          _buildSectionTitle('ACCOUNT'),
                          _buildOption(
                            icon: Icons.person_outline,
                            title: 'Personal Information',
                            subtitle: 'Update your name, email and details',
                            onTap: () => Get.to(() => const EditProfilePage()),
                            color: Colors.teal,
                          ),
                          _buildOption(
                            icon: Icons.lock_outline,
                            title: 'Change Password',
                            subtitle: 'Update your account security',
                            onTap: () => Get.to(
                              () => const SettingDetailPage(),
                              arguments: const {
                                'title': 'Change Password',
                                'description': 'Update your password',
                              },
                            ),
                            color: Colors.blueGrey,
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.l,
                            ),
                            child: Divider(height: 32),
                          ),

                          if (!isOwner) ...[
                            _buildSectionTitle('ACTIVITY'),
                            _buildOption(
                              icon: Icons.calendar_today_outlined,
                              title: 'My Match Bookings',
                              subtitle: 'Upcoming and past arena games',
                              onTap: () =>
                                  Get.to(() => const UserBookingsPage()),
                              color: Colors.blue,
                            ),
                            _buildOption(
                              icon: Icons.account_balance_wallet_outlined,
                              title: 'Wallet & Withdrawals',
                              subtitle: 'Balance and cash-out requests',
                              onTap: () => Get.to(() => const WalletPage()),
                              color: Colors.green,
                            ),
                            _buildOption(
                              icon: Icons.favorite_border,
                              title: 'Saved Grounds',
                              subtitle: 'Quick access to your favorite arenas',
                              onTap: () => Get.to(() => const FavoritesPage()),
                              color: Colors.red,
                            ),
                            _buildOption(
                              icon: Icons.event_seat_outlined,
                              title: 'My Booked Events',
                              subtitle: 'Manage events you have joined',
                              onTap: () =>
                                  Get.to(() => const JoinedEventsPage()),
                              color: Colors.cyan,
                            ),
                            _buildOption(
                              icon: Icons.event_note_outlined,
                              title: 'My Managed Events',
                              subtitle: 'Events you organize for the community',
                              onTap: () =>
                                  Get.to(() => const ManagedEventsPage()),
                              color: Colors.pink,
                            ),
                            Obx(() => (profileController.hasOrganizedEvents.value || profileController.pendingJoinRequestsCount.value > 0) ? _buildOption(
                              icon: Icons.person_add_alt_1_outlined,
                              title: 'Join Requests',
                              subtitle: 'Approve players for your events',
                              onTap: () =>
                                  Get.to(() => const JoinRequestsPage()),
                              color: Colors.orange,
                              badge: profileController.pendingJoinRequestsCount.value > 0
                                  ? profileController.pendingJoinRequestsCount.value.toString()
                                  : null,
                            ) : const SizedBox.shrink()),
                            _buildOption(
                              icon: Icons.local_offer_outlined,
                              title: 'Active Promo Codes',
                              subtitle: 'Exclusive deals just for you',
                              onTap: () => Get.to(() => const DealsPage()),
                              color: Colors.orange,
                            ),
                          ],
                          if (!isOwner)
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.l,
                              ),
                              child: Divider(height: 32),
                            ),

                          _buildSectionTitle('SETTINGS'),
                          _buildOption(
                            icon: Icons.notifications_none_outlined,
                            title: 'Notifications',
                            subtitle: 'Manage alerts and push notifications',
                            onTap: () =>
                                Get.to(() => const NotificationsPage()),
                            color: Colors.amber,
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.l,
                            ),
                            child: Divider(height: 32),
                          ),

                          _buildSectionTitle('SUPPORT'),
                          _buildOption(
                            icon: Icons.help_outline,
                            title: 'Help & Support',
                            subtitle: 'Questions? Reach out to our team',
                            onTap: () => Get.to(() => const ContactPage()),
                            color: Colors.deepPurple,
                          ),

                          const SizedBox(height: AppSpacing.l),
                          _buildLogoutButton(landingController),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  // Branding Footer
                  Column(
                    children: [
                      Image.asset(
                        AppConstants.appLogo,
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Version 1.0.0',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textMuted.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF1B6CF2)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Obx(() {
        if (profileController.isLoadingProfile.value) {
          return const AppProgressIndicator(color: Colors.white);
        }

        final user = profileController.userProfile;
        final name = user['name'] ?? 'Sports Lover';
        final email = user['email'] ?? 'Welcome to Sport Studio';

        return Column(
          children: [
            Stack(
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
                    backgroundImage:
                        (user['avatar'] != null &&
                            user['avatar'].toString().isNotEmpty)
                        ? NetworkImage(
                            UrlHelper.sanitizeUrl(user['avatar'].toString()),
                          )
                        : null,
                    child:
                        (user['avatar'] == null ||
                            user['avatar'].toString().isEmpty)
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Get.to(() => const EditProfilePage()),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Text(name, style: AppTextStyles.h2.copyWith(color: Colors.white)),
            Text(
              email,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 12),
            if (!profileController.isPhoneVerified)
              GestureDetector(
                onTap: () {
                  Get.dialog(
                    PhoneVerificationDialog(
                      initialPhone: user['phone']?.toString() ?? '',
                      onVerified: () {
                        profileController.fetchProfile();
                      },
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Verify Phone Number',
                        style: AppTextStyles.label.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified,
                    color: Colors.greenAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Verified Account',
                    style: AppTextStyles.label.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
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
    String? badge,
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
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style:
                AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
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
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: TextButton(
              onPressed: () {
                Get.dialog(
                  _buildCustomDialog(
                    icon: Icons.logout_rounded,
                    color: AppColors.primary,
                    title: 'Sign Out',
                    message:
                        'Are you sure you want to sign out from your account?',
                    confirmText: 'Sign Out',
                    onConfirm: () => controller.logout(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.05),
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Sign Out',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDialog({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: AppSpacing.l),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        confirmText,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
