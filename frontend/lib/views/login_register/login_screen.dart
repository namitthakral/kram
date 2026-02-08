import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/bottom_nav_provider.dart';
import '../../provider/login_signup/login_provider.dart';
import '../../provider/theme_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/custom_images.dart';
import '../../utils/extensions.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/router_service.dart';
import '../../widgets/custom_widgets/custom_bottom_modal_sheet.dart';
import '../../widgets/custom_widgets/custom_elevated_button.dart';
import '../../widgets/custom_widgets/custom_text_button.dart';
import '../../widgets/custom_widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    // Load saved credentials if Remember Me was previously checked
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginProvider = context.read<LoginProvider>();
      loginProvider.loadSavedCredentials();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    final isWebLayout = context.isDesktop;

    return Scaffold(
      body: SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient:
                isWebLayout
                    ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        CustomAppColors.blue50.withValues(alpha: 0.3),
                        CustomAppColors.white,
                      ],
                    )
                    : const LinearGradient(
                      colors: [Colors.transparent, Colors.transparent],
                    ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child:
                  isWebLayout
                      ? _buildWebLayout(context, themeProvider)
                      : _buildMobileLayout(context, themeProvider),
            ),
          ),
        ),
      ),
    );
  }

  // Mobile/Tablet Layout (Vertical)
  Widget _buildMobileLayout(
    BuildContext context,
    ThemeProvider themeProvider,
  ) => Padding(
    padding: const EdgeInsets.all(16.0),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo and Title Section
            _buildHeader(context, themeProvider),
            const SizedBox(height: 32),

            // Login Form
            _buildLoginForm(context, themeProvider),
            const SizedBox(height: 16),

            // Footer
            _buildFooter(context, themeProvider),
          ],
        ),
      ),
    ),
  );

  // Web Layout (Horizontal with divider)
  Widget _buildWebLayout(
    BuildContext context,
    ThemeProvider themeProvider,
  ) => Container(
    constraints: const BoxConstraints(maxWidth: 1200),
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
    child: Row(
      children: [
        // Left Section - Logo and Branding
        Expanded(flex: 5, child: _buildWebLogoSection(context, themeProvider)),

        // Vertical Divider
        Container(
          width: 1,
          height: 500,
          margin: const EdgeInsets.symmetric(horizontal: 48),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                CustomAppColors.grey01.withValues(alpha: 0.1),
                CustomAppColors.grey01.withValues(alpha: 0.5),
                CustomAppColors.grey01.withValues(alpha: 0.1),
              ],
            ),
          ),
        ),

        // Right Section - Login Form
        Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLoginForm(context, themeProvider),
              const SizedBox(height: 24),
              _buildFooter(context, themeProvider),
            ],
          ),
        ),
      ],
    ),
  );

  // Web Logo Section
  Widget _buildWebLogoSection(
    BuildContext context,
    ThemeProvider themeProvider,
  ) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // Large Logo
      Image.asset(CustomImages.appLogo, width: 200, height: 200),
      const SizedBox(height: 32),

      // // Welcome Text
      // Text(
      //   context.translate('welcome'),
      //   style: context.textTheme.titleXl.copyWith(
      //     fontSize: 42,
      //     fontWeight: FontWeight.bold,
      //     color:
      //         themeProvider.isDarkMode
      //             ? CustomAppColors.darkTextPrimary
      //             : CustomAppColors.textPrimary,
      //   ),
      //   textAlign: TextAlign.center,
      // ),

      // App Name
      Text(
        context.translate('app_name'),
        style: context.textTheme.titleLg.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: CustomAppColors.blue500,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );

  Widget _buildHeader(BuildContext context, ThemeProvider themeProvider) =>
      Column(
        children: [
          // Logo with EdVerse text
          Image.asset(CustomImages.appLogo, width: 150, height: 150),
          const SizedBox(height: 24),

          // Login title
          Text(
            context.translate('login_account'),
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
    child: Consumer<LoginProvider>(
      builder:
          (context, provider, child) => Column(
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
                      const Icon(
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
                        icon: const Icon(
                          Icons.close,
                          color: CustomAppColors.red500,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),

              // Login Identifier field (EdVerse ID, Email, or Phone)
              Text(
                context.translate('login_identifier'),
                style: context.textTheme.labelBase.copyWith(
                  fontWeight: FontWeight.w600,
                  color: CustomAppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: provider.emailController,
                hintText: context.translate('login_identifier_hint'),
                onChanged: (value) => provider.onEmailChanged(),
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
              Selector<LoginProvider, bool>(
                selector: (context, provider1) => provider1.isPasswordVisible,
                builder:
                    (context, value, child) => CustomTextField(
                      controller: provider.passwordController,
                      obscureText: !value,
                      hintText: context.translate('password_hint'),
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
                  // Consumer<LoginProvider>(
                  //   builder:
                  //       (context, loginProvider, child) => Checkbox(
                  //         value: loginProvider.rememberPassword,
                  //         onChanged: (value) {
                  //           loginProvider.updateRememberPassword(
                  //             rememberPass: value ?? false,
                  //           );
                  //         },
                  //         materialTapTargetSize:
                  //             MaterialTapTargetSize.shrinkWrap,
                  //       ),
                  // ),
                  Checkbox(
                    value: provider.rememberPassword,
                    onChanged: (value) {
                      provider.updateRememberPassword(
                        rememberPass: value ?? false,
                      );
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Text(
                    context.translate('remember_password'),
                    style: context.textTheme.bodySm.copyWith(
                      color: CustomAppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomElevatedButton(
                text:
                    provider.isLoading
                        ? context.translate('signing_in')
                        : context.translate('sign_in'),
                borderRadius: 8.0,
                isLoading: provider.isLoading,
                onPressed:
                    provider.isLoading
                        ? null
                        : () async {
                          await provider.loginAccount();
                          if (provider.currentUser != null && context.mounted) {
                            // Initialize navigation provider before navigating to home
                            final navProvider = context.read<BottomNavProvider>();
                            final user = provider.currentUser;

                            if (user?.role?.id != null) {
                              navProvider.initializeForRole(user!.role!.id);
                            }

                            // Navigate to home - user data and navigation already set up
                            if (context.mounted) {
                              context.router.goToHome();
                            }
                          }
                        },
              ),

              const SizedBox(height: 12),

              // Forgot Password link
              Center(
                child: CustomTextButton(
                  onButtonPressed:
                      () => CustomBottomSheet.forgetPasswordUpdate(
                        context: context,
                      ),
                  text: context.translate('forgot_password'),
                  textStyle: context.textTheme.bodySm.copyWith(
                    color: CustomAppColors.blue500,
                  ),
                ),
              ),
            ],
          ),
    ),
  );

  Widget _buildFooter(BuildContext context, ThemeProvider themeProvider) =>
      Column(
        children: [
          // Don't have an account
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Text(
          //       context.translate('dont_have_account'),
          //       style: context.textTheme.bodySm.copyWith(
          //         color:
          //             themeProvider.isDarkMode
          //                 ? CustomAppColors.grey01
          //                 : CustomAppColors.textSecondary,
          //       ),
          //     ),
          //     const SizedBox(width: 8),
          //     CustomTextButton(
          //       text: context.translate('contact_administrator'),
          //       onButtonPressed: () {
          //         // context.router.goToContactAdministrator();
          //       },
          //       textStyle: context.textTheme.bodySm.copyWith(
          //         color: CustomAppColors.blue500,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 24),

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

          // // Copyright
          // Text(
          //   context.translate('copyright_text'),
          //   style: context.textTheme.bodySm.copyWith(
          //     color:
          //         themeProvider.isDarkMode
          //             ? CustomAppColors.grey01
          //             : CustomAppColors.textSecondary,
          //   ),
          //   textAlign: TextAlign.center,
          // ),
        ],
      );
}
