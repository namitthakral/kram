import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/onboarding_provider.dart';
import '../../utils/enum.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class LoginRegisterMain extends StatelessWidget {
  const LoginRegisterMain({super.key});

  @override
  Widget build(BuildContext context) => Selector<OnboardingProvider, LoginType>(
    selector: (context, provider) => provider.loginType,
    builder:
        (context, loginType, child) =>
            loginType == LoginType.register
                ? const SignUpScreen()
                : const LoginScreen(),
  );
}
