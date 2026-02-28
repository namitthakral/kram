import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/router_service.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_sliding_segmented_control.dart';
import '../../../widgets/custom_widgets/dashboard_widgets.dart';
import '../providers/admin_analytics_tab_provider.dart';
import '../providers/admin_dashboard_provider.dart';
import '../widgets/add_student_dialog.dart';
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
      await context.read<AdminDashboardProvider>().fetchDashboardStats();
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
      title: context.translate('admin_dashboard'),
      appBarConfig: AppBarConfig.admin(
        userInitials: userInitials,
        userName: userName,
        institutionName: user.institution?.name ?? '',
        onNotificationIconPressed: () {},
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards
            _buildStatsSection(isMobile),
            const SizedBox(height: 24),

            // Quick actions (relative admin links)
            _buildQuickActionsSection(isMobile),
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

  Widget _buildQuickActionsSection(bool isMobile) => LayoutBuilder(
    builder: (context, constraints) {
      final crossCount = isMobile ? 2 : 4;
      return GridView.count(
        crossAxisCount: crossCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isMobile ? 1.4 : 2.2,
        children: [
          FeatureActionCard(
            title: context.translate('add_student'),
            icon: Icons.person_add_rounded,
            color: AppTheme.blue500,
            onTap: () => _showAddStudent(context),
          ),
          FeatureActionCard(
            title: context.translate('add_teacher'),
            icon: Icons.school_rounded,
            color: AppTheme.success,
            onTap: () => context.router.router.push('/teachers'),
          ),
          FeatureActionCard(
            title: context.translate('generate_report'),
            icon: Icons.analytics_rounded,
            color: AppTheme.danger,
            onTap: () => context.router.router.push('/reports'),
          ),
          FeatureActionCard(
            title: context.translate('send_notice'),
            icon: Icons.campaign_rounded,
            color: AppTheme.warning,
            onTap: () => context.router.router.push('/notifications'),
          ),
        ],
      );
    },
  );

  void _showAddStudent(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const AddStudentDialog(),
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
              DashboardStatCard(
                title: context.translate('total_students'),
                value: '$totalStudents',
                subtitle: context.translate('across_all_grades'),
                backgroundColor: const Color(0xFF3b82f6),
                iconColor: const Color(0xFF3b82f6),
                icon: Icons.groups,
              ),
              DashboardStatCard(
                title: context.translate('teachers'),
                value: '$totalTeachers',
                subtitle: context.translate('active_faculty'),
                backgroundColor: const Color(0xFF10b981),
                iconColor: const Color(0xFF10b981),
                icon: Icons.school,
              ),
              DashboardStatCard(
                title: context.translate('classes'),
                value: '$totalClasses',
                subtitle: context.translate('total_sections'),
                backgroundColor: const Color(0xFF8B5CF6),
                iconColor: const Color(0xFF8B5CF6),
                icon: Icons.class_,
              ),
              DashboardStatCard(
                title: context.translate('attendance'),
                value: '${attendanceRate.toStringAsFixed(1)}%',
                subtitle: context.translate('school_average'),
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
                        context.translate('failed_to_load_dashboard_stats'),
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
        Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFf59e0b),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              context.translate('system_alerts_notifications'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1e293b),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          context.translate('important_items_requiring_attention'),
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748b)),
        ),
        const SizedBox(height: 20),
        Consumer<AdminDashboardProvider>(
          builder: (context, provider, child) {
            final alerts = provider.systemAlerts ?? [];

            if (alerts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    context.translate('no_alerts'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF94a3b8),
                    ),
                  ),
                ),
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
          final totalTeachers = stats?.totalTeachers ?? 0;
          final totalStaff = stats?.totalStaff ?? 0;
          final totalStudents = stats?.totalStudents ?? 0;

          return Column(
            children: [
              _buildQuickStatCard(
                context.translate('pending_fees'),
                '₹${(pendingFees / 1000).toStringAsFixed(1)}K',
                context.translate('needs_follow_up'),
                Icons.warning_amber_rounded,
                const Color(0xFFfee2e2),
                const Color(0xFFef4444),
                onTap: () => context.go('/fees/student-fees'),
              ),
              const SizedBox(height: 16),
              _buildQuickStatCard(
                context.translate('fee_collection'),
                '₹${(feeCollection / 1000).toStringAsFixed(0)}K',
                context.translate('this_month'),
                Icons.attach_money,
                const Color(0xFFdbeafe),
                const Color(0xFF3b82f6),
                onTap: () => context.go('/fees'),
              ),
              const SizedBox(height: 16),
              _buildQuickStatCard(
                context.translate('staff_overview'),
                '$totalTeachers / $totalStaff',
                context.translate('teachers_staff'),
                Icons.badge_rounded,
                const Color(0xFFe0e7ff),
                const Color(0xFF6366f1),
                onTap: () => context.router.router.push('/teachers'),
              ),
              const SizedBox(height: 16),
              _buildQuickStatCard(
                context.translate('enrollment_trend'),
                '$totalStudents',
                context.translate('total_students'),
                Icons.trending_up_rounded,
                const Color(0xFFd1fae5),
                const Color(0xFF10b981),
                onTap: () => context.router.router.push('/students'),
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
    Color iconColor, {
    VoidCallback? onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
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
        Text(
          context.translate('analytics_overview'),
          style: const TextStyle(
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
            Text(
              context.translate('grade_distribution'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748b),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.translate('overall_academic_performance'),
              style: const TextStyle(fontSize: 14, color: Color(0xFF94a3b8)),
            ),
            const SizedBox(height: 16),
            AdminGradeDistributionChart(
              distributionData: provider.gradeDistribution,
            ),
            const SizedBox(height: 24),
            Text(
              context.translate('class_performance_overview'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748b),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.translate('average_grades_by_class'),
              style: const TextStyle(fontSize: 14, color: Color(0xFF94a3b8)),
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
            Text(
              context.translate('school_wide_attendance_trends'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748b),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.translate('monthly_attendance_vs_target'),
              style: const TextStyle(fontSize: 14, color: Color(0xFF94a3b8)),
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
            Text(
              context.translate('financial_overview'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748b),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.translate('monthly_revenue_expenses'),
              style: const TextStyle(fontSize: 14, color: Color(0xFF94a3b8)),
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
            Text(
              context.translate('teacher_performance_dashboard'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748b),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.translate('faculty_performance_metrics'),
              style: const TextStyle(fontSize: 14, color: Color(0xFF94a3b8)),
            ),
            const SizedBox(height: 16),
            AdminTeacherPerformanceTable(
              teacherData: provider.teacherPerformance,
            ),
          ],
        ),
  );

  Widget _buildReviewsTab() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: Color(0xFF94a3b8),
          ),
          const SizedBox(height: 16),
          Text(
            context.translate('performance_reviews'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748b),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.translate('annual_performance_review'),
            style: const TextStyle(fontSize: 14, color: Color(0xFF94a3b8)),
          ),
        ],
      ),
    ),
  );
}
