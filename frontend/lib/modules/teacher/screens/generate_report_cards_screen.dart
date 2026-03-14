import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_dialog.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/unified_loader.dart';
import '../models/report_card_models.dart';
import '../providers/report_cards_provider.dart';

class GenerateReportCardsScreen extends StatefulWidget {
  const GenerateReportCardsScreen({super.key});

  @override
  State<GenerateReportCardsScreen> createState() =>
      _GenerateReportCardsScreenState();
}

class _GenerateReportCardsScreenState extends State<GenerateReportCardsScreen> {
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => ReportCardsProvider(),
    child: const _GenerateReportCardsContent(),
  );
}

class _GenerateReportCardsContent extends StatefulWidget {
  const _GenerateReportCardsContent();

  @override
  State<_GenerateReportCardsContent> createState() =>
      _GenerateReportCardsContentState();
}

class _GenerateReportCardsContentState
    extends State<_GenerateReportCardsContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final loginProvider = context.read<LoginProvider>();
    final teacherId = loginProvider.currentUser?.teacher?.id;
    await context.read<ReportCardsProvider>().loadInitialData(
      teacherId: teacherId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportCardsProvider>();
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final userInitials = UserUtils.getInitials(user?.name ?? 'Teacher');

    final classNames =
        provider.availableClasses
            .map((c) => c.className ?? 'Class')
            .toSet()
            .toList()
          ..sort();
    final sections =
        provider.selectedClassName == null
              ? <String>[]
              : provider.availableClasses
                  .where(
                    (c) =>
                        (c.className ?? 'Class') == provider.selectedClassName,
                  )
                  .map((c) => c.sectionName)
                  .toSet()
                  .toList()
          ..sort();

    return CustomMainScreenWithAppbar(
      title: 'Generate Report Cards',
      appBarConfig: AppBarConfig.teacher(
        userInitials: userInitials,
        userName: user?.name ?? 'Teacher',
        designation: user?.teacher?.designation ?? 'Faculty',
        employeeId: user?.teacher?.employeeId ?? 'N/A',
        onNotificationIconPressed: () {},
      ),
      isLoading: provider.isLoading && provider.availableClasses.isEmpty,
      child: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _SelectorTile<String>(
                        label: 'Class',
                        value: provider.selectedClassName,
                        items: classNames,
                        itemLabel: (s) => 'Class $s',
                        onTap:
                            () => _showPicker<String>(
                              context,
                              'Class',
                              classNames,
                              (s) => 'Class $s',
                              provider.selectedClassName,
                              (val) {
                                provider.setSelectedClassAndSection(val, null);
                              },
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: _SelectorTile<String>(
                        label: 'Section',
                        value: provider.selectedSectionName,
                        items: sections,
                        itemLabel: (s) => 'Sec $s',
                        isDisabled: provider.selectedClassName == null,
                        onTap:
                            () => _showPicker<String>(
                              context,
                              'Section',
                              sections,
                              (s) => 'Sec $s',
                              provider.selectedSectionName,
                              (val) async {
                                provider.setSelectedClassAndSection(
                                  provider.selectedClassName,
                                  val,
                                );
                                await provider.loadStudentsForSection();
                              },
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: provider.includeExamDetails,
                  onChanged: (v) => provider.setIncludeExamDetails(v ?? true),
                  title: const Text(
                    'Include exam details in report card',
                    style: TextStyle(fontSize: 14),
                  ),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),

          // Error
          if (provider.error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.error!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Report Cards header + student list
          Expanded(child: _buildStudentList(provider)),
        ],
      ),
    );
  }

  Widget _buildStudentList(ReportCardsProvider provider) {
    if (provider.selectedClass == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Select Class & Section to see students',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
    if (provider.isLoadingStudents) {
      return const Center(child: UnifiedLoader());
    }
    final students = provider.sectionStudents;
    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No students in this section',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
    final isGeneratingAll = provider.isGeneratingAll;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Text(
                'Report Cards',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed:
                    isGeneratingAll
                        ? null
                        : () async {
                          final result = await provider.generateForAll();
                          if (!mounted) return;
                          if (result.successCount > 0 || result.failCount > 0) {
                            final total =
                                result.successCount + result.failCount;
                            if (result.failCount == 0) {
                              showCustomSnackbar(
                                message:
                                    'Report cards generated for all $total students',
                                type: SnackbarType.success,
                              );
                            } else {
                              showCustomSnackbar(
                                message:
                                    'Generated ${result.successCount} of $total report cards. ${result.failCount} failed.',
                                type:
                                    result.successCount > 0
                                        ? SnackbarType.success
                                        : SnackbarType.error,
                              );
                            }
                          }
                          if (provider.error != null && mounted) {
                            showCustomSnackbar(
                              message: provider.error!,
                              type: SnackbarType.error,
                            );
                          }
                        },
                icon:
                    isGeneratingAll
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.batch_prediction, size: 20),
                label: Text(
                  isGeneratingAll ? 'Generating all...' : 'Generate All',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final student = students[index];
              final card = provider.reportCardForStudent(student.id);
              final isGenerating =
                  provider.isGeneratingForStudent(student.id) ||
                  provider.isGeneratingAll;
              return _StudentReportCardRow(
                student: student,
                reportCard: card,
                isGenerating: isGenerating,
                onGenerate: () async {
                  final success = await provider.generateForStudent(student.id);
                  if (mounted) {
                    if (success) {
                      final newCard = provider.reportCardForStudent(student.id);
                      if (newCard != null) {
                        context.push(
                          '/academic/report-cards/view',
                          extra: newCard,
                        );
                      } else {
                        showCustomSnackbar(
                          message: 'Report card generated for ${student.name}',
                          type: SnackbarType.success,
                        );
                      }
                    } else {
                      showCustomSnackbar(
                        message: provider.error ?? 'Failed to generate',
                        type: SnackbarType.error,
                      );
                    }
                  }
                },
                onView:
                    card != null
                        ? () => context.push(
                          '/academic/report-cards/view',
                          extra: card,
                        )
                        : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showPicker<T>(
    BuildContext context,
    String title,
    List<T> items,
    String Function(T) itemLabel,
    T? currentValue,
    ValueChanged<T> onSelected,
  ) async {
    final selected = await CustomDialog.showSelection<T>(
      context: context,
      title: 'Select $title',
      subtitle: 'Choose $title',
      items:
          items
              .map(
                (item) => SelectionItem<T>(
                  value: item,
                  label: itemLabel(item),
                  icon: Icons.check_circle_outline,
                ),
              )
              .toList(),
      selectedValue: currentValue,
    );
    if (context.mounted && selected != null) {
      onSelected(selected);
    }
  }
}

class _SelectorTile<T> extends StatelessWidget {
  const _SelectorTile({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onTap,
    this.isDisabled = false,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final VoidCallback? onTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: isDisabled ? null : onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDisabled ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.tune,
            size: 18,
            color: isDisabled ? Colors.grey : CustomAppColors.primaryBlue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
                Text(
                  value != null ? itemLabel(value as T) : 'Select',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color:
                        value == null || isDisabled
                            ? Colors.grey
                            : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
        ],
      ),
    ),
  );
}

class _StudentReportCardRow extends StatelessWidget {
  const _StudentReportCardRow({
    required this.student,
    required this.isGenerating,
    required this.onGenerate,
    this.reportCard,
    this.onView,
  });

  final ReportCardStudentItem student;
  final ReportCardData? reportCard;
  final bool isGenerating;
  final VoidCallback onGenerate;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: CustomAppColors.primaryBlue.withValues(alpha: 0.1),
          radius: 22,
          child: Text(
            student.initials.isNotEmpty
                ? student.initials
                : student.name.isNotEmpty
                ? student.name.substring(0, 1).toUpperCase()
                : '?',
            style: const TextStyle(
              color: CustomAppColors.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              if (reportCard != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'SGPA: ${reportCard!.performanceSummary.sgpa} • ${reportCard!.performanceSummary.overallGrade}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (onView != null)
          OutlinedButton.icon(
            onPressed: onView,
            icon: const Icon(Icons.visibility, size: 18),
            label: const Text('View'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        if (onView != null) const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: isGenerating ? null : onGenerate,
          icon:
              isGenerating
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Icon(Icons.add_chart, size: 18),
          label: Text(isGenerating ? 'Generating...' : 'Generate'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    ),
  );
}
