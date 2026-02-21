import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/landing/controller/landing_controller.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        60,
        AppSpacing.m,
        AppSpacing.xl,
      ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Text(
              'WELCOME TO SPORTS STUDIO',
              style: AppTextStyles.label.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            'Book Your Favorite\nSports Ground',
            style: AppTextStyles.h1.copyWith(color: Colors.white, height: 1.1),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            'Experience the professional match feel at our premium grounds and arenas.',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navigate to Grounds tab (index 1) in the bottom nav
                  final landingController = Get.find<LandingController>();
                  landingController.changeNavIndex(1);
                },
                child: const Text('Explore Grounds'),
              ),
              const SizedBox(width: AppSpacing.m),
              TextButton(
                onPressed: () {
                  Get.defaultDialog(
                    title: 'How It Works',
                    titleStyle: AppTextStyles.h3,
                    content: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStep('1', 'Browse premium grounds near you'),
                          const SizedBox(height: 12),
                          _buildStep('2', 'Select a date and time slot'),
                          const SizedBox(height: 12),
                          _buildStep('3', 'Confirm booking and pay securely'),
                          const SizedBox(height: 12),
                          _buildStep('4', 'Show up and play!'),
                        ],
                      ),
                    ),
                    confirm: ElevatedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Got it!'),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'How it works',
                      style: AppTextStyles.button.copyWith(color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.play_circle_outline, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(description, style: AppTextStyles.bodyMedium)),
      ],
    );
  }
}
