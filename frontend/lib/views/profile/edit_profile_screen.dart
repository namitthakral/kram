import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../provider/login_signup/login_provider.dart';
import '../../utils/app_bar_config_helper.dart';
import '../../utils/extensions.dart';
import '../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../widgets/custom_widgets/custom_sliding_segmented_control.dart';
import '../../widgets/custom_widgets/responsive_layout.dart';
import 'tabs/academic_info_tab.dart';
import 'tabs/contact_info_tab.dart';
import 'tabs/personal_info_tab.dart';
import 'tabs/professional_info_tab.dart';
import 'tabs/security_tab.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text(context.translate('user_not_found'))),
      );
    }

    // Determine which tabs to show based on role
    final tabs = _getTabsForRole(user.role?.id ?? 0);
    final tabNames = tabs.map((t) => t.label).toList();

    return Scaffold(
      body: CustomMainScreenWithAppbar(
        title: 'Edit Profile',
        appBarConfig: AppBarConfigHelper.getConfigForUser(
          user,
          onNotificationIconPressed: () {},
          isProfileScreen: true,
        ),
        child: ResponsiveLayout(
          mobile: _buildMobileLayout(tabs, tabNames),
          tablet: _buildDesktopLayout(tabs, tabNames),
          desktop: _buildDesktopLayout(tabs, tabNames),
        ),
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

  List<ProfileTab> _getTabsForRole(int roleId) {
    final baseTabs = [
      const ProfileTab(label: 'Personal', icon: Icons.person_outline),
      const ProfileTab(label: 'Contact', icon: Icons.contact_mail_outlined),
    ];

    // Add role-specific tabs
    switch (roleId) {
      case 2: // Student
        return [
          ...baseTabs,
          const ProfileTab(label: 'Academic', icon: Icons.school_outlined),
          const ProfileTab(label: 'Security', icon: Icons.security_outlined),
        ];
      case 4: // Teacher
        return [
          ...baseTabs,
          const ProfileTab(label: 'Professional', icon: Icons.work_outline),
          const ProfileTab(label: 'Security', icon: Icons.security_outlined),
        ];
      case 3: // Librarian
      case 5: // Admin
      case 6: // Staff
      case 7: // Super Admin
        return [
          ...baseTabs,
          const ProfileTab(label: 'Professional', icon: Icons.work_outline),
          const ProfileTab(label: 'Security', icon: Icons.security_outlined),
        ];
      default:
        return [
          ...baseTabs,
          const ProfileTab(label: 'Security', icon: Icons.security_outlined),
        ];
    }
  }

  Widget _buildMobileLayout(List<ProfileTab> tabs, List<String> tabNames) =>
      Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: CustomSlidingSegmentedControl<int>(
              segments: Map.fromIterables(
                List.generate(tabNames.length, (i) => i),
                tabNames,
              ),
              initialValue: _selectedTabIndex,
              onValueChanged: (value) {
                setState(() {
                  _selectedTabIndex = value;
                });
              },
            ),
          ),
          Expanded(child: _buildTabContent(tabs[_selectedTabIndex])),
        ],
      );

  Widget _buildDesktopLayout(List<ProfileTab> tabs, List<String> tabNames) =>
      ResponsivePadding(
        desktop: const EdgeInsets.all(32),
        tablet: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: CustomSlidingSegmentedControl<int>(
                segments: Map.fromIterables(
                  List.generate(tabNames.length, (i) => i),
                  tabNames,
                ),
                initialValue: _selectedTabIndex,
                onValueChanged: (value) {
                  setState(() {
                    _selectedTabIndex = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ResponsiveCenter(
                maxWidth: 1200,
                child: _buildTabContent(tabs[_selectedTabIndex]),
              ),
            ),
          ],
        ),
      );

  Widget _buildTabContent(ProfileTab tab) {
    switch (tab.label) {
      case 'Personal':
        return const PersonalInfoTab();
      case 'Contact':
        return const ContactInfoTab();
      case 'Academic':
        return const AcademicInfoTab();
      case 'Professional':
        return const ProfessionalInfoTab();
      case 'Security':
        return const SecurityTab();
      default:
        return const Center(child: Text('Tab not implemented'));
    }
  }
}

class ProfileTab {
  const ProfileTab({required this.label, required this.icon});
  final String label;
  final IconData icon;
}
