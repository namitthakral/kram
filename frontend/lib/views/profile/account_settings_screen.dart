import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../provider/login_signup/login_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/custom_widgets/responsive_layout.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'language_screen.dart';
import 'legal_policies_screen.dart';
import 'notifications_settings_screen.dart';
import 'security/security_screen.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });
      return const SizedBox();
    }

    return ResponsiveLayout(
      mobile: _buildMobileLayout(context, user),
      tablet: _buildDesktopLayout(context, user),
      desktop: _buildDesktopLayout(context, user),
    );
  }

  // Mobile Layout
  Widget _buildMobileLayout(BuildContext context, user) =>
      AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.slate800),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Account Settings',
              style: context.textTheme.h3.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.slate800,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSettingsSection(
                    context,
                    title: 'Profile',
                    items: [
                      _SettingsItem(
                        icon: Icons.edit_outlined,
                        title: 'Edit Profile',
                        subtitle: 'Update your personal information',
                        color: AppTheme.blue500,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsSection(
                    context,
                    title: 'Security & Privacy',
                    items: [
                      _SettingsItem(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        subtitle: 'Update your account password',
                        color: AppTheme.danger,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const ChangePasswordScreen(),
                            ),
                          );
                        },
                      ),
                      _SettingsItem(
                        icon: Icons.security_outlined,
                        title: 'Security',
                        subtitle: 'Privacy and security settings',
                        color: AppTheme.success,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const SecurityScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsSection(
                    context,
                    title: 'Preferences',
                    items: [
                      _SettingsItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Manage notification preferences',
                        color: AppTheme.warning,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  const NotificationsSettingsScreen(),
                            ),
                          );
                        },
                      ),
                      _SettingsItem(
                        icon: Icons.language_outlined,
                        title: 'Language',
                        subtitle: 'Change app language',
                        color: AppTheme.info,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const LanguageScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsSection(
                    context,
                    title: 'Support',
                    items: [
                      _SettingsItem(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'Get help and FAQs',
                        color: AppTheme.blue500,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const HelpSupportScreen(),
                            ),
                          );
                        },
                      ),
                      _SettingsItem(
                        icon: Icons.description_outlined,
                        title: 'Legal & Policies',
                        subtitle: 'Terms and privacy policy',
                        color: AppTheme.slate600,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const LegalAndPolicies(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  // Desktop/Tablet Layout
  Widget _buildDesktopLayout(BuildContext context, user) => Scaffold(
    backgroundColor: AppTheme.backgroundColor,
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.slate800),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Account Settings',
        style: context.textTheme.h3.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.slate800,
        ),
      ),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        child: ResponsivePadding(
          desktop: const EdgeInsets.all(32),
          tablet: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildDesktopHeader(context),
              const SizedBox(height: 32),

              // Content
              ResponsiveCenter(
                maxWidth: 1200,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column
                    Expanded(
                      child: Column(
                        children: [
                          _buildSettingsSection(
                            context,
                            title: 'Profile',
                            items: [
                              _SettingsItem(
                                icon: Icons.edit_outlined,
                                title: 'Edit Profile',
                                subtitle: 'Update your personal information',
                                color: AppTheme.blue500,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          const EditProfileScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildSettingsSection(
                            context,
                            title: 'Security & Privacy',
                            items: [
                              _SettingsItem(
                                icon: Icons.lock_outline,
                                title: 'Change Password',
                                subtitle: 'Update your account password',
                                color: AppTheme.danger,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          const ChangePasswordScreen(),
                                    ),
                                  );
                                },
                              ),
                              _SettingsItem(
                                icon: Icons.security_outlined,
                                title: 'Security',
                                subtitle: 'Privacy and security settings',
                                color: AppTheme.success,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          const SecurityScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Right column
                    Expanded(
                      child: Column(
                        children: [
                          _buildSettingsSection(
                            context,
                            title: 'Preferences',
                            items: [
                              _SettingsItem(
                                icon: Icons.notifications_outlined,
                                title: 'Notifications',
                                subtitle: 'Manage notification preferences',
                                color: AppTheme.warning,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          const NotificationsSettingsScreen(),
                                    ),
                                  );
                                },
                              ),
                              _SettingsItem(
                                icon: Icons.language_outlined,
                                title: 'Language',
                                subtitle: 'Change app language',
                                color: AppTheme.info,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          const LanguageScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildSettingsSection(
                            context,
                            title: 'Support',
                            items: [
                              _SettingsItem(
                                icon: Icons.help_outline,
                                title: 'Help & Support',
                                subtitle: 'Get help and FAQs',
                                color: AppTheme.blue500,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          const HelpSupportScreen(),
                                    ),
                                  );
                                },
                              ),
                              _SettingsItem(
                                icon: Icons.description_outlined,
                                title: 'Legal & Policies',
                                subtitle: 'Terms and privacy policy',
                                color: AppTheme.slate600,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          const LegalAndPolicies(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildDesktopHeader(BuildContext context) => Container(
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
        Container(
          width: 4,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Settings',
                style: context.textTheme.h2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your profile, security, and preferences',
                style: context.textTheme.bodyBase.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.settings_outlined,
            color: Colors.white,
            size: 32,
          ),
        ),
      ],
    ),
  );

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required List<_SettingsItem> items,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 12),
        child: Text(
          title,
          style: context.textTheme.titleBase.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.slate800,
          ),
        ),
      ),
      Container(
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
          children: [
            for (int i = 0; i < items.length; i++) ...[
              _buildSettingsTile(
                context,
                icon: items[i].icon,
                title: items[i].title,
                subtitle: items[i].subtitle,
                color: items[i].color,
                onTap: items[i].onTap,
              ),
              if (i < items.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: AppTheme.slate100),
                ),
            ],
          ],
        ),
      ),
    ],
  );

  Widget _buildSettingsTile(
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
      borderRadius: BorderRadius.circular(12),
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
}

class _SettingsItem {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
}
