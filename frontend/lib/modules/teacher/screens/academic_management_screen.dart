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

import '../providers/assignment_provider.dart';
import '../providers/examination_provider.dart';
import '../providers/teacher_dashboard_provider.dart';

class AcademicManagementScreen extends StatefulWidget {
  const AcademicManagementScreen({super.key});

  @override
  State<AcademicManagementScreen> createState() =>
      _AcademicManagementScreenState();
}

class _AcademicManagementScreenState extends State<AcademicManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final loginProvider = context.read<LoginProvider>();
    final userUuid = loginProvider.currentUser?.uuid;
    if (userUuid != null) {
      // Load all necessary data for the dashboard
      final dashboardProvider = context.read<TeacherDashboardProvider>();
      final assignmentProvider = context.read<AssignmentProvider>();
      final examProvider = context.read<ExaminationProvider>();

      // Load in parallel/sequence
      await Future.wait([
        dashboardProvider.loadDashboardData(userUuid),
        assignmentProvider.loadAssignments(userUuid),
        examProvider.loadExaminations(userUuid),
        // Timetable/Classes could be added here if needed for "Classes Today"
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final loginProvider = context.watch<LoginProvider>();
    final dashboardProvider = context.watch<TeacherDashboardProvider>();
    final assignmentProvider = context.watch<AssignmentProvider>();
    final examProvider = context.watch<ExaminationProvider>();

    final user = loginProvider.currentUser;
    final teacher = user?.teacher;
    final userInitials = UserUtils.getInitials(user?.name ?? 'Teacher');

    // Counts
    final assignmentCount = assignmentProvider.assignments.length.toString();
    final examCount = examProvider.examinations.length.toString();
    final attendanceAvg =
        dashboardProvider.stats != null
            ? '${dashboardProvider.stats!.attendancePercentage.toStringAsFixed(1)}%'
            : '--';

    final isLoading = dashboardProvider.isLoading || assignmentProvider.isLoading;

    return CustomMainScreenWithAppbar(
      title: context.translate('academic_management'),
      isLoading: isLoading,
      appBarConfig: AppBarConfig.teacher(
        userInitials: userInitials,
        userName: user?.name ?? 'Teacher',
        designation: teacher?.designation ?? 'Faculty',
        employeeId: teacher?.employeeId ?? 'N/A',
        onNotificationIconPressed: () {},
      ),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
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
                    children: [
                      DashboardStatCard(
                        title: 'Assignments',
                        value: assignmentCount,
                        subtitle: 'Total assignments',
                        backgroundColor: CustomAppColors.warning,
                        iconColor: CustomAppColors.warning,
                        icon: Icons.assignment_turned_in_rounded,
                        onTap: () => context.pushNamed('assignments_list'),
                      ),
                      DashboardStatCard(
                        title: 'Exams',
                        value: examCount,
                        subtitle: 'Scheduled exams',
                        backgroundColor: CustomAppColors.purple,
                        iconColor: CustomAppColors.purple,
                        icon: Icons.quiz_rounded,
                        onTap: () => context.pushNamed('examinations_list'),
                      ),
                      DashboardStatCard(
                        title: 'Classes Today',
                        value:
                            '5', // Needs TimetableProvider integration for dynamic value
                        subtitle: 'Scheduled classes',
                        backgroundColor: CustomAppColors.blue500,
                        iconColor: CustomAppColors.blue500,
                        icon: Icons.schedule_rounded,
                        onTap: () => context.pushNamed('timetables_list'),
                      ),
                      DashboardStatCard(
                        title: 'Avg Attendance',
                        value: attendanceAvg,
                        subtitle: 'Today',
                        backgroundColor: CustomAppColors.success,
                        iconColor: CustomAppColors.success,
                        icon: Icons.check_circle_rounded,
                        onTap: () => context.pushNamed('attendance_view'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Create New Section Header
                  Text(
                    'Academic Modules',
                    style: TextStyle(
                      fontSize:
                          isMobile
                              ? AppTheme.fontSizeXl
                              : AppTheme.fontSize2xl,
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
                ],
              ),
            ),
          ),

          // Action Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 2 : 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildListDelegate([
                _ActionGridCard(
                  title: 'Attendance',
                  icon: Icons.calendar_today,
                  color: const Color(0xFF4F7CFF),
                  onTap: () => context.pushNamed('attendance_view'),
                ),
                _ActionGridCard(
                  title: 'Marks',
                  icon: Icons.grade,
                  color: const Color(0xFF10B981),
                  onTap: () => context.pushNamed('marks_list'),
                ),
                _ActionGridCard(
                  title: 'Examinations',
                  icon: Icons.assignment,
                  color: const Color(0xFFF59E0B),
                  onTap: () => context.pushNamed('examinations_list'),
                ),
                _ActionGridCard(
                  title: 'Timetables',
                  icon: Icons.schedule,
                  color: const Color(0xFF8B5CF6),
                  onTap: () => context.pushNamed('timetables_list'),
                ),
                _ActionGridCard(
                  title: 'Question Papers',
                  icon: Icons.description,
                  color: const Color(0xFFEC4899),
                  onTap: () => context.pushNamed('question_papers_list'),
                ),
                _ActionGridCard(
                  title: 'Assignments',
                  icon: Icons.assignment_ind,
                  color: const Color(0xFF6366F1),
                  onTap: () => context.pushNamed('assignments_list'),
                ),
              ]),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Recent Activities',
                    style: TextStyle(
                      fontSize:
                          isMobile
                              ? AppTheme.fontSizeXl
                              : AppTheme.fontSize2xl,
                      fontWeight: AppTheme.fontWeightBold,
                      color: CustomAppColors.slate800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (dashboardProvider.activities.isNotEmpty)
                    _RecentActivitiesSection(
                      activities: dashboardProvider.activities,
                    )
                  else if (!dashboardProvider.isLoading)
                    const Center(child: Text('No recent activities')),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
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
  const _RecentActivitiesSection({required this.activities});

  final List<dynamic> activities; // Using dynamic as common interface

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
    child: Column(
      children: [
        for (var i = 0; i < activities.length; i++) ...[
          _ActivityItem(
            icon:
                Icons
                    .notifications_active_rounded, // Generic icon if type not avail
            iconColor: CustomAppColors.blue500,
            title: activities[i].name ?? 'Activity',
            subtitle: activities[i].grade ?? '',
            time: activities[i].lastActive ?? '',
          ),
          if (i < activities.length - 1) const Divider(height: 1),
        ],
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
