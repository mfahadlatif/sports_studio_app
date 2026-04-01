import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/landing/controller/landing_controller.dart';
import 'package:sports_studio/features/user/controller/profile_controller.dart';
import 'package:sports_studio/features/auth/presentation/widgets/phone_verification_dialog.dart';
import 'package:sports_studio/features/user/presentation/pages/wallet_page.dart';
import 'package:sports_studio/features/user/presentation/pages/user_bookings_page.dart';
import 'package:sports_studio/features/user/presentation/pages/favorites_page.dart';
import 'package:sports_studio/features/user/presentation/pages/managed_events_page.dart';
import 'package:sports_studio/features/user/presentation/pages/deals_page.dart';
import 'package:sports_studio/features/user/presentation/pages/edit_profile_page.dart';
// import 'package:sports_studio/features/user/presentation/pages/setting_detail_page.dart';
import 'package:sports_studio/features/user/presentation/pages/notifications_page.dart';
import 'package:sports_studio/features/user/presentation/pages/privacy_policy_page.dart';
import 'package:sports_studio/features/user/presentation/pages/contact_page.dart';
import 'package:sports_studio/features/user/presentation/pages/terms_page.dart';
import 'package:sports_studio/features/user/presentation/pages/booking_policy_page.dart';
import 'package:sports_studio/features/user/presentation/pages/cancellation_policy_page.dart';
import 'package:sports_studio/features/user/presentation/pages/newsletter_subscribe_page.dart';
import 'package:sports_studio/features/user/presentation/pages/joined_events_page.dart';
import 'package:sports_studio/core/utils/url_helper.dart';
import 'package:sports_studio/widgets/app_progress_indicator.dart';

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
                      _buildSectionTitle('ACCOUNT'),
                      _buildOption(
                        icon: Icons.person_outline,
                        title: 'Personal Information',
                        subtitle: 'Update your name, email and details',
                        onTap: () => Get.to(() => const EditProfilePage()),
                        color: Colors.teal,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.l),
                        child: Divider(height: 32),
                      ),
                      _buildSectionTitle('ACTIVITY'),
                      _buildOption(
                        icon: Icons.calendar_today_outlined,
                        title: 'My Match Bookings',
                        subtitle: 'View your upcoming and past arena games',
                        onTap: () => Get.to(() => const UserBookingsPage()),
                        color: Colors.blue,
                      ),
                      _buildOption(
                        icon: Icons.event_seat_outlined,
                        title: 'My Booked Events',
                        subtitle: 'Manage events you have joined',
                        onTap: () => Get.to(() => const JoinedEventsPage()),
                        color: Colors.cyan,
                      ),
                      _buildOption(
                        icon: Icons.favorite_border,
                        title: 'Saved Grounds',
                        subtitle: 'Quick access to your favorite arenas',
                        onTap: () => Get.to(() => const FavoritesPage()),
                        color: Colors.red,
                      ),
                      _buildOption(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Wallet & Withdrawals',
                        subtitle: 'Balance, bank accounts, and cash-out requests',
                        onTap: () => Get.to(() => const WalletPage()),
                        color: Colors.green,
                      ),
                      _buildOption(
                        icon: Icons.event_note_outlined,
                        title: 'My Managed Events',
                        subtitle: 'Events you organize for the community',
                        onTap: () => Get.to(() => const ManagedEventsPage()),
                        color: Colors.pink,
                      ),
                      _buildOption(
                        icon: Icons.local_offer_outlined,
                        title: 'Active Promo Codes',
                        subtitle: 'Exclusive deals just for you',
                        onTap: () => Get.to(() => const DealsPage()),
                        color: Colors.orange,
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.l),
                        child: Divider(height: 32),
                      ),

                      _buildSectionTitle('SETTINGS'),
                      // if (!profileController.isSocialUser)
                      //   _buildOption(
                      //     icon: Icons.security_outlined,
                      //     title: 'Account Security',
                      //     subtitle: 'Manage password and privacy',
                      //     onTap: () => Get.to(
                      //       () => const SettingDetailPage(),
                      //       arguments: {'title': 'Security & Privacy'},
                      //     ),
                      //     color: Colors.indigo,
                      //   ),
                      _buildOption(
                        icon: Icons.notifications_none_outlined,
                        title: 'Notifications',
                        subtitle: 'Manage alerts and push notifications',
                        onTap: () => Get.to(() => const NotificationsPage()),
                        color: Colors.amber,
                      ),
                      _buildOption(
                        icon: Icons.policy_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'How we handle your data',
                        onTap: () => Get.to(() => const PrivacyPolicyPage()),
                        color: Colors.blueGrey,
                      ),
                      _buildOption(
                        icon: Icons.gavel_outlined,
                        title: 'Terms & Conditions',
                        subtitle: 'Legal terms for using the platform',
                        onTap: () => Get.to(() => const TermsPage()),
                        color: Colors.indigo,
                      ),
                      _buildOption(
                        icon: Icons.rule_outlined,
                        title: 'Booking Policy',
                        subtitle: 'How reservations and time windows work',
                        onTap: () => Get.to(() => const BookingPolicyPage()),
                        color: Colors.deepOrange,
                      ),
                      _buildOption(
                        icon: Icons.policy,
                        title: 'Cancellation & Refund Policy',
                        subtitle: 'Cancellation rules and refunds overview',
                        onTap: () => Get.to(() => const CancellationPolicyPage()),
                        color: Colors.brown,
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
                        onTap: () => Get.to(() => const ContactPage()),
                        color: Colors.deepPurple,
                      ),
                      _buildOption(
                        icon: Icons.mark_email_read_outlined,
                        title: 'Newsletter',
                        subtitle: 'Subscribe for updates and deals',
                        onTap: () => Get.to(() => const NewsletterSubscribePage()),
                        color: Colors.teal,
                      ),

                      const SizedBox(height: AppSpacing.l),
                      _buildLogoutButton(landingController),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                // Branding Footer
                Column(
                  children: [
                    Image.asset(
                      AppConstants.appLogo,
                      height: 30,
                      fit: BoxFit.contain,
                      // color: AppColors.textMuted.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Version 1.0.0',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textMuted.withOpacity(0.5),
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
        if (profileController.isLoadingProfile.value) {
          return const AppProgressIndicator(color: Colors.white);
        }

        final user = profileController.userProfile;
        final name = user['name'] ?? 'Sports Lover';
        final email = user['email'] ?? 'Welcome to Sports Studio';

        return Column(
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
                        UrlHelper.sanitizeUrl(user['avatar'].toString()),
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
            const SizedBox(height: AppSpacing.m),
            Text(name, style: AppTextStyles.h2.copyWith(color: Colors.white)),
            Text(
              email,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.8),
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
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
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
                      color: Colors.white.withOpacity(0.8),
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
                    message: 'Are you sure you want to sign out from your account?',
                    confirmText: 'Sign Out',
                    onConfirm: () => controller.logout(),
                  ),
                );
              },
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
                  SizedBox(width: 8),
                  Text(
                    'Sign Out',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                Get.dialog(
                  _buildCustomDialog(
                    icon: Icons.delete_forever_rounded,
                    color: Colors.red,
                    title: 'Delete Account',
                    message: 'Are you sure you want to permanently delete your account? This action cannot be undone.',
                    confirmText: 'Delete',
                    onConfirm: () {
                      final profileController = Get.find<ProfileController>();
                      profileController.deleteAccount();
                    },
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_forever, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Delete Account',
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
              color: Colors.black.withOpacity(0.1),
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
                  color: color.withOpacity(0.1),
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
                      child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
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
                      child: Text(confirmText, style: const TextStyle(fontWeight: FontWeight.bold)),
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
