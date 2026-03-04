import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/widgets/app_text_field.dart';

/// Premium Phone Input Field with Country Code Picker
/// Styled based on user sample code
class PhoneTextfield extends StatelessWidget {
  final TextEditingController controller;
  final RxString countryCode;
  final RxString dialCode;
  final String label;
  final bool isRequired;
  final Function(String)? onPhoneChanged;

  const PhoneTextfield({
    super.key,
    required this.controller,
    required this.countryCode,
    required this.dialCode,
    this.label = 'Phone Number',
    this.isRequired = false,
    this.onPhoneChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Row(
            children: [
              Text(
                label,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isRequired)
                const Text(' *', style: TextStyle(color: Colors.red)),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: 58,
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 1, color: AppColors.border),
          ),
          child: Row(
            children: [
              Obx(
                () => Container(
                  height: 58,
                  width: 90,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(11),
                      bottomLeft: Radius.circular(11),
                    ),
                  ),
                  child: CountryCodePicker(
                    key: ValueKey(countryCode.value),
                    padding: const EdgeInsets.all(0),
                    margin: const EdgeInsets.all(2),
                    onChanged: (value) {
                      dialCode.value = value.dialCode ?? '+92';
                      countryCode.value = value.code ?? 'PK';
                      if (onPhoneChanged != null) {
                        onPhoneChanged!(dialCode.value + controller.text);
                      }
                    },
                    initialSelection: countryCode.value.isEmpty
                        ? 'PK'
                        : countryCode.value,
                    favorite: const ['PK', 'AE', 'SA'],
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    showCountryOnly: false,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppTextField(
                  fillColor: Colors.transparent,
                  controller: controller,
                  keyboardType: TextInputType.number,
                  hasBorder: false,
                  hintText: "Enter phone number",
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) {
                    if (onPhoneChanged != null) {
                      onPhoneChanged!(dialCode.value + v);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Legacy wrapper for SimplePhoneInputField to maintain compatibility while using the new design
class SimplePhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final bool isRequired;
  final Function(String)? onPhoneChanged;
  final String initialCountry;

  // We need to provide Rx variables if they aren't provided
  // In many cases these come from a controller, so it's better to use PhoneTextfield directly.
  // But for compatibility with existing code:

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
  Widget build(BuildContext context) {
    // For local state if not provided
    final RxString cCode = initialCountry.obs;
    final RxString dCode =
        '+92'.obs; // Default dial code, will be updated by picker

    return PhoneTextfield(
      controller: controller,
      countryCode: cCode,
      dialCode: dCode,
      label: label,
      isRequired: isRequired,
      onPhoneChanged: onPhoneChanged,
    );
  }
}
