import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../provider/login_signup/login_provider.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/extensions.dart';
import '../../utils/router_service.dart';
import '../../widgets/custom_widgets/responsive_layout.dart';
import 'widgets/profile_header.dart';
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

    // Use ResponsiveLayout widget following project pattern
    return ResponsiveLayout(
      mobile: _buildMobileLayout(context, user),
      tablet: _buildDesktopLayout(context, user), // Same as desktop for tablet
      desktop: _buildDesktopLayout(context, user),
    );
  }

  // Mobile Layout - Original Design with ProfileHeader
  Widget _buildMobileLayout(BuildContext context, user) =>
      AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProfileHeader(user: user),
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      color: AppTheme.backgroundColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ProfileInfoCard(user: user),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildLogoutButton(context),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  // Desktop/Tablet Layout - Modern design
  Widget _buildDesktopLayout(BuildContext context, user) => Scaffold(
    backgroundColor: AppTheme.backgroundColor,
    body: SafeArea(
      child: SingleChildScrollView(
        child: ResponsivePadding(
          desktop: const EdgeInsets.all(32),
          tablet: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Modern header with gradient background
              _buildModernHeader(context, user),
              const SizedBox(height: 32),

              // Content section with cards
              ResponsiveCenter(
                maxWidth: 1000,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Stats cards row
                    _buildStatsCards(context, user),
                    const SizedBox(height: 24),

                    // Main content
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column - Profile details
                        Expanded(flex: 2, child: ProfileInfoCard(user: user)),
                        const SizedBox(width: 24),

                        // Right column - Quick actions & additional info
                        Expanded(
                          child: Column(
                            children: [
                              _buildQuickActionsCard(context),
                              const SizedBox(height: 24),
                              _buildAccountStatusCard(context, user),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ),
  );

  // Modern header with gradient
  Widget _buildModernHeader(BuildContext context, user) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppTheme.blue500, AppTheme.blue600],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppTheme.blue500.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Row(
      children: [
        // Decorative element
        Container(
          width: 4,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 24),

        // Text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.translate('profile_information'),
                style: context.textTheme.h2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'View and manage your account information',
                style: context.textTheme.bodyBase.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),

        // Icon
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.person_outline,
            color: Colors.white,
            size: 32,
          ),
        ),
      ],
    ),
  );

  // Stats cards
  Widget _buildStatsCards(BuildContext context, user) => Row(
    children: [
      Expanded(
        child: _buildStatCard(
          context,
          'Account Status',
          user.status,
          Icons.check_circle_outline,
          AppTheme.success,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _buildStatCard(
          context,
          'Role',
          user.role?.roleName ?? 'N/A',
          Icons.work_outline,
          AppTheme.blue500,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _buildStatCard(
          context,
          'Member Since',
          _getMemberSince(user.createdAt),
          Icons.calendar_today_outlined,
          AppTheme.info,
        ),
      ),
    ],
  );

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) => Container(
    padding: const EdgeInsets.all(20),
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: context.textTheme.bodySm.copyWith(
                  color: AppTheme.slate500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: context.textTheme.titleLg.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.slate800,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );

  // Quick actions card
  Widget _buildQuickActionsCard(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.blue50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt, size: 20, color: AppTheme.blue500),
            ),
            const SizedBox(width: 12),
            Text(
              'Quick Actions',
              style: context.textTheme.titleBase.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.slate800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildActionButton(
          context,
          icon: Icons.edit_outlined,
          label: 'Edit Profile',
          onTap: () {
            // TODO: Navigate to edit profile
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context,
          icon: Icons.lock_outline,
          label: 'Change Password',
          onTap: () {
            // TODO: Navigate to change password
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context,
          icon: Icons.settings_outlined,
          label: 'Account Settings',
          onTap: () {
            // TODO: Navigate to settings
          },
        ),
      ],
    ),
  );

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) => Material(
    color: AppTheme.slate100,
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.slate600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: context.textTheme.bodyBase.copyWith(
                  color: AppTheme.slate800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.slate500),
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
              'Account Status',
              style: context.textTheme.titleBase.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.slate800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatusRow(Icons.check_circle, 'Email Verified', Colors.green),
        const SizedBox(height: 8),
        _buildStatusRow(Icons.check_circle, 'Account Active', Colors.green),
        if (user.edverseId != null) ...[
          const SizedBox(height: 8),
          _buildStatusRow(
            Icons.badge,
            'EdVerse ID: ${user.edverseId}',
            AppTheme.blue500,
          ),
        ],
      ],
    ),
  );

  Widget _buildStatusRow(IconData icon, String text, Color color) => Row(
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

  String _getMemberSince(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 30) {
      return '${difference.inDays} days';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months';
    } else {
      return '${(difference.inDays / 365).floor()} years';
    }
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppTheme.danger,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  context.translate('logout_title'),
                  style: context.textTheme.titleLg.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
                    color: AppTheme.slate500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();

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
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.danger,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  context.translate('logout'),
                  style: context.textTheme.labelBase.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
