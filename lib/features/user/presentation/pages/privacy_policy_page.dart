import 'package:flutter/material.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/theme/app_spacing.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sports Studio Privacy Policy', style: AppTextStyles.h1),
            const SizedBox(height: 8),
            Text(
              'Last Updated: October 2023',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 32),
            _section(
              '1. Information We Collect',
              'We collect information you provide directly to us when you create an account, make a booking, subscribe to our newsletter, or communicate with us.',
              items: [
                'Personal Information: Name, email address, phone number, and payment information.',
                'Usage Data: Information about your interactions with our platform, such as booking history and preferences.',
              ],
            ),
            _section(
              '2. How We Use Your Information',
              'We use the collected data to:',
              items: [
                'Process your bookings and payments.',
                'Send you booking confirmations and reminders.',
                'Improve our platform functionality and user experience.',
                'Respond to your comments, questions, and customer service requests.',
              ],
            ),
            _section(
              '3. Information Sharing',
              'We do not sell your personal information. We may share your information with third-party service providers who assist us in operating our platform (e.g., payment processors), strictly for the purpose of providing those services.',
            ),
            _section(
              '4. Data Security',
              'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no internet transmission is completely secure.',
            ),
            _section(
              '5. Contact Us',
              'If you have any questions about this Privacy Policy, please contact us at privacy@indoorsportsarena.com.',
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String content, {List<String>? items}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(content, style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
          if (items != null) ...[
            const SizedBox(height: 8),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
