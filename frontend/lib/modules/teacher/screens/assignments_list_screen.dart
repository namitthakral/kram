import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../providers/assignment_provider.dart';
import 'assignment_form_screen.dart';

/// Screen to display and manage all assignments for a teacher
class AssignmentsListScreen extends StatefulWidget {
  const AssignmentsListScreen({super.key});

  @override
  State<AssignmentsListScreen> createState() => _AssignmentsListScreenState();
}

class _AssignmentsListScreenState extends State<AssignmentsListScreen> {
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

    final provider = context.read<AssignmentProvider>();
    await provider.loadCourses(uuid);
    await provider.loadAssignments(uuid);
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
        title: const Text('My Assignments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Consumer<AssignmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.assignments.isEmpty) {
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
                    'Error loading assignments',
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

          if (provider.assignments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No assignments yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first assignment to get started',
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
              itemCount: provider.assignments.length,
              itemBuilder: (context, index) {
                final assignment = provider.assignments[index];
                return _AssignmentCard(
                  assignment: assignment,
                  onTap: () => _navigateToEdit(assignment.id),
                  onDelete: () => _confirmDelete(assignment.id),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreate,
        icon: const Icon(Icons.add),
        label: const Text('New Assignment'),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final provider = context.read<AssignmentProvider>();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter Assignments'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: provider.selectedCourseFilter,
                  decoration: const InputDecoration(
                    labelText: 'Course',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(child: Text('All Courses')),
                    ...provider.courses.map(
                      (course) => DropdownMenuItem(
                        value: course.id.toString(),
                        child: Text(course.courseName),
                      ),
                    ),
                  ],
                  onChanged: provider.setCourseFilter,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: provider.selectedStatusFilter,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(child: Text('All Statuses')),
                    DropdownMenuItem(value: 'DRAFT', child: Text('Draft')),
                    DropdownMenuItem(
                      value: 'PUBLISHED',
                      child: Text('Published'),
                    ),
                    DropdownMenuItem(value: 'CLOSED', child: Text('Closed')),
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
      MaterialPageRoute(builder: (context) => const AssignmentFormScreen()),
    ).then((_) => _loadData());
  }

  void _navigateToEdit(int assignmentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignmentFormScreen(assignmentId: assignmentId),
      ),
    ).then((_) => _loadData());
  }

  Future<void> _confirmDelete(int assignmentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Assignment'),
            content: const Text(
              'Are you sure you want to delete this assignment? This action cannot be undone.',
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

      final provider = context.read<AssignmentProvider>();
      final success = await provider.deleteAssignment(uuid, assignmentId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Assignment deleted successfully'
                  : 'Failed to delete assignment',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({
    required this.assignment,
    required this.onTap,
    required this.onDelete,
  });
  final dynamic assignment;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dueDate = DateTime.parse(assignment.dueDate.toString());
    final isOverdue = dueDate.isBefore(DateTime.now());
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;

    Color statusColor;
    IconData statusIcon;
    switch (assignment.status.toString().toUpperCase()) {
      case 'PUBLISHED':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'DRAFT':
        statusColor = Colors.orange;
        statusIcon = Icons.edit;
        break;
      case 'CLOSED':
        statusColor = Colors.grey;
        statusIcon = Icons.lock;
        break;
      default:
        statusColor = Colors.blue;
        statusIcon = Icons.info;
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
                      assignment.title,
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
                          assignment.status.toString().toUpperCase(),
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
              Text(
                assignment.courseName ?? 'No course',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4F7CFF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (assignment.sectionName != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Section: ${assignment.sectionName}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: isOverdue ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${DateFormat('MMM dd, yyyy').format(dueDate)}',
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  if (!isOverdue && daysUntilDue <= 7) ...[
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
                        '$daysUntilDue days left',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Icon(Icons.grade, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${assignment.maxMarks} marks',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
