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
import '../providers/admin_analytics_tab_provider.dart';
import '../providers/admin_dashboard_provider.dart';
import '../widgets/admin_chart_widgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
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

    if (user != null && mounted) {
      final provider = context.read<AdminDashboardProvider>();
      await Future.wait([
        provider.fetchDashboardStats(),
        provider.fetchAllChartData(),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.router.goToLogin();
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userInitials = UserUtils.getInitials(user.name);
    final userName = user.name;

    return CustomMainScreenWithAppbar(
      title: context.translate('Admin Dashboard'),
      appBarConfig: AppBarConfig.admin(
        userInitials: userInitials,
        userName: userName,
        institutionName: 'EdVerse Institution',
        onNotificationIconPressed: () {},
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards
            _buildStatsSection(isMobile),
            const SizedBox(height: 24),

            // Main Content
            if (isMobile) _buildMobileLayout() else _buildDesktopLayout(),

            const SizedBox(height: 24),

            // Analytics Section with Tabs
            _buildAnalyticsSection(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() => Column(
    children: [
      _buildSystemAlertsSection(isMobile: true),
      const SizedBox(height: 16),
      _buildQuickStatsSection(isMobile: true),
    ],
  );

  Widget _buildDesktopLayout() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(flex: 2, child: _buildSystemAlertsSection()),
      const SizedBox(width: 24),
      Expanded(child: _buildQuickStatsSection()),
    ],
  );

  Widget _buildStatsSection(bool isMobile) => Consumer<AdminDashboardProvider>(
    builder: (context, dashboardProvider, child) {
      final stats = dashboardProvider.stats;
      final totalStudents = stats?.totalStudents ?? 0;
      final totalTeachers = stats?.totalTeachers ?? 0;
      final totalClasses = stats?.totalClasses ?? 0;
      final attendanceRate = stats?.attendanceRate ?? 0.0;

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
              StatCard(
                title: 'Total Students',
                value: '$totalStudents',
                subtitle: 'Across all grades',
                backgroundColor: const Color(0xFF3b82f6),
                iconColor: const Color(0xFF3b82f6),
                icon: Icons.groups,
              ),
              StatCard(
                title: 'Teachers',
                value: '$totalTeachers',
                subtitle: 'Active faculty',
                backgroundColor: const Color(0xFF10b981),
                iconColor: const Color(0xFF10b981),
                icon: Icons.school,
              ),
              StatCard(
                title: 'Classes',
                value: '$totalClasses',
                subtitle: 'Total sections',
                backgroundColor: const Color(0xFF8B5CF6),
                iconColor: const Color(0xFF8B5CF6),
                icon: Icons.class_,
              ),
              StatCard(
                title: 'Attendance',
                value: '${attendanceRate.toStringAsFixed(1)}%',
                subtitle: 'School average',
                backgroundColor: const Color(0xFF10b981),
                iconColor: const Color(0xFF10b981),
                icon: Icons.check_circle,
              ),
            ],
          ),
          if (dashboardProvider.isLoading)
            ColoredBox(
              color: Colors.white.withValues(alpha: 0.8),
              child: const Center(child: CircularProgressIndicator()),
            ),
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
                        'Failed to load dashboard stats',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadDashboardData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );

  Widget _buildSystemAlertsSection({bool isMobile = false}) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFf59e0b),
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'System Alerts & Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1e293b),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Important items requiring immediate attention',
          style: TextStyle(fontSize: 14, color: Color(0xFF64748b)),
        ),
        const SizedBox(height: 20),
        Consumer<AdminDashboardProvider>(
          builder: (context, provider, child) {
            final alerts = provider.systemAlerts ?? [];

            if (alerts.isEmpty) {
              return _buildAlertItem(
                'Attendance',
                'Grade 4B has 78% attendance this week',
                'high',
              );
            }

            return Column(
              children:
                  alerts
                      .map(
                        (alert) => _buildAlertItem(
                          alert.category,
                          alert.message,
                          alert.severity,
                        ),
                      )
                      .toList(),
            );
          },
        ),
      ],
    ),
  );

  Widget _buildAlertItem(String category, String message, String severity) {
    Color backgroundColor;
    Color borderColor;

    switch (severity.toLowerCase()) {
      case 'high':
        backgroundColor = const Color(0xFFfee2e2);
        borderColor = const Color(0xFFef4444);
        break;
      case 'medium':
        backgroundColor = const Color(0xFFfef3c7);
        borderColor = const Color(0xFFf59e0b);
        break;
      default:
        backgroundColor = const Color(0xFFe0f2fe);
        borderColor = const Color(0xFF3b82f6);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1e293b),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            severity,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: borderColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection({bool isMobile = false}) =>
      Consumer<AdminDashboardProvider>(
        builder: (context, provider, child) {
          final stats = provider.stats;
          final feeCollection = stats?.feeCollection ?? 0.0;
          final pendingFees = stats?.pendingFees ?? 0.0;

          return Column(
            children: [
              _buildQuickStatCard(
                'Pending Fees',
                '\$${(pendingFees / 1000).toStringAsFixed(1)}K',
                'Needs follow-up',
                Icons.warning_amber_rounded,
                const Color(0xFFfee2e2),
                const Color(0xFFef4444),
              ),
              const SizedBox(height: 16),
              _buildQuickStatCard(
                'Fee Collection',
                '\$${(feeCollection / 1000).toStringAsFixed(0)}K',
                'This month',
                Icons.attach_money,
                const Color(0xFFdbeafe),
                const Color(0xFF3b82f6),
              ),
            ],
          );
        },
      );

  Widget _buildQuickStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color backgroundColor,
    Color iconColor,
  ) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748b),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: iconColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748b)),
        ),
      ],
    ),
  );

  Widget _buildAnalyticsSection(bool isMobile) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analytics Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1e293b),
          ),
        ),
        const SizedBox(height: 20),
        Consumer<AdminAnalyticsTabProvider>(
          builder:
              (context, tabProvider, child) => Column(
                children: [
                  CustomSlidingSegmentedControl<AdminAnalyticsTab>(
                    segments: tabProvider.segments,
                    initialValue: tabProvider.selectedValue,
                    onValueChanged: tabProvider.updateSelectedValue,
                    useExternalProvider: true,
                  ),
                  const SizedBox(height: 24),
                  _buildAnalyticsContent(tabProvider.selectedValue, isMobile),
                ],
              ),
        ),
      ],
    ),
  );

  Widget _buildAnalyticsContent(AdminAnalyticsTab selectedTab, bool isMobile) {
    switch (selectedTab) {
      case AdminAnalyticsTab.performance:
        return _buildPerformanceTab();
      case AdminAnalyticsTab.attendance:
        return _buildAttendanceTab();
      case AdminAnalyticsTab.financial:
        return _buildFinancialTab();
      case AdminAnalyticsTab.staff:
        return _buildStaffTab();
      case AdminAnalyticsTab.reviews:
        return _buildReviewsTab();
    }
  }

  Widget _buildPerformanceTab() => Consumer<AdminDashboardProvider>(
    builder:
        (context, provider, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grade Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748b),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Overall academic performance across school',
              style: TextStyle(fontSize: 14, color: Color(0xFF94a3b8)),
            ),
            const SizedBox(height: 16),
            AdminGradeDistributionChart(
              distributionData: provider.gradeDistribution,
            ),
            const SizedBox(height: 24),
            const Text(
              'Class Performance Overview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748b),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Average grades and attendance by class',
              style: TextStyle(fontSize: 14, color: Color(0xFF94a3b8)),
            ),
            const SizedBox(height: 16),
            AdminClassPerformanceList(classData: provider.classPerformance),
          ],
        ),
  );

  Widget _buildAttendanceTab() => Consumer<AdminDashboardProvider>(
    builder:
        (context, provider, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'School-wide Attendance Trends',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748b),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Monthly attendance vs target (95%)',
              style: TextStyle(fontSize: 14, color: Color(0xFF94a3b8)),
            ),
            AdminAttendanceTrendsChart(trendsData: provider.attendanceTrends),
          ],
        ),
  );

  Widget _buildFinancialTab() => Consumer<AdminDashboardProvider>(
    builder:
        (context, provider, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Overview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748b),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Monthly revenue, expenses, and profit analysis',
              style: TextStyle(fontSize: 14, color: Color(0xFF94a3b8)),
            ),
            AdminFinancialOverviewChart(
              financialData: provider.financialOverview,
            ),
          ],
        ),
  );

  Widget _buildStaffTab() => Consumer<AdminDashboardProvider>(
    builder:
        (context, provider, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Teacher Performance Dashboard',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748b),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Faculty performance metrics and ratings',
              style: TextStyle(fontSize: 14, color: Color(0xFF94a3b8)),
            ),
            const SizedBox(height: 16),
            AdminTeacherPerformanceTable(
              teacherData: provider.teacherPerformance,
            ),
          ],
        ),
  );

  Widget _buildReviewsTab() => const Center(
    child: Padding(
      padding: EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 64, color: Color(0xFF94a3b8)),
          SizedBox(height: 16),
          Text(
            'Performance Reviews',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748b),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Annual performance review section',
            style: TextStyle(fontSize: 14, color: Color(0xFF94a3b8)),
          ),
        ],
      ),
    ),
  );
}
