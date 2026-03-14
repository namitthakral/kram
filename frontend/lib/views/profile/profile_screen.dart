import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/role_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../modules/student/providers/student_provider.dart';
import '../../provider/login_signup/login_provider.dart';
import '../../utils/app_bar_config_helper.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/extensions.dart';
import '../../utils/router_service.dart';
import '../../utils/user_utils.dart';
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

    // Use the same app bar config as role-specific screens (student, teacher, etc.)
    AppBarConfig appBarConfig;
    final roleId = user.role?.id;

    if (roleId == RoleConstants.student.id) {
      final studentProvider = context.watch<StudentProvider>();
      final userInitials = UserUtils.getInitials(user.name);
      final userName = user.name;

      final className = studentProvider.studentClassName;
      final section = studentProvider.studentSection;
      final grade =
          (className.isNotEmpty || section.isNotEmpty)
              ? '$className $section'.trim()
              : 'Class N/A';

      final rollNumber = user.student?.rollNumber ?? 'N/A';
      final statsData = studentProvider.dashboardStats;
      final gpa = statsData?['gpa']?.toString();

      appBarConfig = AppBarConfig.student(
        userInitials: userInitials,
        userName: userName,
        grade: grade,
        rollNumber: rollNumber,
        gpa: gpa,
        onNotificationIconPressed: () {},
      );
    } else if (roleId == RoleConstants.teacher.id) {
      // Same teacher app bar as My Classes and other teacher screens
      final teacher = user.teacher;
      appBarConfig = AppBarConfig.teacher(
        userInitials: UserUtils.getInitials(user.name),
        userName: user.name,
        designation: teacher?.designation ?? 'Faculty',
        employeeId: teacher?.employeeId ?? 'N/A',
        onNotificationIconPressed: () {},
      );
    } else {
      appBarConfig = AppBarConfigHelper.getConfigForUser(
        user,
        onNotificationIconPressed: () {},
        isProfileScreen: true,
      );
    }

    // Use CustomMainScreenWithAppbar for consistent header
    return CustomMainScreenWithAppbar(
      title: context.translate('profile'),
      appBarConfig: appBarConfig,
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
