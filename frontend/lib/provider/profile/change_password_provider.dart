import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';

class ChangePasswordProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;
  bool _isPasswordChanged = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPasswordChanged => _isPasswordChanged;

  /// Change user password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    _isPasswordChanged = false;
    notifyListeners();

    try {
      await _authService.changePassword(
        oldPassword: currentPassword,
        newPassword: newPassword,
      );

      _isPasswordChanged = true;
      _error = null;
    } on Exception catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isPasswordChanged = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset the state
  void reset() {
    _isLoading = false;
    _error = null;
    _isPasswordChanged = false;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
