import 'package:flutter/material.dart';

import '../../core/services/user_service.dart';

class EditProfileProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  bool _isLoading = false;
  String? _error;
  bool _isProfileUpdated = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isProfileUpdated => _isProfileUpdated;

  /// Update user profile
  Future<void> updateProfile({
    required String userUuid,
    required Map<String, dynamic> profileData,
  }) async {
    _isLoading = true;
    _error = null;
    _isProfileUpdated = false;
    notifyListeners();

    try {
      await _userService.updateUser(userUuid, profileData);

      _isProfileUpdated = true;
      _error = null;
    } on Exception catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isProfileUpdated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset the state
  void reset() {
    _isLoading = false;
    _error = null;
    _isProfileUpdated = false;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
