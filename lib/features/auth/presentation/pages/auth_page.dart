import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/auth/controller/auth_controller.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());

    return Scaffold(
      body: Stack(
        children: [
          // Background Decor
          Container(
            height: Get.height * 0.4,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.l),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.sports_soccer, color: AppColors.primary, size: 32),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Obx(() => Text(
                      controller.isLogin.value ? 'Welcome\nBack!' : 'Create\nAccount',
                      style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 36, height: 1.1),
                    )),
                  ],
                ),
              ),
            ),
          ),

          // Auth Form
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: Get.height * 0.32),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  padding: const EdgeInsets.all(AppSpacing.l),
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
                  child: Column(
                    children: [
                      _buildAuthForm(controller),
                      const SizedBox(height: AppSpacing.l),
                      _buildSocialAuth(),
                      const SizedBox(height: AppSpacing.l),
                      _buildToggleAuth(controller),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthForm(AuthController controller) {
    return Column(
      children: [
        if (!controller.isLogin.value) ...[
          const TextField(
            decoration: InputDecoration(
              hintText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
        ],
        TextField(
          controller: controller.emailController,
          decoration: const InputDecoration(
            hintText: 'Email Address',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Obx(() => TextField(
          controller: controller.passwordController,
          obscureText: controller.obscurePassword.value,
          decoration: InputDecoration(
            hintText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                controller.obscurePassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              ),
              onPressed: () => controller.togglePasswordVisibility(),
            ),
          ),
        )),
        const SizedBox(height: AppSpacing.l),
        Obx(() => SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : () => controller.login(),
            child: controller.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(controller.isLogin.value ? 'Login' : 'Sign Up'),
          ),
        )),
      ],
    );
  }

  Widget _buildSocialAuth() {
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialButton(Icons.g_mobiledata, 'Google', Colors.red),
            const SizedBox(width: AppSpacing.m),
            _socialButton(Icons.apple, 'Apple', Colors.black),
          ],
        ),
      ],
    );
  }

  Widget _socialButton(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildToggleAuth(AuthController controller) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          controller.isLogin.value ? "Don't have an account? " : "Already have an account? ",
          style: AppTextStyles.bodySmall,
        ),
        TextButton(
          onPressed: () => controller.toggleAuthMode(),
          child: Text(
            controller.isLogin.value ? 'Sign Up' : 'Login',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ));
  }
}
