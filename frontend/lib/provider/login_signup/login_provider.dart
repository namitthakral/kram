import 'dart:developer';

import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../../models/auth_models.dart';

class LoginProvider extends ChangeNotifier {
  TextEditingController? passwordController = TextEditingController(),
      emailController = TextEditingController(),
      forgetPasswordEmailController = TextEditingController(),
      changePasswordController = TextEditingController(),
      changeConfirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false,
      _isLoginAccountClicked = false,
      _rememberPassword = false,
      _isLoading = false;

  String? _errorMessage;
  User? _currentUser;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isLoginAccountClicked => _isLoginAccountClicked;
  bool get rememberPassword => _rememberPassword;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;

  final AuthService _authService = AuthService();

  void updatePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void updateRememberPassword({bool rememberPass = false}) {
    _rememberPassword = rememberPass;
    notifyListeners();
  }

  void updateLoginAccountClicked({bool loginAccountClicked = false}) {
    _isLoginAccountClicked = loginAccountClicked;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void onEmailChanged() {
    // Clear error when user starts typing in email field
    if (_errorMessage != null) {
      clearError();
    }
  }

  void onPasswordChanged() {
    // Clear error when user starts typing in password field
    if (_errorMessage != null) {
      clearError();
    }
  }

  Future<void> loginAccount() async {
    // Clear any previous errors first
    _setError(null);

    // Validate input fields
    final email = emailController?.text.trim() ?? '';
    final password = passwordController?.text.trim() ?? '';

    if (email.isEmpty && password.isEmpty) {
      _setError('Please enter both email and password');
      return;
    } else if (email.isEmpty) {
      _setError('Please enter your email address');
      return;
    } else if (password.isEmpty) {
      _setError('Please enter your password');
      return;
    }

    _setLoading(true);

    try {
      final loginRequest = LoginRequest(email: email, password: password);

      final response = await _authService.login(loginRequest);
      _currentUser = response.user;

      log('Login successful for user: ${response.user.email}');
      updateLoginAccountClicked(loginAccountClicked: true);
    } on Exception catch (e) {
      var errorMessage = 'Login failed. Please try again.';

      if (e.toString().contains('Invalid credentials')) {
        errorMessage =
            'Invalid email or password. Please check your credentials.';
      } else if (e.toString().contains('Account is not active')) {
        errorMessage =
            'Your account is not active. Please contact administrator.';
      } else if (e.toString().contains('Network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      }

      _setError(errorMessage);
      log('Login failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Logout user and clear all stored data
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();

      // Clear local state
      _currentUser = null;
      emailController?.clear();
      passwordController?.clear();
      updateLoginAccountClicked();
      clearError();

      log('Logout successful');
    } on Exception catch (e) {
      _setError('Logout failed: $e');
      log('Logout failed: $e');
      // Even if logout fails, clear local data
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> checkLoginStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _currentUser = await _authService.getCurrentUser();
      }
      return isLoggedIn;
    } on Exception catch (e) {
      log('Error checking login status: $e');
      return false;
    }
  }

  void changePasswordButton() {
    updateLoginAccountClicked(loginAccountClicked: true);
    log('Controller 2: ${changePasswordController?.text}');
    log('Controller 3: ${changeConfirmPasswordController?.text}');
  }

  @override
  void dispose() {
    emailController?.dispose();
    passwordController?.dispose();
    forgetPasswordEmailController?.dispose();
    changePasswordController?.dispose();
    changeConfirmPasswordController?.dispose();
    super.dispose();
  }
}
