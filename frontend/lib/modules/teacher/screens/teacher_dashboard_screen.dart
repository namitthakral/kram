import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/router_service.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_sliding_segmented_control.dart';
import '../../../widgets/custom_widgets/dashboard_widgets.dart';
import '../models/dashboard_stats.dart';
import '../providers/performance_tab_provider.dart';
import '../providers/teacher_dashboard_provider.dart';
import '../widgets/chart_widgets.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/student_activity_card.dart';
import 'assignments_list_screen.dart';
import 'examinations_list_screen.dart';

enum PerformanceTab { attendance, subject, grade }

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Defer loading until after the build phase completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    final loginProvider = context.read<LoginProvider>();
    final user = loginProvider.currentUser;

    if (user?.uuid != null && user?.teacher != null && mounted) {
      final provider = context.read<TeacherDashboardProvider>();
      await Future.wait([
        provider.fetchDashboardStats(user!.uuid!),
        provider.fetchAllChartData(user.uuid!),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final teacher = user?.teacher;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.router.goToLogin();
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Use real user data
    final userInitials = UserUtils.getInitials(user.name);
    final userName = user.name;
    final designation = teacher?.designation ?? 'Teacher';
    final employeeId = teacher?.employeeId ?? 'N/A';

    return CustomMainScreenWithAppbar(
      title: context.translate('teacher_dashboard'),
      appBarConfig: AppBarConfig.teacher(
        userInitials: userInitials,
        userName: userName,
        designation: designation,
        employeeId: employeeId,
      ),
      child: SingleChildScrollView(
        child: Consumer<TeacherDashboardProvider>(
          builder: (context, dashboardProvider, child) {
            final stats = dashboardProvider.dashboardStats;
            final hasAttendanceAccess = stats?.hasAttendanceAccess ?? true;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (hide on mobile to save space)
                // if (!isMobile) ...[_buildHeader(), const SizedBox(height: 24)],

                // Statistics Cards - only show if teacher has access
                if (hasAttendanceAccess) ...[
                  _buildStatsSection(isMobile),
                  const SizedBox(height: 24),
                ],

                // Main Content - Responsive Layout
                if (isMobile) _buildMobileLayout() else _buildDesktopLayout(),

                const SizedBox(height: 24),

                // Charts Section with Tabs
                _buildChartsSection(isMobile),
              ],
            );
          },
        ),
      ),
    );
  }

  // Mobile Layout: Stack vertically
  Widget _buildMobileLayout() => Column(
    children: [
      _buildRecentActivitySection(isMobile: true),
      const SizedBox(height: 16),
      _buildQuickActionsSection(isMobile: true),
    ],
  );

  // Desktop Layout: Side by side
  Widget _buildDesktopLayout() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Left Column - Recent Activity
      Expanded(flex: 2, child: _buildRecentActivitySection()),
      const SizedBox(width: 24),

      // Right Column - Quick Actions
      Expanded(child: _buildQuickActionsSection()),
    ],
  );

  Widget _buildStatsSection(
    bool isMobile,
  ) => Consumer<TeacherDashboardProvider>(
    builder: (context, dashboardProvider, child) {
      // Use stats from provider or default values
      final stats = dashboardProvider.dashboardStats;
      final totalStudents = stats?.totalStudents ?? 0;
      final presentToday = stats?.presentToday ?? 0;
      final absentToday = stats?.absentToday ?? 0;
      final attendancePercentageToday = stats?.attendancePercentageToday ?? 0.0;
      final avgAttendance = stats?.avgAttendance ?? 0.0;

      // Show loading overlay if loading
      return Stack(
        children: [
          GridView.count(
            crossAxisCount: isMobile ? 2 : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: isMobile ? 12 : 16,
            mainAxisSpacing: isMobile ? 12 : 16,
            childAspectRatio: isMobile ? 1.3 : 1.5,
            children: [
              DashboardStatCard(
                title: context.translate('total_students'),
                value: '$totalStudents',
                subtitle: context.translate('active_in_classes'),
                backgroundColor: const Color(0xFF155dfc),
                iconColor: const Color(0xFF155dfc),
                icon: Icons.groups,
              ),
              DashboardStatCard(
                title: context.translate('present_today'),
                value: '$presentToday',
                subtitle: context.translate(
                  'attendance_percentage',
                  params: {
                    'percentage': attendancePercentageToday.toStringAsFixed(1),
                  },
                ),
                backgroundColor: const Color(0xFF00a63e),
                iconColor: const Color(0xFF00a63e),
                icon: Icons.check_circle,
              ),
              DashboardStatCard(
                title: context.translate('absent_today'),
                value: '$absentToday',
                subtitle: context.translate('requires_follow_up'),
                backgroundColor: const Color(0xFFe7000b),
                iconColor: const Color(0xFFe7000b),
                icon: Icons.cancel,
              ),
              DashboardStatCard(
                title: context.translate('avg_attendance'),
                value: '${avgAttendance.toStringAsFixed(1)}%',
                subtitle: context.translate('this_month'),
                backgroundColor: const Color(0xFFfe9a00),
                iconColor: const Color(0xFFfe9a00),
                icon: Icons.trending_up,
              ),
            ],
          ),

          // Show loading indicator overlay if loading
          if (dashboardProvider.isLoading)
            ColoredBox(
              color: Colors.white.withValues(alpha: 0.8),
              child: const Center(child: CircularProgressIndicator()),
            ),

          // Show error message if there's an error
          if (dashboardProvider.error != null && !dashboardProvider.isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.translate('failed_to_load_stats'),
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadDashboardData,
                      child: Text(context.translate('retry')),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );

  Widget _buildRecentActivitySection({bool isMobile = false}) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.translate('recent_student_activity'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1e293b),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.translate('students_with_recent_updates'),
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748b)),
        ),
        const SizedBox(height: 20),
        ..._getMockStudents().map(
          (student) => StudentActivityCard(student: student, onTap: () {}),
        ),
      ],
    ),
  );

  Widget _buildQuickActionsSection({bool isMobile = false}) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.translate('quick_actions'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1e293b),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.translate('common_tasks_shortcuts'),
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748b)),
        ),
        const SizedBox(height: 20),
        QuickActionButton(
          title: context.translate('manage_assignments'),
          icon: Icons.assignment,
          backgroundColor: const Color(0xFF4F7CFF),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AssignmentsListScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        QuickActionButton(
          title: context.translate('manage_examinations'),
          icon: Icons.quiz,
          backgroundColor: const Color(0xFF8b5cf6),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExaminationsListScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        QuickActionButton(
          title: context.translate('mark_attendance'),
          icon: Icons.calendar_today,
          backgroundColor: const Color(0xFF10b981),
          onTap: () {
            context.pushNamed('attendance_view');
          },
        ),
        const SizedBox(height: 12),
        QuickActionButton(
          title: context.translate('enter_marks'),
          icon: Icons.grade,
          backgroundColor: const Color(0xFFf59e0b),
          onTap: () {
            context.push('/academic/marks');
          },
        ),
        const SizedBox(height: 12),
        QuickActionButton(
          title: context.translate('generate_report_cards'),
          icon: Icons.description,
          backgroundColor: const Color(0xFFef4444),
          onTap: () {
            context.push('/academic/report-cards');
          },
        ),
      ],
    ),
  );

  Widget _buildChartsSection(bool isMobile) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cupertino Sliding Segmented Control with Provider
        SizedBox(
          width: double.infinity,
          child: Consumer<PerformanceTabProvider>(
            builder:
                (context, provider, child) =>
                    CustomSlidingSegmentedControl<PerformanceTab>(
                      segments: {
                        PerformanceTab.attendance: context.translate(
                          'attendance_trends',
                        ),
                        PerformanceTab.subject: context.translate(
                          'subject_performance',
                        ),
                        PerformanceTab.grade: context.translate(
                          'grade_distribution',
                        ),
                      },
                      initialValue: provider.selectedValue,
                      onValueChanged: (value) {
                        provider.updateSelectedValue(value);
                        debugPrint('Selected: $value');
                      },
                    ),
          ),
        ),

        const SizedBox(height: 24),

        // Content based on selected segment from Provider
        Consumer<PerformanceTabProvider>(
          builder:
              (context, provider, child) => SizedBox(
                height: 400,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                  child: KeyedSubtree(
                    key: ValueKey<PerformanceTab>(provider.selectedValue),
                    child: SingleChildScrollView(
                      child: switch (provider.selectedValue) {
                        PerformanceTab.attendance =>
                          _buildAttendanceTrendsTab(),
                        PerformanceTab.subject => _buildSubjectPerformanceTab(),
                        PerformanceTab.grade => _buildGradeDistributionTab(),
                      },
                    ),
                  ),
                ),
              ),
        ),
      ],
    ),
  );

  Widget _buildAttendanceTrendsTab() => Consumer<TeacherDashboardProvider>(
    builder:
        (context, dashboardProvider, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.translate('weekly_attendance_overview'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1e293b),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.translate('daily_attendance_this_week'),
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748b)),
            ),
            const SizedBox(height: 20),
            AttendanceTrendsChart(
              trendsData: dashboardProvider.attendanceTrends,
            ),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10b981),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  context.translate('present'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1e293b),
                  ),
                ),
                const SizedBox(width: 24),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFef4444),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  context.translate('absent'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1e293b),
                  ),
                ),
              ],
            ),
          ],
        ),
  );

  Widget _buildSubjectPerformanceTab() => Consumer<TeacherDashboardProvider>(
    builder:
        (context, dashboardProvider, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.translate('subject_performance_overview'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1e293b),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.translate('average_scores_across_subjects'),
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748b)),
            ),
            const SizedBox(height: 20),
            SubjectPerformanceChart(
              performanceData: dashboardProvider.subjectPerformance,
            ),
          ],
        ),
  );

  Widget _buildGradeDistributionTab() => Consumer<TeacherDashboardProvider>(
    builder:
        (context, dashboardProvider, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.translate('grade_distribution'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1e293b),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.translate('current_grade_distribution'),
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748b)),
            ),
            const SizedBox(height: 20),
            GradeDistributionChart(
              distributionData: dashboardProvider.gradeDistribution,
            ),
          ],
        ),
  );

  List<StudentActivity> _getMockStudents() => const [
    StudentActivity(
      name: 'Emma Johnson',
      initials: 'EJ',
      lastActive: '2 hours ago',
      grade: 'A',
      percentage: 95,
    ),
    StudentActivity(
      name: 'Michael Chen',
      initials: 'MC',
      lastActive: '1 hour ago',
      grade: 'B+',
      percentage: 88,
    ),
    StudentActivity(
      name: 'Sarah Williams',
      initials: 'SW',
      lastActive: '30 mins ago',
      grade: 'A-',
      percentage: 97,
    ),
    StudentActivity(
      name: 'Lisa Davis',
      initials: 'LD',
      lastActive: '1 hour ago',
      grade: 'A+',
      percentage: 99,
    ),
  ];
}
