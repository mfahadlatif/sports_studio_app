import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/constants/user_roles.dart';
import 'package:sports_studio/features/landing/controller/landing_controller.dart';

class AuthController extends GetxController {
  final RxBool isLogin = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void toggleAuthMode() {
    isLogin.value = !isLogin.value;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;

    if (email == 'user@gmail.com' && password == 'user12345') {
      _navigateToHome(UserRole.user);
    } else if (email == 'owner@gmail.com' && password == 'owner12345') {
      _navigateToHome(UserRole.owner);
    } else {
      Get.snackbar('Login Failed', 'Invalid email or password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red);
    }
  }

  void _navigateToHome(UserRole role) {
    // Ensure LandingController is available and set the role
    final landingController = Get.put(LandingController(), permanent: true);
    landingController.currentRole.value = role;
    landingController.currentNavIndex.value = 0;
    
    Get.offAllNamed('/');
  }

  Future<void> register() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
    _navigateToHome(UserRole.user);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
