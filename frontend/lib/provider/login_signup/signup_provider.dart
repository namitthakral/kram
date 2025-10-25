import 'dart:developer';

import 'package:flutter/material.dart';

class SignUpProvider extends ChangeNotifier {
  TextEditingController? usernameController = TextEditingController(),
      passwordController = TextEditingController(),
      confirmPasswordController = TextEditingController(),
      emailController = TextEditingController();

  bool _isPasswordVisible = false,
      _isConfirmPasswordVisible = false,
      _isCreateAccountClicked = false;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  bool get isCreateAccountClicked => _isCreateAccountClicked;

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

  void createAccount() {
    updateAccountClicked(signupAccountClicked: true);
    log('Controller 1: ${usernameController?.text}');
    log('Controller 2: ${emailController?.text}');
    log('Controller 3: ${passwordController?.text}');
    log('Controller 4: ${confirmPasswordController?.text}');

    // Add password validation logic here
    if (passwordController?.text != confirmPasswordController?.text) {
      log('Passwords do not match');
      // Handle password mismatch error
      return;
    }
  }
}
