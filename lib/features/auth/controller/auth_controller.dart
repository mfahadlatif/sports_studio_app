import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:sports_studio/core/constants/user_roles.dart';
import 'package:sports_studio/features/landing/controller/landing_controller.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthController extends GetxController {
  final RxBool isLogin = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;
  final RxBool isAppleLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final Rx<UserRole> selectedRole = UserRole.user.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void toggleAuthMode() {
    isLogin.value = !isLogin.value;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      print('--- LOGIN ATTEMPT ---');
      print('URL: ${ApiClient.baseUrl}/login');
      print('Payload: {"email": "$email", "password": "***"}');

      final response = await ApiClient().dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      print('Response Status: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['access_token'];
        if (token != null) {
          const storage = FlutterSecureStorage();
          await storage.write(key: 'auth_token', value: token);
          print('Token saved securely.');
        }

        UserRole userRole = UserRole.user;
        final roleString =
            data['user']?['role']?.toString().toLowerCase() ?? 'user';
        if (roleString == 'owner' || roleString == 'admin') {
          userRole = UserRole.owner;
        }

        print('Navigating to home with role: $userRole');
        Get.snackbar(
          'Success',
          'Logged in successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        _navigateToHome(userRole);
      }
    } on DioException catch (e) {
      print('--- LOGIN DIO EXCEPTION ---');
      print('Error message: ${e.message}');
      print('Response status: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');

      final errorMessage =
          e.response?.data?['message'] ?? 'Invalid email or password';
      Get.snackbar(
        'Login Failed',
        errorMessage.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } catch (e) {
      print('--- LOGIN UNKNOWN EXCEPTION ---');
      print('Error: $e');

      Get.snackbar(
        'Login Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
      print('--- LOGIN ATTEMPT END ---');
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
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final roleString = selectedRole.value == UserRole.owner
          ? 'owner'
          : 'user';

      final response = await ApiClient().dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': confirmPassword,
          'role': roleString,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final token = data['access_token'];
        if (token != null) {
          const storage = FlutterSecureStorage();
          await storage.write(key: 'auth_token', value: token);
        }

        // Parse role specifically incase backend overwrites it
        UserRole userRole = selectedRole.value;
        final actualRoleString = data['user']?['role']
            ?.toString()
            .toLowerCase();
        if (actualRoleString != null) {
          userRole =
              (actualRoleString == 'owner' || actualRoleString == 'admin')
              ? UserRole.owner
              : UserRole.user;
        }

        Get.snackbar(
          'Success',
          'Registered successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        _navigateToHome(userRole);
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to register account.';
      if (e.response?.data != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          errorMessage = responseData['message'] ?? errorMessage;
          if (responseData['errors'] != null) {
            errorMessage += '\n' + responseData['errors'].toString();
          }
        }
      }
      Get.snackbar(
        'Registration Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } catch (e) {
      Get.snackbar(
        'Registration Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    isGoogleLoading.value = true;
    try {
      print('--- GOOGLE LOGIN START ---');
      const String serverClientId =
          '945595614098-805nscipvooqrdl7ilut986h82nlg5me.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: serverClientId,
      );

      // Force account picker by signing out first
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      print('Attempting Google Sign-In...');
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print('Google Sign-In cancelled by user.');
        return;
      }

      print('Google User found: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        print('ID Token obtained. Sending to backend...');
        final roleString = selectedRole.value == UserRole.owner
            ? 'owner'
            : 'user';
        final response = await ApiClient().dio.post(
          '/login/google',
          data: {'id_token': idToken, 'role': roleString},
        );

        print('Backend Response: ${response.statusCode}');
        if (response.statusCode == 200) {
          final data = response.data;
          final token = data['access_token'];
          if (token != null) {
            const storage = FlutterSecureStorage();
            await storage.write(key: 'auth_token', value: token);
          }

          UserRole userRole = UserRole.user;
          final roleString =
              data['user']?['role']?.toString().toLowerCase() ?? 'user';
          if (roleString == 'owner' || roleString == 'admin') {
            userRole = UserRole.owner;
          }

          _navigateToHome(userRole);
        }
      }
    } catch (e) {
      print('Google Login Exception: $e');
      Get.snackbar('Google Login Failed', e.toString());
    } finally {
      isGoogleLoading.value = false;
    }
  }

  Future<void> loginWithApple() async {
    isAppleLoading.value = true;
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Send to backend
      final roleString = selectedRole.value == UserRole.owner
          ? 'owner'
          : 'user';
      final response = await ApiClient().dio.post(
        '/login/apple',
        data: {
          'id_token': credential.identityToken,
          'name': '${credential.givenName ?? ""} ${credential.familyName ?? ""}'
              .trim(),
          'email': credential.email,
          'role': roleString,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['access_token'];
        if (token != null) {
          const storage = FlutterSecureStorage();
          await storage.write(key: 'auth_token', value: token);
        }

        UserRole userRole = UserRole.user;
        final roleString =
            data['user']?['role']?.toString().toLowerCase() ?? 'user';
        if (roleString == 'owner' || roleString == 'admin') {
          userRole = UserRole.owner;
        }

        _navigateToHome(userRole);
      }
    } catch (e) {
      Get.snackbar('Apple Login Failed', e.toString());
    } finally {
      isAppleLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
