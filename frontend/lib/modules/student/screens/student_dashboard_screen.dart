import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/router_service.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_tab_bar.dart';
import '../../../widgets/custom_widgets/dashboard_widgets.dart';
import '../providers/dashboard_tab_provider.dart';
import '../providers/student_dashboard_provider.dart';
import '../providers/student_provider.dart';
import '../widgets/assignment_card.dart';
import '../widgets/event_card.dart';
import '../widgets/student_chart_widgets.dart';
import '../widgets/subject_performance_card.dart';
import '../../fees/providers/fees_provider.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  void _loadDashboardData() {
    final loginProvider = context.read<LoginProvider>();
    final user = loginProvider.currentUser;

    debugPrint('🔄 _loadDashboardData called');
    debugPrint('👤 Current user: ${user?.name}, UUID: ${user?.uuid}');

    if (user?.uuid != null) {
      debugPrint('✅ Loading dashboard data for UUID: ${user!.uuid}');
      context.read<StudentDashboardProvider>().loadAllDashboardData(user.uuid!);


      // Load student data first, then fees
      context.read<StudentProvider>().loadStudentData(user.uuid!).then((_) {
        if (mounted) {
          final profile = context.read<StudentProvider>().studentProfile;
          // Use user.student if available, otherwise profile
          final studentId = user.student?.id ?? profile?['id'];
          if (studentId != null) {
            context.read<FeesProvider>().loadStudentFeeSummary(studentId);
          }
        }
      });
    } else {
      debugPrint('❌ Cannot load dashboard data - user UUID is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final loginProvider = context.watch<LoginProvider>();
    final dashboardProvider = context.watch<StudentDashboardProvider>();
    final user = loginProvider.currentUser;
    final student = user?.student;

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

    // Get dynamic grade/class info
    final studentProvider = context.watch<StudentProvider>();
    final className = studentProvider.studentClassName;
    final section = studentProvider.studentSection;
    final grade =
        (className.isNotEmpty || section.isNotEmpty)
            ? '$className $section'.trim()
            : 'Class N/A';

    final rollNumber = student?.rollNumber ?? 'N/A';

    // Get GPA from dashboard stats
    final statsData = dashboardProvider.dashboardStats;
    final dataObject = statsData?['data'] ?? statsData;
    final gpa = dataObject?['currentGpa'] ?? dataObject?['gpa'];
    final gpaString = gpa?.toString();

    return CustomMainScreenWithAppbar(
      title: context.translate('student_dashboard'),
      appBarConfig: AppBarConfig.student(
        userInitials: userInitials,
        userName: userName,
        grade: grade,
        rollNumber: rollNumber,
        gpa: gpaString,
      ),
      child:
          dashboardProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: () async {
                  if (user.uuid != null) {
                    await dashboardProvider.refresh(user.uuid!);
                    // Refresh fees if student data is loaded
                    if (context.mounted) {
                      final profile = context.read<StudentProvider>().studentProfile;
                      final studentId = user.student?.id ?? profile?['id'];
                      if (studentId != null) {
                        context.read<FeesProvider>().loadStudentFeeSummary(studentId);
                      }
                    }
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Statistics Cards
                      _buildStatsSection(isMobile, dashboardProvider),
                      const SizedBox(height: 24),

                      // Main Content - Responsive Layout
                      if (isMobile)
                        _buildMobileLayout(dashboardProvider)
                      else
                        _buildDesktopLayout(dashboardProvider),

                      const SizedBox(height: 24),

                      // Charts Section with Tabs
                      _buildChartsSection(isMobile, dashboardProvider),
                    ],
                  ),
                ),
              ),
    );
  }

  // Mobile Layout: Stack vertically
  Widget _buildMobileLayout(StudentDashboardProvider dashboardProvider) =>
      Column(
        children: [
          _buildSubjectPerformanceSection(
            dashboardProvider: dashboardProvider,
            isMobile: true,
          ),
          const SizedBox(height: 16),
          _buildUpcomingEventsSection(
            dashboardProvider: dashboardProvider,
            isMobile: true,
          ),
        ],
      );

  // Desktop Layout: Side by side
  Widget _buildDesktopLayout(StudentDashboardProvider dashboardProvider) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Left Column - Subject Performance
      Expanded(
        child: _buildSubjectPerformanceSection(
          dashboardProvider: dashboardProvider,
        ),
      ),
      const SizedBox(width: 24),

      // Right Column - Upcoming Events
      Expanded(
        child: _buildUpcomingEventsSection(
          dashboardProvider: dashboardProvider,
        ),
      ),
    ],
  );

  Widget _buildStatsSection(
    bool isMobile,
    StudentDashboardProvider dashboardProvider,
  ) {
    // Loading handled at page level, so we don't need individual loaders here
    // However, if we want to support partial loading later, we can check specific flags
    // if (dashboardProvider.isLoadingStats) { ... }

    if (dashboardProvider.statsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(context.translate('error_loading_stats')),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  final user = context.read<LoginProvider>().currentUser;
                  if (user?.uuid != null) {
                    dashboardProvider.loadDashboardStats(user!.uuid!);
                  }
                },
                child: Text(context.translate('retry')),
              ),
            ],
          ),
        ),
      );
    }

    // Get stats safely from API
    // Backend returns: { success: true, data: { currentGpa, attendance, classRank, ... } }
    final stats = dashboardProvider.dashboardStats;
    final data = stats?['data'] ?? stats;

    final gpa = data?['currentGpa'] ?? data?['gpa'] ?? 0.0;
    final attendance =
        data?['attendance'] ?? data?['attendancePercentage'] ?? 0.0;
    final classRank = data?['classRank'] ?? 'N/A';
    final assignmentsDue = data?['assignmentsDue'] ?? 0;

    // Get fees data
    final feesProvider = context.watch<FeesProvider>();
    final feeSummary = feesProvider.studentFeeSummary;
    final totalDue = feeSummary?.pendingAmount ?? 0.0;

    // Debug: Print individual stat values
    debugPrint('Stats Data Object: $data');
    debugPrint(
      'Stats - GPA: $gpa, Attendance: $attendance, Rank: $classRank, Assignments: $assignmentsDue',
    );

    // Get screen dimensions for better control
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscapeMode = context.isLandscape;
    final isMobileScreen = screenWidth < 600;
    final isTabletScreen = screenWidth >= 600 && screenWidth < 900;
    final isDesktopScreen = screenWidth >= 900;

    // Desktop: 4 columns (1 row), Mobile & Tablet: 2 columns (2x2 grid)
    final crossAxisCount = isDesktopScreen ? 4 : 2;

    // Adjust spacing based on device and orientation
    final crossAxisSpacing =
        isDesktopScreen ? 16.0 : (isMobileScreen ? 10.0 : 12.0);
    final mainAxisSpacing =
        isDesktopScreen ? 16.0 : (isMobileScreen ? 10.0 : 12.0);

    // Increase aspect ratio (makes cards shorter/smaller) for landscape and tablet
    // Higher ratio = shorter cards
    final childAspectRatio =
        isDesktopScreen
            ? 1.5
            : (isMobileScreen && isLandscapeMode)
            ? 1.7 // Mobile landscape: taller ratio for smaller cards
            : isTabletScreen && isLandscapeMode
            ? 1.8 // Tablet landscape: 2x2 grid with smaller cards
            : isTabletScreen
            ? 1.6 // Tablet portrait: smaller cards
            : 1.3; // Mobile portrait: default

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      childAspectRatio: childAspectRatio,
      children: [
        DashboardStatCard(
          title: context.translate('current_gpa'),
          value: gpa.toString(),
          subtitle: context.translate('out_of_4'),
          backgroundColor: const Color(0xFF7f22fe),
          iconColor: const Color(0xFF7f22fe),
          icon: Icons.school,
        ),
        DashboardStatCard(
          title: context.translate('attendance'),
          value: '${attendance.toStringAsFixed(1)}%',
          subtitle: context.translate('this_semester'),
          backgroundColor: const Color(0xFF4f39f6),
          iconColor: const Color(0xFF4f39f6),
          icon: Icons.calendar_today,
        ),
        DashboardStatCard(
          title: context.translate('class_rank'),
          value: classRank.toString(),
          subtitle: context.translate('current_ranking'),
          backgroundColor: const Color(0xFFe7000b),
          iconColor: const Color(0xFFe7000b),
          icon: Icons.trending_up,
        ),
        DashboardStatCard(
          title: context.translate('fees_due'),
          value: '\$${totalDue.toStringAsFixed(0)}',
          subtitle: totalDue > 0 ? 'Pay Now' : 'All Clear',
          backgroundColor:
              totalDue > 0 ? const Color(0xFFef4444) : const Color(0xFF10b981),
          iconColor:
              totalDue > 0 ? const Color(0xFFef4444) : const Color(0xFF10b981),
          icon: Icons.payments,
          onTap: () => context.go('/my-fees'),
        ),
      ],
    );
  }

  Widget _buildSubjectPerformanceSection({
    required StudentDashboardProvider dashboardProvider,
    bool isMobile = false,
  }) {
    // Loading handled at page level

    if (dashboardProvider.subjectPerformanceError != null) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error: ${dashboardProvider.subjectPerformanceError}'),
          ),
        ),
      );
    }

    final subjects = dashboardProvider.getSubjectPerformanceList();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.translate('subject_performance'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1e293b),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.translate('your_current_grades'),
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748b)),
          ),
          const SizedBox(height: 20),
          // Flexible scrollable content
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child:
                subjects.isEmpty
                    ? const SizedBox(
                      height: 100,
                      child: Center(child: Text('No subject data')),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: subjects.length,
                      itemBuilder:
                          (context, index) =>
                              SubjectPerformanceCard(subject: subjects[index]),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsSection({
    required StudentDashboardProvider dashboardProvider,
    bool isMobile = false,
  }) {
    // Loading handled at page level

    final events = dashboardProvider.getUpcomingEventsList();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.translate('upcoming_events'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1e293b),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.translate('tests_assignments_events'),
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748b)),
          ),
          const SizedBox(height: 20),
          // Flexible scrollable content
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child:
                events.isEmpty
                    ? const SizedBox(
                      height: 100,
                      child: Center(child: Text('No upcoming events')),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: events.length,
                      itemBuilder:
                          (context, index) => EventCard(event: events[index]),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(
    bool isMobile,
    StudentDashboardProvider dashboardProvider,
  ) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab Bar with Provider
        Consumer<DashboardTabProvider>(
          builder:
              (context, provider, child) => CustomTabBar<DashboardTab>(
                tabs: [
                  TabItem(
                    value: DashboardTab.recentAssignments,
                    label: context.translate('recent_assignments'),
                    icon: Icons.assignment,
                  ),
                  TabItem(
                    value: DashboardTab.performanceTrends,
                    label: context.translate('performance_trends'),
                    icon: Icons.trending_up,
                  ),
                  TabItem(
                    value: DashboardTab.attendanceHistory,
                    label: context.translate('attendance_history'),
                    icon: Icons.calendar_today,
                  ),
                ],
                selectedValue: provider.selectedTab,
                onTabSelected: (value) {
                  provider.updateSelectedTab(value);
                },
              ),
        ),

        const SizedBox(height: 8),

        // Content based on selected segment from Provider
        Consumer<DashboardTabProvider>(
          builder: (context, provider, child) {
            // Responsive height based on screen size
            final screenWidth = MediaQuery.of(context).size.width;
            final isMobileScreen = screenWidth < 600;
            final isTabletScreen = screenWidth >= 600 && screenWidth < 900;
            final containerHeight =
                isMobileScreen ? 300.0 : (isTabletScreen ? 420.0 : 450.0);

            return SizedBox(
              height: containerHeight,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder:
                    (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                child: KeyedSubtree(
                  key: ValueKey<DashboardTab>(provider.selectedTab),
                  child: switch (provider.selectedTab) {
                    DashboardTab.recentAssignments =>
                      _buildRecentAssignmentsTab(
                        dashboardProvider,
                        containerHeight,
                      ),
                    DashboardTab.performanceTrends =>
                      SingleChildScrollView(
                        child: _buildPerformanceTrendsTab(dashboardProvider),
                      ),
                    DashboardTab.attendanceHistory =>
                      SingleChildScrollView(
                        child: _buildAttendanceHistoryTab(dashboardProvider),
                      ),
                  },
                ),
              ),
            );
          },
        ),
      ],
    ),
  );

  Widget _buildRecentAssignmentsTab(
    StudentDashboardProvider dashboardProvider,
    double containerHeight,
  ) {
    if (dashboardProvider.isLoadingAssignments) {
      return const Center(child: CircularProgressIndicator());
    }

    final assignments = dashboardProvider.getAssignmentsList();

    // Fixed section header (title + subtitle)
    final sectionHeader = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.translate('recent_assignments_tests'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1e293b),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.translate('latest_submissions_grades'),
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748b)),
        ),
      ],
    );

    // Fixed table header row (aligned with AssignmentCard columns)
    final tableHeader = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(color: Color(0xFFe2e8f0), width: 2),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Assignment',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Subject',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Due Date',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              'Status',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 50,
            child: Text(
              'Grade',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              'Score',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        sectionHeader,
        const SizedBox(height: 20),
        if (assignments.isEmpty)
          Expanded(
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No assignments available'),
              ),
            ),
          )
        else ...[
          tableHeader,
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: assignments.length,
              itemBuilder: (context, index) =>
                  AssignmentCard(assignment: assignments[index]),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPerformanceTrendsTab(
    StudentDashboardProvider dashboardProvider,
  ) {
    if (dashboardProvider.isLoadingPerformanceTrends) {
      return const Center(child: CircularProgressIndicator());
    }

    // Check if there's actual performance data
    final trendsData = dashboardProvider.performanceTrends;
    final hasData =
        trendsData != null &&
        trendsData['data'] != null &&
        (trendsData['data']['trends'] as List<dynamic>?)?.isNotEmpty == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Academic Performance Trends',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1e293b),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Your progress across all subjects over time',
          style: TextStyle(fontSize: 14, color: Color(0xFF64748b)),
        ),
        const SizedBox(height: 20),
        if (!hasData)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  const Icon(
                    Icons.show_chart,
                    size: 64,
                    color: Color(0xFFCBD5E1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Performance Data Available',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Performance trends will appear here once you have academic records',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else ...[
          Builder(
            builder: (context) {
              debugPrint(
                '🎯 Passing to PerformanceTrendsChart: ${dashboardProvider.performanceTrends}',
              );
              return PerformanceTrendsChart(
                trendsData: dashboardProvider.performanceTrends,
              );
            },
          ),
          const SizedBox(height: 16),
          // Dynamic legend based on actual data
          _buildDynamicLegend(trendsData),
        ],
      ],
    );
  }

  Widget _buildDynamicLegend(Map<String, dynamic>? trendsData) {
    if (trendsData == null) {
      return const SizedBox.shrink();
    }

    final data = trendsData['data'];
    if (data == null) {
      return const SizedBox.shrink();
    }

    final trends = data['trends'] as List<dynamic>?;
    if (trends == null || trends.isEmpty) {
      return const SizedBox.shrink();
    }

    // Extract subject names and colors for legend
    final legendItems = <Widget>[];
    final subjectColors = <String, String>{
      'mathematics': '#4F7CFF',
      'math': '#4F7CFF',
      'physics': '#10b981',
      'chemistry': '#8B5CF6',
      'english': '#f59e0b',
      'history': '#ef4444',
      'biology': '#06b6d4',
      'computer': '#8b5cf6',
      'science': '#10b981',
    };

    for (final trend in trends) {
      final subjectName = trend['subject'] ?? '';
      if (subjectName.isEmpty) {
        continue;
      }

      // Get color for subject
      var colorHex = '#4F7CFF'; // default
      final lowerName = subjectName.toLowerCase();
      for (final entry in subjectColors.entries) {
        if (lowerName.contains(entry.key)) {
          colorHex = entry.value;
          break;
        }
      }

      // Parse color
      Color color;
      try {
        final hex = colorHex.replaceAll('#', '');
        color = Color(int.parse('FF$hex', radix: 16));
      } on Exception catch (_) {
        color = const Color(0xFF4F7CFF);
      }

      legendItems.add(_LegendItem(color: color, label: subjectName));
    }

    if (legendItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(spacing: 24, runSpacing: 12, children: legendItems);
  }

  Widget _buildAttendanceHistoryTab(
    StudentDashboardProvider dashboardProvider,
  ) {
    if (dashboardProvider.isLoadingAttendanceHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attendance History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1e293b),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Breakdown of your attendance status',
          style: TextStyle(fontSize: 14, color: Color(0xFF64748b)),
        ),
        const SizedBox(height: 20),
        Builder(
          builder: (context) {
            debugPrint(
              '🎯 Passing to AttendanceHistoryChart: ${dashboardProvider.attendanceHistory}',
            );
            return AttendanceHistoryChart(
              attendanceData: dashboardProvider.attendanceHistory,
            );
          },
        ),
      ],
    );
  }
}

// Legend Item Widget
class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1e293b),
        ),
      ),
    ],
  );
}
