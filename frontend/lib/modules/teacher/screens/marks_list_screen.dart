import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_dialog.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/unified_loader.dart';
import '../models/examination_models.dart';
import '../models/marks_models.dart';
import '../providers/marks_provider.dart';

class MarksListScreen extends StatefulWidget {
  const MarksListScreen({super.key});

  @override
  State<MarksListScreen> createState() => _MarksListScreenState();
}

class _MarksListScreenState extends State<MarksListScreen> {
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => MarksProvider(),
    child: const _MarksListContent(),
  );
}

class _MarksListContent extends StatefulWidget {
  const _MarksListContent();

  @override
  State<_MarksListContent> createState() => _MarksListContentState();
}

class _MarksListContentState extends State<_MarksListContent> {
  // Filter States
  String? _selectedClassName;
  String? _selectedSectionName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final loginProvider = context.read<LoginProvider>();
    final userUuid = loginProvider.currentUser?.uuid;
    final teacherId = loginProvider.currentUser?.teacher?.id;
    if (userUuid != null) {
      final provider = context.read<MarksProvider>();
      provider.reset();
      await provider.loadInitialData(userUuid, teacherId: teacherId);
      if (mounted) {
        _checkAutoSelections(provider);
      }
    }
  }

  void _checkAutoSelections(MarksProvider provider) {
    if (!mounted) return;

    final classNames =
        provider.availableClasses
            .map((c) => c.className ?? 'Class')
            .toSet()
            .toList()
          ..sort();

    var stateChanged = false;

    // 1. Auto-select Class
    if (_selectedClassName == null && classNames.length == 1) {
      _selectedClassName = classNames.first;
      stateChanged = true;
    }

    // 2. Auto-select Section
    final sections =
        _selectedClassName == null
              ? <String>[]
              : provider.availableClasses
                  .where((c) => (c.className ?? 'Class') == _selectedClassName)
                  .map((c) => c.sectionName)
                  .toSet()
                  .toList()
          ..sort();

    if (_selectedClassName != null &&
        _selectedSectionName == null &&
        sections.length == 1) {
      _selectedSectionName = sections.first;
      stateChanged = true;
    } else if (_selectedClassName != null &&
        _selectedSectionName != null &&
        !sections.contains(_selectedSectionName)) {
      _selectedSectionName = null;
      stateChanged = true;
    }

    if (stateChanged) {
      setState(() {});
      _updateSelection(provider);
    }

    if (stateChanged) {
      setState(() {});
      _updateSelection(provider);
    }
  }

  void _updateSelection(MarksProvider provider) {
    // If Class & Section selected, load students AND exams
    if (_selectedClassName != null && _selectedSectionName != null) {
      provider.loadExamsForSection(_selectedClassName!, _selectedSectionName!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MarksProvider>();
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final userInitials = UserUtils.getInitials(user?.name ?? 'Teacher');

    // Check loading state for initial classes load
    final isLoadingClasses =
        provider.isLoading && provider.availableClasses.isEmpty;

    // --- Derived Lists Logic ---

    // 1. Unique Class Names
    final classNames =
        provider.availableClasses
            .map((c) => c.className ?? 'Class')
            .toSet()
            .toList()
          ..sort();

    // 2. Sections (Filtered by Class)
    final sections =
        _selectedClassName == null
              ? <String>[]
              : provider.availableClasses
                  .where((c) => (c.className ?? 'Class') == _selectedClassName)
                  .map((c) => c.sectionName)
                  .toSet()
                  .toList()
          ..sort();

    // 4. Exams (Filtered by Class/Subject)
    // 4. Exams (Now directly from provider)
    // Removed local filter logic since provider handles it via loadExamsForClass

    return CustomMainScreenWithAppbar(
      title: 'Marks & Results',
      appBarConfig: AppBarConfig.teacher(
        userInitials: userInitials,
        userName: user?.name ?? 'Teacher',
        designation: user?.teacher?.designation ?? 'Faculty',
        employeeId: user?.teacher?.employeeId ?? 'N/A',
        onNotificationIconPressed: () {},
      ),
      isLoading: provider.isLoading,
      bottomWidget:
          (provider.canSave && !provider.isLoading)
              ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final success = await provider.saveMarks();
                      if (context.mounted) {
                        if (success) {
                          showCustomSnackbar(
                            message: 'Marks saved successfully',
                            type: SnackbarType.success,
                          );
                        } else {
                          showCustomSnackbar(
                            message: provider.error ?? 'Failed to save',
                            type: SnackbarType.error,
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomAppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text(
                      'Save Marks',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
              : null,
      bottomWidgetPadding: EdgeInsets.zero,
      child: Column(
        children: [
          // Filter Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                // Row 1: Class, Section, Subject
                Row(
                  children: [
                    // 1. Class (Flex 2)
                    Expanded(
                      flex: 2,
                      child: _GenericSelector<String>(
                        label: 'Class',
                        selectedValue: _selectedClassName,
                        items: classNames,
                        isLoading: isLoadingClasses,
                        itemLabelBuilder: (s) => 'Class $s',
                        onItemSelected: (val) {
                          setState(() {
                            _selectedClassName = val;
                            _selectedSectionName = null;
                          });
                          _updateSelection(provider);
                        },
                        placeholder: 'Class',
                        iconData: Icons.class_,
                        compact: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 2. Section (Flex 2)
                    Expanded(
                      flex: 2,
                      child: _GenericSelector<String>(
                        label: 'Section',
                        selectedValue: _selectedSectionName,
                        items: sections,
                        isLoading: isLoadingClasses,
                        itemLabelBuilder: (s) => 'Sec $s',
                        onItemSelected: (val) {
                          setState(() {
                            _selectedSectionName = val;
                          });
                          _updateSelection(provider);
                        },
                        placeholder: 'Sec',
                        iconData: Icons.view_module,
                        isDisabled: _selectedClassName == null,
                        compact: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 12),
                // Row 2: Select Exam (Mandatory) + Date (Display Only)
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _GenericSelector<Examination?>(
                        label: 'Select Exam',
                        selectedValue: provider.selectedExam,
                        items: provider.availableExams,
                        isLoading: false,
                        itemLabelBuilder: (e) => e?.examName ?? 'Unnamed Exam',
                        onItemSelected: provider.setSelectedExam,
                        placeholder: 'Select Exam',
                        iconData: Icons.history_edu,
                        compact: true,
                        isDisabled: provider.availableExams.isEmpty,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Date Display (Read Only)
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Date',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    provider.examDate != null
                                        ? DateFormat(
                                          'MMM dd, yyyy',
                                        ).format(provider.examDate!)
                                        : '-',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Summary & Total Marks Config
          if (provider.selectedClass != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  // Total Marks Input
                  // Total Marks (Read Only)
                  Container(
                    width: 120,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: CustomAppColors.slate50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: CustomAppColors.slate300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Marks',
                          style: TextStyle(
                            fontSize: 10,
                            color: CustomAppColors.slate500,
                          ),
                        ),
                        Text(
                          provider.totalMarks?.toStringAsFixed(0) ?? '-',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: CustomAppColors.slate500, // Dimmed
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Average
                  _buildSummaryMetric(
                    'Avg',
                    '${provider.summary.averageMarks.toStringAsFixed(1)}%',
                    CustomAppColors.primaryBlue,
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),

          // Main Content
          Expanded(
            child:
                provider.isLoading && provider.students.isEmpty
                    ? const UnifiedLoader()
                    : (_selectedClassName == null ||
                        _selectedSectionName == null)
                    ? _buildEmptyState(
                      'Select Class & Section to view students',
                    )
                    : provider.students.isEmpty
                    ? _buildEmptyState('No students found in this class')
                    : _StudentMarksList(
                      students: provider.students,
                      totalMarks: provider.totalMarks ?? 100,
                      onMarksChanged: provider.updateStudentMarks,
                      readOnly:
                          provider.selectedExam ==
                          null, // Disable if no exam selected
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(String label, String value, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    ],
  );

  Widget _buildEmptyState(String message) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.assignment_outlined, size: 48, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(message, style: TextStyle(color: Colors.grey.shade500)),
      ],
    ),
  );
}

// Student Marks List
class _StudentMarksList extends StatelessWidget {
  const _StudentMarksList({
    required this.students,
    required this.totalMarks,
    required this.onMarksChanged,
    this.readOnly = false,
  });

  final List<StudentMarks> students;
  final double totalMarks;
  final Function(String, double?) onMarksChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: students.length,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (context, index) {
      final student = students[index];
      final marks = student.marks;
      final hasMarks = marks != null;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: hasMarks ? Colors.transparent : Colors.grey.shade200,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor:
                  hasMarks
                      ? CustomAppColors.primaryBlue.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
              radius: 22,
              child: Text(
                student.initials,
                style: TextStyle(
                  color:
                      hasMarks
                          ? CustomAppColors.primaryBlue
                          : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
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
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${student.id}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            // Marks Input
            Container(
              width: 70,
              padding: const EdgeInsets.symmetric(),
              child: TextField(
                key: ValueKey('student_marks_${student.id}'),
                enabled: !readOnly,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      hasMarks ? CustomAppColors.primaryBlue : Colors.black87,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor:
                      readOnly
                          ? Colors.grey.shade100
                          : (hasMarks
                              ? CustomAppColors.primaryBlue.withValues(
                                alpha: 0.05,
                              )
                              : Colors.grey.shade50),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: CustomAppColors.primaryBlue,
                      width: 2,
                    ),
                  ),
                  hintText: readOnly ? '-' : (marks?.toStringAsFixed(0) ?? '-'),
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                ),
                controller: TextEditingController.fromValue(
                  TextEditingValue(
                    text: marks?.toStringAsFixed(0) ?? '',
                    selection: TextSelection.collapsed(
                      offset: marks?.toStringAsFixed(0).length ?? 0,
                    ),
                  ),
                ),
                onChanged: (value) {
                  final marks = double.tryParse(value);
                  // Optional: Add validation against totalMarks
                  onMarksChanged(student.id, marks);
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

// Generic Selector Widget (Copied and adapted)
class _GenericSelector<T> extends StatelessWidget {
  const _GenericSelector({
    required this.label,
    required this.selectedValue,
    required this.items,
    required this.isLoading,
    required this.itemLabelBuilder,
    required this.onItemSelected,
    required this.placeholder,
    required this.iconData,
    this.isDisabled = false,
    this.compact = false,
  });

  final String label;
  final T? selectedValue;
  final List<T> items;
  final bool isLoading;
  final String Function(T) itemLabelBuilder;
  final ValueChanged<T> onItemSelected;
  final String placeholder;
  final IconData iconData;
  final bool isDisabled;
  final bool compact;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap:
        (isLoading || isDisabled) ? null : () => _showSelectionDialog(context),
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: (isDisabled || isLoading) ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            iconData,
            color: isDisabled ? Colors.grey : CustomAppColors.primaryBlue,
            size: compact ? 16 : 18,
          ),
          SizedBox(width: compact ? 6 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: compact ? 9 : 10,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (isLoading)
                  const SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    selectedValue != null
                        ? itemLabelBuilder(selectedValue as T)
                        : placeholder,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: compact ? 11 : 13,
                      color:
                          selectedValue == null || isDisabled
                              ? Colors.grey
                              : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_drop_down,
            color: Colors.grey,
            size: compact ? 16 : 18,
          ),
        ],
      ),
    ),
  );

  Future<void> _showSelectionDialog(BuildContext context) async {
    final selected = await CustomDialog.showSelection<T>(
      context: context,
      title: 'Select $label',
      subtitle: 'Choose a $label to view',
      items:
          items
              .map(
                (item) => SelectionItem(
                  value: item,
                  label: itemLabelBuilder(item),
                  icon: iconData,
                ),
              )
              .toList(),
      selectedValue: selectedValue,
    );

    if (context.mounted && selected != null) {
      onItemSelected(selected);
    }
  }
}

// Compact Date Picker (Copied and adapted)
