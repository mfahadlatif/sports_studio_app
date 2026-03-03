import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';

/// Phone Input Field Widgets with Country Code Picker
/// 
/// This file provides two phone input widgets with integrated country code picker:
/// 
/// 1. **SimplePhoneInputField** (Recommended for most use cases)
///    - Easy to use, minimal configuration
///    - Shows label and renders complete phone field
///    - Automatically handles country code selection
///    
///    Example:
///    ```dart
///    SimplePhoneInputField(
///      controller: phoneController,
///      hint: 'Enter your phone number',
///      label: 'Phone Number',
///      isRequired: true,
///    )
///    ```
/// 
/// 2. **PhoneInputField** (Advanced use case)
///    - More customization options
///    - Optional label rendering
///    - Callbacks for phone changes and country code changes
///    - Better for complex forms
///    
///    Example:
///    ```dart
///    PhoneInputField(
///      controller: phoneController,
///      labelText: 'Phone Number',
///      hintText: 'Enter phone number',
///      isRequired: true,
///      onChanged: (phone) => print('Phone: $phone'),
///      onCountryCodeChanged: (code) => print('Country: $code'),
///    )
///    ```
/// 
/// Features:
/// - 🌍 180+ countries supported
/// - 📱 Real-time validation
/// - 🎨 Themed input with app colors
/// - ♿ Accessible design
/// - 📝 Complete phone numbers with country codes

class PhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final bool isRequired;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCountryCodeChanged;
  final String initialCountryCode;
  final bool showLabel;
  final int? maxLines;
  final int? minLines;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.hintText = 'Enter phone number',
    this.labelText,
    this.isRequired = false,
    this.onChanged,
    this.onCountryCodeChanged,
    this.initialCountryCode = 'PK',
    this.showLabel = true,
    this.maxLines = 1,
    this.minLines = 1,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  String _selectedCountryCode = 'PK';

  @override
  void initState() {
    super.initState();
    _selectedCountryCode = widget.initialCountryCode;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel && widget.labelText != null) ...[
          Row(
            children: [
              Text(
                widget.labelText!,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (widget.isRequired)
                const Text(
                  ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        IntlPhoneField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.phone_outlined),
            filled: true,
            fillColor: AppColors.background,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide.none,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          initialCountryCode: _selectedCountryCode,
          onChanged: (phone) {
            widget.onChanged?.call(phone.completeNumber);
          },
          onCountryChanged: (country) {
            setState(() {
              _selectedCountryCode = country.countryCode ?? 'PK';
            });
            widget.onCountryCodeChanged?.call(country.countryCode ?? 'PK');
          },
        ),
      ],
    );
  }
}

/// Widget for phone input without specific text field controller
/// This version uses the IntlPhoneField directly for simpler use cases
class SimplePhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final bool isRequired;
  final Function(String)? onPhoneChanged;
  final String initialCountry;

  const SimplePhoneInputField({
    super.key,
    required this.controller,
    this.hint = 'Phone number',
    this.label = 'Phone Number',
    this.isRequired = false,
    this.onPhoneChanged,
    this.initialCountry = 'PK',
  });

  @override
  State<SimplePhoneInputField> createState() => _SimplePhoneInputFieldState();
}

class _SimplePhoneInputFieldState extends State<SimplePhoneInputField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 8),
        IntlPhoneField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: const Icon(Icons.phone_outlined),
            filled: true,
            fillColor: AppColors.background,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide.none,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          initialCountryCode: widget.initialCountry,
          onChanged: (phone) {
            widget.onPhoneChanged?.call(phone.completeNumber);
          },
        ),
      ],
    );
  }
}
