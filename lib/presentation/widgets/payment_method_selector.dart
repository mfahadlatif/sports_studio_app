import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'glass_container.dart';

enum PaymentMethod { safepay, card, cash }

class PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod selectedMethod;
  final ValueChanged<PaymentMethod> onMethodChanged;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Payment Method',
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildMethodItem(
          method: PaymentMethod.safepay,
          title: 'SafePay (Digital Wallet)',
          icon: Icons.account_balance_wallet_rounded,
        ),
        const SizedBox(height: 12),
        _buildMethodItem(
          method: PaymentMethod.card,
          title: 'Credit / Debit Card',
          icon: Icons.credit_card_rounded,
        ),
        const SizedBox(height: 12),
        _buildMethodItem(
          method: PaymentMethod.cash,
          title: 'Pay at Ground (Cash)',
          icon: Icons.payments_rounded,
        ),
      ],
    );
  }

  Widget _buildMethodItem({
    required PaymentMethod method,
    required String title,
    required IconData icon,
  }) {
    final isSelected = selectedMethod == method;

    return GestureDetector(
      onTap: () => onMethodChanged(method),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.glassBorder,
          width: isSelected ? 2 : 1,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
