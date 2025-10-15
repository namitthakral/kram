import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../provider/login_signup/login_provider.dart';
import '../../provider/onboarding_provider.dart';
import '../../provider/theme_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/custom_images.dart';
import '../../utils/enum.dart';
import '../../utils/extensions.dart';
import '../../utils/localization/app_localizations.dart';
import '../../utils/router_service.dart';
import '../../widgets/custom_widgets/adaptive_builder.dart';
import '../../widgets/custom_widgets/custom_bottom_modal_sheet.dart';
import '../../widgets/custom_widgets/custom_elevated_button.dart';
import '../../widgets/custom_widgets/custom_text_button.dart';
import '../../widgets/custom_widgets/custom_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!.translate;
    final provider = context.read<LoginProvider>();

    return Scaffold(
      body: SafeArea(
        child: AdaptiveBuilder(
          builder: (context, info) {
            // For tablet/desktop landscape, use two-column layout
            if ((info.isTabletLandscape || info.isDesktop) &&
                info.isWideScreen) {
              return _buildTwoColumnLayout(context, translate, provider, info);
            }

            // For all other cases, use single column scrollable layout
            return _buildSingleColumnLayout(context, translate, provider, info);
          },
        ),
      ),
    );
  }

  Widget _buildTwoColumnLayout(
    BuildContext context,
    String Function(String, {Map<String, dynamic>? params}) translate,
    LoginProvider provider,
    AdaptiveInfo info,
  ) => Row(
    children: [
      // Left side - Branding/Image
      Expanded(
        child: ColoredBox(
          color: context
              .read<ThemeProvider>()
              .themeData
              .primaryColor
              .withValues(alpha: 0.1),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(CustomImages.logo, width: 200, height: 200),
                const SizedBox(height: 24),
                Text(translate('app_name'), style: context.textTheme.titleXl),
              ],
            ),
          ),
        ),
      ),
      // Right side - Login form
      Expanded(
        child: AdaptiveContainer(
          maxWidth: 500,
          child: _buildLoginForm(context, translate, provider, info),
        ),
      ),
    ],
  );

  Widget _buildSingleColumnLayout(
    BuildContext context,
    String Function(String, {Map<String, dynamic>? params}) translate,
    LoginProvider provider,
    AdaptiveInfo info,
  ) => SingleChildScrollView(
    child: AdaptiveContainer(
      child: _buildLoginForm(context, translate, provider, info),
    ),
  );

  Widget _buildLoginForm(
    BuildContext context,
    String Function(String, {Map<String, dynamic>? params}) translate,
    LoginProvider provider,
    AdaptiveInfo info,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          translate('login_account'),
          style: context.textTheme.titleXl,
        ),
        subtitle: Text(
          translate('login_account_desc'),
          style: context.textTheme.bodySm.copyWith(
            color: CustomAppColors.grey01,
          ),
        ),
        trailing: CustomTextButton(
          onButtonPressed: () {
            context.read<OnboardingProvider>().setLogintype(LoginType.register);

            context.read<LoginProvider>().updatePasswordVisibility();

            return context.router.goToLogin();
          },
          text: translate('create_account'),
          textStyle: context.textTheme.bodySm.copyWith(
            color: context.read<ThemeProvider>().themeData.primaryColor,
          ),
        ),
      ),
      const SizedBox(height: 24),
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
      Selector<LoginProvider, bool>(
        selector: (context, provider1) => provider1.isPasswordVisible,
        builder:
            (context, value, child) => CustomTextField(
              controller: provider.passwordController,
              obscureText: !value,
              prefixButtonIcon: ButtonIcon(icon: CustomImages.iconLock),
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
      Align(
        alignment: Alignment.centerRight,
        child: CustomTextButton(
          onButtonPressed:
              () => CustomBottomSheet.forgetPasswordUpdate(context: context),
          text: '${translate('forgot_password')}?',
          textStyle: context.textTheme.bodySm,
        ),
      ),
      const SizedBox(height: 16),
      CustomElevatedButton(
        text: translate('sign_in'),
        onPressed: () {
          provider.loginAccount();
          context.router.goToHome();
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
  );
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
