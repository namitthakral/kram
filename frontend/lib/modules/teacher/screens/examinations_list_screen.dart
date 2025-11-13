import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../providers/examination_provider.dart';
import 'examination_form_screen.dart';

/// Screen to display and manage all examinations for a teacher
class ExaminationsListScreen extends StatefulWidget {
  const ExaminationsListScreen({super.key});

  @override
  State<ExaminationsListScreen> createState() => _ExaminationsListScreenState();
}

class _ExaminationsListScreenState extends State<ExaminationsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final loginProvider = context.read<LoginProvider>();
    final user = loginProvider.currentUser;
    final uuid = user?.uuid;
    if (uuid == null) return;

    final provider = context.read<ExaminationProvider>();
    await provider.loadSemesters();
    await provider.loadExaminations(uuid);
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    if (user?.uuid == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Examinations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Consumer<ExaminationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.examinations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading examinations',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.examinations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No examinations yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first examination to get started',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.examinations.length,
              itemBuilder: (context, index) {
                final examination = provider.examinations[index];
                return _ExaminationCard(
                  examination: examination,
                  onTap: () => _navigateToEdit(examination.id),
                  onDelete: () => _confirmDelete(examination.id),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreate,
        icon: const Icon(Icons.add),
        label: const Text('New Examination'),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final provider = context.read<ExaminationProvider>();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter Examinations'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: provider.selectedStatusFilter,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(child: Text('All Statuses')),
                    DropdownMenuItem(
                      value: 'SCHEDULED',
                      child: Text('Scheduled'),
                    ),
                    DropdownMenuItem(value: 'ONGOING', child: Text('Ongoing')),
                    DropdownMenuItem(
                      value: 'COMPLETED',
                      child: Text('Completed'),
                    ),
                    DropdownMenuItem(
                      value: 'CANCELLED',
                      child: Text('Cancelled'),
                    ),
                  ],
                  onChanged: provider.setStatusFilter,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  provider.clearFilters();
                  Navigator.pop(context);
                  _loadData();
                },
                child: const Text('Clear'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _loadData();
                },
                child: const Text('Apply'),
              ),
            ],
          ),
    );
  }

  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExaminationFormScreen()),
    ).then((_) => _loadData());
  }

  void _navigateToEdit(int examId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExaminationFormScreen(examinationId: examId),
      ),
    ).then((_) => _loadData());
  }

  Future<void> _confirmDelete(int examId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Examination'),
            content: const Text(
              'Are you sure you want to delete this examination? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      final loginProvider = context.read<LoginProvider>();
      final user = loginProvider.currentUser;
      final uuid = user?.uuid;
      if (uuid == null) return;

      final provider = context.read<ExaminationProvider>();
      final success = await provider.deleteExamination(uuid, examId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Examination deleted successfully'
                  : 'Failed to delete examination',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}

class _ExaminationCard extends StatelessWidget {
  const _ExaminationCard({
    required this.examination,
    required this.onTap,
    required this.onDelete,
  });
  final dynamic examination;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final examDate = DateTime.parse(examination.examDate.toString());
    final isPast = examDate.isBefore(DateTime.now());
    final daysUntilExam = examDate.difference(DateTime.now()).inDays;

    Color statusColor;
    IconData statusIcon;
    switch (examination.status.toString().toUpperCase()) {
      case 'SCHEDULED':
        statusColor = Colors.blue;
        statusIcon = Icons.schedule;
        break;
      case 'ONGOING':
        statusColor = Colors.orange;
        statusIcon = Icons.play_circle;
        break;
      case 'COMPLETED':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'CANCELLED':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    Color examTypeColor;
    switch (examination.examType.toString().toUpperCase()) {
      case 'QUIZ':
        examTypeColor = Colors.purple;
        break;
      case 'MIDTERM':
        examTypeColor = Colors.orange;
        break;
      case 'FINAL':
        examTypeColor = Colors.red;
        break;
      case 'PRACTICAL':
        examTypeColor = Colors.teal;
        break;
      default:
        examTypeColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      examination.examName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          examination.status.toString().toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: examTypeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      examination.examType.toString().toUpperCase(),
                      style: TextStyle(
                        color: examTypeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      examination.courseName ?? 'No course',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF4F7CFF),
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
                    color: isPast ? Colors.grey : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(examDate),
                    style: TextStyle(
                      color: isPast ? Colors.grey : Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  if (!isPast && daysUntilExam <= 7 && daysUntilExam >= 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$daysUntilExam days left',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${examination.durationMinutes} min',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.grade, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Total: ${examination.totalMarks} marks',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.check_circle, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Passing: ${examination.passingMarks} marks',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
              if (examination.venue != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      examination.venue,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
