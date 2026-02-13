import 'package:flutter/material.dart';

import '../../../../utils/custom_colors.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class SystemSettingsScreen extends StatelessWidget {
  const SystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock super admin data
    const userInitials = 'SA';
    const userName = 'Super Admin';
    const systemName = 'Kram Master';

    return CustomMainScreenWithAppbar(
      title: 'System Settings',
      appBarConfig: AppBarConfig.superAdmin(
        userInitials: userInitials,
        userName: userName,
        systemName: systemName,
        onNotificationIconPressed: () {},
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('General'),
          _buildsettingItem(Icons.language, 'Language', 'English'),
          _buildsettingItem(Icons.color_lens, 'Theme', 'Light'),
          const Divider(),
          _buildSectionHeader('Notifications'),
          _buildSwitchItem('Email Notifications', true),
          _buildSwitchItem('Push Notifications', true),
          const Divider(),
          _buildSectionHeader('Maintenance'),
          _buildsettingItem(Icons.storage, 'Clear Cache', ''),
          _buildsettingItem(Icons.update, 'Check for Updates', 'v2.0.1'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: CustomAppColors.primary,
      ),
    ),
  );

  Widget _buildsettingItem(IconData icon, String title, String subtitle) =>
      ListTile(
        leading: Icon(icon, color: Colors.grey[600]),
        title: Text(title),
        subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      );

  Widget _buildSwitchItem(String title, bool value) => SwitchListTile(
    value: value,
    onChanged: (val) {},
    title: Text(title),
    activeThumbColor: CustomAppColors.primary,
  );
}
