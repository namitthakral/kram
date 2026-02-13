import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // SharedPreferences keys for Remember Me
  static const String _keyRememberMe = 'remember_me';
  static const String _keySavedIdentifier = 'saved_identifier';
  static const String _keySavedPassword = 'saved_password';

  void updatePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void updateRememberPassword({bool rememberPass = false}) {
    _rememberPassword = rememberPass;
    notifyListeners();

    // If unchecked, clear saved credentials
    if (!rememberPass) {
      _clearSavedCredentials();
    }
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
      _setError('Please enter your Kram ID, email, or phone number');
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
        case LoginIdentifierType.kramid:
          loginRequest = LoginRequest(
            password: password,
            kramid: loginIdentifier.value,
          );
          log('Logging in with Kram ID: ${loginIdentifier.value}');
      }

      final response = await _authService.login(loginRequest);
      _currentUser = response.user;

      log('Login successful for user: ${response.user.email}');

      // Save credentials if Remember Me is checked
      await _saveCredentials(identifier, password);
      // if (_rememberPassword) {
      // } else {
      //   await _clearSavedCredentials();
      // }

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

      // Clear saved credentials on logout (user can re-check Remember Me on next login)
      await _clearSavedCredentials();
      _rememberPassword = false;

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

  /// Load saved credentials if Remember Me was previously checked
  Future<void> loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(_keyRememberMe) ?? false;

      if (rememberMe) {
        final savedIdentifier = prefs.getString(_keySavedIdentifier);
        final savedPassword = prefs.getString(_keySavedPassword);

        if (savedIdentifier != null && savedPassword != null) {
          emailController?.text = savedIdentifier;
          passwordController?.text = savedPassword;
          _rememberPassword = true;
          notifyListeners();
          log('Loaded saved credentials');
        }
      }
    } on Exception catch (e) {
      log('Error loading saved credentials: $e');
    }
  }

  /// Save credentials to SharedPreferences
  Future<void> _saveCredentials(String identifier, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyRememberMe, true);
      await prefs.setString(_keySavedIdentifier, identifier);
      if (_rememberPassword) {
        await prefs.setString(_keySavedPassword, password);
      }
      log('Credentials saved');
    } on Exception catch (e) {
      log('Error saving credentials: $e');
    }
  }

  /// Clear saved credentials from SharedPreferences
  Future<void> _clearSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyRememberMe);
      await prefs.remove(_keySavedIdentifier);
      await prefs.remove(_keySavedPassword);
      log('Saved credentials cleared');
    } on Exception catch (e) {
      log('Error clearing saved credentials: $e');
    }
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

  /// Initialize auth state from storage
  Future<void> init() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        // Validate token validity
        final isValid = await _authService.validateAndRefreshToken();
        if (isValid) {
          _currentUser = await _authService.getCurrentUser();
          notifyListeners();
        } else {
          // Token invalid, clear everything
          await logout();
        }
      }
    } on Exception catch (e) {
      log('Error initializing LoginProvider: $e');
    }
  }
}
