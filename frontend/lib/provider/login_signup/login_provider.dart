import 'dart:developer';

import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier {
  TextEditingController? passwordController = TextEditingController(),
      emailController = TextEditingController(),
      forgetPasswordEmailController = TextEditingController(),
      changePasswordController = TextEditingController(),
      changeConfirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false, _isLoginAccountClicked = false;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isLoginAccountClicked => _isLoginAccountClicked;

  void updatePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void updateLoginAccountClicked({bool loginAccountClicked = false}) {
    _isLoginAccountClicked = loginAccountClicked;
    notifyListeners();
  }

  void loginAccount() {
    updateLoginAccountClicked(loginAccountClicked: true);
    log('Controller 2: ${emailController?.text}');
    log('Controller 3: ${passwordController?.text}');
    log('Controller 3: ${forgetPasswordEmailController?.text}');
  }

  void changePasswordButton() {
    updateLoginAccountClicked(loginAccountClicked: true);
    log('Controller 2: ${changePasswordController?.text}');
    log('Controller 3: ${changeConfirmPasswordController?.text}');
  }
}
