import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../utils/custom_images.dart';
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
    splashImage = Image.asset(CustomImages.splash);
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
    final authToken = await _secureStorage.read(AppConstants.accessTokenKey);

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
      // User hasn't completed onboarding, show onboarding screens
      context.router.goToOnboarding();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(splashImage!.image, context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            CustomImages.splash,
            height: 500,
            width: 500,
            fit: BoxFit.contain,
          ),
        ],
      ),
    ),
  );
}
