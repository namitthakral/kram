import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../provider/onboarding_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/enum.dart';
import '../../utils/extensions.dart';
import '../../utils/router_service.dart';
import '../../utils/secure_storge.dart';
import 'indicator.dart';
import 'onboarding_state_model.dart';

class OnboardingMain extends StatelessWidget {
  const OnboardingMain({super.key});

  Future<void> _markOnboardingComplete() async {
    final secureStorage = SecureStorageService();
    await secureStorage.write(AppConstants.onboardingCompletedKey, 'true');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: CustomAppColors.white,
    body: SafeArea(
      child: Consumer<OnboardingProvider>(
        builder:
            (context, provider, child) => Column(
              children: [
                // Simple header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),

                // Main content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: PageView.builder(
                      itemCount: provider.model.length,
                      onPageChanged:
                          (value) =>
                              provider.setCurrentModel(provider.model[value]),
                      itemBuilder:
                          (context, index) => _CleanTitleDisplay(
                            onboardingStateModel: provider.model[index],
                          ),
                    ),
                  ),
                ),

                // Bottom section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      IndicatorWidget(
                        length: provider.model.length,
                        selectedIndex: provider.currentModel?.index ?? 0,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _markOnboardingComplete();
                            provider.setLogintype(LoginType.register);
                            if (context.mounted) {
                              context.router.goToLogin();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomAppColors.blue500,
                            foregroundColor: CustomAppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            context.translate('create_account'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () async {
                          await _markOnboardingComplete();
                          provider.setLogintype(LoginType.login);
                          if (context.mounted) {
                            context.router.goToLogin();
                          }
                        },
                        child: Text(
                          context.translate('account_exist'),
                          style: const TextStyle(
                            color: CustomAppColors.slate600,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
      ),
    ),
  );
}

class _CleanTitleDisplay extends StatelessWidget {
  const _CleanTitleDisplay({required this.onboardingStateModel});

  final OnboardingStateModel onboardingStateModel;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // Large, clean illustration area
      Container(
        height: 280,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: CustomAppColors.blue50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: CustomAppColors.blue500,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                _getIconForStep(onboardingStateModel.index),
                size: 50,
                color: CustomAppColors.white,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 48),

      // Clean title
      Text(
        context.translate(onboardingStateModel.title),
        style: context.textTheme.titleXl.copyWith(
          color: CustomAppColors.slate800,
          fontWeight: FontWeight.bold,
          fontSize: 28,
          height: 1.3,
        ),
        textAlign: TextAlign.center,
      ),

      const SizedBox(height: 16),

      // Clean subtitle
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          context.translate(onboardingStateModel.subtitle),
          style: context.textTheme.bodyLg.copyWith(
            color: CustomAppColors.slate600,
            height: 1.5,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ],
  );

  IconData _getIconForStep(int index) {
    switch (index) {
      case 0:
        return Icons.school_outlined;
      case 1:
        return Icons.people_outline;
      case 2:
        return Icons.rocket_launch_outlined;
      default:
        return Icons.star_outline;
    }
  }
}
