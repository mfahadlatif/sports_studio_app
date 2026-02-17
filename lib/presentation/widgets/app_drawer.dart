import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'app_logo.dart';
import '../screens/root_screen.dart';
import '../screens/events/events_screen.dart';

import 'package:provider/provider.dart';
import 'package:sports_studio/domain/providers/auth_provider.dart';
import '../screens/admin/admin_dashboard_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isAdmin = user?.role == 'admin';

    return Drawer(
      backgroundColor: AppColors.background,
      child: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          children: [
            // Header
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: Container(
                padding: const EdgeInsets.all(10),
                alignment: Alignment.centerLeft,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppLogo(size: 80, iconSize: 40, showText: true), // Branded
                  ],
                ),
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  if (isAdmin)
                    _buildDrawerItem(
                      icon: Icons.admin_panel_settings_rounded,
                      title: 'Admin Dashboard',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminDashboardScreen(),
                          ),
                        );
                      },
                    ),
                  _buildDrawerItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const RootScreen()),
                        (route) => false,
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.event_available_rounded,
                    title: 'Events',
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EventsScreen()),
                      );
                    },
                  ),
                  Divider(color: AppColors.glassBorder, height: 32),
                  _buildDrawerItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to Settings
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.info_outline_rounded,
                    title: 'About Us',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: About Screen
                    },
                  ),
                ],
              ),
            ),

            // Footer
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        hoverColor: AppColors.primary.withOpacity(0.1),
        onTap: onTap,
      ),
    );
  }
}
