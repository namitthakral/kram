import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/dashboard_widgets.dart';
import '../providers/student_provider.dart';

/// Defers navigation to the next frame to avoid UI freeze when tapping.
void _navigateAfterFrame(BuildContext context, void Function() navigate) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) {
      navigate();
    }
  });
}

class StudentAcademicScreen extends StatelessWidget {
  const StudentAcademicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final loginProvider = context.watch<LoginProvider>();
    final studentProvider = context.watch<StudentProvider>();

    final user = loginProvider.currentUser;
    final student = user?.student;

    final userInitials = UserUtils.getInitials(user?.name ?? 'Student');
    final userName = user?.name ?? 'Student';

    // Dynamic Data from StudentProvider
    final className = studentProvider.studentClassName;
    final section = studentProvider.studentSection;
    final grade = className.isNotEmpty ? '$className $section' : 'Class N/A';
    final rollNumber = student?.rollNumber ?? 'N/A';

    final stats = studentProvider.dashboardStats;
    final pendingAssignments = stats?['pendingAssignments'] ?? 0;
    final upcomingEvents = stats?['upcomingEvents'] ?? 0;
    final gpa = stats?['gpa'] ?? 'N/A';
    // final attendance = stats?['attendance'] ?? 0.0;

    return CustomMainScreenWithAppbar(
      title: context.translate('academic_management'),
      appBarConfig: AppBarConfig.student(
        userInitials: userInitials,
        userName: userName,
        grade: grade,
        rollNumber: rollNumber,
        gpa: gpa.toString(),
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
                color: AppTheme.slate800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.translate('access_academic_tools_reports'),
              style: const TextStyle(
                fontSize: AppTheme.fontSizeSm,
                color: AppTheme.slate500,
              ),
            ),
            const SizedBox(height: 24),

            // Grid of options using DashboardStatCard for consistency
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isMobile ? 2 : 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio:
                  isMobile ? 1.3 : 1.5, // Adjusted aspect ratio for stat cards
              children: [
                DashboardStatCard(
                  title: context.translate('my_grades'),
                  value: gpa.toString(),
                  subtitle: context.translate('current_gpa'),
                  icon: Icons.assignment_turned_in,
                  backgroundColor: const Color(0xFF10B981),
                  iconColor: const Color(0xFF10B981),
                  onTap:
                      () => _navigateAfterFrame(
                        context,
                         () => context.push('/grades'),
                      ),
                ),
                DashboardStatCard(
                  title: context.translate('timetable'),
                  value: context.translate('view'),
                  subtitle: context.translate('weekly_schedule'),
                  icon: Icons.calendar_today,
                  backgroundColor: const Color(0xFF4F7CFF),
                  iconColor: const Color(0xFF4F7CFF),
                  onTap:
                      () => _navigateAfterFrame(
                        context,
                         () => context.push('/timetable'),
                      ),
                ),
                DashboardStatCard(
                  title: context.translate('assignments'),
                  value: '$pendingAssignments',
                  subtitle: context.translate('pending_submission'),
                  icon: Icons.assignment,
                  backgroundColor: const Color(0xFF6366F1),
                  iconColor: const Color(0xFF6366F1),
                  onTap:
                      () => _navigateAfterFrame(
                        context,
                         () => context.push('/assignments'),
                      ),
                ),
                DashboardStatCard(
                  title: context.translate('examinations'),
                  value: context.translate('check'),
                  subtitle: context.translate('examination_schedule'),
                  icon: Icons.quiz,
                  backgroundColor: const Color(0xFFF59E0B),
                  iconColor: const Color(0xFFF59E0B),
                  onTap:
                      () => _navigateAfterFrame(
                        context,
                         () => context.push('/exams'),
                      ),
                ),
                DashboardStatCard(
                  title: context.translate('events'),
                  value: '$upcomingEvents',
                  subtitle: context.translate('upcoming_events'),
                  icon: Icons.event,
                  backgroundColor: const Color(0xFFEC4899),
                  iconColor: const Color(0xFFEC4899),
                  onTap:
                      () => _navigateAfterFrame(
                        context,
                         () => context.push('/events'),
                      ),
                ),
                DashboardStatCard(
                  title: context.translate('attendance'),
                  value: context.translate('view'),
                  subtitle: context.translate('monthly_trends'),
                  icon: Icons.check_circle_rounded,
                  backgroundColor: AppTheme.info,
                  iconColor: AppTheme.info,
                  onTap:
                      () => _navigateAfterFrame(
                        context,
                         () => context.push('/attendance'),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
