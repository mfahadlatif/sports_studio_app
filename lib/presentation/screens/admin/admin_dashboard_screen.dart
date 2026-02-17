import 'package:flutter/material.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/data/services/api_service.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/presentation/widgets/glass_container.dart';
import 'package:sports_studio/presentation/widgets/app_drawer.dart';
import 'manage_users_screen.dart';
import 'manage_grounds_screen.dart';
import 'manage_bookings_screen.dart';
import 'complexes/manage_complexes_screen.dart';
import 'reports/reports_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Admin Dashboard')),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Metrics Row 1
            FutureBuilder(
              future: ApiService().get('/admin/stats'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.hasData
                    ? snapshot.data?.data
                    : {
                        'users': '0',
                        'revenue': '0',
                        'bookings': '0',
                        'grounds': '0',
                      };

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Total Users',
                            value: '${data?['users'] ?? 0}',
                            icon: Icons.people_alt_rounded,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Revenue',
                            value: '\$${data?['revenue'] ?? 0}',
                            icon: Icons.attach_money_rounded,
                            color: Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Bookings',
                            value: '${data?['bookings'] ?? 0}',
                            icon: Icons.calendar_month_rounded,
                            color: Colors.orangeAccent,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Active Grounds',
                            value: '${data?['grounds'] ?? 0}',
                            icon: Icons.stadium_rounded,
                            color: Colors.purpleAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Management Links
            _buildManagementLink(
              context,
              title: 'Manage Users',
              subtitle: 'View, edit, or block users',
              icon: Icons.people_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
                );
              },
            ),
            _buildManagementLink(
              context,
              title: 'Manage Complexes',
              subtitle: 'Manage sports clubs and facilities',
              icon: Icons.business_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageComplexesScreen(),
                  ),
                );
              },
            ),
            _buildManagementLink(
              context,
              title: 'Manage Grounds',
              subtitle: 'Approve or edit sports grounds',
              icon: Icons.sports_cricket_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageGroundsScreen(),
                  ),
                );
              },
            ),
            _buildManagementLink(
              context,
              title: 'Manage Bookings',
              subtitle: 'Monitor all booking activities',
              icon: Icons.book_online_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageBookingsScreen(),
                  ),
                );
              },
            ),
            _buildManagementLink(
              context,
              title: 'Reports & Analytics',
              subtitle: 'View detailed business insights',
              icon: Icons.analytics_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              // Graph placeholder
              Icon(
                Icons.ssid_chart_rounded,
                color: AppColors.textMuted.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: AppTextStyles.heading2),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementLink(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          // Make it tappable
          onTap: onTap,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textMuted,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
