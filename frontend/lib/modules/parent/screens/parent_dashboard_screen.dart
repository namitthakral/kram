import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/router_service.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_sliding_segmented_control.dart';
import '../../../widgets/custom_widgets/dashboard_widgets.dart';
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
          title: context.translate('parent_dashboard'),
          appBarConfig: AppBarConfig.parent(
            childInitials: childInitials,
            childName: childName,
            grade: grade,
            rollNumber: rollNumber,
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
        DashboardStatCard(
          title: context.translate('overall_grade'),
          value: provider.childInfo?.overallGrade ?? 'A',
          subtitle: context.translate('excellent_performance'),
          backgroundColor: const Color(0xFFf59e0b),
          iconColor: const Color(0xFFf59e0b),
          icon: Icons.school,
        ),
        DashboardStatCard(
          title: context.translate('attendance'),
          value: '${provider.childInfo?.attendance ?? 94.5}%',
          subtitle: context.translate('above_average'),
          backgroundColor: const Color(0xFF10b981),
          iconColor: const Color(0xFF10b981),
          icon: Icons.calendar_today,
        ),
        DashboardStatCard(
          title: context.translate('test_average'),
          value: '${provider.testAverage.toInt()}%',
          subtitle: context.translate('last_5_tests'),
          backgroundColor: const Color(0xFF4F7CFF),
          iconColor: const Color(0xFF4F7CFF),
          icon: Icons.analytics,
        ),
        DashboardStatCard(
          title: context.translate('improvement'),
          value: '+${provider.semesterImprovement}%',
          subtitle: context.translate('this_semester'),
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
              context.translate('recent_academic_activities'),
              style: TextStyle(
                fontSize: isDesktop ? 18 : 17,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1e293b),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.translate('latest_tests_assignments'),
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
              context.translate('school_announcements'),
              style: TextStyle(
                fontSize: isDesktop ? 18 : 17,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1e293b),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.translate('important_updates_events'),
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
                (context, provider, child) =>
                    CustomSlidingSegmentedControl<ParentDashboardTab>(
                      segments: {
                        ParentDashboardTab.academicPerformance: context
                            .translate('academic_performance'),
                        ParentDashboardTab.attendanceHistory: context.translate(
                          'attendance_history',
                        ),
                        ParentDashboardTab.subjectBreakdown: context.translate(
                          'subject_breakdown',
                        ),
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
            Text(
              context.translate('subject_wise_performance'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1e293b),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.translate('current_grades_improvements'),
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748b)),
            ),
            const SizedBox(height: 20),
            ...provider.subjectBreakdowns.map(
              (subject) => SubjectBreakdownCard(subject: subject),
            ),
          ],
        ),
  );
}
