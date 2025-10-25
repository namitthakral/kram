import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/login_signup/login_provider.dart';
import '../../provider/theme_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/custom_images.dart';
import '../../utils/extensions.dart';
import '../../utils/localization/app_localizations.dart';
import '../../utils/router_service.dart';
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
    final themeProvider = context.read<ThemeProvider>();

    return Scaffold(
      backgroundColor:
          themeProvider.isDarkMode
              ? CustomAppColors.darkBackground
              : CustomAppColors.backgroundColor,
      body: SafeArea(
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
                  _buildHeader(context, translate, themeProvider),
                  const SizedBox(height: 40),

                  // Login Form
                  _buildLoginForm(context, translate, provider, themeProvider),
                  const SizedBox(height: 16),

                  // Footer
                  _buildFooter(context, translate, themeProvider),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String Function(String, {Map<String, dynamic>? params}) translate,
    ThemeProvider themeProvider,
  ) => Column(
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

      // Login title
      Text(
        translate('login_account'),
        style: context.textTheme.titleXl.copyWith(
          fontWeight: FontWeight.bold,
          color:
              themeProvider.isDarkMode
                  ? CustomAppColors.darkTextPrimary
                  : CustomAppColors.textPrimary,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );

  Widget _buildLoginForm(
    BuildContext context,
    String Function(String, {Map<String, dynamic>? params}) translate,
    LoginProvider provider,
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
        // Error message display - moved above email field
        if (provider.errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: CustomAppColors.red50,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: CustomAppColors.red200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: CustomAppColors.red500,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.errorMessage!,
                    style: context.textTheme.bodySm.copyWith(
                      color: CustomAppColors.red700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: provider.clearError,
                  icon: Icon(
                    Icons.close,
                    color: CustomAppColors.red500,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),

        // Username field
        Text(
          translate('username'),
          style: context.textTheme.labelBase.copyWith(
            fontWeight: FontWeight.w600,
            color: CustomAppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: provider.emailController,
          hintText: translate('username_hint'),
          onChanged: (value) => provider.onEmailChanged(),
        ),
        const SizedBox(height: 20),

        // Password field
        Text(
          translate('password'),
          style: context.textTheme.labelBase.copyWith(
            fontWeight: FontWeight.w600,
            color: CustomAppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Selector<LoginProvider, bool>(
          selector: (context, provider1) => provider1.isPasswordVisible,
          builder:
              (context, value, child) => CustomTextField(
                controller: provider.passwordController,
                obscureText: !value,
                hintText: translate('password_hint'),
                onChanged: (value) => provider.onPasswordChanged(),
                suffixButtonIcon: ButtonIcon(
                  icon:
                      value
                          ? CustomImages.iconVisible
                          : CustomImages.iconVisibleOff,
                  onIconTapped: provider.updatePasswordVisibility,
                ),
              ),
        ),
        const SizedBox(height: 16),

        // Remember me checkbox
        Row(
          children: [
            Consumer<LoginProvider>(
              builder:
                  (context, loginProvider, child) => Checkbox(
                    value: loginProvider.rememberPassword,
                    onChanged: (value) {
                      loginProvider.updateRememberPassword(value ?? false);
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
            ),
            Text(
              translate('remember_password'),
              style: context.textTheme.bodySm.copyWith(
                color: CustomAppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Login button
        Consumer<LoginProvider>(
          builder:
              (context, loginProvider, child) => CustomElevatedButton(
                text:
                    loginProvider.isLoading
                        ? translate('signing_in')
                        : translate('sign_in'),
                borderRadius: 8.0,
                isLoading: loginProvider.isLoading,
                onPressed:
                    loginProvider.isLoading
                        ? null
                        : () async {
                          await loginProvider.loginAccount();
                          if (loginProvider.currentUser != null &&
                              context.mounted) {
                            context.router.goToHome();
                          }
                        },
              ),
        ),
        const SizedBox(height: 12),

        // Forgot Password link
        Center(
          child: CustomTextButton(
            onButtonPressed:
                () => CustomBottomSheet.forgetPasswordUpdate(context: context),
            text: translate('forgot_password'),
            textStyle: context.textTheme.bodySm.copyWith(
              color: CustomAppColors.blue500,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildFooter(
    BuildContext context,
    String Function(String, {Map<String, dynamic>? params}) translate,
    ThemeProvider themeProvider,
  ) => Column(
    children: [
      // Don't have an account
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            translate('dont_have_account'),
            style: context.textTheme.bodySm.copyWith(
              color:
                  themeProvider.isDarkMode
                      ? CustomAppColors.grey01
                      : CustomAppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          CustomTextButton(
            text: translate('contact_administrator'),
            onButtonPressed: () {
              // Handle contact administrator
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
        translate('by_logging_in_agree'),
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
            text: translate('privacy_policy'),
            onButtonPressed: () {},
            textStyle: context.textTheme.bodySm.copyWith(
              color: CustomAppColors.blue500,
            ),
          ),
          Text(
            translate('and'),
            style: context.textTheme.bodySm.copyWith(
              color:
                  themeProvider.isDarkMode
                      ? CustomAppColors.grey01
                      : CustomAppColors.textSecondary,
            ),
          ),
          CustomTextButton(
            text: translate('terms_of_service'),
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
        translate('copyright_text'),
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
