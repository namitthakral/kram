import 'dart:developer';

import 'package:flutter/material.dart';

class SignUpProvider extends ChangeNotifier {
  TextEditingController? usernameController = TextEditingController(),
      passwordController = TextEditingController(),
      emailController = TextEditingController();

  bool _isPasswordVisible = false, _isCreateAccountClicked = false;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isCreateAccountClicked => _isCreateAccountClicked;

  void updatePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
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
  }
}
