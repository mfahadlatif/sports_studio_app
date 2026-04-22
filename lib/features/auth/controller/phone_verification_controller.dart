import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:sport_studio/core/network/api_client.dart';
import 'package:sport_studio/features/user/controller/profile_controller.dart';
import 'package:sport_studio/core/utils/app_utils.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneVerificationController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isVerified = false.obs;
  final RxString phoneNumber = ''.obs;
  final countryCode = 'PK'.obs;
  final dialCode = '+92'.obs;
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  int? _resendToken;

  String formatPhone(String? dCode, String? p) {
    if (dCode == null || p == null) return '';
    String cleaned = p.replaceAll(RegExp(r'\D'), '');
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }
    String d = dCode.replaceAll('+', '');
    return '+$d$cleaned';
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
      AppUtils.showError(message: 'Please enter a valid phone number');
      return false;
    }

    isLoading.value = true;
    final completer = Completer<bool>();

    try {
      print('🌐 [PhoneVerification] Requesting Firebase OTP for: $phone');
      
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (rare on some devices, common on others)
          log('✅ [PhoneVerification] Auto-verification completed');
          await _onFirebaseVerified(phone, credential);
          if (!completer.isCompleted) completer.complete(true);
        },
        verificationFailed: (FirebaseAuthException e) {
          log('❌ [PhoneVerification] Firebase Error: ${e.code} | ${e.message}');
          isLoading.value = false;
          AppUtils.showError(title: 'Verification Failed', message: e.message ?? 'An error occurred');
          if (!completer.isCompleted) completer.complete(false);
        },
        codeSent: (String verificationId, int? resendToken) {
          log('📩 [PhoneVerification] Code sent to $phone');
          _verificationId = verificationId;
          _resendToken = resendToken;
          isLoading.value = false;
          AppUtils.showSuccess(title: 'Code Sent', message: 'Verification code has been sent to your phone');
          if (!completer.isCompleted) completer.complete(true);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      
      return completer.future;
    } catch (e) {
      isLoading.value = false;
      log('❌ [PhoneVerification] Unexpected Error: $e');
      AppUtils.showError(title: 'Error', message: 'Failed to initiate verification');
      return false;
    }
  }

  Future<bool> verifyPhone(String phone, String code) async {
    if (_verificationId == null) {
      AppUtils.showError(message: 'Session expired. Please request a new code.');
      return false;
    }

    isLoading.value = true;
    try {
      log('🌐 [PhoneVerification] Verifying SMS Code: $code');
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      
      return await _onFirebaseVerified(phone, credential);
    } catch (e) {
      isLoading.value = false;
      log('❌ [PhoneVerification] Manual Verify Error: $e');
      AppUtils.showError(title: 'Error', message: 'Incorrect or expired code');
      return false;
    }
  }

  Future<bool> _onFirebaseVerified(String phone, PhoneAuthCredential credential) async {
    try {
      // 1. Sign in with the credential to confirm with Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      
      if (firebaseUser == null) throw Exception('Firebase user is null after sign in');

      // 2. Synchronize with backend
      log('📡 [PhoneVerification] Syncing with backend...');
      final response = await ApiClient().dio.post(
        '/verify-phone',
        data: {
          'phone': phone,
          'verified': true,
          'firebase_uid': firebaseUser.uid,
          'code': 'firebase_verified', // Handshake with backend
        },
      );

      if (response.statusCode == 200) {
        isVerified.value = true;
        phoneNumber.value = phone;
        
        // Refresh profile to update UI flags
        try {
          final profileController = Get.find<ProfileController>();
          await profileController.fetchProfile();
        } catch (_) {}

        return true;
      }
      return false;
    } catch (e) {
      log('❌ [PhoneVerification] Backend Sync Error: $e');
      String msg = 'Failed to sync verification with server';
      if (e is DioException) {
        msg = e.response?.data?['message'] ?? msg;
      }
      AppUtils.showError(title: 'Sync Error', message: msg);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
