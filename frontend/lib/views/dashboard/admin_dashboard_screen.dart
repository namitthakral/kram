import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../modules/admin/services/admin_service.dart';
import '../../provider/login_signup/login_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/extensions.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/router_service.dart';
import '../../utils/user_utils.dart';
import '../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../widgets/custom_widgets/dashboard_widgets.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
    final institutionId = user.institutionId;

    return FutureBuilder<Map<String, dynamic>?>(
      future: institutionId != null
          ? AdminService().getInstitutionProfile(institutionId)
          : null,
      builder: (context, snapshot) {
        final institutionName = snapshot.data?['name'] as String? ??
            user.institution?.name ??
            '';
        return CustomMainScreenWithAppbar(
          title: context.translate('Admin Dashboard'),
          appBarConfig: AppBarConfig.admin(
            userInitials: userInitials,
            userName: userName,
            institutionName: institutionName,
            onNotificationIconPressed: () {},
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsSection(context),
                const SizedBox(height: 24),
                _buildQuickActionsSection(context),
                const SizedBox(height: 24),
                _buildRecentActivitiesSection(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final isMobile = context.isMobile;

    return GridView.count(
      crossAxisCount: isMobile ? 2 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: isMobile ? 12 : 16,
      mainAxisSpacing: isMobile ? 12 : 16,
      childAspectRatio: isMobile ? 1.3 : 1.5,
      children: const [
        DashboardStatCard(
          title: 'Total Students',
          value: '1,234',
          subtitle: 'Enrolled this year',
          icon: Icons.school,
          backgroundColor: CustomAppColors.primary,
          iconColor: CustomAppColors.primary,
        ),
        DashboardStatCard(
          title: 'Total Teachers',
          value: '156',
          subtitle: 'Active faculty',
          icon: Icons.people,
          backgroundColor: Color(0xFF10b981),
          iconColor: Color(0xFF10b981),
        ),
        DashboardStatCard(
          title: 'Courses',
          value: '45',
          subtitle: 'Active courses',
          icon: Icons.book,
          backgroundColor: Color(0xFFf59e0b),
          iconColor: Color(0xFFf59e0b),
        ),
        DashboardStatCard(
          title: 'Revenue',
          value: r'$125K',
          subtitle: 'This month',
          icon: Icons.attach_money,
          backgroundColor: Color(0xFF8B5CF6),
          iconColor: Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    final isMobile = context.isMobile;

    return Container(
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
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: isMobile ? 2 : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildActionButton('Add Student', Icons.person_add, () {}),
              _buildActionButton('Add Teacher', Icons.person_add_alt, () {}),
              _buildActionButton('Manage Courses', Icons.book, () {}),
              _buildActionButton('View Reports', Icons.analytics, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CustomAppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CustomAppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: CustomAppColors.primary, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1e293b),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  Widget _buildRecentActivitiesSection(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1e293b),
          ),
        ),
        const SizedBox(height: 16),
        _buildActivityItem(
          'New student enrollment',
          'John Doe enrolled in Grade 10',
          '2 hours ago',
          Icons.person_add,
        ),
        _buildActivityItem(
          'Teacher assignment',
          'Ms. Smith assigned to Physics',
          '5 hours ago',
          Icons.assignment_ind,
        ),
        _buildActivityItem(
          'Course updated',
          'Mathematics syllabus updated',
          'Yesterday',
          Icons.book,
        ),
      ],
    ),
  );

  Widget _buildActivityItem(
    String title,
    String description,
    String time,
    IconData icon,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CustomAppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: CustomAppColors.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1e293b),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748b)),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: const TextStyle(fontSize: 12, color: Color(0xFF94a3b8)),
        ),
      ],
    ),
  );
}
