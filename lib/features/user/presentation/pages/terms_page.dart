import 'package:flutter/material.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/theme/app_spacing.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Terms & Conditions', style: AppTextStyles.h2),
            const SizedBox(height: 10),
            Text(
              'These terms govern the use of Sports Studio. By using the app, you agree to these terms.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 20),
            _section(
              'Bookings',
              'Bookings are subject to ground availability. You are responsible for arriving on time and following ground rules.',
            ),
            _section(
              'Payments',
              'Online payments are processed via Safepay. Wallet/cash payments follow the applicable flow shown in the app.',
            ),
            _section(
              'User Conduct',
              'Users must not misuse the platform, attempt fraud, or violate venue policies.',
            ),
            _section(
              'Liability',
              'Sports Studio is a booking platform; venue-specific rules and safety policies apply at the venue.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: 6),
          Text(body, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

