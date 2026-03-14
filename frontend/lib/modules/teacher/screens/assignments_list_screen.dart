import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/extensions.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_bottom_modal_sheet.dart';
import '../../../widgets/custom_widgets/custom_dialog.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_search_bar.dart';
import '../../../widgets/custom_widgets/unified_loader.dart';
import '../providers/assignment_provider.dart';
import 'create_assignment_screen.dart';

/// Screen to display and manage all assignments for a teacher
class AssignmentsListScreen extends StatefulWidget {
  const AssignmentsListScreen({super.key});

  @override
  State<AssignmentsListScreen> createState() => _AssignmentsListScreenState();
}

class _AssignmentsListScreenState extends State<AssignmentsListScreen> {
  String _searchQuery = '';

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
    if (uuid == null) {
      return;
    }

    final provider = context.read<AssignmentProvider>();
    await provider.loadCourses();
    await provider.loadAssignments(uuid);
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final teacher = user?.teacher;

    if (user?.uuid == null) {
      return Scaffold(
        body: Center(child: Text(context.translate('user_not_found'))),
      );
    }

    // Get teacher info for app bar
    final userInitials = UserUtils.getInitials(user!.name);
    final userName = user.name;
    final designation = teacher?.designation ?? 'Teacher';
    final employeeId = teacher?.employeeId ?? 'N/A';

    return CustomMainScreenWithAppbar(
      title: context.translate('my_assignments'),
      appBarConfig: AppBarConfig.teacher(
        userInitials: userInitials,
        userName: userName,
        designation: designation,
        employeeId: employeeId,
        onNotificationIconPressed: () {
          // Notification handler to be implemented
        },
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      child: Stack(
        children: [
          Column(
            children: [
              // Search bar and filter - always visible
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomSearchBar(
                        hintText: context.translate('search_assignments'),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _showFilterDialog(context),
                      icon: const Icon(Icons.filter_list, size: 20),
                      label: Text(context.translate('filter')),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content area
              Expanded(
                child: Consumer<AssignmentProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading && provider.assignments.isEmpty) {
                      return const SizedBox(); // Loader handles this
                    }

                    if (provider.error != null) {
                      return _buildErrorState(provider.error!);
                    }

                    if (provider.assignments.isEmpty) {
                      return _buildEmptyState();
                    }

                    // Apply provider filters (course, status), then search query
                    final filteredByProvider =
                        provider.getFilteredAssignments();
                    final filteredAssignments =
                        filteredByProvider.where((assignment) {
                          if (_searchQuery.isEmpty) {
                            return true;
                          }
                          final query = _searchQuery.toLowerCase();
                          return assignment.title.toLowerCase().contains(
                                query,
                              ) ||
                              assignment.courseName.toLowerCase().contains(
                                query,
                              );
                        }).toList();

                    return RefreshIndicator(
                      onRefresh: _loadData,
                      child:
                          filteredAssignments.isEmpty
                              ? Center(
                                child: Text(
                                  context.translate('no_assignments_found'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.slate500,
                                  ),
                                ),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.only(
                                  bottom: 80,
                                ), // Space for FAB
                                itemCount: filteredAssignments.length,
                                itemBuilder: (context, index) {
                                  final assignment = filteredAssignments[index];
                                  final assignmentId = assignment.id;
                                  return _AssignmentCard(
                                    assignment: assignment,
                                    onTap:
                                        () => WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              if (mounted) {
                                                _navigateToEdit(assignmentId);
                                              }
                                            }),
                                    onDelete:
                                        () => WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              if (mounted) {
                                                _confirmDelete(assignmentId);
                                              }
                                            }),
                                  );
                                },
                              ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Unified Loader
          Consumer<AssignmentProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const UnifiedLoader();
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) =>
      FloatingActionButton.extended(
        onPressed: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _navigateToCreate();
            }
          });
        },
        icon: const Icon(Icons.add),
        label: Text(context.translate('new_assignment')),
      );

