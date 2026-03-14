import 'package:flutter/material.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class TeacherReportsScreen extends StatelessWidget {
  const TeacherReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock teacher data
    const userInitials = 'JD';
    const userName = 'John Doe';
    const designation = 'Senior Teacher';
    const employeeId = 'EMP-001';

    return CustomMainScreenWithAppbar(
      title: 'Reports',
      appBarConfig: AppBarConfig.teacher(
        userInitials: userInitials,
        userName: userName,
        designation: designation,
        employeeId: employeeId,
        onNotificationIconPressed: () {},
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReportCard(
            context,
            'Class Performance',
            'Overall academic performance analysis for Class 10-A.',
            Icons.bar_chart,
            Colors.blue,
          ),
          _buildReportCard(
            context,
            'Attendance Report',
            'Monthly attendance summary and defaulters list.',
            Icons.calendar_today,
            Colors.orange,
          ),
          _buildReportCard(
            context,
            'Subject Analysis',
            'Subject-wise grade distribution and improvement areas.',
            Icons.pie_chart,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    child: InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    ),
  );
}
