import 'dart:developer';

import 'package:flutter/material.dart';

import '../utils/enum.dart';
import '../views/onboarding/onboarding_state_model.dart';

class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider() {
    model = [
      const OnboardingStateModel(
        index: 0,
        title: 'onboard_title_1',
        subtitle: 'onboard_subtitle_1',
      ),
      const OnboardingStateModel(
        index: 1,
        title: 'onboard_title_2',
        subtitle: 'onboard_subtitle_2',
      ),
      const OnboardingStateModel(
        index: 2,
        title: 'onboard_title_3',
        subtitle: 'onboard_subtitle_3',
      ),
    ];
  }

  List<OnboardingStateModel> model = [];
  OnboardingStateModel? _currentModel;
  LoginType _loginType = LoginType.login;

  OnboardingStateModel? get currentModel => _currentModel;
  LoginType get loginType => _loginType;

  void setCurrentModel(OnboardingStateModel state) {
    log(state.toString());
    _currentModel = state;
    notifyListeners();
  }

  void setLogintype(LoginType type) {
    log(type.toString());
    _loginType = type;
    notifyListeners();
  }
}
