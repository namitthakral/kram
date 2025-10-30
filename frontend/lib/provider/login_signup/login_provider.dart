import 'dart:developer';

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/validators.dart';
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
      _isLoading = false,
      _isLoggingOut = false;

  String? _errorMessage;
  User? _currentUser;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isLoginAccountClicked => _isLoginAccountClicked;
  bool get rememberPassword => _rememberPassword;
  bool get isLoading => _isLoading;
  bool get isLoggingOut => _isLoggingOut;
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
    final identifier = emailController?.text.trim() ?? '';
    final password = passwordController?.text.trim() ?? '';

    if (identifier.isEmpty && password.isEmpty) {
      _setError('Please enter both login credentials and password');
      return;
    } else if (identifier.isEmpty) {
      _setError('Please enter your EdVerse ID, email, or phone number');
      return;
    } else if (password.isEmpty) {
      _setError('Please enter your password');
      return;
    }

    _setLoading(true);

    try {
      // Detect what type of identifier the user entered
      final loginIdentifier = Validators.detectLoginIdentifier(identifier);

      // Create login request based on detected type
      final LoginRequest loginRequest;
      switch (loginIdentifier.type) {
        case LoginIdentifierType.email:
          loginRequest = LoginRequest(
            password: password,
            email: loginIdentifier.value,
          );
          log('Logging in with email: ${loginIdentifier.value}');
        case LoginIdentifierType.phone:
          loginRequest = LoginRequest(
            password: password,
            phone: loginIdentifier.value,
          );
          log('Logging in with phone: ${loginIdentifier.value}');
        case LoginIdentifierType.edverseId:
          loginRequest = LoginRequest(
            password: password,
            edverseId: loginIdentifier.value,
          );
          log('Logging in with EdVerse ID: ${loginIdentifier.value}');
      }

      final response = await _authService.login(loginRequest);
      _currentUser = response.user;

      log('Login successful for user: ${response.user.email}');
      updateLoginAccountClicked(loginAccountClicked: true);
    } on Exception catch (e) {
      var errorMessage = 'Login failed. Please try again.';

      final errorString = e.toString().toLowerCase();

      if (errorString.contains('invalid credentials')) {
        errorMessage = 'Invalid credentials. Please check your login details.';
      } else if (errorString.contains('account is not active')) {
        errorMessage =
            'Your account is not active. Please contact administrator.';
      } else if (errorString.contains('xmlhttprequest') ||
          errorString.contains('connection') ||
          errorString.contains('network') ||
          errorString.contains('errored')) {
        errorMessage =
            'Cannot connect to server. Please check:\n'
            '1. Backend server is running on ${AppConstants.baseUrl}\n'
            '2. Network connectivity\n'
            '3. CORS is configured properly';
      } else if (errorString.contains('timeout')) {
        errorMessage =
            'Connection timeout. Please check your network and try again.';
      }

      _setError(errorMessage);
      log('Login failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Logout user and clear all stored data
  Future<void> logout() async {
    // Prevent duplicate logout calls
    if (_isLoggingOut) {
      return;
    }

    _isLoggingOut = true;
    _setLoading(true);
    notifyListeners();

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
      _isLoggingOut = false;
      notifyListeners();
    }
  }

  Future<bool> checkLoginStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _currentUser = await _authService.getCurrentUser();
        notifyListeners(); // Notify UI that user data is loaded
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
