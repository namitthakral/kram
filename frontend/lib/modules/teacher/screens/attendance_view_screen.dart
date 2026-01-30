import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class AttendanceViewScreen extends StatelessWidget {
  const AttendanceViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;

    return CustomMainScreenWithAppbar(
      title: 'Attendance',
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
              context.pushNamed('mark_attendance');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomAppColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.how_to_reg_rounded, color: Colors.white),
            label: const Text(
              'Mark Attendance',
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
              'Today\'s Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CustomAppColors.slate800,
              ),
            ),
            const SizedBox(height: 16),
            _buildAttendanceCard('Class 10-A', '28/30 Present', true),
            const SizedBox(height: 12),
            _buildAttendanceCard('Class 9-B', 'Not marked yet', false),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(String className, String status, bool isMarked) {
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
                  isMarked
                      ? CustomAppColors.success.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isMarked ? Icons.check_circle_outline : Icons.pending_outlined,
              color: isMarked ? CustomAppColors.success : Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                className,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CustomAppColors.slate800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(
                  fontSize: 14,
                  color: isMarked ? CustomAppColors.success : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
