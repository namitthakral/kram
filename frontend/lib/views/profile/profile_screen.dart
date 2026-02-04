import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../provider/login_signup/login_provider.dart';
import '../../utils/app_bar_config_helper.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/extensions.dart';
import '../../utils/router_service.dart';
import '../../widgets/custom_widgets/custom_dialog.dart';
import '../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../widgets/custom_widgets/responsive_layout.dart';
import 'account_settings_screen.dart';
import 'widgets/profile_info_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.router.goToLogin();
        }
      });
      return const SizedBox();
    }

    // Use CustomMainScreenWithAppbar for consistent header
    return CustomMainScreenWithAppbar(
      title: 'Profile',
      appBarConfig: AppBarConfigHelper.getConfigForUser(
        user,
        onNotificationIconPressed: () {},
        isProfileScreen: true,
      ),
      child: SingleChildScrollView(
        child: ResponsivePadding(
          mobile: const EdgeInsets.all(16),
          tablet: const EdgeInsets.all(24),
          desktop: const EdgeInsets.all(32),
          child: ResponsiveCenter(
            maxWidth: 1000,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Info Card
                ProfileInfoCard(user: user),
                const SizedBox(height: 24),

                // Profile Links Section
                _buildProfileLinksSection(context),
                const SizedBox(height: 24),

                // Logout Button
                _buildLogoutButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Profile Links Section
  Widget _buildProfileLinksSection(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.slate100),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: _buildProfileLinkTile(
      context,
      icon: Icons.settings_outlined,
      title: context.translate('account_settings'),
      subtitle: context.translate('manage_profile_security_preferences'),
      color: AppTheme.blue500,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => const AccountSettingsScreen(),
          ),
        );
      },
    ),
  );

  Widget _buildProfileLinkTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.bodyBase.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.slate800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySm.copyWith(
                      color: AppTheme.slate500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.slate500,
            ),
          ],
        ),
      ),
    ),
  );

  // Account status card
  Widget _buildAccountStatusCard(BuildContext context, user) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppTheme.success.withValues(alpha: 0.1),
          AppTheme.info.withValues(alpha: 0.1),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.success,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.verified_user,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              context.translate('account_status'),
              style: context.textTheme.titleBase.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.slate800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatusRow(
          context,
          Icons.check_circle,
          context.translate('email_verified'),
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildStatusRow(
          context,
          Icons.check_circle,
          context.translate('account_active'),
          Colors.green,
        ),
        if (user.edverseId != null) ...[
          const SizedBox(height: 8),
          _buildStatusRow(
            context,
            Icons.badge,
            '${context.translate('edverse_id')}: ${user.edverseId}',
            AppTheme.blue500,
          ),
        ],
      ],
    ),
  );

  Widget _buildStatusRow(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) => Row(
    children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.slate600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );

  String _getMemberSince(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 30) {
      return '${difference.inDays} ${context.translate('days')}';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} ${context.translate('months')}';
    } else {
      return '${(difference.inDays / 365).floor()} ${context.translate('years')}';
    }
  }

  String _capitalizeRole(String? roleName) {
    if (roleName == null || roleName.isEmpty) {
      return 'N/A';
    }
    return roleName
        .split(' ')
        .map((word) {
          if (word.isEmpty) {
            return word;
          }
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  Widget _buildLogoutButton(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppTheme.danger.withValues(alpha: 0.3),
        width: 2,
      ),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showLogoutDialog(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout_rounded,
                color: AppTheme.danger,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                context.translate('profile_logout'),
                style: context.textTheme.titleBase.copyWith(
                  color: AppTheme.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> _showLogoutDialog(BuildContext context) async {
    final result = await CustomDialog.showConfirmation(
      context: context,
      title: context.translate('logout_title'),
      message: context.translate('logout_message'),
      confirmText: context.translate('logout'),
      cancelText: context.translate('cancel'),
      confirmColor: AppTheme.danger,
      icon: Icons.logout_rounded,
      iconColor: AppTheme.danger,
    );

    if (result == true && context.mounted) {
      final loginProvider = context.read<LoginProvider>();

      unawaited(
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (BuildContext loadingContext) =>
                  const Center(child: CircularProgressIndicator()),
        ),
      );

      await loginProvider.logout();

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        context.router.goToLogin();

        showCustomSnackbar(
          message: context.translate('logout_success'),
          type: SnackbarType.success,
        );
      }
    }
  }
}
