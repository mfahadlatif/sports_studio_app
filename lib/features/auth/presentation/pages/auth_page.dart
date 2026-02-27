import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/constants/user_roles.dart';
import 'package:sports_studio/features/auth/controller/auth_controller.dart';
import 'package:sports_studio/widgets/app_button.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Fixed Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.l,
                vertical: AppSpacing.l,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      AppConstants.appLogo,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Obx(
                    () => Text(
                      controller.isLogin.value
                          ? 'Welcome\nBack!'
                          : 'Create\nAccount',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h1.copyWith(
                        color: Colors.white,
                        fontSize: 40,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Form
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.xl,
                  ),
                  child: Column(
                    children: [
                      _buildAuthForm(controller),
                      const SizedBox(height: AppSpacing.l),
                      _buildSocialAuth(controller),
                      const SizedBox(height: AppSpacing.l),
                      _buildToggleAuth(controller),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthForm(AuthController controller) {
    return Obx(
      () => Column(
        children: [
          Text(
            controller.isLogin.value ? 'Login' : 'Sign Up',
            style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            controller.isLogin.value
                ? 'Access your Sports Studio account'
                : 'Join the community today',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (!controller.isLogin.value) ...[
            _lbl('Register as:'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.selectedRole.value = UserRole.user,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: controller.selectedRole.value == UserRole.user
                            ? AppColors.primary
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: controller.selectedRole.value == UserRole.user
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Player',
                          style: TextStyle(
                            color:
                                controller.selectedRole.value == UserRole.user
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.selectedRole.value = UserRole.owner,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: controller.selectedRole.value == UserRole.owner
                            ? AppColors.primary
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: controller.selectedRole.value == UserRole.owner
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Ground Owner',
                          style: TextStyle(
                            color:
                                controller.selectedRole.value == UserRole.owner
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
          ],

          if (!controller.isLogin.value) ...[
            TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(
                hintText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
          ],
          TextField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Email Address',
              prefixIcon: Icon(Icons.email_outlined),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: controller.passwordController,
            obscureText: controller.obscurePassword.value,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              filled: true,
              fillColor: AppColors.background,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => controller.togglePasswordVisibility(),
              ),
            ),
          ),
          if (!controller.isLogin.value) ...[
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: controller.confirmPasswordController,
              obscureText: controller.obscureConfirmPassword.value,
              decoration: InputDecoration(
                hintText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_reset_outlined),
                filled: true,
                fillColor: AppColors.background,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscureConfirmPassword.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => controller.toggleConfirmPasswordVisibility(),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.l),
          AppButton(
            label: controller.isLogin.value ? 'Login' : 'Sign Up',
            onPressed: controller.isLogin.value
                ? controller.login
                : controller.register,
            isLoading: controller.isLoading.value,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialAuth(AuthController controller) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('OR', style: AppTextStyles.label),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: AppSpacing.l),
        const SizedBox(height: AppSpacing.l),
        Obx(
          () => Column(
            children: [
              if (Platform.isIOS) ...[
                _socialButton(
                  Icons.g_mobiledata,
                  'Continue with Google',
                  Colors.red,
                  onTap: controller.loginWithGoogle,
                  isFullWidth: true,
                  isLoading: controller.isGoogleLoading.value,
                ),
                const SizedBox(height: AppSpacing.m),
                _socialButton(
                  Icons.apple,
                  'Continue with Apple',
                  Colors.black,
                  onTap: controller.loginWithApple,
                  isFullWidth: true,
                  isLoading: controller.isAppleLoading.value,
                ),
              ] else
                _socialButton(
                  Icons.g_mobiledata,
                  'Continue with Google',
                  Colors.red,
                  onTap: controller.loginWithGoogle,
                  isFullWidth: true,
                  isLoading: controller.isGoogleLoading.value,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _socialButton(
    IconData icon,
    String label,
    Color color, {
    required VoidCallback onTap,
    bool isFullWidth = false,
    bool isLoading = false,
  }) {
    final button = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: isLoading
          ? const SizedBox(
              height: 28,
              width: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isFullWidth ? 16 : 14,
                  ),
                ),
              ],
            ),
    );

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: isFullWidth
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }

  Widget _buildToggleAuth(AuthController controller) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            controller.isLogin.value
                ? "Don't have an account? "
                : "Already have an account? ",
            style: AppTextStyles.bodySmall,
          ),
          TextButton(
            onPressed: () => controller.toggleAuthMode(),
            child: Text(
              controller.isLogin.value ? 'Sign Up' : 'Login',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lbl(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: AppTextStyles.label.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
