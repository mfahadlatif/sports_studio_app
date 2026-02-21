import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/features/landing/controller/landing_controller.dart';
import 'package:sports_studio/features/landing/presentation/widgets/home_view.dart';
import 'package:sports_studio/features/grounds/presentation/grounds_page.dart';
import 'package:sports_studio/features/events/presentation/events_page.dart';
import 'package:sports_studio/features/contact/presentation/contact_page.dart';
import 'package:sports_studio/core/constants/user_roles.dart';
import 'package:sports_studio/features/owner/presentation/widgets/owner_dashboard_view.dart';
import 'package:sports_studio/features/owner/presentation/widgets/owner_grounds_view.dart';
import 'package:sports_studio/features/owner/presentation/widgets/owner_bookings_view.dart';
import 'package:sports_studio/features/owner/presentation/widgets/owner_settings_view.dart';
import 'package:sports_studio/features/profile/presentation/profile_page.dart';

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
      const ContactPage(),
      const ProfilePage(),
    ];

    final List<Widget> ownerPages = [
      const OwnerDashboardView(),
      OwnerGroundsView(),
      const OwnerBookingsView(),
      const OwnerSettingsView(),
      const ProfilePage(),
    ];

    final List<GButton> userTabs = const [
      GButton(icon: Icons.home_outlined, text: 'Home'),
      GButton(icon: Icons.sports_soccer_outlined, text: 'Grounds'),
      GButton(icon: Icons.event_outlined, text: 'Events'),
      GButton(icon: Icons.contact_support_outlined, text: 'Contact'),
      GButton(icon: Icons.person_outline, text: 'Profile'),
    ];

    final List<GButton> ownerTabs = const [
      GButton(icon: Icons.dashboard_outlined, text: 'Dashboard'),
      GButton(icon: Icons.manage_accounts_outlined, text: 'Manage'),
      GButton(icon: Icons.calendar_month_outlined, text: 'Bookings'),
      GButton(icon: Icons.settings_outlined, text: 'Settings'),
      GButton(icon: Icons.person_outline, text: 'Profile'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.currentRole.value == UserRole.user
                ? 'Sports Studio'
                : 'Owner Dashboard',
            style: AppTextStyles.h3,
          ),
        ),
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
                                : ownerTabs)
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
                          : ownerPages,
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
                        : ownerPages,
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
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 8,
                ),
                child: Obx(
                  () => GNav(
                    rippleColor: Colors.grey[300]!,
                    hoverColor: Colors.grey[100]!,
                    gap: 4,
                    activeColor: AppColors.primary,
                    iconSize: 22,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    duration: const Duration(milliseconds: 400),
                    tabBackgroundColor: AppColors.primaryLight,
                    color: AppColors.textSecondary,
                    tabs: controller.currentRole.value == UserRole.user
                        ? userTabs
                        : ownerTabs,
                    selectedIndex: controller.currentNavIndex.value,
                    onTabChange: (index) {
                      controller.changeNavIndex(index);
                    },
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
