import 'dart:async';
import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/features/user/controller/profile_controller.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneVerificationController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isVerified = false.obs;
  final RxString phoneNumber = ''.obs;
  final countryCode = 'PK'.obs;
  final dialCode = '+92'.obs;
  final RxString _verificationId = ''.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String formatPhone(String dialCode, String phone) {
    String cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }
    return '${dialCode.replaceAll('+', '')}$cleaned'.startsWith('+') 
      ? '${dialCode.replaceAll('+', '')}$cleaned' 
      : '+${dialCode.replaceAll('+', '')}$cleaned';
  }

  @override
  void onInit() {
    super.onInit();
    checkStatus();
  }

  Future<void> checkStatus() async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.get('/phone-verification-status');
      if (response.statusCode == 200) {
        isVerified.value = response.data['is_verified'] ?? false;
        phoneNumber.value = response.data['phone'] ?? '';
        
        // Sync with ProfileController
        try {
          final profileController = Get.find<ProfileController>();
          profileController.updateUserData({
            'is_phone_verified': isVerified.value,
            'phone': phoneNumber.value,
          });
        } catch (_) {}
      }
    } catch (e) {
      print('Error checking phone status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> requestVerification(String phone) async {
    if (phone.isEmpty) {
      Get.snackbar('Error', 'Please enter a valid phone number');
      return false;
    }

    isLoading.value = true;
    try {

      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // AUTO-VERIFICATION (usually on Android)
          try {
            await _auth.signInWithCredential(credential);
            final success = await _notifyBackendVerified(phone);
            if (success) isVerified.value = true;
            isLoading.value = false;
          } catch (e) {
            print('Auto-verification failed: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          String msg = 'Verification failed';
          if (e.code == 'invalid-phone-number') {
            msg = 'The provided phone number is not valid.';
          } else if (e.code == 'too-many-requests') {
            msg = 'Too many requests. Please try again later.';
          }
          AppUtils.showError(title: 'Failed', message: msg);
          print('Firebase Auth Error: ${e.code} | ${e.message}');
        },
        codeSent: (String verId, int? resendToken) {
          _verificationId.value = verId;
          isLoading.value = false;
          AppUtils.showSuccess(title: 'Code Sent', message: 'Verification code sent to $phone');
        },
        codeAutoRetrievalTimeout: (String verId) {
          _verificationId.value = verId;
        },
        timeout: const Duration(seconds: 60),
      );
      
      // We return true because the request was physically successful (Firebase didn't throw an immediate error)
      return true;
    } catch (e) {
      isLoading.value = false;
      print('Firebase Request Error: $e');
      AppUtils.showError(title: 'Error', message: 'Something went wrong. Please try again.');
      return false;
    }
  }

  Future<bool> verifyPhone(String phone, String code) async {
    if (code.isEmpty || _verificationId.value.isEmpty) {
      AppUtils.showError(message: 'Invalid session or missing code');
      return false;
    }

    isLoading.value = true;
    try {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId.value,
        smsCode: code,
      );

      // Sign the user in (or link)
      await _auth.signInWithCredential(credential);

      // Notify backend after successful Firebase verification
      return await _notifyBackendVerified(phone);
    } catch (e) {
      String msg = 'Verification failed';
      if (e is FirebaseAuthException) {
        if (e.code == 'invalid-verification-code') msg = 'The code you entered is invalid.';
        if (e.code == 'expired-action-code') msg = 'The code has expired.';
      }
      AppUtils.showError(title: 'Failed', message: msg);
      print('Verify Error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _notifyBackendVerified(String phone) async {
    try {
      final response = await ApiClient().dio.post(
        '/verify-phone',
        data: {'phone': phone, 'verified': true},
      );

      if (response.statusCode == 200) {
        isVerified.value = true;
        phoneNumber.value = phone;
        
        // Refresh profile
        try {
          final profileController = Get.find<ProfileController>();
          await profileController.fetchProfile();
        } catch (_) {}

        AppUtils.showSuccess(title: 'Success', message: 'Phone verified successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Backend Notification Error: $e');
      return false;
    }
  }
}
