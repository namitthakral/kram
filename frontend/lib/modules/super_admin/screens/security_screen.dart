import 'package:flutter/material.dart';

import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock super admin data
    const userInitials = 'SA';
    const userName = 'Super Admin';
    const systemName = 'Kram Master';

    return CustomMainScreenWithAppbar(
      title: 'Security',
      appBarConfig: AppBarConfig.superAdmin(
        userInitials: userInitials,
        userName: userName,
        systemName: systemName,
        onNotificationIconPressed: () {},
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSecurityCard(
            'Audit Logs',
            'View detailed logs of system activities.',
            Icons.list_alt,
            Colors.blue,
          ),
          _buildSecurityCard(
            'Access Control',
            'Manage user roles and permissions.',
            Icons.verified_user,
            Colors.green,
          ),
          _buildSecurityCard(
            'Data Backup',
            'Configure automatic backups and disaster recovery.',
            Icons.backup,
            Colors.orange,
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Alerts',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          _buildAlertItem(
            'Failed login attempt from IP 192.168.1.10',
            'Just now',
            Colors.red,
          ),
          _buildAlertItem(
            'New admin role assigned to User #456',
            '2 hours ago',
            Colors.blue,
          ),
          _buildAlertItem(
            'System backup completed successfully',
            'Yesterday',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
    ),
  );

  Widget _buildAlertItem(String title, String time, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(left: BorderSide(color: color, width: 4)),
      boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4)],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title)),
        Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      ],
    ),
  );
}
