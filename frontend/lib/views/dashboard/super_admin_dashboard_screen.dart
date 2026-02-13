import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/login_signup/login_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/extensions.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/router_service.dart';
import '../../utils/user_utils.dart';
import '../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../widgets/custom_widgets/dashboard_widgets.dart';

class SuperAdminDashboardScreen extends StatelessWidget {
  const SuperAdminDashboardScreen({super.key});

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

    return CustomMainScreenWithAppbar(
      title: context.translate('Super Admin Dashboard'),
      appBarConfig: AppBarConfig.superAdmin(
        userInitials: userInitials,
        userName: userName,
        systemName: 'Kram Platform',
        onNotificationIconPressed: () {},
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SystemHealthWidget(healthPercentage: 99.9),
            const SizedBox(height: 24),
            _buildStatsSection(context),
            const SizedBox(height: 24),
            _buildSystemOverviewSection(context),
            const SizedBox(height: 24),
            _buildRecentInstitutionsSection(context),
          ],
        ),
      ),
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
          title: 'Total Institutions',
          value: '48',
          subtitle: 'Active institutions',
          icon: Icons.business,
          backgroundColor: CustomAppColors.primary,
          iconColor: CustomAppColors.primary,
        ),
        DashboardStatCard(
          title: 'Total Users',
          value: '12.5K',
          subtitle: 'Across all institutions',
          icon: Icons.people,
          backgroundColor: Color(0xFF10b981),
          iconColor: Color(0xFF10b981),
        ),
        DashboardStatCard(
          title: 'Active Sessions',
          value: '1,234',
          subtitle: 'Currently online',
          icon: Icons.online_prediction,
          backgroundColor: Color(0xFF8B5CF6),
          iconColor: Color(0xFF8B5CF6),
        ),
        DashboardStatCard(
          title: 'Storage Used',
          value: '45.2 GB',
          subtitle: 'of 100 GB (45%)',
          icon: Icons.storage,
          backgroundColor: Color(0xFFf59e0b),
          iconColor: Color(0xFFf59e0b),
        ),
      ],
    );
  }

  Widget _buildSystemOverviewSection(BuildContext context) {
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
            'System Overview',
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
              _buildActionButton(
                'Manage Institutions',
                Icons.business_center,
                () {},
              ),
              _buildActionButton('View Analytics', Icons.analytics, () {}),
              _buildActionButton('System Settings', Icons.settings, () {}),
              _buildActionButton(
                'User Management',
                Icons.supervised_user_circle,
                () {},
              ),
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

  Widget _buildRecentInstitutionsSection(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Institutions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1e293b),
          ),
        ),
        const SizedBox(height: 16),
        _buildInstitutionItem(
          'Springfield High School',
          '1,234 students • 56 teachers',
          'Active',
          true,
        ),
        _buildInstitutionItem(
          'Tech Valley Academy',
          '890 students • 42 teachers',
          'Active',
          true,
        ),
        _buildInstitutionItem(
          'Riverside College',
          '2,145 students • 98 teachers',
          'Active',
          true,
        ),
        _buildInstitutionItem(
          'Sunset Elementary',
          '456 students • 23 teachers',
          'Inactive',
          false,
        ),
      ],
    ),
  );

  Widget _buildInstitutionItem(
    String name,
    String stats,
    String status,
    bool isActive,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isActive ? CustomAppColors.primary : Colors.grey.shade400)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.business,
            color: isActive ? CustomAppColors.primary : Colors.grey.shade400,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1e293b),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stats,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748b)),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: (isActive ? const Color(0xFF10b981) : Colors.grey.shade400)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isActive ? const Color(0xFF10b981) : Colors.grey.shade400)
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFF10b981) : Colors.grey.shade600,
            ),
          ),
        ),
      ],
    ),
  );
}
