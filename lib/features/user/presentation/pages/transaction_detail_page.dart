import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:sports_studio/core/models/models.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';

class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final arg = Get.arguments;
    final Transaction? tx = arg is Transaction ? arg : null;

    if (tx == null) {
      return const Scaffold(
        body: Center(child: Text('Transaction not found')),
      );
    }

    final status = tx.status.toLowerCase();
    final statusColor = switch (status) {
      'completed' || 'success' => Colors.green,
      'pending' => Colors.orange,
      'failed' || 'cancelled' => Colors.red,
      _ => AppColors.textMuted,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${AppConstants.currencySymbol} ${tx.amount.toStringAsFixed(0)}',
                              style: AppTextStyles.h2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: statusColor.withOpacity(0.25),
                              ),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: AppTextStyles.label.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.m),
                      _row('Booking', tx.bookingId == 0 ? '—' : '#BK${tx.bookingId}'),
                      _row('Payment method', (tx.paymentMethod ?? '—').toString().toUpperCase()),
                      _row('Transaction ID', tx.transactionId ?? '—'),
                      _row(
                        'Created',
                        AppUtils.formatDateTime(tx.createdAt),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                Text(
                  'Tip: If this is pending for a long time, try again or contact support.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

