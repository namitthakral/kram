import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../models/examination_oversight_models.dart';
import '../services/admin_examination_service.dart';

class AdminExaminationScheduleScreen extends StatefulWidget {
  const AdminExaminationScheduleScreen({super.key});

  @override
  State<AdminExaminationScheduleScreen> createState() =>
      _AdminExaminationScheduleScreenState();
}

class _AdminExaminationScheduleScreenState
    extends State<AdminExaminationScheduleScreen> {
  List<ExaminationScheduleItem> _examinations = [];
  PaginationInfo? _pagination;
  bool _isLoading = true;
  String? _error;

  // Filters
  String? _selectedStatus;
  String? _selectedExamType;
  DateTimeRange? _dateRange;
  int _currentPage = 1;
  final int _itemsPerPage = 20;

  final List<String> _statusOptions = [
    'SCHEDULED',
    'ONGOING',
    'COMPLETED',
    'CANCELLED',
  ];
  final List<String> _examTypeOptions = [
    'QUIZ',
    'MIDTERM',
    'FINAL',
    'ASSIGNMENT',
    'PROJECT',
    'PRACTICAL',
  ];

  @override
  void initState() {
    super.initState();
    _loadExaminations();
  }

  Future<void> _loadExaminations() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await AdminExaminationService.getExaminationSchedule(
        startDate: _dateRange?.start.toIso8601String().split('T')[0],
        endDate: _dateRange?.end.toIso8601String().split('T')[0],
        status: _selectedStatus,
        examType: _selectedExamType,
        limit: _itemsPerPage,
        page: _currentPage,
      );

      setState(() {
        _examinations = response.examinations;
        _pagination = response.pagination;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _currentPage = 1;
    });
    _loadExaminations();
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedExamType = null;
      _dateRange = null;
      _currentPage = 1;
    });
    _loadExaminations();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _dateRange,
    );

    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final userInitials = UserUtils.getInitials(user?.name ?? 'AD');
    final userName = user?.name ?? 'Admin';

    return CustomMainScreenWithAppbar(
      title: 'Examination Schedule',
      appBarConfig: AppBarConfig.admin(
        showBackButton: true,
        userInitials: userInitials,
        userName: userName,
        institutionName: user?.institution?.name ?? '',
        onBackButtonTapped: () => context.pop(),
      ),
      child: Column(
        children: [
          // Filters
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
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items:
                            _statusOptions.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedExamType,
                        decoration: const InputDecoration(
                          labelText: 'Exam Type',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items:
                            _examTypeOptions.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedExamType = value;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
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
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Filters'),
                    ),
                  ],
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
                            'Error loading examinations',
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
                            onPressed: _loadExaminations,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                    : _examinations.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No examinations found',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                    : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _examinations.length,
                            itemBuilder: (context, index) {
                              final exam = _examinations[index];
                              return _buildExaminationCard(exam);
                            },
                          ),
                        ),
                        if (_pagination != null) _buildPagination(),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildExaminationCard(ExaminationScheduleItem exam) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.examName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${exam.subject.subjectName} (${exam.subject.subjectCode})',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(exam.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    exam.status,
                    style: TextStyle(
                      color: _getStatusColor(exam.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(exam.examDate),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (exam.startTime != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    exam.startTime!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (exam.durationMinutes != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${exam.durationMinutes} min',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  exam.creator.name,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  '${exam.totalMarks} marks',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            if (exam.venue != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    exam.venue!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Students',
                    exam.statistics.totalStudents.toString(),
                  ),
                  _buildStatItem(
                    'Evaluated',
                    exam.statistics.completedEvaluations.toString(),
                  ),
                  _buildStatItem(
                    'Pending',
                    exam.statistics.pendingEvaluations.toString(),
                  ),
                  _buildStatItem(
                    'Absent',
                    exam.statistics.absentStudents.toString(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildPagination() {
    if (_pagination == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page ${_pagination!.page} of ${_pagination!.totalPages}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Row(
            children: [
              IconButton(
                onPressed:
                    _currentPage > 1
                        ? () {
                          setState(() {
                            _currentPage--;
                          });
                          _loadExaminations();
                        }
                        : null,
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                onPressed:
                    _currentPage < _pagination!.totalPages
                        ? () {
                          setState(() {
                            _currentPage++;
                          });
                          _loadExaminations();
                        }
                        : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
