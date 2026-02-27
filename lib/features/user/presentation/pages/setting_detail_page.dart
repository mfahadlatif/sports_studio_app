import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/user/controller/profile_controller.dart';
import 'package:sports_studio/features/landing/controller/landing_controller.dart';
import 'package:sports_studio/core/constants/user_roles.dart';
import 'package:sports_studio/widgets/app_button.dart';

class SettingDetailPage extends StatefulWidget {
  const SettingDetailPage({super.key});

  @override
  State<SettingDetailPage> createState() => _SettingDetailPageState();
}

class _SettingDetailPageState extends State<SettingDetailPage> {
  final ProfileController controller = Get.find<ProfileController>();
  final LandingController landingController = Get.find<LandingController>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController businessNameController;

  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    final user = controller.userProfile;
    nameController = TextEditingController(
      text: user['name']?.toString() ?? '',
    );
    emailController = TextEditingController(
      text: user['email']?.toString() ?? '',
    );
    phoneController = TextEditingController(
      text: user['phone']?.toString() ?? '',
    );
    businessNameController = TextEditingController(
      text: user['business_name']?.toString() ?? '',
    );

    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    businessNameController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final String title = args != null && args is Map
        ? args['title']
        : 'Settings';
    final isEditProfile = title == 'Edit Profile';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(title),
                const SizedBox(height: AppSpacing.xl),
                if (isEditProfile)
                  _buildEditProfileForm()
                else
                  _buildSecurityForm(),
                const SizedBox(height: 40),
                Obx(
                  () => AppButton(
                    label: isEditProfile ? 'Save Changes' : 'Update Password',
                    onPressed: () => isEditProfile
                        ? _handleUpdateProfile()
                        : _handleChangePassword(),
                    isLoading: controller.isLoading.value,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    String subtitle = 'Manage your account settings and preferences.';
    if (title == 'Edit Profile') {
      subtitle =
          'Update your personal information to keep your profile current.';
    } else if (title.contains('Security')) {
      subtitle =
          'Ensure your account'
          's safety by keeping your password secure.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEditProfileForm() {
    final isOwner = landingController.currentRole.value == UserRole.owner;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputField('Full Name', nameController, Icons.person_outline),
        const SizedBox(height: AppSpacing.m),
        _buildInputField(
          'Email Address',
          emailController,
          Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppSpacing.m),
        _buildInputField(
          'Phone Number',
          phoneController,
          Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        if (isOwner) ...[
          const SizedBox(height: AppSpacing.m),
          _buildInputField(
            'Business/Complex Name',
            businessNameController,
            Icons.business_outlined,
          ),
        ],
      ],
    );
  }

  Widget _buildSecurityForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Change Password', Icons.lock_outline),
        const SizedBox(height: AppSpacing.m),
        _buildInputField(
          'Current Password',
          currentPasswordController,
          Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: AppSpacing.m),
        _buildInputField(
          'New Password',
          newPasswordController,
          Icons.lock_reset_outlined,
          isPassword: true,
        ),
        const SizedBox(height: AppSpacing.m),
        _buildInputField(
          'Confirm New Password',
          confirmPasswordController,
          Icons.lock_reset_outlined,
          isPassword: true,
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, IconData icon) => Row(
    children: [
      Icon(icon, size: 18, color: AppColors.primary),
      const SizedBox(width: 8),
      Text(title, style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
      const SizedBox(width: 8),
      Expanded(child: Divider(color: AppColors.primary.withOpacity(0.2))),
    ],
  );

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  void _handleUpdateProfile() {
    controller.updateProfile(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      businessName: businessNameController.text.trim(),
    );
  }

  void _handleChangePassword() {
    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'New passwords do not match',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }
    controller.changePassword(
      currentPassword: currentPasswordController.text,
      newPassword: newPasswordController.text,
      confirmPassword: confirmPasswordController.text,
    );
  }
}
