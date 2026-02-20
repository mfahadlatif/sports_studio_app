import 'package:flutter/material.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/widgets/section_header.dart';

class OwnerDashboardView extends StatelessWidget {
  const OwnerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSpacing.l),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.m,
                mainAxisSpacing: AppSpacing.m,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard('Total Bookings', '156', Icons.calendar_today, Colors.blue),
                  _buildStatCard('Total Revenue', 'Rs. 45k', Icons.payments_outlined, Colors.green),
                  _buildStatCard('Active Grounds', '4', Icons.sports_soccer, Colors.orange),
                  _buildStatCard('Reviews', '4.8/5', Icons.star_outline, Colors.amber),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.l),
            
            const SectionHeader(
              title: 'Recent Bookings',
              subtitle: 'Latest activity from your grounds',
            ),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildBookingItem();
              },
            ),
            
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppSpacing.m, 60, AppSpacing.m, AppSpacing.l),
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Owner Dashboard',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                  ),
                  Text(
                    'Welcome Back!',
                    style: AppTextStyles.h1.copyWith(color: Colors.white),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.h3),
          Text(title, style: AppTextStyles.label),
        ],
      ),
    );
  }

  Widget _buildBookingItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sports_cricket, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('John Doe', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text('Cricket Arena - Pitch 1', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('6:00 PM', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
              Text('Today', style: AppTextStyles.label),
            ],
          ),
        ],
      ),
    );
  }
}
