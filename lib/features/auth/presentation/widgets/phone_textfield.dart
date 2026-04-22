import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/features/auth/controller/auth_controller.dart';
import 'package:sport_studio/widgets/app_text_field.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PhoneTextfield extends StatefulWidget {
  final TextEditingController controller;
  const PhoneTextfield({super.key, required this.controller});

  @override
  State<PhoneTextfield> createState() => _PhoneTextfieldState();
}

class _PhoneTextfieldState extends State<PhoneTextfield> {
  final AuthController _authController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: AppColors.border),
      ),
      child: Row(
        children: [
          Obx(
            () => Container(
              height: 58,
              width: 105,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: CountryCodePicker(
                key: ValueKey(_authController.countryCode.value),
                padding: const EdgeInsets.all(0),
                margin: const EdgeInsets.all(2),
                onChanged: (value) {
                  _authController.code.value = value.dialCode!;
                  _authController.dialCode.value = value.dialCode!;
                },
                initialSelection: _authController.countryCode.value.isEmpty
                    ? '+92' // Default to Pakistan if no value is set
                    : _authController.countryCode.value,
                // Only show the country code that matches the selected country
                countryFilter: _authController.countryCode.value.isNotEmpty
                    ? [_authController.countryCode.value]
                    : null,
                favorite: ['PK', 'AE', 'SA'],
                textStyle: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppTextField(
              fillColor: Colors.transparent,
              controller: widget.controller,
              keyboardType: TextInputType.number,
              hasBorder: false,
              hintText: "Enter your phone number".tr,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        ],
      ),
    );
  }
}
