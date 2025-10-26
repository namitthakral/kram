import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/extensions.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/custom_widgets/custom_cupertino_segmented.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../models/dashboard_stats.dart';
import '../providers/performance_tab_provider.dart';
import '../widgets/chart_widgets.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/stat_card.dart';
import '../widgets/student_activity_card.dart';

enum PerformanceTab { attendance, subject, grade }

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return CustomMainScreenWithAppbar(
      title: context.translate('Teacher Dashboard'),
      showBackButton: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (hide on mobile to save space)
            if (!isMobile) ...[_buildHeader(), const SizedBox(height: 24)],

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

  Widget _buildHeader() => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF4F7CFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.school, color: Colors.white, size: 24),
      ),
      const SizedBox(width: 16),
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Teacher Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1e293b),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Class overview and management',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748b)),
          ),
        ],
      ),
    ],
  );

  Widget _buildStatsSection(bool isMobile) => GridView.count(
    crossAxisCount: isMobile ? 1 : 4,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    childAspectRatio: isMobile ? 4 : 1.5,
    children: const [
      StatCard(
        title: 'Total Students',
        value: '28',
        subtitle: 'Active in your classes',
        backgroundColor: Color(0xFFEEF2FF),
        iconColor: Color(0xFF4F7CFF),
        icon: Icons.groups,
      ),
      StatCard(
        title: 'Present Today',
        value: '26',
        subtitle: '92.9% attendance',
        backgroundColor: Color(0xFFECFDF5),
        iconColor: Color(0xFF10b981),
        icon: Icons.check_circle,
      ),
      StatCard(
        title: 'Absent Today',
        value: '2',
        subtitle: 'Requires follow-up',
        backgroundColor: Color(0xFFFEF2F2),
        iconColor: Color(0xFFef4444),
        icon: Icons.cancel,
      ),
      StatCard(
        title: 'Avg. Attendance',
        value: '92.5%',
        subtitle: 'This month',
        backgroundColor: Color(0xFFFFFBEB),
        iconColor: Color(0xFFf59e0b),
        icon: Icons.trending_up,
      ),
    ],
  );

  Widget _buildRecentActivitySection({bool isMobile = false}) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Student Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1e293b),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Students in your classes with recent updates',
          style: TextStyle(fontSize: 14, color: Color(0xFF64748b)),
        ),
        const SizedBox(height: 20),
        ..._getMockStudents().map(
          (student) => StudentActivityCard(student: student, onTap: () {}),
        ),
      ],
    ),
  );

  Widget _buildQuickActionsSection({bool isMobile = false}) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1e293b),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Common tasks and shortcuts',
          style: TextStyle(fontSize: 14, color: Color(0xFF64748b)),
        ),
        const SizedBox(height: 20),
        QuickActionButton(
          title: 'Mark Attendance',
          icon: Icons.calendar_today,
          backgroundColor: const Color(0xFF4F7CFF),
          onTap: () {},
        ),
        const SizedBox(height: 12),
        QuickActionButton(
          title: 'Enter Marks',
          icon: Icons.book,
          backgroundColor: const Color(0xFF10b981),
          onTap: () {},
        ),
        const SizedBox(height: 12),
        QuickActionButton(
          title: 'Generate Report Cards',
          icon: Icons.star,
          backgroundColor: const Color(0xFFf59e0b),
          onTap: () {},
        ),
        const SizedBox(height: 12),
        QuickActionButton(
          title: 'Send Absence Alerts',
          icon: Icons.warning,
          backgroundColor: const Color(0xFFef4444),
          onTap: () {},
        ),
      ],
    ),
  );

  Widget _buildChartsSection(bool isMobile) => Container(
    padding: const EdgeInsets.all(20),
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
                      segments: const {
                        PerformanceTab.attendance: 'Attendance Trends',
                        PerformanceTab.subject: 'Subject Performance',
                        PerformanceTab.grade: 'Grade Distribution',
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

  Widget _buildAttendanceTrendsTab() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Weekly Attendance Overview',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1e293b),
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        'Daily attendance for this week',
        style: TextStyle(fontSize: 14, color: Color(0xFF64748b)),
      ),
      const SizedBox(height: 20),
      const AttendanceTrendsChart(),
      const SizedBox(height: 20),
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
          const Text(
            'Present',
            style: TextStyle(
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
          const Text(
            'Absent',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1e293b),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _buildSubjectPerformanceTab() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Subject Performance Overview',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1e293b),
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        'Average scores across different subjects',
        style: TextStyle(fontSize: 14, color: Color(0xFF64748b)),
      ),
      const SizedBox(height: 20),
      const SubjectPerformanceChart(),
    ],
  );

  Widget _buildGradeDistributionTab() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Grade Distribution',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1e293b),
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        'Current grade distribution across all students',
        style: TextStyle(fontSize: 14, color: Color(0xFF64748b)),
      ),
      const SizedBox(height: 20),
      const GradeDistributionChart(),
    ],
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
