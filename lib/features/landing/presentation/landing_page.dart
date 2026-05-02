import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/constants/app_constants.dart';
import 'package:sport_studio/features/landing/controller/landing_controller.dart';
import 'package:sport_studio/features/user/presentation/widgets/home_view.dart';
import 'package:sport_studio/features/user/presentation/pages/grounds_page.dart';
import 'package:sport_studio/features/user/presentation/pages/events_page.dart';
import 'package:sport_studio/core/constants/user_roles.dart';
import 'package:sport_studio/features/owner/presentation/widgets/owner_dashboard_view.dart';
import 'package:sport_studio/features/owner/presentation/widgets/owner_grounds_view.dart';
import 'package:sport_studio/features/owner/presentation/widgets/owner_bookings_view.dart';
import 'package:sport_studio/features/user/presentation/pages/profile_page.dart';
import 'package:sport_studio/features/admin/presentation/widgets/admin_dashboard_view.dart';
import 'package:sport_studio/features/admin/presentation/pages/admin_users_page.dart';
import 'package:sport_studio/features/admin/presentation/pages/admin_complex_management_page.dart';
import 'package:sport_studio/features/admin/presentation/pages/admin_reports_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use put() which reuses existing instance if already registered
    final controller = Get.find<LandingController>();

    final List<Widget> userPages = [
      const HomeView(),
      const GroundsPage(isTab: true),
      const EventsPage(isTab: true),
      const ProfilePage(),
    ];

    final List<Widget> ownerPages = [
      const OwnerDashboardView(),
      const OwnerGroundsView(isTab: true),
      const OwnerBookingsView(isTab: true),
      const ProfilePage(),
    ];

    final List<Widget> adminPages = [
      const AdminDashboardView(),
      const AdminUsersPage(isTab: true),
      const AdminComplexManagementPage(isTab: true),
      const AdminReportsPage(isTab: true),
      const ProfilePage(),
    ];

    final List<GButton> userTabs = [
      GButton(icon: LucideIcons.house, text: 'Home'),
      GButton(icon: LucideIcons.mapPin, text: 'Grounds'),
      GButton(icon: LucideIcons.calendarDays, text: 'Events'),
      GButton(icon: LucideIcons.user, text: 'Profile'),
    ];

    final List<GButton> ownerTabs = [
      GButton(icon: LucideIcons.layoutDashboard, text: 'Dashboard'),
      GButton(icon: LucideIcons.notebookPen, text: 'Manage'),
      GButton(icon: LucideIcons.calendarClock, text: 'Bookings'),
      GButton(icon: LucideIcons.user, text: 'Profile'),
    ];

    final List<GButton> adminTabs = [
      GButton(icon: LucideIcons.shieldCheck, text: 'Admin'),
      GButton(icon: LucideIcons.users, text: 'Users'),
      GButton(icon: LucideIcons.building, text: 'Complexes'),
      GButton(icon: LucideIcons.chartBar, text: 'Reports'),
      GButton(icon: LucideIcons.user, text: 'Profile'),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // 1. If not on Home tab, go back to Home first
        if (controller.currentNavIndex.value > 0) {
          controller.changeNavIndex(0);
          return;
        }

        // 2. Double-tap to exit logic
        final now = DateTime.now();
        final backButtonHasNotBeenPressedOrSnackBarHasClosed =
            controller.lastPressedTime == null ||
            now.difference(controller.lastPressedTime!) >
                const Duration(seconds: 2);

        if (backButtonHasNotBeenPressedOrSnackBarHasClosed) {
          controller.lastPressedTime = now;
          Get.snackbar(
            'Exit App',
            'Press back again to exit',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.black87,
            colorText: Colors.white,
            margin: const EdgeInsets.all(20),
            snackStyle: SnackStyle.FLOATING,
          );
        } else {
          // Allow exit on second press
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
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
                                  : controller.currentRole.value ==
                                        UserRole.owner
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
                    child: Obx(() {
                      final role = controller.currentRole.value;
                      final index = controller.currentNavIndex.value;
                      if (role == UserRole.user) return userPages[index];
                      if (role == UserRole.owner) return ownerPages[index];
                      return adminPages[index];
                    }),
                  ),
                ],
              );
            }

            // Mobile Layout: Use the Bottom Navigation Bar
            return Column(
              children: [
                Expanded(
                  child: Obx(() {
                    final role = controller.currentRole.value;
                    final index = controller.currentNavIndex.value;
                    if (role == UserRole.user) return userPages[index];
                    if (role == UserRole.owner) return ownerPages[index];
                    return adminPages[index];
                  }),
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
            return Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8,
                        ),
                        child: Obx(
                          () => GNav(
                            rippleColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            hoverColor: AppColors.primary.withValues(
                              alpha: 0.05,
                            ),
                            gap: 8,
                            activeColor: AppColors.primary,
                            iconSize: 24,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                            duration: const Duration(milliseconds: 400),
                            tabBackgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
