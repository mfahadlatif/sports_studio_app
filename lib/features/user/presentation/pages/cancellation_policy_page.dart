import 'package:flutter/material.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/theme/app_spacing.dart';

class CancellationPolicyPage extends StatelessWidget {
  const CancellationPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cancellation & Refund Policy'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cancellation & Refund Policy', style: AppTextStyles.h2),
            const SizedBox(height: 10),
            Text(
              'Cancellation rules can vary by venue. Always review the ground’s cancellation policy on the ground details screen.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 20),
            _section(
              'When you cancel',
              'Cancelling a booking releases the reserved slot immediately.',
            ),
            _section(
              'Refunds',
              'If a refund is applicable, it depends on the venue policy and payment method. Wallet refunds (if supported) typically return to wallet balance.',
            ),
            _section(
              'Support',
              'If you believe there is an issue with a cancellation/refund, contact support from the Help screen.',
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

