import 'package:flutter/material.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/theme/app_spacing.dart';

class BookingPolicyPage extends StatelessWidget {
  const BookingPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Policy'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking Policy', style: AppTextStyles.h2),
            const SizedBox(height: 10),
            Text(
              'This policy explains how bookings and slot reservations work.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 20),
            _section(
              'Slot reservation window',
              'Online payments reserve your slot for a limited time (typically 20 minutes). If payment is not completed, the reservation may expire and the slot becomes available again.',
            ),
            _section(
              'Cash / Wallet',
              'Cash and Wallet bookings are confirmed instantly and do not expire automatically.',
            ),
            _section(
              'Cancellations',
              'You can cancel a booking from your bookings screen. Refunds (if applicable) depend on the venue policy.',
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

