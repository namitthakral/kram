import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../services/admin_examination_service.dart';

class AdminExaminationAnalyticsScreen extends StatefulWidget {
  const AdminExaminationAnalyticsScreen({super.key});

  @override
  State<AdminExaminationAnalyticsScreen> createState() => _AdminExaminationAnalyticsScreenState();
}

class _AdminExaminationAnalyticsScreenState extends State<AdminExaminationAnalyticsScreen> {
  Map<String, dynamic>? _analyticsData;
  bool _isLoading = true;
  String? _error;
  String _selectedPeriod = 'month';

  final List<String> _periodOptions = ['week', 'month', 'semester', 'year'];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final data = await AdminExaminationService.getExaminationAnalytics(
        period: _selectedPeriod,
      );

      setState(() {
        _analyticsData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onPeriodChanged(String? period) {
    if (period != null && period != _selectedPeriod) {
      setState(() {
        _selectedPeriod = period;
      });
      _loadAnalytics();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final userInitials = UserUtils.getInitials(user?.name ?? 'AD');
    final userName = user?.name ?? 'Admin';

    return CustomMainScreenWithAppbar(
      title: 'Examination Analytics',
      appBarConfig: AppBarConfig.admin(
        showBackButton: true,
        userInitials: userInitials,
        userName: userName,
        institutionName: user?.institution?.name ?? '',
        onBackButtonTapped: () => context.pop(),
      ),
      child: Column(
        children: [
          // Period Selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  'Period:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedPeriod,
                  items: _periodOptions.map((period) {
                    return DropdownMenuItem(
                      value: period,
                      child: Text(period.capitalize),
                    );
                  }).toList(),
                  onChanged: _onPeriodChanged,
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
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
                              'Error loading analytics',
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
                              onPressed: _loadAnalytics,
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
                            // Examination Trends
                            if (_analyticsData?['trends'] != null) ...[
                              Text(
                                'Examination Trends',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildTrendsSection(),
                              const SizedBox(height: 32),
                            ],

                            // Subject Performance
                            if (_analyticsData?['subjectPerformance'] != null) ...[
                              Text(
                                'Subject Performance',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildSubjectPerformanceSection(),
                            ],
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsSection() {
    final trends = _analyticsData!['trends'] as List<dynamic>;
    
    if (trends.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No trend data available for this period',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Simple trend display (could be enhanced with charts)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Scheduled')),
                  DataColumn(label: Text('Completed')),
                  DataColumn(label: Text('Cancelled')),
                ],
                rows: trends.map<DataRow>((trend) {
                  return DataRow(
                    cells: [
                      DataCell(Text(trend['date'] ?? '')),
                      DataCell(Text('${trend['scheduled'] ?? 0}')),
                      DataCell(Text('${trend['completed'] ?? 0}')),
                      DataCell(Text('${trend['cancelled'] ?? 0}')),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectPerformanceSection() {
    final subjectPerformance = _analyticsData!['subjectPerformance'] as List<dynamic>;
    
    if (subjectPerformance.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.subject,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No subject performance data available',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: subjectPerformance.map<Widget>((subject) {
        final averageScore = subject['averageScore'] ?? 0.0;
        final totalExams = subject['totalExams'] ?? 0;
        final completionRate = subject['completionRate'] ?? 0.0;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject['subject'] ?? 'Unknown Subject',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricItem(
                        'Average Score',
                        '${averageScore.toStringAsFixed(1)}%',
                        Icons.grade,
                        _getScoreColor(averageScore),
                      ),
                    ),
                    Expanded(
                      child: _buildMetricItem(
                        'Total Exams',
                        totalExams.toString(),
                        Icons.quiz,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildMetricItem(
                        'Completion Rate',
                        '${completionRate.toStringAsFixed(1)}%',
                        Icons.check_circle,
                        _getCompletionColor(completionRate),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getCompletionColor(double rate) {
    if (rate >= 90) return Colors.green;
    if (rate >= 70) return Colors.orange;
    return Colors.red;
  }
}