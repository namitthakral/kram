import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../provider/login_signup/signup_provider.dart';
import '../../provider/onboarding_provider.dart';
import '../../provider/theme_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/custom_images.dart';
import '../../utils/enum.dart';
import '../../utils/extensions.dart';
import '../../utils/localization/app_localizations.dart';
import '../../utils/router_service.dart';
import '../../widgets/custom_widgets/custom_bottom_modal_sheet.dart';
import '../../widgets/custom_widgets/custom_elevated_button.dart';
import '../../widgets/custom_widgets/custom_text_button.dart';
import '../../widgets/custom_widgets/custom_text_field.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!.translate;
    final provider = context.read<SignUpProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    translate('create_account'),
                    style: context.textTheme.titleXl,
                  ),
                  subtitle: Text(
                    translate('create_account_desc'),
                    style: context.textTheme.bodySm.copyWith(
                      color: CustomAppColors.grey01,
                    ),
                  ),
                  trailing: CustomTextButton(
                    onButtonPressed: () {
                      context.read<OnboardingProvider>().setLogintype(
                        LoginType.login,
                      );

                      return context.router.goToLogin();
                    },
                    text: translate('login_account'),
                    textStyle: context.textTheme.bodySm.copyWith(
                      color:
                          context.read<ThemeProvider>().themeData.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(translate('username'), style: context.textTheme.labelBase),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: provider.usernameController,
                  prefixButtonIcon: ButtonIcon(icon: CustomImages.iconUser),
                  hintText: translate('username_hint'),
                ),
                const SizedBox(height: 16),
                Text(
                  translate('email_or_phone_number'),
                  style: context.textTheme.labelBase,
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: provider.emailController,
                  prefixButtonIcon: ButtonIcon(icon: CustomImages.iconSms),
                  hintText: translate('email_or_phone_number_hint'),
                ),
                const SizedBox(height: 16),
                Text(translate('password'), style: context.textTheme.labelBase),
                const SizedBox(height: 8),
                Selector<SignUpProvider, bool>(
                  selector: (context, provider1) => provider1.isPasswordVisible,
                  builder:
                      (context, value, child) => CustomTextField(
                        controller: provider.passwordController,
                        obscureText: !value,
                        prefixButtonIcon: ButtonIcon(
                          icon: CustomImages.iconLock,
                        ),
                        suffixButtonIcon: ButtonIcon(
                          icon:
                              value
                                  ? CustomImages.iconVisible
                                  : CustomImages.iconVisibleOff,
                          onIconTapped: provider.updatePasswordVisibility,
                        ),
                        hintText: translate('password_hint'),
                      ),
                ),
                const SizedBox(height: 32),
                CustomElevatedButton(
                  text: translate('create_account'),
                  onPressed: () {
                    provider.createAccount();

                    if (provider.isCreateAccountClicked) {
                      CustomBottomSheet.register(context: context);
                    }
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    translate('other_methods_hint'),
                    style: context.textTheme.bodySm.copyWith(
                      color: CustomAppColors.grey01,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _SocialButton(
                  text: translate('connect_with_google'),
                  image: CustomImages.iconGoogle,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.text,
    required this.image,
    required this.onPressed,
  });
  final String text;
  final VoidCallback onPressed;
  final String image;

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: CustomAppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 32.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      fixedSize: Size(MediaQuery.sizeOf(context).width, 44.0),
    ),
    icon: SvgPicture.asset(image, height: 24, width: 24),
    label: Text(
      text,
      style: context.textTheme.labelBase.copyWith(
        color: CustomAppColors.black01,
      ),
    ),
  );
}
