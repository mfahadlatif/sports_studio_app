import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final bool hasBorder;
  final Color fillColor;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final TextCapitalization? _textCapitalization;
  TextCapitalization get textCapitalization {
    if (_textCapitalization != null) return _textCapitalization!;
    if (keyboardType == TextInputType.emailAddress ||
        keyboardType == TextInputType.number ||
        keyboardType == TextInputType.phone ||
        keyboardType == TextInputType.visiblePassword) {
      return TextCapitalization.none;
    }
    return TextCapitalization.sentences;
  }

  const AppTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.hasBorder = true,
    this.fillColor = Colors.transparent,
    this.keyboardType = TextInputType.text,
    TextCapitalization? textCapitalization,
    this.inputFormatters,
    this.onChanged,
    this.readOnly = false,
  }) : _textCapitalization = textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      readOnly: readOnly,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textMuted,
        ),
        filled: true,
        fillColor: fillColor,
        border: hasBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              )
            : InputBorder.none,
        enabledBorder: hasBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              )
            : InputBorder.none,
        focusedBorder: hasBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              )
            : InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
