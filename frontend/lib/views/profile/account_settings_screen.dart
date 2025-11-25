import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../provider/login_signup/login_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/extensions.dart';
import '../../widgets/custom_widgets/custom_tab_bar.dart';
import '../../widgets/custom_widgets/responsive_layout.dart';
import 'tabs/academic_info_tab.dart';
import 'tabs/contact_info_tab.dart';
import 'tabs/institution_settings_tab.dart';
import 'tabs/language_tab.dart';
import 'tabs/notifications_tab.dart';
import 'tabs/personal_info_tab.dart';
import 'tabs/professional_info_tab.dart';
import 'tabs/security_tab.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  int _selectedTabIndex = 0;

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

    // Determine which tabs to show based on role
    final tabs = _getTabsForRole(user.role?.id ?? 0);
    final selectedTab = tabs[_selectedTabIndex].value;

    return Scaffold(
      backgroundColor: CustomAppColors.backgroundColor,
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(tabs, selectedTab),
        tablet: _buildDesktopLayout(tabs, selectedTab),
        desktop: _buildDesktopLayout(tabs, selectedTab),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement save changes
        },
        icon: const Icon(Icons.save_outlined),
        label: const Text('Save Changes'),
        backgroundColor: AppTheme.blue500,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  List<TabItem<String>> _getTabsForRole(int roleId) {
    final baseTabs = [
      const TabItem(
        value: 'Personal',
        label: 'Personal',
        icon: Icons.person_outline,
      ),
      const TabItem(
        value: 'Contact',
        label: 'Contact',
        icon: Icons.contact_mail_outlined,
      ),
    ];

    // Add role-specific tabs
    switch (roleId) {
      case 3: // Student
        return [
          ...baseTabs,
          const TabItem(
            value: 'Academic',
            label: 'Academic',
            icon: Icons.school_outlined,
          ),
          const TabItem(
            value: 'Security',
            label: 'Security',
            icon: Icons.security_outlined,
          ),
          const TabItem(
            value: 'Notifications',
            label: 'Notifications',
            icon: Icons.notifications_outlined,
          ),
          const TabItem(
            value: 'Language',
            label: 'Language',
            icon: Icons.language_outlined,
          ),
        ];
      case 5: // Teacher
        return [
          ...baseTabs,
          const TabItem(
            value: 'Professional',
            label: 'Professional',
            icon: Icons.work_outline,
          ),
          const TabItem(
            value: 'Security',
            label: 'Security',
            icon: Icons.security_outlined,
          ),
          const TabItem(
            value: 'Notifications',
            label: 'Notifications',
            icon: Icons.notifications_outlined,
          ),
          const TabItem(
            value: 'Language',
            label: 'Language',
            icon: Icons.language_outlined,
          ),
        ];
      case 6: // Librarian
      case 7: // Staff
        return [
          ...baseTabs,
          const TabItem(
            value: 'Professional',
            label: 'Professional',
            icon: Icons.work_outline,
          ),
          const TabItem(
            value: 'Security',
            label: 'Security',
            icon: Icons.security_outlined,
          ),
          const TabItem(
            value: 'Notifications',
            label: 'Notifications',
            icon: Icons.notifications_outlined,
          ),
          const TabItem(
            value: 'Language',
            label: 'Language',
            icon: Icons.language_outlined,
          ),
        ];
      case 1: // Super Admin
      case 2: // Admin
        return [
          ...baseTabs,
          const TabItem(
            value: 'Professional',
            label: 'Professional',
            icon: Icons.work_outline,
          ),
          const TabItem(
            value: 'Institution',
            label: 'Institution',
            icon: Icons.business_outlined,
          ),
          const TabItem(
            value: 'Security',
            label: 'Security',
            icon: Icons.security_outlined,
          ),
          const TabItem(
            value: 'Notifications',
            label: 'Notifications',
            icon: Icons.notifications_outlined,
          ),
          const TabItem(
            value: 'Language',
            label: 'Language',
            icon: Icons.language_outlined,
          ),
        ];
      default:
        return [
          ...baseTabs,
          const TabItem(
            value: 'Security',
            label: 'Security',
            icon: Icons.security_outlined,
          ),
          const TabItem(
            value: 'Notifications',
            label: 'Notifications',
            icon: Icons.notifications_outlined,
          ),
          const TabItem(
            value: 'Language',
            label: 'Language',
            icon: Icons.language_outlined,
          ),
        ];
    }
  }

  Widget _buildMobileLayout(List<TabItem<String>> tabs, String selectedTab) =>
      Column(
        children: [
          // Profile-style Gradient Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.blue500, AppTheme.blue600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.blue600.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  children: [
                    // Back button row
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Settings Icon
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.settings,
                          size: 36,
                          color: AppTheme.blue500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Title
                    Text(
                      'Account Settings',
                      style: context.textTheme.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 6),

                    // Subtitle badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Manage Your Profile',
                        style: context.textTheme.labelSm.copyWith(
                          color: AppTheme.blue600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Horizontal Scrollable Tabs
          CustomTabBar<String>(
            tabs: tabs,
            selectedValue: selectedTab,
            onTabSelected: (value) {
              setState(() {
                _selectedTabIndex = tabs.indexWhere((t) => t.value == value);
              });
            },
          ),

          Expanded(child: _buildTabContent(selectedTab)),
        ],
      );

  Widget _buildDesktopLayout(List<TabItem<String>> tabs, String selectedTab) =>
      SafeArea(
        child: ResponsivePadding(
          desktop: const EdgeInsets.all(32),
          tablet: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Modern header with gradient
              _buildModernHeader(context),
              const SizedBox(height: 32),

              // Horizontal Scrollable Tabs
              Container(
                constraints: const BoxConstraints(maxWidth: 980),
                child: CustomTabBar<String>(
                  tabs: tabs,
                  selectedValue: selectedTab,
                  onTabSelected: (value) {
                    setState(() {
                      _selectedTabIndex = tabs.indexWhere(
                        (t) => t.value == value,
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ResponsiveCenter(
                  maxWidth: 1200,
                  child: _buildTabContent(selectedTab),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildModernHeader(BuildContext context) => Container(
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
    child: Stack(
      children: [
        // Back button positioned absolutely
        Positioned(
          left: 0,
          top: 0,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),

        // Main content
        Padding(
          padding: const EdgeInsets.only(left: 48),
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

              // Icon
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
        ),
      ],
    ),
  );

  Widget _buildTabContent(String tabName) {
    switch (tabName) {
      case 'Personal':
        return const PersonalInfoTab();
      case 'Contact':
        return const ContactInfoTab();
      case 'Academic':
        return const AcademicInfoTab();
      case 'Professional':
        return const ProfessionalInfoTab();
      case 'Institution':
        return const InstitutionSettingsTab();
      case 'Security':
        return const SecurityTab();
      case 'Notifications':
        return const NotificationsTab();
      case 'Language':
        return const LanguageTab();
      default:
        return const Center(child: Text('Tab not implemented'));
    }
  }
}
