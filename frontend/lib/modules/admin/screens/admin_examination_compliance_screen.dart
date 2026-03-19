import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../models/examination_oversight_models.dart';
import '../services/admin_examination_service.dart';

class AdminExaminationComplianceScreen extends StatefulWidget {
  const AdminExaminationComplianceScreen({super.key});

  @override
  State<AdminExaminationComplianceScreen> createState() =>
      _AdminExaminationComplianceScreenState();
}

class _AdminExaminationComplianceScreenState
    extends State<AdminExaminationComplianceScreen> {
  ExaminationComplianceReport? _complianceReport;
  bool _isLoading = true;
  String? _error;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _loadComplianceReport();
  }

  Future<void> _loadComplianceReport() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final report =
          await AdminExaminationService.getExaminationComplianceReport(
            startDate: _dateRange?.start.toIso8601String().split('T')[0],
            endDate: _dateRange?.end.toIso8601String().split('T')[0],
          );

      setState(() {
        _complianceReport = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
      _loadComplianceReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final userInitials = UserUtils.getInitials(user?.name ?? 'AD');
    final userName = user?.name ?? 'Admin';

    return CustomMainScreenWithAppbar(
      title: 'Compliance Report',
      appBarConfig: AppBarConfig.admin(
        showBackButton: true,
        userInitials: userInitials,
        userName: userName,
        institutionName: user?.institution?.name ?? '',
        onBackButtonTapped: () => context.pop(),
      ),
      child: Column(
        children: [
          // Date Range Selector
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
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _dateRange == null
                          ? 'Select Date Range'
                          : '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _dateRange = null;
                    });
                    _loadComplianceReport();
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
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
                            'Error loading compliance report',
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
                            onPressed: _loadComplianceReport,
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
                          // Summary
                          _buildSummarySection(),
                          const SizedBox(height: 32),

                          // Overdue Evaluations
                          if (_complianceReport!
                              .violations
                              .overdueEvaluations
                              .isNotEmpty) ...[
                            _buildViolationSection(
                              'Overdue Evaluations',
                              Icons.schedule,
                              Colors.red,
                              _complianceReport!
                                  .violations
                                  .overdueEvaluations
                                  .length,
                              _buildOverdueEvaluationsList(),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Short Notice Exams
                          if (_complianceReport!
                              .violations
                              .shortNoticeExams
                              .isNotEmpty) ...[
                            _buildViolationSection(
                              'Short Notice Exams',
                              Icons.warning,
                              Colors.orange,
                              _complianceReport!
                                  .violations
                                  .shortNoticeExams
                                  .length,
                              _buildShortNoticeExamsList(),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Long Duration Exams
                          if (_complianceReport!
                              .violations
                              .longDurationExams
                              .isNotEmpty) ...[
                            _buildViolationSection(
                              'Long Duration Exams',
                              Icons.timer,
                              Colors.blue,
                              _complianceReport!
                                  .violations
                                  .longDurationExams
                                  .length,
                              _buildLongDurationExamsList(),
                            ),
                          ],

                          // No Violations Message
                          if (_complianceReport!.summary.totalViolations ==
                              0) ...[
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 64,
                                        color: Colors.green.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No Policy Violations Found',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineSmall?.copyWith(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'All examinations are compliant with current policies',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final summary = _complianceReport!.summary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compliance Summary',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Violations',
                    summary.totalViolations.toString(),
                    Icons.warning,
                    summary.totalViolations > 0 ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Overdue Evaluations',
                    summary.overdueEvaluationsCount.toString(),
                    Icons.schedule,
                    summary.overdueEvaluationsCount > 0
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Short Notice',
                    summary.shortNoticeExamsCount.toString(),
                    Icons.notification_important,
                    summary.shortNoticeExamsCount > 0
                        ? Colors.orange
                        : Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Long Duration',
                    summary.longDurationExamsCount.toString(),
                    Icons.timer,
                    summary.longDurationExamsCount > 0
                        ? Colors.blue
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _buildViolationSection(
    String title,
    IconData icon,
    Color color,
    int count,
    Widget content,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            '$title ($count)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      content,
    ],
  );

  Widget _buildOverdueEvaluationsList() => Card(
    child: Column(
      children:
          _complianceReport!.violations.overdueEvaluations
              .map(
                (evaluation) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    child: const Icon(
                      Icons.schedule,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                  title: Text(evaluation.examName),
                  subtitle: Text(
                    '${evaluation.subject} • ${evaluation.creator}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${evaluation.daysOverdue} days overdue',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatDate(evaluation.examDate),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    ),
  );

  Widget _buildShortNoticeExamsList() => Card(
    child: Column(
      children:
          _complianceReport!.violations.shortNoticeExams
              .map(
                (exam) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    child: const Icon(
                      Icons.warning,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  title: Text(exam.examName),
                  subtitle: Text('${exam.subject} • ${exam.creator}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${exam.noticeGiven} days notice',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Min: ${exam.minimumRequired} days',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    ),
  );

  Widget _buildLongDurationExamsList() => Card(
    child: Column(
      children:
          _complianceReport!.violations.longDurationExams
              .map(
                (exam) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: const Icon(
                      Icons.timer,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  title: Text(exam.examName),
                  subtitle: Text('${exam.subject} • ${exam.creator}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${exam.duration} minutes',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Max: ${exam.maximumAllowed} min',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    ),
  );

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
