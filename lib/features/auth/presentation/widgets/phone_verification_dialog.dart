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
  bool isSuccess = false;

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
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with Illustration-like Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    showOtpField ? Icons.vibration : Icons.phone_iphone_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                
                Text(
                  showOtpField ? 'Verify OTP' : 'Phone Verification',
                  style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  showOtpField 
                    ? 'Enter the 6-digit code we sent to your phone'
                    : 'We need to verify your number to proceed with bookings',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isSuccess 
                    ? _buildSuccessView() 
                    : (!showOtpField ? _buildPhoneInput() : _buildOtpInput()),
                ),

                const SizedBox(height: AppSpacing.xl),
                if (!isSuccess) _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      key: const ValueKey('phone_input'),
      children: [
        PhoneTextfield(
          controller: phoneController,
          countryCode: controller.countryCode,
          dialCode: controller.dialCode,
          label: 'Your Number',
          isRequired: true,
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Column(
      key: const ValueKey('otp_input'),
      children: [
        Text(
          controller.formatPhone(controller.dialCode.value, phoneController.text.trim()),
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          autofocus: true,
          style: const TextStyle(
            letterSpacing: 12,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: '●●●●●●',
            hintStyle: TextStyle(
              color: Colors.grey.shade300,
              letterSpacing: 12,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            counterText: '',
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        TextButton(
          onPressed: () => setState(() => showOtpField = false),
          child: Text(
            'Edit Phone Number',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            if (showOtpField)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
                  ),
                ),
              ),
            Expanded(
              flex: 2,
              child: AppButton(
                label: showOtpField ? 'Confirm & Verify' : 'Get Verification Code',
                isLoading: controller.isLoading.value,
                onPressed: () async {
                  if (!showOtpField) {
                    _handleSendCode();
                  } else {
                    _handleVerify();
                  }
                },
              ),
            ),
          ],
        ),
        if (!showOtpField) ...[
          const SizedBox(height: AppSpacing.m),
          GestureDetector(
            onTap: () => Get.back(),
            child: Text(
              'Not now, maybe later',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ],
    );
  }

  void _handleSendCode() async {
    if (phoneController.text.trim().isEmpty) {
      AppUtils.showWarning(message: 'Please enter your phone number');
      return;
    }
    FocusScope.of(context).unfocus();
    final formattedPhone = controller.formatPhone(
      controller.dialCode.value,
      phoneController.text.trim(),
    );
    final success = await controller.requestVerification(formattedPhone);
    if (success) {
      setState(() => showOtpField = true);
    }
  }

  void _handleVerify() async {
    if (otpController.text.trim().length != 6) {
      AppUtils.showWarning(message: 'Please enter the 6-digit code');
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
      setState(() => isSuccess = true);
      widget.onVerified();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      });
    }
  }

  Widget _buildSuccessView() {
    return Column(
      key: const ValueKey('success_view'),
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: Colors.green,
          size: 64,
        ),
        const SizedBox(height: AppSpacing.l),
        Text(
          'Verified Successfully!',
          style: AppTextStyles.h3.copyWith(color: Colors.green),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          'Closing in a moment...',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}
