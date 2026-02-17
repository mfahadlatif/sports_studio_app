import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../widgets/glass_container.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Reports & Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildChartPlaceholder(
              'Revenue Over Time',
              Icons.show_chart_rounded,
              Colors.greenAccent,
            ),
            const SizedBox(height: 20),
            _buildChartPlaceholder(
              'Bookings by Sport',
              Icons.pie_chart_rounded,
              Colors.orangeAccent,
            ),
            const SizedBox(height: 20),
            _buildChartPlaceholder(
              'Top Performing Grounds',
              Icons.bar_chart_rounded,
              Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder(String title, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.heading3.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.1)),
            ),
            child: Center(
              child: Icon(
                Icons.analytics_outlined,
                size: 64,
                color: color.withOpacity(0.2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total this month',
                style: TextStyle(color: AppColors.textMuted),
              ),
              Text(
                '+15% from last month',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
