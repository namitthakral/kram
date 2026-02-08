import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../utils/custom_colors.dart';
import '../../../../utils/extensions.dart';
import '../../../../utils/responsive_utils.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../../widgets/custom_widgets/dashboard_widgets.dart';
import '../providers/parent_dashboard_provider.dart';

class ChildProgressScreen extends StatelessWidget {
  const ChildProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final dashboardProvider = context.watch<ParentDashboardProvider>();
    final childInfo = dashboardProvider.childInfo;

    // Use child info if available, otherwise use default values
    final childInitials = childInfo?.initials ?? 'N/A';
    final childName = childInfo?.name ?? 'Student';
    final grade = childInfo?.grade ?? 'Grade N/A';
    final rollNumber = childInfo?.rollNumber ?? 'N/A';

    return CustomMainScreenWithAppbar(
      title: context.translate('child_progress'),
      appBarConfig: AppBarConfig.parent(
        childInitials: childInitials,
        childName: childName,
        grade: grade,
        rollNumber: rollNumber,
        onNotificationIconPressed: () {},
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.translate('academic_modules'),
              style: TextStyle(
                fontSize: isMobile ? AppTheme.fontSizeXl : AppTheme.fontSize2xl,
                fontWeight: AppTheme.fontWeightBold,
                color: CustomAppColors.slate800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.translate('access_academic_tools_reports'),
              style: const TextStyle(
                fontSize: AppTheme.fontSizeSm,
                color: CustomAppColors.slate500,
              ),
            ),
            const SizedBox(height: 24),

            // Grid of options
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isMobile ? 2 : 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 1.3 : 1.5,
              children: [
                DashboardStatCard(
                  title: context.translate('attendance'),
                  value: '${childInfo?.attendance ?? 0}%',
                  subtitle: context.translate('monthly_trends'),
                  icon: Icons.check_circle,
                  backgroundColor: Colors.teal,
                  iconColor: Colors.teal,
                  onTap: () => context.pushNamed('student_attendance'),
                ),
                DashboardStatCard(
                  title: context.translate('grades'),
                  value: childInfo?.overallGrade ?? 'N/A',
                  subtitle: context.translate('current_gpa'),
                  icon: Icons.assignment_turned_in,
                  backgroundColor: const Color(0xFF10B981),
                  iconColor: const Color(0xFF10B981),
                  onTap: () => context.pushNamed('student_grades'),
                ),
                DashboardStatCard(
                  title: context.translate('events'),
                  value: context.translate('view'),
                  subtitle: context.translate('upcoming_events'),
                  icon: Icons.event,
                  backgroundColor: const Color(0xFFEC4899),
                  iconColor: const Color(0xFFEC4899),
                  onTap: () => context.pushNamed('student_events'),
                ),
                DashboardStatCard(
                  title: context.translate('fees'),
                  value: context.translate('pay'),
                  subtitle: context.translate('fee_payment'),
                  icon: Icons.account_balance_wallet,
                  backgroundColor: const Color(0xFF6366F1),
                  iconColor: const Color(0xFF6366F1),
                  onTap: () => context.pushNamed('parent_fee_payment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
