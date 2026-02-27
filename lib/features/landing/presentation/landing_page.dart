import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/landing/controller/landing_controller.dart';
import 'package:sports_studio/features/user/presentation/widgets/home_view.dart';
import 'package:sports_studio/features/user/presentation/pages/grounds_page.dart';
import 'package:sports_studio/features/user/presentation/pages/events_page.dart';
import 'package:sports_studio/features/user/presentation/pages/teams_page.dart'; // Changed from contact_page.dart to teams_page.dart
import 'package:sports_studio/core/constants/user_roles.dart';
import 'package:sports_studio/features/owner/presentation/widgets/owner_dashboard_view.dart';
import 'package:sports_studio/features/owner/presentation/widgets/owner_grounds_view.dart';
import 'package:sports_studio/features/owner/presentation/widgets/owner_bookings_view.dart';
import 'package:sports_studio/features/owner/presentation/widgets/owner_settings_view.dart';
import 'package:sports_studio/features/user/presentation/pages/profile_page.dart';
import 'package:sports_studio/features/admin/presentation/widgets/admin_dashboard_view.dart';
import 'package:sports_studio/features/admin/presentation/pages/admin_users_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use put() which reuses existing instance if already registered
    final controller = Get.put(LandingController(), permanent: true);

    final List<Widget> userPages = [
      const HomeView(),
      const GroundsPage(),
      const EventsPage(),
      const TeamsPage(), // Changed from ContactPage to TeamsPage
      const ProfilePage(),
    ];

    final List<Widget> ownerPages = [
      const OwnerDashboardView(),
      OwnerGroundsView(),
      const OwnerBookingsView(),
      const OwnerSettingsView(),
      const ProfilePage(),
    ];

    final List<Widget> adminPages = [
      const AdminDashboardView(),
      const AdminUsersPage(),
      const Center(child: Text('Complex Management')),
      const Center(child: Text('Global Reports')),
      const ProfilePage(),
    ];

    final List<GButton> userTabs = const [
      GButton(icon: Icons.home_outlined, text: 'Home'),
      GButton(icon: Icons.sports_soccer_outlined, text: 'Grounds'),
      GButton(icon: Icons.event_outlined, text: 'Events'),
      GButton(
        icon: Icons.groups_outlined,
        text: 'Community',
      ), // Changed text from 'Community'
      GButton(icon: Icons.person_outline, text: 'Profile'),
    ];

    final List<GButton> ownerTabs = const [
      GButton(icon: Icons.dashboard_outlined, text: 'Dashboard'),
      GButton(icon: Icons.manage_accounts_outlined, text: 'Manage'),
      GButton(icon: Icons.calendar_month_outlined, text: 'Bookings'),
      GButton(icon: Icons.settings_outlined, text: 'Settings'),
      GButton(icon: Icons.person_outline, text: 'Profile'),
    ];

    final List<GButton> adminTabs = const [
      GButton(icon: Icons.admin_panel_settings_outlined, text: 'Admin'),
      GButton(icon: Icons.people_outline, text: 'Users'),
      GButton(icon: Icons.business_outlined, text: 'Complexes'),
      GButton(icon: Icons.analytics_outlined, text: 'Reports'),
      GButton(icon: Icons.person_outline, text: 'Profile'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final role = controller.currentRole.value;
          if (role == UserRole.user) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AppConstants.appLogo,
                  height: 32,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Text('Sports Studio', style: AppTextStyles.h3),
              ],
            );
          } else if (role == UserRole.owner) {
            return Text('Owner Dashboard', style: AppTextStyles.h3);
          } else {
            return Text('Admin Control Panel', style: AppTextStyles.h3);
          }
        }),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            // Web Layout: Use a side Navigation Rail
            return Row(
              children: [
                Obx(
                  () => NavigationRail(
                    selectedIndex: controller.currentNavIndex.value,
                    onDestinationSelected: (index) {
                      controller.changeNavIndex(index);
                    },
                    labelType: NavigationRailLabelType.all,
                    selectedIconTheme: const IconThemeData(
                      color: AppColors.primary,
                    ),
                    selectedLabelTextStyle: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    destinations:
                        (controller.currentRole.value == UserRole.user
                                ? userTabs
                                : controller.currentRole.value == UserRole.owner
                                ? ownerTabs
                                : adminTabs)
                            .map(
                              (tab) => NavigationRailDestination(
                                icon: Icon(tab.icon),
                                label: Text(tab.text),
                              ),
                            )
                            .toList(),
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: Obx(
                    () => IndexedStack(
                      index: controller.currentNavIndex.value,
                      children: controller.currentRole.value == UserRole.user
                          ? userPages
                          : controller.currentRole.value == UserRole.owner
                          ? ownerPages
                          : adminPages,
                    ),
                  ),
                ),
              ],
            );
          }

          // Mobile Layout: Use the Bottom Navigation Bar
          return Column(
            children: [
              Expanded(
                child: Obx(
                  () => IndexedStack(
                    index: controller.currentNavIndex.value,
                    children: controller.currentRole.value == UserRole.user
                        ? userPages
                        : controller.currentRole.value == UserRole.owner
                        ? ownerPages
                        : adminPages,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return const SizedBox.shrink(); // Hide bottom nav on web
          }
          return ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.black.withOpacity(.1),
                    ),
                  ],
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 8,
                    ),
                    child: Obx(
                      () => GNav(
                        rippleColor: AppColors.primary.withOpacity(0.1),
                        hoverColor: AppColors.primary.withOpacity(0.05),
                        gap: 8,
                        activeColor: AppColors.primary,
                        iconSize: 24,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        duration: const Duration(milliseconds: 400),
                        tabBackgroundColor: AppColors.primary.withOpacity(0.1),
                        color: AppColors.textSecondary,
                        tabs: controller.currentRole.value == UserRole.user
                            ? userTabs
                            : controller.currentRole.value == UserRole.owner
                            ? ownerTabs
                            : adminTabs,
                        selectedIndex: controller.currentNavIndex.value,
                        onTabChange: (index) {
                          controller.changeNavIndex(index);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
