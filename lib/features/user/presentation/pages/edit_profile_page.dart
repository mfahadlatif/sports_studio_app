import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/user/controller/profile_controller.dart';
import 'package:sports_studio/widgets/app_button.dart';
import 'package:sports_studio/features/auth/presentation/widgets/phone_verification_dialog.dart';
import 'package:sports_studio/widgets/phone_input_field.dart';
import 'package:sports_studio/core/utils/url_helper.dart';
import 'package:sports_studio/widgets/app_progress_indicator.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ProfileController controller = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    controller.populateProfileForm();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoadingProfile.value) {
          return const Center(child: AppProgressIndicator());
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.l,
                vertical: AppSpacing.m,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAvatarSection(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildFormSection(),
                  const SizedBox(height: 40),
                  AppButton(
                    label: 'Save Changes',
                    onPressed: _handleSave,
                    isLoading: controller.isUpdatingProfile.value,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAvatarSection() {
    final user = controller.userProfile;
    final avatarUrl = user['avatar']?.toString();
    String displayUrl = UrlHelper.sanitizeUrl(avatarUrl);

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipOval(
            child: controller.pickedAvatarPath.value.isNotEmpty
                ? Image.file(
                    File(controller.pickedAvatarPath.value),
                    fit: BoxFit.cover,
                  )
                : (avatarUrl != null
                    ? Image.network(
                        displayUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          size: 70,
                          color: AppColors.border,
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                      )
                    : const Icon(
                        Icons.person,
                        size: 70,
                        color: AppColors.border,
                      )),
          ),
        ),
        GestureDetector(
          onTap: controller.updateAvatar,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Details',
          style: AppTextStyles.label.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        _buildInputField(
          'Full Name',
          controller.nameController,
          Icons.person_outline,
          'Enter your full name',
        ),
        const SizedBox(height: AppSpacing.m),
        _buildInputField(
          'Email Address',
          controller.emailController,
          Icons.email_outlined,
          'Enter your email',
          keyboardType: TextInputType.emailAddress,
          readOnly: true,
        ),
        const SizedBox(height: AppSpacing.m),
        PhoneTextfield(
          controller: controller.phoneController,
          countryCode: controller.countryCode,
          dialCode: controller.dialCode,
          label: 'Phone Number',
          isRequired: true,
          onPhoneChanged: (v) => controller.fullPhone.value = v,
          readOnly: controller.isPhoneVerified,
        ),
        if (!controller.isPhoneVerified) ...[
          const SizedBox(height: AppSpacing.s),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 24),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Text(
                    'Your phone number needs verification.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.dialog(
                      PhoneVerificationDialog(
                        initialPhone: controller.phoneController.text.trim(),
                        onVerified: () {
                          controller.fetchProfile();
                        },
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Verify'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: AppTextStyles.bodyLarge.copyWith(
            color: readOnly ? AppColors.textMuted : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSave() {
    controller.updateProfile();
  }
}
