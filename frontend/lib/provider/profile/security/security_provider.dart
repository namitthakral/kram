import 'package:flutter/material.dart';

class ProfileSecurityProvider extends ChangeNotifier {
  bool _faceId = false, _rememberPassword = false, _touchId = false;

  bool get faceId => _faceId;
  bool get rememberPassword => _rememberPassword;
  bool get touchId => _touchId;

  void setFaceId({bool faceId = false}) {
    _faceId = faceId;
    notifyListeners();
  }

  void setRememberPassword({bool rememberPassword = false}) {
    _rememberPassword = rememberPassword;
    notifyListeners();
  }

  void setTouchId({bool touchId = false}) {
    _touchId = touchId;
    notifyListeners();
  }
}
