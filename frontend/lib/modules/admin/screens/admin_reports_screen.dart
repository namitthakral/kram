import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../provider/login_signup/login_provider.dart';
import '../../../../utils/extensions.dart';
import '../../../../utils/user_utils.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final userInitials = UserUtils.getInitials(user?.name ?? 'AD');
    final userName = user?.name ?? 'Admin';
    final institutionName = context.translate('kram_institution');

    return CustomMainScreenWithAppbar(
      title: context.translate('admin_reports'),
      appBarConfig: AppBarConfig.admin(
        userInitials: userInitials,
        userName: userName,
        institutionName: institutionName,
        onNotificationIconPressed: () {},
      ),
      child: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildReportTile(Icons.people, 'Student Enrollment', Colors.blue),
          _buildReportTile(Icons.work, 'Staff Attendance', Colors.orange),
          _buildReportTile(
            Icons.monetization_on,
            'Financial Audit',
            Colors.green,
          ),
          _buildReportTile(
            Icons.directions_bus,
            'Transport Usage',
            Colors.purple,
          ),
          _buildReportTile(Icons.library_books, 'Library Stats', Colors.red),
          _buildReportTile(Icons.settings, 'System Logs', Colors.grey),
        ],
      ),
    );
  }

  Widget _buildReportTile(IconData icon, String title, Color color) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 2,
    child: InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    ),
  );
}
