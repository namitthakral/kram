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
import '../models/parent_dashboard_models.dart';
import '../providers/parent_dashboard_provider.dart';
import '../providers/parent_tab_provider.dart';
import '../widgets/academic_activity_card.dart';
import '../widgets/announcement_card.dart';
import '../widgets/parent_chart_widgets.dart';
import '../widgets/subject_breakdown_card.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    final loginProvider = context.read<LoginProvider>();
    final user = loginProvider.currentUser;

    if (user?.uuid != null && mounted) {
      final provider = context.read<ParentDashboardProvider>();
      await provider.fetchDashboardData(user!.uuid!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isLargeDesktop = context.isLargeDesktop;

    return Consumer<ParentDashboardProvider>(
      builder: (context, dashboardProvider, child) {
        final childInfo = dashboardProvider.childInfo;
        final loginProvider = context.watch<LoginProvider>();
        final user = loginProvider.currentUser;

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

        // Use child info if available, otherwise use default values
        final childInitials =
            childInfo?.initials ?? UserUtils.getInitials(user.name);
        final childName = childInfo?.name ?? user.name;
        final grade = childInfo?.grade ?? 'Grade N/A';
        final rollNumber = childInfo?.rollNumber ?? 'N/A';

        return CustomMainScreenWithAppbar(
          title: context.translate('Parent Dashboard'),
          appBarConfig: AppBarConfig.parent(
            childInitials: childInitials,
            childName: childName,
            grade: grade,
            rollNumber: rollNumber,
            onNotificationIconPressed: () {
              // Notification handler to be implemented
            },
          ),
          child:
              dashboardProvider.isLoading && childInfo == null
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Statistics Cards
                        _buildStatsSection(dashboardProvider, context),
                        const SizedBox(height: 24),

                        // Main Content - Responsive Layout
                        // Mobile and Tablet use same layout, Desktop uses different layout
                        if (isLargeDesktop)
                          _buildDesktopLayout()
                        else if (isDesktop)
                          _buildDesktopLayout()
                        else
                          _buildMobileLayout(),

                        const SizedBox(height: 24),

                        // Charts Section with Tabs
                        _buildChartsSection(context),
                      ],
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildStatsSection(
    ParentDashboardProvider provider,
    BuildContext context,
  ) {
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
        StatCard(
          title: 'Overall Grade',
          value: provider.childInfo?.overallGrade ?? 'A',
          subtitle: 'Excellent performance',
          backgroundColor: const Color(0xFFf59e0b),
          iconColor: const Color(0xFFf59e0b),
          icon: Icons.school,
        ),
        StatCard(
          title: 'Attendance',
          value: '${provider.childInfo?.attendance ?? 94.5}%',
          subtitle: 'Above average',
          backgroundColor: const Color(0xFF10b981),
          iconColor: const Color(0xFF10b981),
          icon: Icons.calendar_today,
        ),
        StatCard(
          title: 'Test Average',
          value: '${provider.testAverage.toInt()}%',
          subtitle: 'Last 5 tests',
          backgroundColor: const Color(0xFF4F7CFF),
          iconColor: const Color(0xFF4F7CFF),
          icon: Icons.analytics,
        ),
        StatCard(
          title: 'Improvement',
          value: '+${provider.semesterImprovement}%',
          subtitle: 'This semester',
          backgroundColor: const Color(0xFF8B5CF6),
          iconColor: const Color(0xFF8B5CF6),
          icon: Icons.trending_up,
        ),
      ],
    );
  }

  Widget _buildMobileLayout() => Column(
    children: [
      _buildRecentActivitiesSection(),
      const SizedBox(height: 16),
      _buildAnnouncementsSection(),
    ],
  );

  Widget _buildDesktopLayout() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(flex: 2, child: _buildRecentActivitiesSection()),
      const SizedBox(width: 24),
      Expanded(child: _buildAnnouncementsSection()),
    ],
  );

  Widget _buildRecentActivitiesSection() => Consumer<ParentDashboardProvider>(
    builder: (context, provider, child) {
      final isDesktop = context.isDesktop;

      return DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Academic Activities',
              style: TextStyle(
                fontSize: isDesktop ? 18 : 17,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1e293b),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Latest tests, assignments, and projects',
              style: TextStyle(
                fontSize: isDesktop ? 14 : 13,
                color: const Color(0xFF64748b),
              ),
            ),
            const SizedBox(height: 20),
            ...provider.academicActivities.map(
              (activity) => AcademicActivityCard(activity: activity),
            ),
          ],
        ),
      );
    },
  );

  Widget _buildAnnouncementsSection() => Consumer<ParentDashboardProvider>(
    builder: (context, provider, child) {
      final isDesktop = context.isDesktop;

      return DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'School Announcements',
              style: TextStyle(
                fontSize: isDesktop ? 18 : 17,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1e293b),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Important updates and events',
              style: TextStyle(
                fontSize: isDesktop ? 14 : 13,
                color: const Color(0xFF64748b),
              ),
            ),
            const SizedBox(height: 20),
            ...provider.announcements.map(
              (announcement) => AnnouncementCard(announcement: announcement),
            ),
          ],
        ),
      );
    },
  );

  Widget _buildChartsSection(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Consumer<ParentTabProvider>(
            builder:
                (
                  context,
                  provider,
                  child,
                ) => CustomSlidingSegmentedControl<ParentDashboardTab>(
                  segments: const {
                    ParentDashboardTab.academicPerformance:
                        'Academic Performance',
                    ParentDashboardTab.attendanceHistory: 'Attendance History',
                    ParentDashboardTab.subjectBreakdown: 'Subject Breakdown',
                  },
                  initialValue: provider.selectedTab,
                  onValueChanged: (value) {
                    provider.updateSelectedTab(value);
                  },
                ),
          ),
        ),
        const SizedBox(height: 24),
        Consumer<ParentTabProvider>(
          builder: (context, provider, child) {
            // Responsive height based on screen size
            final screenWidth = MediaQuery.of(context).size.width;
            final isMobileScreen = screenWidth < 600;
            final isTabletScreen = screenWidth >= 600 && screenWidth < 900;
            final containerHeight =
                isMobileScreen ? 380.0 : (isTabletScreen ? 450.0 : 480.0);

            return SizedBox(
              height: containerHeight,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder:
                    (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                child: KeyedSubtree(
                  key: ValueKey<ParentDashboardTab>(provider.selectedTab),
                  child: SingleChildScrollView(
                    child: switch (provider.selectedTab) {
                      ParentDashboardTab.academicPerformance =>
                        _buildAcademicPerformanceTab(),
                      ParentDashboardTab.attendanceHistory =>
                        _buildAttendanceHistoryTab(),
                      ParentDashboardTab.subjectBreakdown =>
                        _buildSubjectBreakdownTab(),
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    ),
  );

  Widget _buildAcademicPerformanceTab() => Consumer<ParentDashboardProvider>(
    builder:
        (context, provider, child) => ParentPerformanceTrendsChart(
          trendsData: provider.performanceTrends,
        ),
  );

  Widget _buildAttendanceHistoryTab() => Consumer<ParentDashboardProvider>(
    builder:
        (context, provider, child) =>
            ParentAttendanceTrendsChart(trendsData: provider.attendanceTrends),
  );

  Widget _buildSubjectBreakdownTab() => Consumer<ParentDashboardProvider>(
    builder:
        (context, provider, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subject-wise Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1e293b),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Current grades and recent improvements',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748b)),
            ),
            const SizedBox(height: 20),
            ...provider.subjectBreakdowns.map(
              (subject) => SubjectBreakdownCard(subject: subject),
            ),
          ],
        ),
  );
}
