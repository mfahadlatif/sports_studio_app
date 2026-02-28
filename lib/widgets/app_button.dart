import 'package:flutter/material.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';

/// A premium app-wide button with proper inline loading state.
/// Loading shows a small [20×20] white spinner + label, NOT a full-width indicator.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final Widget? leadingIcon;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.height = 54,
    this.borderRadius = 16,
    this.leadingIcon,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primary;
    final fg = textColor ?? Colors.white;

    Widget child;

    if (isLoading) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: fg.withOpacity(0.85),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leadingIcon != null) ...[leadingIcon!, const SizedBox(width: 8)],
          Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: fg,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    final button = SizedBox(
      height: height,
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          disabledBackgroundColor: bg.withOpacity(0.7),
          elevation: isLoading ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: child,
      ),
    );

    return button;
  }
}
