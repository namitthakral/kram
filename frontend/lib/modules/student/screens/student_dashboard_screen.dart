import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/router_service.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_sliding_segmented_control.dart';
import '../../teacher/widgets/stat_card.dart';
import '../models/student_dashboard_models.dart';
import '../providers/dashboard_tab_provider.dart';
import '../widgets/assignment_card.dart';
import '../widgets/event_card.dart';
import '../widgets/student_chart_widgets.dart';
import '../widgets/subject_performance_card.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final student = user?.student;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.router.goToLogin();
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Use real user data
    final userInitials = UserUtils.getInitials(user.name);
    final userName = user.name;
    const grade = 'Grade 10B'; // To be fetched from API when available
    final rollNumber = student?.rollNumber ?? 'N/A';

    return CustomMainScreenWithAppbar(
          title: context.translate('Student Dashboard'),
          appBarConfig: AppBarConfig.student(
            userInitials: userInitials,
            userName: userName,
            grade: grade,
            rollNumber: rollNumber,
            onNotificationIconPressed: () {
              // Notification handler to be implemented
            },
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // // Header with Student Info
                // _buildHeader(isMobile),
                // const SizedBox(height: 24),

                // Statistics Cards
                _buildStatsSection(isMobile),
                const SizedBox(height: 24),

                // Main Content - Responsive Layout
                if (isMobile) _buildMobileLayout() else _buildDesktopLayout(),

                const SizedBox(height: 24),

                // Charts Section with Tabs
                _buildChartsSection(isMobile),
              ],
            ),
          ),
        );
  }

  // Mobile Layout: Stack vertically
  Widget _buildMobileLayout() => Column(
    children: [
      _buildSubjectPerformanceSection(isMobile: true),
      const SizedBox(height: 16),
      _buildUpcomingEventsSection(isMobile: true),
    ],
  );

  // Desktop Layout: Side by side
  Widget _buildDesktopLayout() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Left Column - Subject Performance
      Expanded(flex: 2, child: _buildSubjectPerformanceSection()),
      const SizedBox(width: 24),

      // Right Column - Upcoming Events
      Expanded(child: _buildUpcomingEventsSection()),
    ],
  );

  Widget _buildStatsSection(bool isMobile) => GridView.count(
    crossAxisCount: isMobile ? 2 : 4,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: isMobile ? 12 : 16,
    mainAxisSpacing: isMobile ? 12 : 16,
    childAspectRatio: isMobile ? 1.3 : 1.5,
    children: const [
      StatCard(
        title: 'Current GPA',
        value: '3.8',
        subtitle: 'Out of 4.0\n+0.2',
        backgroundColor: Color(0xFF7f22fe),
        iconColor: Color(0xFF7f22fe),
        icon: Icons.school,
      ),
      StatCard(
        title: 'Attendance',
        value: '96.2%',
        subtitle: 'This semester\n+1.5%',
        backgroundColor: Color(0xFF4f39f6),
        iconColor: Color(0xFF4f39f6),
        icon: Icons.calendar_today,
      ),
      StatCard(
        title: 'Class Rank',
        value: '#5',
        subtitle: 'Out of 45 students\n↑2',
        backgroundColor: Color(
          0xFFe7000b,
        ), //TODO: WIll change acording to increase/descrease of rank
        iconColor: Color(
          0xFFe7000b,
        ), //TODO: WIll change acording to increase/descrease of rank
        icon: Icons.trending_up,
      ),
      StatCard(
        title: 'Assignments Due',
        value: '3',
        subtitle: 'This week',
        backgroundColor: Color(0xFFfe9a00),
        iconColor: Color(0xFFfe9a00),
        icon: Icons.assignment,
      ),
    ],
  );

  Widget _buildSubjectPerformanceSection({bool isMobile = false}) =>
      DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subject Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1e293b),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your current grades and progress',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748b)),
            ),
            const SizedBox(height: 20),
            ..._getMockSubjects().map(
              (subject) => SubjectPerformanceCard(subject: subject),
            ),
          ],
        ),
      );

  Widget _buildUpcomingEventsSection({bool isMobile = false}) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Events',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1e293b),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tests, assignments & events',
          style: TextStyle(fontSize: 14, color: Color(0xFF64748b)),
        ),
        const SizedBox(height: 20),
        ..._getMockEvents().map((event) => EventCard(event: event)),
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
        // Sliding Segmented Control with Provider
        SizedBox(
          width: double.infinity,
          child: Consumer<DashboardTabProvider>(
            builder:
                (context, provider, child) =>
                    CustomSlidingSegmentedControl<DashboardTab>(
                      segments: const {
                        DashboardTab.recentAssignments: 'Recent Assignments',
                        DashboardTab.performanceTrends: 'Performance Trends',
                        DashboardTab.attendanceHistory: 'Attendance History',
                      },
                      initialValue: provider.selectedTab,
                      onValueChanged: (value) {
                        provider.updateSelectedTab(value);
                      },
                    ),
          ),
        ),

        const SizedBox(height: 24),

        // Content based on selected segment from Provider
        Consumer<DashboardTabProvider>(
          builder:
              (context, provider, child) => SizedBox(
                height: 400,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                  child: KeyedSubtree(
                    key: ValueKey<DashboardTab>(provider.selectedTab),
                    child: SingleChildScrollView(
                      child: switch (provider.selectedTab) {
                        DashboardTab.recentAssignments =>
                          _buildRecentAssignmentsTab(),
                        DashboardTab.performanceTrends =>
                          _buildPerformanceTrendsTab(),
                        DashboardTab.attendanceHistory =>
                          _buildAttendanceHistoryTab(),
                      },
                    ),
                  ),
                ),
              ),
        ),
      ],
    ),
  );

  Widget _buildRecentAssignmentsTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = context.isMobile;

        if (isMobile) {
          // Mobile: Scrollable horizontal table
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Assignments & Tests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1e293b),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your latest submissions and grades',
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748b)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 900, // Fixed width for horizontal scrolling
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFe2e8f0),
                              width: 2,
                            ),
                          ),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(
                              width: 200,
                              child: Text(
                                'Assignment',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            SizedBox(
                              width: 150,
                              child: Text(
                                'Subject',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            SizedBox(
                              width: 120,
                              child: Text(
                                'Due Date',
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
                                'Status',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            SizedBox(
                              width: 60,
                              child: Text(
                                'Grade',
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
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Table Rows
                      ..._getMockAssignments().map(
                        (assignment) => AssignmentCard(assignment: assignment),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        // Desktop: Normal table layout
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Assignments & Tests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1e293b),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your latest submissions and grades',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748b)),
            ),
            const SizedBox(height: 20),
            // Table Header
            Container(
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
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Table Rows
            ..._getMockAssignments().map(
              (assignment) => AssignmentCard(assignment: assignment),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPerformanceTrendsTab() => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Academic Performance Trends',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1e293b),
        ),
      ),
      SizedBox(height: 4),
      Text(
        'Your progress across all subjects over time',
        style: TextStyle(fontSize: 14, color: Color(0xFF64748b)),
      ),
      SizedBox(height: 20),
      PerformanceTrendsChart(),
      SizedBox(height: 16),
      // Legend
      Wrap(
        spacing: 24,
        runSpacing: 12,
        children: [
          _LegendItem(color: Color(0xFF8B5CF6), label: 'Chemistry'),
          _LegendItem(color: Color(0xFFf59e0b), label: 'English'),
          _LegendItem(color: Color(0xFFef4444), label: 'History'),
          _LegendItem(color: Color(0xFF4F7CFF), label: 'Mathematics'),
          _LegendItem(color: Color(0xFF10b981), label: 'Physics'),
        ],
      ),
    ],
  );

  Widget _buildAttendanceHistoryTab() => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Attendance History',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1e293b),
        ),
      ),
      SizedBox(height: 4),
      Text(
        'Your attendance percentage over the semester',
        style: TextStyle(fontSize: 14, color: Color(0xFF64748b)),
      ),
      SizedBox(height: 20),
      AttendanceHistoryChart(),
    ],
  );

  List<SubjectPerformance> _getMockSubjects() => const [
    SubjectPerformance(
      subject: 'Mathematics',
      teacher: 'Mr. Smith',
      nextTest: 'Oct 25',
      grade: 'A',
      percentage: 92,
      color: '#4F7CFF',
    ),
    SubjectPerformance(
      subject: 'Physics',
      teacher: 'Dr. Johnson',
      nextTest: 'Oct 28',
      grade: 'A-',
      percentage: 89,
      color: '#10b981',
    ),
    SubjectPerformance(
      subject: 'Chemistry',
      teacher: 'Ms. Davis',
      nextTest: 'Nov 2',
      grade: 'B+',
      percentage: 85,
      color: '#8B5CF6',
    ),
    SubjectPerformance(
      subject: 'English',
      teacher: 'Mrs. Wilson',
      nextTest: 'Nov 5',
      grade: 'A',
      percentage: 94,
      color: '#f59e0b',
    ),
    SubjectPerformance(
      subject: 'History',
      teacher: 'Mr. Brown',
      nextTest: 'Nov 8',
      grade: 'B',
      percentage: 82,
      color: '#ef4444',
    ),
  ];

  List<UpcomingEvent> _getMockEvents() => const [
    UpcomingEvent(
      title: 'Mathematics Test',
      date: 'Oct 25, 2024',
      time: '10:00 AM',
      type: EventType.test,
    ),
    UpcomingEvent(
      title: 'Science Fair Project Due',
      date: 'Oct 30, 2024',
      time: '11:59 PM',
      type: EventType.assignment,
    ),
    UpcomingEvent(
      title: 'Parent-Teacher Conference',
      date: 'Nov 5, 2024',
      time: '2:00 PM',
      type: EventType.event,
    ),
    UpcomingEvent(
      title: 'Sports Day',
      date: 'Nov 12, 2024',
      time: '9:00 AM',
      type: EventType.event,
    ),
  ];

  List<Assignment> _getMockAssignments() => const [
    Assignment(
      title: 'Calculus Problem Set',
      subject: 'Mathematics',
      dueDate: '2024-09-22',
      status: AssignmentStatus.submitted,
      grade: 'A',
      score: '45/50',
    ),
    Assignment(
      title: 'Lab Report - Momentum',
      subject: 'Physics',
      dueDate: '2024-09-20',
      status: AssignmentStatus.graded,
      grade: 'B+',
      score: '38/40',
    ),
    Assignment(
      title: 'Essay - Climate Change',
      subject: 'English',
      dueDate: '2024-09-25',
      status: AssignmentStatus.pending,
    ),
    Assignment(
      title: 'Organic Compounds Quiz',
      subject: 'Chemistry',
      dueDate: '2024-09-18',
      status: AssignmentStatus.graded,
      grade: 'A-',
      score: '28/30',
    ),
  ];
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
