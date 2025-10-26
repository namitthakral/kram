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
import '../../utils/router_service.dart';
import '../../widgets/custom_widgets/custom_bottom_modal_sheet.dart';
import '../../widgets/custom_widgets/custom_elevated_button.dart';
import '../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../widgets/custom_widgets/custom_text_button.dart';
import '../../widgets/custom_widgets/custom_text_field.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SignUpProvider>();
    final themeProvider = context.read<ThemeProvider>();

    return CustomMainScreenWithAppbar(
      title: context.translate('create_account'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Logo and Title Section
                _buildHeader(context, themeProvider),
                const SizedBox(height: 40),

                // Sign Up Form
                _buildSignUpForm(context, provider, themeProvider),
                const SizedBox(height: 16),

                // Footer
                _buildFooter(context, themeProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeProvider themeProvider) =>
      Column(
        children: [
          // Logo with EdVerse text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: CustomAppColors.blue500,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Icon(
                  Icons.school,
                  color: CustomAppColors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'EdVerse',
                style: context.textTheme.titleXl.copyWith(
                  fontWeight: FontWeight.bold,
                  color: CustomAppColors.blue500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Create Account title
          Text(
            context.translate('create_account'),
            style: context.textTheme.titleXl.copyWith(
              fontWeight: FontWeight.bold,
              color:
                  themeProvider.isDarkMode
                      ? CustomAppColors.darkTextPrimary
                      : CustomAppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            context.translate('create_account_desc'),
            style: context.textTheme.bodySm.copyWith(
              color:
                  themeProvider.isDarkMode
                      ? CustomAppColors.grey01
                      : CustomAppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );

  Widget _buildSignUpForm(
    BuildContext context,

    SignUpProvider provider,
    ThemeProvider themeProvider,
  ) => Container(
    padding: const EdgeInsets.all(24.0),
    decoration: BoxDecoration(
      color: CustomAppColors.white,
      borderRadius: BorderRadius.circular(16.0),
      boxShadow: [
        BoxShadow(
          color: CustomAppColors.black01.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Username field
        // Text(
        //   context.translate('username'),
        //   style: context.textTheme.labelBase.copyWith(
        //     fontWeight: FontWeight.w600,
        //     color: CustomAppColors.textPrimary,
        //   ),
        // ),
        // const SizedBox(height: 8),
        // CustomTextField(
        //   controller: provider.usernameController,
        //   hintText: context.translate('username_hint'),
        // ),
        // const SizedBox(height: 20),

        // Email field
        Text(
          context.translate('email_or_phone_number'),
          style: context.textTheme.labelBase.copyWith(
            fontWeight: FontWeight.w600,
            color: CustomAppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: provider.emailController,
          hintText: context.translate('email_or_phone_number_hint'),
        ),
        const SizedBox(height: 20),

        // Password field
        Text(
          context.translate('password'),
          style: context.textTheme.labelBase.copyWith(
            fontWeight: FontWeight.w600,
            color: CustomAppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Selector<SignUpProvider, bool>(
          selector: (context, provider1) => provider1.isPasswordVisible,
          builder:
              (context, value, child) => CustomTextField(
                controller: provider.passwordController,
                obscureText: !value,
                hintText: context.translate('password_hint'),
                suffixButtonIcon: ButtonIcon(
                  icon:
                      value
                          ? CustomImages.iconVisible
                          : CustomImages.iconVisibleOff,
                  onIconTapped: provider.updatePasswordVisibility,
                ),
              ),
        ),
        const SizedBox(height: 20),

        // Confirm Password field
        Text(
          context.translate('confirm_password'),
          style: context.textTheme.labelBase.copyWith(
            fontWeight: FontWeight.w600,
            color: CustomAppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Selector<SignUpProvider, bool>(
          selector: (context, provider1) => provider1.isConfirmPasswordVisible,
          builder:
              (context, value, child) => CustomTextField(
                controller: provider.confirmPasswordController,
                obscureText: !value,
                hintText: context.translate('confirm_password_hint'),
                suffixButtonIcon: ButtonIcon(
                  icon:
                      value
                          ? CustomImages.iconVisible
                          : CustomImages.iconVisibleOff,
                  onIconTapped: provider.updateConfirmPasswordVisibility,
                ),
              ),
        ),
        const SizedBox(height: 24),

        // Create Account button
        CustomElevatedButton(
          text: context.translate('create_account'),
          borderRadius: 8.0,
          onPressed: () {
            provider.createAccount();
            if (provider.isCreateAccountClicked) {
              CustomBottomSheet.register(context: context);
            }
          },
        ),
        const SizedBox(height: 16),

        // Or divider
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                context.translate('other_methods_hint'),
                style: context.textTheme.bodySm.copyWith(
                  color: CustomAppColors.textSecondary,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),

        // Google Sign Up button
        _SocialButton(
          text: context.translate('connect_with_google'),
          image: CustomImages.iconGoogle,
          onPressed: () {},
        ),
      ],
    ),
  );

  Widget _buildFooter(BuildContext context, ThemeProvider themeProvider) =>
      Column(
        children: [
          // Already have an account
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.translate('account_exist'),
                style: context.textTheme.bodySm.copyWith(
                  color:
                      themeProvider.isDarkMode
                          ? CustomAppColors.grey01
                          : CustomAppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              CustomTextButton(
                text: context.translate('sign_in'),
                onButtonPressed: () {
                  context.read<OnboardingProvider>().setLogintype(
                    LoginType.login,
                  );
                  context.router.goToLogin();
                },
                textStyle: context.textTheme.bodySm.copyWith(
                  color: CustomAppColors.blue500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Terms and Privacy
          Text(
            context.translate('by_logging_in_agree'),
            style: context.textTheme.bodySm.copyWith(
              color:
                  themeProvider.isDarkMode
                      ? CustomAppColors.grey01
                      : CustomAppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextButton(
                text: context.translate('privacy_policy'),
                onButtonPressed: () {},
                textStyle: context.textTheme.bodySm.copyWith(
                  color: CustomAppColors.blue500,
                ),
              ),
              Text(
                context.translate('and'),
                style: context.textTheme.bodySm.copyWith(
                  color:
                      themeProvider.isDarkMode
                          ? CustomAppColors.grey01
                          : CustomAppColors.textSecondary,
                ),
              ),
              CustomTextButton(
                text: context.translate('terms_of_service'),
                onButtonPressed: () {},
                textStyle: context.textTheme.bodySm.copyWith(
                  color: CustomAppColors.blue500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Copyright
          Text(
            context.translate('copyright_text'),
            style: context.textTheme.bodySm.copyWith(
              color:
                  themeProvider.isDarkMode
                      ? CustomAppColors.grey01
                      : CustomAppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
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
