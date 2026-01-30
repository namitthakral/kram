import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/extensions.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/dashboard_widgets.dart';

class AcademicManagementScreen extends StatelessWidget {
  const AcademicManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final teacher = user?.teacher;

    // Use real user data
    final userInitials = UserUtils.getInitials(user?.name ?? 'Teacher');
    final userName = user?.name ?? 'Teacher';
    final designation = teacher?.designation ?? 'Teacher';
    final employeeId = teacher?.employeeId ?? 'N/A';

    return CustomMainScreenWithAppbar(
      title: context.translate('academic_management'),
      appBarConfig: AppBarConfig.teacher(
        userInitials: userInitials,
        userName: userName,
        designation: designation,
        employeeId: employeeId,
        onNotificationIconPressed: () {
          // Notification handler to be implemented
        },
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Section
            GridView.count(
              crossAxisCount: isMobile ? 2 : 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: isMobile ? 12 : 16,
              mainAxisSpacing: isMobile ? 12 : 16,
              childAspectRatio: isMobile ? 1.3 : 1.5,
              children: const [
                DashboardStatCard(
                  title: 'Assignments',
                  value: '12',
                  subtitle: 'Active assignments',
                  backgroundColor: CustomAppColors.warning,
                  iconColor: CustomAppColors.warning,
                  icon: Icons.assignment_turned_in_rounded,
                ),
                DashboardStatCard(
                  title: 'Exams',
                  value: '3',
                  subtitle: 'Upcoming exams',
                  backgroundColor: CustomAppColors.purple,
                  iconColor: CustomAppColors.purple,
                  icon: Icons.quiz_rounded,
                ),
                DashboardStatCard(
                  title: 'Classes Today',
                  value: '5',
                  subtitle: 'Scheduled classes',
                  backgroundColor: CustomAppColors.blue500,
                  iconColor: CustomAppColors.blue500,
                  icon: Icons.schedule_rounded,
                ),
                DashboardStatCard(
                  title: 'Avg Attendance',
                  value: '95%',
                  subtitle: 'This month',
                  backgroundColor: CustomAppColors.success,
                  iconColor: CustomAppColors.success,
                  icon: Icons.check_circle_rounded,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Create New Section Header
            Text(
              'Create & Manage',
              style: TextStyle(
                fontSize: isMobile ? AppTheme.fontSizeXl : AppTheme.fontSize2xl,
                fontWeight: AppTheme.fontWeightBold,
                color: CustomAppColors.slate800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Quick access to common academic tasks',
              style: TextStyle(
                fontSize: AppTheme.fontSizeSm,
                color: CustomAppColors.slate500,
              ),
            ),
            const SizedBox(height: 16),

            // Grid of Action Cards
            GridView.count(
              crossAxisCount: isMobile ? 2 : 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 1.1 : 1.2,
              children: [
                _ActionGridCard(
                  title: 'Mark\nAttendance',
                  icon: Icons.how_to_reg_rounded,
                  color: CustomAppColors.success,
                  onTap: () => context.pushNamed('mark_attendance'),
                ),
                _ActionGridCard(
                  title: 'Enter\nMarks',
                  icon: Icons.grading_rounded,
                  color: CustomAppColors.pink,
                  onTap: () => context.pushNamed('enter_marks'),
                ),
                _ActionGridCard(
                  title: 'Create\nExamination',
                  icon: Icons.quiz_rounded,
                  color: CustomAppColors.purple,
                  onTap: () => context.pushNamed('examinations_list'),
                ),
                _ActionGridCard(
                  title: 'Create\nTimetable',
                  icon: Icons.calendar_month_rounded,
                  color: CustomAppColors.blue500,
                  onTap: () => context.pushNamed('timetables_list'),
                ),
                _ActionGridCard(
                  title: 'Create\nQuestion Paper',
                  icon: Icons.description_rounded,
                  color: CustomAppColors.purple,
                  onTap: () => context.pushNamed('create_question_paper'),
                ),
                _ActionGridCard(
                  title: 'Create\nAssignment',
                  icon: Icons.assignment_rounded,
                  color: CustomAppColors.warning,
                  onTap: () => context.pushNamed('assignments_list'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Recent Activities
            Text(
              'Recent Activities',
              style: TextStyle(
                fontSize: isMobile ? AppTheme.fontSizeXl : AppTheme.fontSize2xl,
                fontWeight: AppTheme.fontWeightBold,
                color: CustomAppColors.slate800,
              ),
            ),
            const SizedBox(height: 16),
            _RecentActivitiesSection(isMobile: isMobile),
          ],
        ),
      ),
    );
  }
}

class _ActionGridCard extends StatelessWidget {
  const _ActionGridCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: CustomAppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CustomAppColors.black01.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 36),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeSm,
              fontWeight: AppTheme.fontWeightSemibold,
              color: CustomAppColors.slate800,
              height: 1.3,
            ),
          ),
        ],
      ),
    ),
  );
}

class _RecentActivitiesSection extends StatelessWidget {
  const _RecentActivitiesSection({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: CustomAppColors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: CustomAppColors.black01.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: const Column(
      children: [
        _ActivityItem(
          icon: Icons.how_to_reg_rounded,
          iconColor: CustomAppColors.success,
          title: 'Attendance marked for Grade 10-A',
          subtitle: '28 students present • 2 hours ago',
          time: '2h ago',
        ),
        Divider(height: 1),
        _ActivityItem(
          icon: Icons.assignment_rounded,
          iconColor: CustomAppColors.warning,
          title: 'Assignment "Chapter 5 Problems" created',
          subtitle: 'Due date: Dec 5, 2025',
          time: '5h ago',
        ),
        Divider(height: 1),
        _ActivityItem(
          icon: Icons.quiz_rounded,
          iconColor: CustomAppColors.purple,
          title: 'Mid-term Examination scheduled',
          subtitle: 'December 10-15, 2025',
          time: '1d ago',
        ),
        Divider(height: 1),
        _ActivityItem(
          icon: Icons.calendar_month_rounded,
          iconColor: CustomAppColors.blue500,
          title: 'Timetable updated for next week',
          subtitle: 'Effective from Dec 2, 2025',
          time: '2d ago',
        ),
      ],
    ),
  );
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: AppTheme.fontWeightSemibold,
                  color: CustomAppColors.slate800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeXs,
                  color: CustomAppColors.slate500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          time,
          style: const TextStyle(
            fontSize: AppTheme.fontSizeXs,
            color: CustomAppColors.slate400,
          ),
        ),
      ],
    ),
  );
}
