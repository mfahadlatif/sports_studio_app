import 'package:flutter/material.dart';
import 'hero_section.dart';
import 'grounds_preview_section.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/widgets/section_header.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HeroSection(),
            const SizedBox(height: AppSpacing.l),
            const GroundsPreviewSection(),
            const SizedBox(height: AppSpacing.l),
            
            // Stats Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                   _buildStat('50+', 'Arenas'),
                   _buildStat('10k+', 'Players'),
                   _buildStat('4.9/5', 'Rating'),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.l),
            
            // Why Choose Us
            SectionHeader(
              title: 'Why Choose Us',
              subtitle: 'The best sports experience in the city',
            ),
            SizedBox(
              height: 160,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFeatureCard(Icons.verified_user_outlined, 'Certified Grounds'),
                  _buildFeatureCard(Icons.support_agent_outlined, '24/7 Support'),
                  _buildFeatureCard(Icons.payments_outlined, 'Secure Payments'),
                  _buildFeatureCard(Icons.star_outline, 'Professional Staff'),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.l),
            
            // Events Preview
            
             const SizedBox(height: AppSpacing.xxl), // Just for scroll space
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: AppSpacing.m, bottom: AppSpacing.s),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
