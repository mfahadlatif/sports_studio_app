import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/constants/app_constants.dart';
import 'package:sport_studio/features/auth/controller/phone_verification_controller.dart';
import 'package:sport_studio/widgets/app_button.dart';
import 'package:sport_studio/widgets/phone_input_field.dart';
import 'package:sport_studio/core/utils/app_utils.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());
  
  bool showOtpField = false;
  bool isSuccess = false;
  Timer? _resendTimer;
  int _resendSeconds = 0;

  @override
  void initState() {
    super.initState();
    
    // Robust stripping of dial code from initial phone to avoid double prefix (e.g. +92+92...)
    String initial = widget.initialPhone;
    String dCode = controller.dialCode.value; // e.g. "+92"
    String dCodeNoPlus = dCode.replaceAll('+', ''); // e.g. "92"
    
    // Remove all non-digits for comparison
    String cleaned = initial.replaceAll(RegExp(r'\D'), '');
    
    if (cleaned.startsWith(dCodeNoPlus)) {
      initial = cleaned.substring(dCodeNoPlus.length);
    } else if (cleaned.startsWith('0')) {
      // If it starts with a leading zero, strip it as well since dial code handles it
      initial = cleaned.substring(1);
    } else {
      initial = cleaned;
    }

    phoneController = TextEditingController(text: initial);
    
    // Add listener to update UI when phone changes (enables button)
    phoneController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    phoneController.dispose();
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var f in otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _resendSeconds = 30);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 415),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF0D4F5C).withValues(alpha: 0.09)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0A1628).withValues(alpha: 0.1),
                  blurRadius: 60,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: const Color(0xFF0D4F5C).withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 24 : 38),
              child: Obx(
                () => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step Progress
                    _buildProgressBar(),
                    const SizedBox(height: 34),
                    
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.05),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: isSuccess 
                        ? _buildSuccessView() 
                        : (showOtpField ? _buildOtpView() : _buildPhoneView()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: [
        for (int i = 0; i < 2; i++)
          Expanded(
            flex: (showOtpField && i == 1) || (!showOtpField && i == 0) || isSuccess ? 2 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              height: 3.5,
              margin: EdgeInsets.only(right: i == 0 ? 5 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: (i == 0 || (showOtpField && i == 1) || isSuccess)
                  ? const LinearGradient(colors: [Color(0xFF0D4F5C), Color(0xFF1E8FA3)])
                  : null,
                color: (i == 0 || (showOtpField && i == 1) || isSuccess) ? null : const Color(0xFFDCE4EA),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPhoneView() {
    return Column(
      key: const ValueKey('phone_view'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIconHeader(Icons.phone_iphone_rounded),
        const SizedBox(height: 22),
        Text(
          'Verify your number',
          style: GoogleFonts.fraunces(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0A1628),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          "We'll send a 6-digit code to confirm it's really you.",
          style: GoogleFonts.dmSans(
            color: const Color(0xFF5A6A7A),
            fontSize: 15,
            height: 1.65,
          ),
        ),
        const SizedBox(height: 30),
        Text(
          'PHONE NUMBER',
          style: GoogleFonts.dmSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8596A6),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 9),
        PhoneTextfield(
          controller: phoneController,
          countryCode: controller.countryCode,
          dialCode: controller.dialCode,
          label: '',
          isRequired: true,
        ),
        const SizedBox(height: 14),
        Text(
          'Standard message and data rates may apply.',
          style: TextStyle(fontSize: 12.5, color: const Color(0xFFA0B0BC)),
        ),
        const SizedBox(height: 26),
        _buildMainButton(
          label: controller.isLoading.value ? "Sending..." : "Send Verification Code →",
          onPressed: _handleSendCode,
          enabled: !controller.isLoading.value && phoneController.text.length >= 7,
        ),
        const SizedBox(height: 10),
        Center(
          child: TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Skip for now',
              style: GoogleFonts.dmSans(
                color: const Color(0xFF9AAAB6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpView() {
    return Column(
      key: const ValueKey('otp_view'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIconHeader(Icons.vibration_rounded),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter the code',
                    style: GoogleFonts.fraunces(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0A1628),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      text: "Sent to ",
                      children: [
                        TextSpan(
                          text: controller.formatPhone(controller.dialCode.value, phoneController.text.trim()),
                          style: const TextStyle(color: Color(0xFF0D4F5C), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    style: const TextStyle(fontSize: 14, color: Color(0xFF5A6A7A), height: 1.55),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        InkWell(
          onTap: () => setState(() => showOtpField = false),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFFDCE4EA), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chevron_left, size: 16, color: Color(0xFF4A6070)),
                Text(
                  'Change number',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4A6070),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          '6-DIGIT CODE',
          style: GoogleFonts.dmSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8596A6),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) => _buildOtpDigitBox(index)),
        ),
        const SizedBox(height: 28),
        _buildMainButton(
          label: controller.isLoading.value ? "Verifying..." : "Verify Code →",
          onPressed: _handleVerify,
          enabled: !controller.isLoading.value && otpControllers.every((c) => c.text.isNotEmpty),
        ),
        const SizedBox(height: 18),
        Center(
          child: Column(
            children: [
              Text(
                "Didn't receive it?",
                style: TextStyle(color: const Color(0xFF9AAAB6), fontSize: 13),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: _resendSeconds == 0 && !controller.isLoading.value ? _handleSendCode : null,
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: Text(
                  _resendSeconds > 0 ? "Resend in ${_resendSeconds}s" : "Resend code",
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _resendSeconds > 0 ? const Color(0xFF9AAAB6) : const Color(0xFF0D4F5C),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconHeader(IconData icon) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D4F5C), Color(0xFF1A7A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D4F5C).withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFFE8F4F1), size: 24),
    );
  }

  Widget _buildOtpDigitBox(int index) {
    return SizedBox(
      width: 45,
      height: 45,
      child: TextField(
        controller: otpControllers[index],
        focusNode: otpFocusNodes[index],
        keyboardType: TextInputType.number,
        textCapitalization: TextCapitalization.none,
        textAlign: TextAlign.center,
        maxLength: 1,
        onChanged: (val) {
          if (val.isNotEmpty && index < 5) {
            otpFocusNodes[index + 1].requestFocus();
          } else if (val.isEmpty && index > 0) {
            otpFocusNodes[index - 1].requestFocus();
          }
          if (otpControllers.every((c) => c.text.isNotEmpty)) {
            _handleVerify();
          }
          setState(() {});
        },
        style: GoogleFonts.fraunces(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0A1628),
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: const Color(0xFFF7FAFC),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: otpControllers[index].text.isNotEmpty 
                ? const Color(0xFF0D4F5C) 
                : const Color(0xFFDCE4EA),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF0D4F5C), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton({required String label, required VoidCallback onPressed, bool enabled = true}) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: enabled 
          ? const LinearGradient(colors: [Color(0xFF0D4F5C), Color(0xFF1E8FA3)]) 
          : null,
        color: enabled ? null : const Color(0xFFE8EEF2),
        boxShadow: enabled ? [
          BoxShadow(
            color: const Color(0xFF0D4F5C).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                color: enabled ? const Color(0xFFE8F8F5) : const Color(0xFFB0C0CC),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      key: const ValueKey('success_view'),
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(colors: [Color(0xFF0D7A5C), Color(0xFF1AAB82)]),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D7A5C).withValues(alpha: 0.32),
                blurRadius: 36,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 22),
        Text(
          'All verified!',
          style: GoogleFonts.fraunces(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0A1628),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Your phone number has been confirmed successfully.',
          textAlign: TextAlign.center,
          style: TextStyle(color: const Color(0xFF5A6A7A), fontSize: 15, height: 1.6),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(colors: [Color(0xFFEDFAF5), Color(0xFFD4F5E9)]),
            border: Border.all(color: const Color(0xFF7DE8BE), width: 1.5),
          ),
          child: Text(
            '✓ ${controller.formatPhone(controller.dialCode.value, phoneController.text.trim())}',
            style: const TextStyle(color: Color(0xFF065F46), fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  void _handleSendCode() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      AppUtils.showWarning(message: 'Please enter your phone number');
      return;
    }
    FocusScope.of(context).unfocus();
    final formattedPhone = controller.formatPhone(controller.dialCode.value, phone);
    final success = await controller.requestVerification(formattedPhone);
    if (success) {
      if (!showOtpField) setState(() => showOtpField = true);
      _startResendTimer();
    }
  }

  void _handleVerify() async {
    final code = otpControllers.map((c) => c.text).join();
    if (code.length != 6) {
      AppUtils.showWarning(message: 'Please enter the complete 6-digit code');
      return;
    }
    FocusScope.of(context).unfocus();
    final formattedPhone = controller.formatPhone(controller.dialCode.value, phoneController.text.trim());
    final success = await controller.verifyPhone(formattedPhone, code);
    if (success) {
      setState(() => isSuccess = true);
      widget.onVerified();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Get.back();
      });
    }
  }
}
