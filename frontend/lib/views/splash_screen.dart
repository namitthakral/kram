import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../provider/theme_provider.dart';
import '../utils/extensions.dart';
import '../utils/localization/app_localizations.dart';
import '../utils/router_service.dart';
import '../utils/secure_storge.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Image? splashImage;
  final _secureStorage = SecureStorageService();

  @override
  void initState() {
    super.initState();
    splashImage = Image.asset('assets/images/logo.png');
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for 3 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Check if user has completed onboarding
    final hasCompletedOnboarding = await _secureStorage.read(
      AppConstants.onboardingCompletedKey,
    );

    // Check if user is logged in
    final authToken = await _secureStorage.read(AppConstants.tokenKey);

    if (!mounted) return;

    // Navigate based on app state
    if (hasCompletedOnboarding == 'true') {
      // User has completed onboarding
      if (authToken != null && authToken.isNotEmpty) {
        // User is logged in, go to home
        context.router.goToHome();
      } else {
        // User completed onboarding but not logged in, go to login
        context.router.goToLogin();
      }
    } else {
      // User hasn't completed onboarding, show onboarding
      context.router.goToOnboarding();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(splashImage!.image, context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/logo.png',
              height: 250,
              width: 250,
              color: themeProvider.themeData.primaryColor,
            ),
            const SizedBox(height: 16.0),
            Text(
              AppLocalizations.of(context)!.translate('app_name'),
              style: context.textTheme.displayLg.copyWith(
                fontSize: 30,
                color: themeProvider.themeData.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
