import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../provider/onboarding_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/custom_images.dart';
import '../../utils/enum.dart';
import '../../utils/extensions.dart';
import '../../utils/localization/app_localizations.dart';
import '../../utils/router_service.dart';
import '../../utils/secure_storge.dart';
import '../../widgets/custom_widgets/custom_elevated_button.dart';
import '../../widgets/custom_widgets/custom_text_button.dart';
import 'indicator.dart';
import 'onboarding_state_model.dart';

class OnboardingMain extends StatelessWidget {
  const OnboardingMain({super.key});

  Future<void> _markOnboardingComplete() async {
    final secureStorage = SecureStorageService();
    await secureStorage.write(
      AppConstants.onboardingCompletedKey,
      'true',
    );
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!.translate;

    return Scaffold(
      body: const DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(CustomImages.background),
            fit: BoxFit.fill,
          ),
        ),
        child: SizedBox(height: double.infinity, width: double.infinity),
      ),
      bottomSheet: SafeArea(
        child: Consumer<OnboardingProvider>(
          builder:
              (context, provider, child) => BottomSheet(
                showDragHandle: false,
                onClosing: () {},
                enableDrag: false,
                builder:
                    (context) => SizedBox(
                      height: 375,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          24.0,
                          32.0,
                          24.0,
                          32.0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: PageView.builder(
                                itemCount: provider.model.length,
                                onPageChanged:
                                    (value) => provider.setCurrentModel(
                                      provider.model[value],
                                    ),
                                itemBuilder:
                                    (context, index) => _TitleDisplay(
                                      translate: translate,
                                      onboardingStateModel:
                                          provider.model[index],
                                    ),
                              ),
                            ),
                            IndicatorWidget(
                              length: provider.model.length,
                              selectedIndex: provider.currentModel?.index ?? 0,
                            ),
                            const SizedBox(height: 16),
                            CustomElevatedButton(
                              text: translate('create_account'),
                              onPressed: () async {
                                await _markOnboardingComplete();
                                provider.setLogintype(LoginType.register);
                                if (context.mounted) {
                                  context.router.goToLogin();
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextButton(
                              text: translate('account_exist'),
                              onButtonPressed: () async {
                                await _markOnboardingComplete();
                                provider.setLogintype(LoginType.login);
                                if (context.mounted) {
                                  context.router.goToLogin();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
              ),
        ),
      ),
    );
  }
}

class _TitleDisplay extends StatelessWidget {
  const _TitleDisplay({
    required this.onboardingStateModel,
    required this.translate,
  });
  final String Function(String, {Map<String, dynamic>? params}) translate;
  final OnboardingStateModel onboardingStateModel;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: width - 100,
          child: Text(
            translate(onboardingStateModel.title),
            style: context.textTheme.titleXl,
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: width - 100,
          child: Text(
            translate(onboardingStateModel.subtitle),
            style: context.textTheme.bodySm.copyWith(
              color: CustomAppColors.grey01,
            ),
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}
