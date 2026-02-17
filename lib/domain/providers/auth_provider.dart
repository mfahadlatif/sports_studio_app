import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';

enum AuthStatus { authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  User? _user;
  AuthStatus _status = AuthStatus.loading;
  String? _errorMessage;

  AuthProvider({required AuthService authService}) : _authService = authService;

  User? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      final success = await _authService.changePassword(
        currentPassword,
        newPassword,
      );

      _status = AuthStatus.authenticated;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> checkAuthStatus() async {
    // In a real app, verify token validity or fetch /me
    // For now we assume unauthenticated on fresh start unless we persist user
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.login(email, password);

      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Login failed';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password, {
    String? phone,
    File? image,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        image: image,
      );

      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    File? image, // Changed from String? avatar to File? image or support both?
    // The service takes avatar string, but I want to support file upload.
    // Actually the service I updated takes avatar string in one method but I haven't updated AuthService.updateProfile yet.
    // I should update AuthService.updateProfile to take File? image.
  }) async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      final user = await _authService.updateProfile(
        name: name,
        phone: phone,
        image: image,
      );
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _status = AuthStatus.authenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> googleLogin(String idToken) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.googleLogin(idToken);

      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> appleLogin(String idToken, {String? name}) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.appleLogin(idToken, name: name);

      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _user = null;
    _status = AuthStatus.unauthenticated;
    // clear storage token here
    notifyListeners();
  }
}
