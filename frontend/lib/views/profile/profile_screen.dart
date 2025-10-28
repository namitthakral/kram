import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/bottom_nav_provider.dart';
import '../../provider/language_provider.dart';
import '../../provider/login_signup/login_provider.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/extensions.dart';
import '../../utils/router_service.dart';
import '../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import 'change_password_screen.dart';
import 'help_support_screen.dart';
import 'language_screen.dart';
import 'legal_policies_screen.dart';
import 'notifications_settings_screen.dart';
import 'security/security_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomNavProvider = context.read<BottomNavProvider>();

    return CustomMainScreenWithAppbar(
      title: 'Profile Screen',
      appBarConfig: AppBarConfig.standard(
        showBackButton: false,
        onBackButtonTapped: () => bottomNavProvider.setIndex(0),
      ),
      child: SingleChildScrollView(
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.translate('profile_general'),
              style: context.textTheme.titleLg,
            ),
            _CustomListTile(
              title: context.translate('profile_edit_profile'),
              iconData: Icons.account_circle_outlined,
            ),
            _CustomListTile(
              title: context.translate('profile_change_password'),
              iconData: Icons.lock_outlined,
              onCardTapped:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ChangePasswordScreen(),
                    ),
                  ),
            ),
            _CustomListTile(
              title: context.translate('profile_notifications'),
              iconData: Icons.notifications_outlined,
              onCardTapped:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationsSettingsScreen(),
                    ),
                  ),
            ),
            _CustomListTile(
              title: context.translate('profile_security'),
              iconData: Icons.shield_outlined,
              onCardTapped:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SecurityScreen(),
                    ),
                  ),
            ),
            Consumer<LanguageProvider>(
              builder:
                  (context, value, child) => _CustomListTile(
                    title: context.translate('profile_language'),
                    iconData: Icons.language_outlined,
                    trailing:
                        context.read<LanguageProvider>().locale.languageCode ==
                                'hi'
                            ? context.translate('hindi')
                            : context.translate('english'),
                    onCardTapped:
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LanguageScreen(),
                          ),
                        ),
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              context.translate('profile_preferences'),
              style: context.textTheme.titleLg,
            ),
            _CustomListTile(
              title: context.translate('profile_legal_policies'),
              iconData: Icons.policy_outlined,
              onCardTapped:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LegalAndPolicies(),
                    ),
                  ),
            ),
            _CustomListTile(
              title: context.translate('profile_help_support'),
              iconData: Icons.help_outline_outlined,
              onCardTapped:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen(),
                    ),
                  ),
            ),
            _CustomListTile(
              title: context.translate('profile_logout'),
              iconData: Icons.logout_rounded,
              color: Colors.red,
              onCardTapped: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: Text(
              context.translate('logout_title'),
              style: context.textTheme.titleLg.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              context.translate('logout_message'),
              style: context.textTheme.bodyBase,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  context.translate('cancel'),
                  style: context.textTheme.labelBase.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();

                  final loginProvider = context.read<LoginProvider>();

                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (BuildContext loadingContext) =>
                            const Center(child: CircularProgressIndicator()),
                  );

                  // Perform logout
                  await loginProvider.logout();

                  // Close loading indicator
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }

                  // Navigate to login screen
                  if (context.mounted) {
                    context.router.goToLogin();

                    // Show success message
                    showCustomSnackbar(
                      message: context.translate('logout_success'),
                      type: SnackbarType.success,
                    );
                  }
                },
                child: Text(
                  context.translate('logout'),
                  style: context.textTheme.labelBase.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

class _CustomListTile extends StatelessWidget {
  const _CustomListTile({
    required this.title,
    required this.iconData,
    this.trailing,
    this.color,
    this.onCardTapped,
  });
  final String title;
  final String? trailing;
  final IconData iconData;
  final Color? color;
  final void Function()? onCardTapped;

  @override
  Widget build(BuildContext context) => InkWell(
    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    onTap: onCardTapped,
    child: Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              iconData,
              size: 30,
              color: color ?? context.textTheme.bodySm.color,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: context.textTheme.labelSm.copyWith(
                color: color ?? context.textTheme.bodySm.color,
              ),
            ),
            const Spacer(),
            if (trailing == null)
              const Icon(Icons.arrow_forward_ios, color: Color(0xFFA7AEC1))
            else
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: trailing,
                      style: context.textTheme.bodySm.copyWith(
                        color: const Color(0xFFA7AEC1),
                      ),
                    ),
                    const WidgetSpan(child: SizedBox(width: 12)),
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFFA7AEC1),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
