import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class MarksListScreen extends StatelessWidget {
  const MarksListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;

    return CustomMainScreenWithAppbar(
      title: 'Marks & Results',
      appBarConfig: AppBarConfig.teacher(
        userInitials: user?.name?.substring(0, 1) ?? 'T',
        userName: user?.name ?? 'Teacher',
        designation: user?.teacher?.designation ?? 'Teacher',
        employeeId: user?.teacher?.employeeId ?? 'EMP',
        onNotificationIconPressed: () {},
      ),
      bottomWidget: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              context.pushNamed('enter_marks');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomAppColors.pink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.grading_rounded, color: Colors.white),
            label: const Text(
              'Enter Marks',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: AppTheme.fontWeightBold,
              ),
            ),
          ),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Submissions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CustomAppColors.slate800,
              ),
            ),
            const SizedBox(height: 16),
            _buildMarksItem(
              'Mid-Term Mathematics',
              'Class 10-A',
              'Submitted yesterday',
            ),
            const SizedBox(height: 12),
            _buildMarksItem(
              'Unit Test 1 - Physics',
              'Class 9-B',
              'Submitted 2 days ago',
            ),
            const SizedBox(height: 12),
            _buildMarksItem(
              'Final Exam - English',
              'Class 10-A',
              'Pending submission',
              isPending: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarksItem(
    String title,
    String subtitle,
    String time, {
    bool isPending = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isPending
                      ? Colors.orange.withOpacity(0.1)
                      : CustomAppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPending
                  ? Icons.pending_actions_rounded
                  : Icons.check_circle_rounded,
              color: isPending ? Colors.orange : CustomAppColors.success,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CustomAppColors.slate800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CustomAppColors.slate500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: CustomAppColors.slate400,
            ),
          ),
        ],
      ),
    );
  }
}
