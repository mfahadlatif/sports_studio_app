import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/features/user/controller/payment_controller.dart';
import 'package:sports_studio/features/user/presentation/pages/transaction_detail_page.dart';
import 'package:sports_studio/widgets/app_progress_indicator.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        centerTitle: true,
      ),
      body: Obx(() {
        final txs = controller.transactions;

        if (txs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppColors.textMuted.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                Text('No payments yet', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Your completed and pending payments will show here.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => controller.refreshTransactions(),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.m),
            itemCount: txs.length,
            itemBuilder: (_, index) {
              final tx = txs[index];
              final createdAt = tx.createdAt;
              final dateStr = createdAt != null
                  ? DateFormat('MMM dd, yyyy • hh:mm a').format(createdAt)
                  : '—';
              final status = tx.status.toLowerCase();
              Color statusColor;
              IconData statusIcon;
              switch (status) {
                case 'completed':
                case 'success':
                  statusColor = Colors.green;
                  statusIcon = Icons.check_circle_outline;
                  break;
                case 'pending':
                  statusColor = Colors.orange;
                  statusIcon = Icons.hourglass_top_outlined;
                  break;
                case 'failed':
                case 'cancelled':
                  statusColor = Colors.red;
                  statusIcon = Icons.error_outline;
                  break;
                default:
                  statusColor = AppColors.textMuted;
                  statusIcon = Icons.help_outline;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.m),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.m),
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Icon(statusIcon, color: statusColor),
                  ),
                  title: Text(
                    'Rs. ${tx.amount.toStringAsFixed(0)}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (tx.paymentMethod ?? 'Safepay').toString().toUpperCase(),
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: AppTextStyles.label.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      if (tx.bookingId != 0) ...[
                        const SizedBox(height: 6),
                        Text(
                          '#BK${tx.bookingId}',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                  onTap: () {
                    Get.to(() => const TransactionDetailPage(), arguments: tx);
                  },
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

