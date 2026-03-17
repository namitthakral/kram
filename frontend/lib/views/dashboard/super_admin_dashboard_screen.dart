import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../provider/login_signup/login_provider.dart';
import '../../provider/super_admin/super_admin_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/extensions.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/router_service.dart';
import '../../utils/user_utils.dart';
import '../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../widgets/custom_widgets/dashboard_widgets.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() => _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final superAdminProvider = context.read<SuperAdminProvider>();
      // Force refresh to test the new camelCase API
      superAdminProvider.loadDashboardData(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final superAdminProvider = context.watch<SuperAdminProvider>();
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
      child: RefreshIndicator(
        onRefresh: () => superAdminProvider.refreshDashboard(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error handling
              if (superAdminProvider.hasError)
                _buildErrorWidget(context, superAdminProvider),
              
              // System health
              _buildSystemHealthWidget(context, superAdminProvider),
              const SizedBox(height: 24),
              
              // Stats section
              _buildStatsSection(context, superAdminProvider),
              const SizedBox(height: 24),
              
              // System overview
              _buildSystemOverviewSection(context),
              const SizedBox(height: 24),
              
              // Recent institutions
              _buildRecentInstitutionsSection(context, superAdminProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, SuperAdminProvider provider) {
    final isMobile = context.isMobile;
    final stats = provider.formattedStats;
    final isLoading = provider.isLoadingDashboard || provider.isLoadingStats;

    return GridView.count(
      crossAxisCount: isMobile ? 2 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: isMobile ? 12 : 16,
      mainAxisSpacing: isMobile ? 12 : 16,
      childAspectRatio: isMobile ? 1.3 : 1.5,
      children: [
        DashboardStatCard(
          title: 'Total Institutions',
          value: isLoading ? '...' : stats['institutions']!,
          subtitle: 'Active institutions',
          icon: Icons.business,
          backgroundColor: CustomAppColors.primary,
          iconColor: CustomAppColors.primary,
        ),
        DashboardStatCard(
          title: 'Total Users',
          value: isLoading ? '...' : stats['users']!,
          subtitle: 'Across all institutions',
          icon: Icons.people,
          backgroundColor: const Color(0xFF10b981),
          iconColor: const Color(0xFF10b981),
        ),
        DashboardStatCard(
          title: 'Active Users',
          value: isLoading ? '...' : stats['users']!,
          subtitle: 'Currently active',
          icon: Icons.online_prediction,
          backgroundColor: const Color(0xFF8B5CF6),
          iconColor: const Color(0xFF8B5CF6),
        ),
        DashboardStatCard(
          title: 'System Health',
          value: isLoading ? '...' : stats['health']!,
          subtitle: 'Overall health',
          icon: Icons.health_and_safety,
          backgroundColor: const Color(0xFFf59e0b),
          iconColor: const Color(0xFFf59e0b),
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
                () => context.go('/institutions'),
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

  Widget _buildRecentInstitutionsSection(BuildContext context, SuperAdminProvider provider) {
    final isLoading = provider.isLoadingDashboard;
    final institutions = provider.recentInstitutions;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Institutions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1e293b),
                ),
              ),
              if (provider.institutionsMeta != null && provider.institutionsMeta!.total > 5)
                TextButton(
                  onPressed: () => context.go('/institutions'),
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (isLoading)
            ...List.generate(4, (index) => _buildInstitutionItemSkeleton())
          else if (institutions.isEmpty)
            _buildEmptyInstitutions()
          else
            ...institutions.map((institution) => _buildInstitutionItem(
              institution.name,
              institution.userSummary,
              institution.status,
              institution.isActive,
            )),
        ],
      ),
    );
  }

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

  /// Build error widget
  Widget _buildErrorWidget(BuildContext context, SuperAdminProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error loading dashboard',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade800,
                  ),
                ),
                Text(
                  provider.error ?? 'Unknown error occurred',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              provider.clearError();
              provider.loadDashboardData(forceRefresh: true);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Build system health widget
  Widget _buildSystemHealthWidget(BuildContext context, SuperAdminProvider provider) {
    final stats = provider.systemStats;
    final isLoading = provider.isLoadingDashboard || provider.isLoadingStats;
    
    double healthPercentage = 99.9; // Default
    if (!isLoading && stats != null) {
      healthPercentage = stats.userHealthPercentage;
    }

    return SystemHealthWidget(healthPercentage: healthPercentage);
  }

  /// Build institution item skeleton for loading state
  Widget _buildInstitutionItemSkeleton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 200,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty institutions widget
  Widget _buildEmptyInstitutions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.business_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No institutions found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Institutions will appear here once they are created',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
