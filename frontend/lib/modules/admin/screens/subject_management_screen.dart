import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../services/admin_service.dart';
import '../widgets/add_subject_dialog.dart';
import '../widgets/edit_subject_dialog.dart';

class SubjectManagementScreen extends StatefulWidget {
  const SubjectManagementScreen({super.key});

  @override
  State<SubjectManagementScreen> createState() =>
      _SubjectManagementScreenState();
}

class _SubjectManagementScreenState extends State<SubjectManagementScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _subjects = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final subjects = await _adminService.getSubjects();
      if (mounted) {
        setState(() {
          _subjects = subjects;
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> get _filtered {
    if (_searchQuery.isEmpty) {
      return _subjects;
    }
    final q = _searchQuery.toLowerCase();
    return _subjects.where((s) {
      final name = (s['subjectName'] as String? ?? '').toLowerCase();
      final code = (s['subjectCode'] as String? ?? '').toLowerCase();
      final type = (s['subjectType'] as String? ?? '').toLowerCase();
      return name.contains(q) || code.contains(q) || type.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final userInitials = UserUtils.getInitials(user?.name ?? 'AD');
    final userName = user?.name ?? 'Admin';
    final filtered = _filtered;

    return CustomMainScreenWithAppbar(
      title: 'Subject Management',
      appBarConfig: AppBarConfig.admin(
        showBackButton: true,
        userInitials: userInitials,
        userName: userName,
        institutionName: user?.institution?.name ?? '',
        onNotificationIconPressed: () {},
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSubject(context),
        backgroundColor: AppTheme.blue500,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Subject',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subjects',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage all academic subjects for your institution',
                  style: TextStyle(fontSize: 14, color: AppTheme.slate500),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _searchController,
                  hintText: 'Search by name, code or type…',
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 12),
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _loadSubjects,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                    : filtered.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.book_outlined,
                            size: 64,
                            color: AppTheme.slate500,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No subjects yet'
                                : 'No subjects match your search',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.slate500,
                            ),
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Tap "Add Subject" to create the first one',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.slate500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder:
                          (context, index) => _buildSubjectCard(
                            filtered[index] as Map<String, dynamic>,
                          ),
                    ),
          ),
          // Summary bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppTheme.slate100,
              border: Border(top: BorderSide(color: AppTheme.slate200)),
            ),
            child: Row(
              children: [
                Text(
                  'Total: ${_subjects.length} subjects',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.slate600,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Active: ${_subjects.where((s) => (s['status'] as String? ?? 'ACTIVE') == 'ACTIVE').length}',
                  style: const TextStyle(fontSize: 13, color: AppTheme.success),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    final name = subject['subjectName'] as String? ?? '—';
    final code = subject['subjectCode'] as String? ?? '—';
    final type = subject['subjectType'] as String? ?? '—';
    final credits = subject['credits']?.toString() ?? '—';
    final status = subject['status'] as String? ?? 'ACTIVE';
    final description = subject['description'] as String?;

    final typeColor = _typeColor(type);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.slate200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.book_rounded, color: typeColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppTheme.slate800,
                          ),
                        ),
                      ),
                      _statusBadge(status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _chip(code, AppTheme.blue500),
                      const SizedBox(width: 6),
                      _chip(type, typeColor),
                      const SizedBox(width: 6),
                      _chip('$credits credits', AppTheme.slate600),
                    ],
                  ),
                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.slate500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditSubject(context, subject);
                }
                if (value == 'delete') {
                  _confirmDelete(context, subject);
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
    ),
  );

  Widget _statusBadge(String status) {
    final isActive = status == 'ACTIVE';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:
            isActive
                ? AppTheme.success.withValues(alpha: 0.1)
                : AppTheme.slate100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? AppTheme.success : AppTheme.slate500,
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'CORE':
        return AppTheme.blue500;
      case 'ELECTIVE':
        return const Color(0xFF8B5CF6);
      case 'MAJOR':
        return AppTheme.success;
      case 'MINOR':
        return AppTheme.warning;
      default:
        return AppTheme.slate500;
    }
  }

  Future<void> _showAddSubject(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const AddSubjectDialog(),
    );
    if (result == true) {
      await _loadSubjects();
    }
  }

  Future<void> _showEditSubject(
    BuildContext context,
    Map<String, dynamic> subject,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => EditSubjectDialog(subject: subject),
    );
    if (result == true) {
      _loadSubjects();
    }
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> subject) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Subject'),
            content: Text(
              'Are you sure you want to delete "${subject['subjectName']}"? This will set it as inactive.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  try {
                    await _adminService.deleteSubject(subject['id'] as int);
                    _loadSubjects();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Subject deleted'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } on Exception catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
