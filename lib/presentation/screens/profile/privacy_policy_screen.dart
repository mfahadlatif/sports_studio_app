import 'package:flutter/material.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy Policy', style: AppTextStyles.heading2),
            const SizedBox(height: 16),
            _buildSection(
              '1. Information Collection',
              'We collect personal information such as name, email, and phone number when you register. Booking details are also stored securely.',
            ),
            _buildSection(
              '2. Usage of Data',
              'Your data is used to process bookings, manage your account, and improve our services. We do not sell your data to third parties.',
            ),
            _buildSection(
              '3. Location Data',
              'We may access your location to show nearby grounds. This permission is optional.',
            ),
            _buildSection(
              '4. Security',
              'We implement industry-standard security measures to protect your information.',
            ),
            _buildSection(
              '5. Contact Us',
              'For privacy concerns, contact support@sportsstudio.com.',
            ),
            const SizedBox(height: 32),
            Text(
              'Last updated: Feb 2026',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(content, style: AppTextStyles.bodyLarge.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}
