import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/dashboard_widgets.dart';
import '../models/examination_oversight_models.dart';
import '../services/admin_examination_service.dart';

class AdminExaminationOversightScreen extends StatefulWidget {
  const AdminExaminationOversightScreen({super.key});

  @override
  State<AdminExaminationOversightScreen> createState() =>
      _AdminExaminationOversightScreenState();
}

class _AdminExaminationOversightScreenState
    extends State<AdminExaminationOversightScreen> {
  ExaminationCompletionStats? _completionStats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCompletionStats();
  }

  Future<void> _loadCompletionStats() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final stats =
          await AdminExaminationService.getExaminationCompletionStats();

      setState(() {
        _completionStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final userInitials = UserUtils.getInitials(user?.name ?? 'AD');
    final userName = user?.name ?? 'Admin';

    return CustomMainScreenWithAppbar(
      title: context.translate('examination_oversight'),
      appBarConfig: AppBarConfig.admin(
        showBackButton: true,
        userInitials: userInitials,
        userName: userName,
        institutionName: user?.institution?.name ?? '',
        onBackButtonTapped: () => context.pop(),
      ),
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading examination data',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadCompletionStats,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Cards
                    if (_completionStats != null) ...[
                      Text(
                        'Examination Overview',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildOverviewCards(),
                      const SizedBox(height: 32),
                    ],

                    // Action Cards
                    Text(
                      'Examination Management',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildActionCards(),

                    const SizedBox(height: 32),

                    // Recent Activity
                    if (_completionStats != null) ...[
                      Text(
                        'Recent Examination Activity',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildRecentActivity(),
                    ],
                  ],
                ),
              ),
    );
  }

  Widget _buildOverviewCards() {
    final stats = _completionStats!.overview;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: context.isMobile ? 2 : 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          title: 'Total Exams',
          value: stats.totalExams.toString(),
          icon: Icons.quiz_outlined,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Scheduled',
          value: stats.scheduledExams.toString(),
          icon: Icons.schedule_outlined,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'Completed',
          value: stats.completedExams.toString(),
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Overdue Evaluations',
          value: stats.overdueEvaluations.toString(),
          icon: Icons.warning_outlined,
          color: stats.overdueEvaluations > 0 ? Colors.red : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  Widget _buildActionCards() => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: context.isMobile ? 1 : 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    childAspectRatio: context.isMobile ? 3 : 2.5,
    children: [
      FeatureActionCard(
        title: 'Examination Schedule',
        icon: Icons.calendar_today_outlined,
        color: const Color(0xFF3b82f6),
        onTap: () => context.push('/admin/examinations/schedule'),
      ),
      FeatureActionCard(
        title: 'Examination Policies',
        icon: Icons.policy_outlined,
        color: const Color(0xFF8b5cf6),
        onTap: () => context.push('/admin/examinations/policies'),
      ),
      FeatureActionCard(
        title: 'Analytics & Reports',
        icon: Icons.analytics_outlined,
        color: const Color(0xFF10b981),
        onTap: () => context.push('/admin/examinations/analytics'),
      ),
      FeatureActionCard(
        title: 'Compliance Report',
        icon: Icons.fact_check_outlined,
        color: const Color(0xFFf59e0b),
        onTap: () => context.push('/admin/examinations/compliance'),
      ),
    ],
  );

  Widget _buildRecentActivity() {
    final recentActivity = _completionStats!.recentActivity;

    if (recentActivity.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No recent examination activity',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          ...recentActivity
              .take(5)
              .map(
                (activity) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(
                      activity.status,
                    ).withOpacity(0.1),
                    child: Icon(
                      _getStatusIcon(activity.status),
                      color: _getStatusColor(activity.status),
                      size: 20,
                    ),
                  ),
                  title: Text(activity.examName),
                  subtitle: Text('${activity.subject} • ${activity.creator}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            activity.status,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          activity.status,
                          style: TextStyle(
                            color: _getStatusColor(activity.status),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(activity.updatedAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return Colors.blue;
      case 'ONGOING':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return Icons.schedule;
      case 'ONGOING':
        return Icons.play_circle;
      case 'COMPLETED':
        return Icons.check_circle;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
