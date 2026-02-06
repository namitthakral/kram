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
import '../providers/student_provider.dart';

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
        onNotificationIconPressed: () {},
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Academic Modules',
              style: TextStyle(
                fontSize: isMobile ? AppTheme.fontSizeXl : AppTheme.fontSize2xl,
                fontWeight: AppTheme.fontWeightBold,
                color: CustomAppColors.slate800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Access all your academic tools and reports',
              style: TextStyle(
                fontSize: AppTheme.fontSizeSm,
                color: CustomAppColors.slate500,
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
                  title: 'My Grades',
                  value: gpa.toString(),
                  subtitle: 'Current GPA',
                  icon: Icons.assignment_turned_in,
                  backgroundColor: const Color(0xFF10B981),
                  iconColor: const Color(0xFF10B981),
                  onTap: () => context.pushNamed('student_grades'),
                ),
                DashboardStatCard(
                  title: 'Timetable',
                  value:
                      'View', // Placeholder as we don't have "classes today" count easily yet
                  subtitle: 'Weekly Schedule',
                  icon: Icons.calendar_today,
                  backgroundColor: const Color(0xFF4F7CFF),
                  iconColor: const Color(0xFF4F7CFF),
                  onTap: () => context.pushNamed('student_timetable'),
                ),
                DashboardStatCard(
                  title: 'Assignments',
                  value: '$pendingAssignments',
                  subtitle: 'Pending Submission',
                  icon: Icons.assignment,
                  backgroundColor: const Color(0xFF6366F1),
                  iconColor: const Color(0xFF6366F1),
                  onTap: () => context.pushNamed('student_assignments'),
                ),
                DashboardStatCard(
                  title: 'Exams',
                  value: 'Check',
                  subtitle: 'Examination Schedule',
                  icon: Icons.quiz,
                  backgroundColor: const Color(0xFFF59E0B),
                  iconColor: const Color(0xFFF59E0B),
                  onTap: () => context.pushNamed('student_exams'),
                ),
                DashboardStatCard(
                  title: 'Events',
                  value: '$upcomingEvents',
                  subtitle: 'Upcoming Events',
                  icon: Icons.event,
                  backgroundColor: const Color(0xFFEC4899),
                  iconColor: const Color(0xFFEC4899),
                  onTap: () => context.pushNamed('student_events'),
                ),
                DashboardStatCard(
                  title: 'Attendance',
                  value: 'View',
                  subtitle: 'Monthly Trends',
                  icon: Icons.check_circle,
                  backgroundColor: Colors.teal,
                  iconColor: Colors.teal,
                  onTap: () => context.pushNamed('student_attendance'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
