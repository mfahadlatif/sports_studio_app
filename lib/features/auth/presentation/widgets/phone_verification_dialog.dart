import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/auth/controller/phone_verification_controller.dart';
import 'package:sports_studio/widgets/app_button.dart';
import 'package:sports_studio/widgets/phone_input_field.dart';
import 'package:sports_studio/core/utils/app_utils.dart';

class PhoneVerificationDialog extends StatefulWidget {
  final String initialPhone;
  final VoidCallback onVerified;

  const PhoneVerificationDialog({
    super.key,
    required this.initialPhone,
    required this.onVerified,
  });

  @override
  State<PhoneVerificationDialog> createState() =>
      _PhoneVerificationDialogState();
}

class _PhoneVerificationDialogState extends State<PhoneVerificationDialog> {
  final controller = Get.put(PhoneVerificationController());
  late TextEditingController phoneController;
  final otpController = TextEditingController();
  bool showOtpField = false;

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Verify Phone', style: AppTextStyles.h2),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                'A verified phone number is required for booking.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              if (!showOtpField) ...[
                PhoneTextfield(
                  controller: phoneController,
                  countryCode: controller.countryCode,
                  dialCode: controller.dialCode,
                  label: 'Phone Number',
                  isRequired: true,
                ),
                const SizedBox(height: AppSpacing.l),
                AppButton(
                  label: 'Send Verification Code',
                  isLoading: controller.isLoading.value,
                  onPressed: () async {
                    if (phoneController.text.trim().isEmpty) {
                      AppUtils.showWarning(
                        message: 'Please enter your phone number',
                      );
                      return;
                    }
                    FocusScope.of(context).unfocus();
                    final formattedPhone = controller.formatPhone(
                      controller.dialCode.value,
                      phoneController.text.trim(),
                    );
                    final success =
                        await controller.requestVerification(formattedPhone);
                    if (success) {
                      setState(() => showOtpField = true);
                    }
                  },
                ),
              ] else ...[
                Text(
                  'Enter the 6-digit code sent to ${controller.formatPhone(controller.dialCode.value, phoneController.text.trim())}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    letterSpacing: 8,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '000000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                const SizedBox(height: AppSpacing.l),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => showOtpField = false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Edit Number'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: AppButton(
                        label: 'Verify',
                        isLoading: controller.isLoading.value,
                        onPressed: () async {
                          if (otpController.text.trim().length != 6) {
                            AppUtils.showWarning(
                              message: 'Please enter the 6-digit code',
                            );
                            return;
                          }
                          FocusScope.of(context).unfocus();
                          final formattedPhone = controller.formatPhone(
                            controller.dialCode.value,
                            phoneController.text.trim(),
                          );
                          final success = await controller.verifyPhone(
                            formattedPhone,
                            otpController.text.trim(),
                          );
                          if (success) {
                            widget.onVerified();
                            Get.back(); // This closes the dialog
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
