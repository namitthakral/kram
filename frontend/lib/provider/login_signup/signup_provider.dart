import 'dart:developer';

import 'package:flutter/material.dart';

import '../../core/constants/role_constants.dart';
import '../../core/services/auth_service.dart';
import '../../models/auth_models.dart';

class SignUpProvider extends ChangeNotifier {
  TextEditingController? firstNameController = TextEditingController(),
      lastNameController = TextEditingController(),
      passwordController = TextEditingController(),
      confirmPasswordController = TextEditingController(),
      emailController = TextEditingController(),
      phoneController = TextEditingController();

  bool _isPasswordVisible = false,
      _isConfirmPasswordVisible = false,
      _isCreateAccountClicked = false,
      _isLoading = false;

  String? _errorMessage;
  String? _successMessage;
  RegisteredUser? _registeredUser;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  bool get isCreateAccountClicked => _isCreateAccountClicked;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  RegisteredUser? get registeredUser => _registeredUser;

  final AuthService _authService = AuthService();

  void updatePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void updateConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  void updateAccountClicked({bool signupAccountClicked = false}) {
    _isCreateAccountClicked = signupAccountClicked;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String? message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  void onFieldChanged() {
    // Clear errors when user starts typing
    if (_errorMessage != null) {
      clearError();
    }
  }

  Future<bool> createAccount() async {
    // Clear any previous messages
    _setError(null);
    _setSuccess(null);

    // Validate input fields
    final firstName = firstNameController?.text.trim() ?? '';
    final lastName = lastNameController?.text.trim() ?? '';
    final email = emailController?.text.trim() ?? '';
    final password = passwordController?.text.trim() ?? '';
    final confirmPassword = confirmPasswordController?.text.trim() ?? '';
    final phone = phoneController?.text.trim();

    // Validation
    if (firstName.isEmpty) {
      _setError('Please enter your first name');
      return false;
    }

    if (lastName.isEmpty) {
      _setError('Please enter your last name');
      return false;
    }

    if (email.isEmpty) {
      _setError('Please enter your email address');
      return false;
    }

    if (!_isValidEmail(email)) {
      _setError('Please enter a valid email address');
      return false;
    }

    if (password.isEmpty) {
      _setError('Please enter a password');
      return false;
    }

    if (password.length < 8) {
      _setError('Password must be at least 8 characters long');
      return false;
    }

    if (confirmPassword.isEmpty) {
      _setError('Please confirm your password');
      return false;
    }

    if (password != confirmPassword) {
      _setError('Passwords do not match');
      return false;
    }

    _setLoading(true);
    updateAccountClicked(signupAccountClicked: true);

    try {
      final registerRequest = RegisterRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        roleId: RoleConstants.parent.id, // Default to parent role
        phoneNumber: phone?.isNotEmpty == true ? phone : null,
      );

      final response = await _authService.register(registerRequest);
      _registeredUser = response.data;

      log('Registration successful for user: ${response.data.email}');
      _setSuccess(response.message);

      return true;
    } on Exception catch (e) {
      var errorMessage = 'Registration failed. Please try again.';

      if (e.toString().contains('already exists')) {
        errorMessage = 'An account with this email already exists.';
      } else if (e.toString().contains('Invalid data')) {
        errorMessage = 'Please check your information and try again.';
      } else if (e.toString().contains('Network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      }

      _setError(errorMessage);
      log('Registration failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  @override
  void dispose() {
    firstNameController?.dispose();
    lastNameController?.dispose();
    emailController?.dispose();
    passwordController?.dispose();
    confirmPasswordController?.dispose();
    phoneController?.dispose();
    super.dispose();
  }
}
