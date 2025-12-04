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
import '../providers/examination_provider.dart';
import 'examination_form_screen.dart';

/// Screen to display and manage all examinations for a teacher
class ExaminationsListScreen extends StatefulWidget {
  const ExaminationsListScreen({super.key});

  @override
  State<ExaminationsListScreen> createState() => _ExaminationsListScreenState();
}

class _ExaminationsListScreenState extends State<ExaminationsListScreen> {
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

    final provider = context.read<ExaminationProvider>();
    await provider.loadSemesters();
    await provider.loadExaminations(uuid);
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final teacher = user?.teacher;

    if (user?.uuid == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }

    // Get teacher info for app bar
    final userInitials = UserUtils.getInitials(user!.name);
    final userName = user.name;
    final designation = teacher?.designation ?? 'Teacher';
    final employeeId = teacher?.employeeId ?? 'N/A';

    return CustomMainScreenWithAppbar(
      title: context.translate('my_examinations'),
      appBarConfig: AppBarConfig.teacher(
        userInitials: userInitials,
        userName: userName,
        designation: designation,
        employeeId: employeeId,
        onNotificationIconPressed: () {
          // Notification handler to be implemented
        },
      ),
      bottomWidget: _buildFloatingButton(context),
      child: Column(
        children: [
          // Search bar and filter - always visible
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: CustomSearchBar(
                    hintText: context.translate('search_examinations'),
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
            child: Consumer<ExaminationProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.examinations.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return _buildErrorState(provider.error!);
                }

                if (provider.examinations.isEmpty) {
                  return _buildEmptyState();
                }

                // Filter examinations based on search query
                final filteredExaminations =
                    provider.examinations.where((examination) {
                      if (_searchQuery.isEmpty) {
                        return true;
                      }
                      final query = _searchQuery.toLowerCase();
                      return examination.examName.toLowerCase().contains(
                            query,
                          ) ||
                          (examination.courseName.toLowerCase().contains(
                                query,
                              ) ??
                              false);
                    }).toList();

                return RefreshIndicator(
                  onRefresh: _loadData,
                  child:
                      filteredExaminations.isEmpty
                          ? Center(
                            child: Text(
                              context.translate('no_examinations_found'),
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.slate500,
                              ),
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: filteredExaminations.length,
                            itemBuilder: (context, index) {
                              final examination = filteredExaminations[index];
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
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFFe7000b)),
          const SizedBox(height: 16),
          Text(
            context.translate('error_loading_examinations'),
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
          Icon(Icons.quiz_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            context.translate('no_examinations_yet'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1e293b),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.translate('create_first_examination'),
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748b)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  Widget _buildFloatingButton(BuildContext context) {
    final isMobile = context.isMobile;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _navigateToCreate,
        icon: const Icon(Icons.add),
        label: Text(
          context.translate('new_examination'),
          style: TextStyle(fontSize: isMobile ? 14 : 16),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 14 : 16,
            horizontal: 24,
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final provider = context.read<ExaminationProvider>();
    CustomBottomSheet.showCustomModalBottomSheet(
      context: context,
      config: const BottomSheetConfig(height: 0.5, canDismiss: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.translate('filter_examinations'),
            style: context.textTheme.titleXl.copyWith(
              color: AppTheme.slate800,
              fontWeight: AppTheme.fontWeightSemibold,
            ),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            initialValue: provider.selectedStatusFilter,
            decoration: InputDecoration(
              labelText: context.translate('status'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.info_outline),
            ),
            items: [
              DropdownMenuItem(child: Text(context.translate('all_statuses'))),
              const DropdownMenuItem(
                value: 'SCHEDULED',
                child: Text('Scheduled'),
              ),
              const DropdownMenuItem(value: 'ONGOING', child: Text('Ongoing')),
              const DropdownMenuItem(
                value: 'COMPLETED',
                child: Text('Completed'),
              ),
              const DropdownMenuItem(
                value: 'CANCELLED',
                child: Text('Cancelled'),
              ),
            ],
            onChanged: provider.setStatusFilter,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    provider.clearFilters();
                    Navigator.pop(context);
                    _loadData();
                  },
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
                  onPressed: () {
                    Navigator.pop(context);
                    _loadData();
                  },
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
    final confirmed = await CustomDialog.showDeleteConfirmation(
      context: context,
      title: context.translate('delete_examination'),
      message: context.translate('delete_examination_confirmation'),
    );

    if (confirmed == true && mounted) {
      final loginProvider = context.read<LoginProvider>();
      final user = loginProvider.currentUser;
      final uuid = user?.uuid;
      if (uuid == null) {
        return;
      }

      final provider = context.read<ExaminationProvider>();
      final success = await provider.deleteExamination(uuid, examId);

      if (mounted) {
        showCustomSnackbar(
          message:
              success
                  ? 'Examination deleted successfully'
                  : 'Failed to delete examination',
          type: success ? SnackbarType.success : SnackbarType.warning,
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
    final isMobile = context.isMobile;

    Color statusColor;
    IconData statusIcon;
    switch (examination.status.toString().toUpperCase()) {
      case 'SCHEDULED':
        statusColor = const Color(0xFF155dfc);
        statusIcon = Icons.schedule;
        break;
      case 'ONGOING':
        statusColor = const Color(0xFFfe9a00);
        statusIcon = Icons.play_circle;
        break;
      case 'COMPLETED':
        statusColor = const Color(0xFF00a63e);
        statusIcon = Icons.check_circle;
        break;
      case 'CANCELLED':
        statusColor = const Color(0xFFe7000b);
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = const Color(0xFF64748b);
        statusIcon = Icons.info;
    }

    Color examTypeColor;
    switch (examination.examType.toString().toUpperCase()) {
      case 'QUIZ':
        examTypeColor = const Color(0xFF8b5cf6);
        break;
      case 'MIDTERM':
        examTypeColor = const Color(0xFFfe9a00);
        break;
      case 'FINAL':
        examTypeColor = const Color(0xFFe7000b);
        break;
      case 'PRACTICAL':
        examTypeColor = const Color(0xFF06b6d4);
        break;
      default:
        examTypeColor = const Color(0xFF155dfc);
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
                          examination.examName,
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
                              examination.status.toString().toUpperCase(),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: examTypeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          examination.examType.toString().toUpperCase(),
                          style: TextStyle(
                            color: examTypeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.book_outlined,
                        size: 16,
                        color: Color(0xFF4F7CFF),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          examination.courseName ?? 'No course',
                          style: const TextStyle(
                            color: Color(0xFF4F7CFF),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFe2e8f0)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color:
                            isPast
                                ? const Color(0xFF94a3b8)
                                : const Color(0xFF64748b),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMM dd, yyyy').format(examDate),
                        style: TextStyle(
                          color:
                              isPast
                                  ? const Color(0xFF94a3b8)
                                  : const Color(0xFF475569),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (!isPast &&
                          daysUntilExam <= 7 &&
                          daysUntilExam >= 0) ...[
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
                            '$daysUntilExam ${daysUntilExam == 1 ? 'day' : 'days'} left',
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
                        Icons.timer_outlined,
                        size: 16,
                        color: Color(0xFF64748b),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${examination.durationMinutes} min',
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.grade_outlined,
                        size: 16,
                        color: Color(0xFF64748b),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Total: ${examination.totalMarks}',
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: Color(0xFF64748b),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Passing: ${examination.passingMarks}',
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (examination.venue != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Color(0xFF64748b),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            examination.venue,
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