  Widget _buildErrorState(String error) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFFe7000b)),
          const SizedBox(height: 16),
          Text(
            context.translate('error_loading_assignments'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1e293b),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748b)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: Text(context.translate('retry')),
          ),
        ],
      ),
    ),
  );

  Widget _buildEmptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            context.translate('no_assignments_yet'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1e293b),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.translate('create_first_assignment'),
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748b)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  void _showFilterDialog(BuildContext context) {
    final provider = context.read<AssignmentProvider>();
    if (ResponsiveUtils.isMobile(context)) {
      _showAssignmentFilterBottomSheet(context, provider);
    } else {
      _showAssignmentFilterDialog(context, provider);
    }
  }

  void _showAssignmentFilterBottomSheet(
    BuildContext context,
    AssignmentProvider provider,
  ) {
    var pendingCourse = provider.selectedCourseFilter;
    var pendingStatus = provider.selectedStatusFilter;

    CustomBottomSheet.showCustomModalBottomSheet(
      context: context,
      config: const BottomSheetConfig(canDismiss: true),
      child: StatefulBuilder(
        builder:
            (ctx, setModalState) => _assignmentFilterContent(
              context: ctx,
              provider: provider,
              pendingCourse: pendingCourse,
              pendingStatus: pendingStatus,
              onPendingCourseChanged:
                  (v) => setModalState(() => pendingCourse = v),
              onPendingStatusChanged:
                  (v) => setModalState(() => pendingStatus = v),
              onClear: () {
                provider.clearFilters();
                Navigator.pop(context);
              },
              onApply: (course, status) {
                provider.setCourseFilter(course);
                provider.setStatusFilter(status);
                Navigator.pop(context);
              },
              showTitle: true,
            ),
      ),
    );
  }

  void _showAssignmentFilterDialog(
    BuildContext context,
    AssignmentProvider provider,
  ) {
    var pendingCourse = provider.selectedCourseFilter;
    var pendingStatus = provider.selectedStatusFilter;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (_, setModalState) => AlertDialog(
                  title: Text(dialogContext.translate('filter_assignments')),
                  content: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: _assignmentFilterContent(
                        context: dialogContext,
                        provider: provider,
                        pendingCourse: pendingCourse,
                        pendingStatus: pendingStatus,
                        onPendingCourseChanged:
                            (v) => setModalState(() => pendingCourse = v),
                        onPendingStatusChanged:
                            (v) => setModalState(() => pendingStatus = v),
                        onClear: () {
                          provider.clearFilters();
                          Navigator.of(dialogContext).pop();
                        },
                        onApply: (course, status) {
                          provider
                            ..setCourseFilter(course)
                            ..setStatusFilter(status);
                          Navigator.of(dialogContext).pop();
                        },
                        showTitle: false,
                      ),
                    ),
                  ),
                ),
          ),
    );
  }

  Widget _assignmentFilterContent({
    required BuildContext context,
    required AssignmentProvider provider,
    required String? pendingCourse,
    required String? pendingStatus,
    required void Function(String?) onPendingCourseChanged,
    required void Function(String?) onPendingStatusChanged,
    required VoidCallback onClear,
    required void Function(String?, String?) onApply,
    required bool showTitle,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (showTitle) ...[
        Text(
          context.translate('filter_assignments'),
          style: context.textTheme.titleXl.copyWith(
            color: AppTheme.slate800,
            fontWeight: AppTheme.fontWeightSemibold,
          ),
        ),
        const SizedBox(height: 24),
      ],
      DropdownButtonFormField<String?>(
        initialValue: pendingCourse,
        decoration: InputDecoration(
          labelText: context.translate('course'),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.book_outlined),
        ),
        items: [
          DropdownMenuItem<String?>(
            child: Text(context.translate('all_courses')),
          ),
          ...provider.courses.map(
            (course) => DropdownMenuItem<String?>(
              value: course.id.toString(),
              child: Text(course.courseName),
            ),
          ),
        ],
        onChanged: (value) => onPendingCourseChanged(value),
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String?>(
        initialValue: pendingStatus,
        decoration: InputDecoration(
          labelText: context.translate('status'),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.info_outline),
        ),
        items: [
          DropdownMenuItem<String?>(
            child: Text(context.translate('all_statuses')),
          ),
          DropdownMenuItem(
            value: 'DRAFT',
            child: Text(context.translate('draft')),
          ),
          DropdownMenuItem(
            value: 'PUBLISHED',
            child: Text(context.translate('published')),
          ),
          DropdownMenuItem(
            value: 'CLOSED',
            child: Text(context.translate('closed')),
          ),
        ],
        onChanged: (value) => onPendingStatusChanged(value),
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onClear,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(context.translate('clear')),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => onApply(pendingCourse, pendingStatus),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(context.translate('apply')),
            ),
          ),
        ],
      ),
    ],
  );

  Future<void> _navigateToCreate() async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final result = await navigator.push<bool>(
      MaterialPageRoute(builder: (context) => const CreateAssignmentScreen()),
    );
    if (result == true && mounted) {
      await _loadData();
    }
  }

  Future<void> _navigateToEdit(int assignmentId) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final result = await navigator.push<bool>(
      MaterialPageRoute(
        builder:
            (context) => CreateAssignmentScreen(assignmentId: assignmentId),
      ),
    );
    if (result == true && mounted) {
      await _loadData();
    }
  }

  Future<void> _confirmDelete(int assignmentId) async {
    final confirmed = await CustomDialog.showDeleteConfirmation(
      context: context,
      title: context.translate('delete_assignment'),
      message: context.translate('delete_assignment_confirmation'),
    );

    if (confirmed == true && mounted) {
      final loginProvider = context.read<LoginProvider>();
      final user = loginProvider.currentUser;
      final uuid = user?.uuid;
      if (uuid == null) {
        return;
      }

      final provider = context.read<AssignmentProvider>();
      final success = await provider.deleteAssignment(uuid, assignmentId);

      if (mounted) {
        showCustomSnackbar(
          message:
              success
                  ? 'Assignment deleted successfully'
                  : 'Failed to delete assignment',
          type: success ? SnackbarType.success : SnackbarType.warning,
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
    final isMobile = context.isMobile;

    Color statusColor;
    IconData statusIcon;
    switch (assignment.status.toString().toUpperCase()) {
      case 'PUBLISHED':
        statusColor = const Color(0xFF00a63e);
        statusIcon = Icons.check_circle;
        break;
      case 'DRAFT':
        statusColor = const Color(0xFFfe9a00);
        statusIcon = Icons.edit;
        break;
      case 'CLOSED':
        statusColor = const Color(0xFF64748b);
        statusIcon = Icons.lock;
        break;
      default:
        statusColor = const Color(0xFF155dfc);
        statusIcon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 14 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          assignment.title,
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1e293b),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 14, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              assignment.status.toString().toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        iconSize: 20,
                        onPressed: onDelete,
                        color: const Color(0xFFe7000b),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.book_outlined,
                        size: 16,
                        color: Color(0xFF4F7CFF),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          assignment.courseName ?? 'No course',
                          style: const TextStyle(
                            color: Color(0xFF4F7CFF),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (assignment.sectionName != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.class_outlined,
                          size: 16,
                          color: Color(0xFF64748b),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Section: ${assignment.sectionName}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748b),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFe2e8f0)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color:
                            isOverdue
                                ? const Color(0xFFe7000b)
                                : const Color(0xFF64748b),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Due: ${DateFormat('MMM dd, yyyy').format(dueDate)}',
                        style: TextStyle(
                          color:
                              isOverdue
                                  ? const Color(0xFFe7000b)
                                  : const Color(0xFF475569),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (!isOverdue && daysUntilDue <= 7) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFfe9a00,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$daysUntilDue ${daysUntilDue == 1 ? 'day' : 'days'} left',
                            style: const TextStyle(
                              color: Color(0xFFfe9a00),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      const Icon(
                        Icons.grade_outlined,
                        size: 16,
                        color: Color(0xFF64748b),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${assignment.maxMarks} marks',
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
