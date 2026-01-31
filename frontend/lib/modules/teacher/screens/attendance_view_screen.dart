import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_dialog.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/unified_loader.dart';
import '../models/attendance_models.dart';
import '../providers/attendance_provider.dart';

class AttendanceViewScreen extends StatefulWidget {
  const AttendanceViewScreen({super.key});

  @override
  State<AttendanceViewScreen> createState() => _AttendanceViewScreenState();
}

class _AttendanceViewScreenState extends State<AttendanceViewScreen> {
  // Filter States
  String? _selectedClassName;
  String? _selectedSectionName;
  String? _selectedSubjectName;

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
    if (userUuid != null) {
      // Create fresh state
      context.read<AttendanceProvider>().reset();
      await context.read<AttendanceProvider>().loadInitialData(userUuid);
      if (mounted) {
        _checkAutoSelections(context.read<AttendanceProvider>());
      }
    }
  }

  void _checkAutoSelections(AttendanceProvider provider) {
    if (!mounted) return;

    final classNames = provider.availableClasses
        .map((c) => c.className ?? 'Class')
        .toSet()
        .toList()
      ..sort();

    bool stateChanged = false;

    // 1. Auto-select Class
    if (_selectedClassName == null && classNames.length == 1) {
      _selectedClassName = classNames.first;
      stateChanged = true;
    }

    // 2. Auto-select Section
    final sections = _selectedClassName == null
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

    // 3. Auto-select Subject
    final subjects = (_selectedClassName == null || _selectedSectionName == null)
        ? <String>[]
        : provider.availableClasses
            .where((c) =>
                (c.className ?? 'Class') == _selectedClassName &&
                c.sectionName == _selectedSectionName)
            .map((c) => c.subjectName ?? 'Unknown Subject')
            .toSet()
            .toList()
          ..sort();

    if (_selectedClassName != null &&
        _selectedSectionName != null &&
        _selectedSubjectName == null &&
        subjects.length == 1) {
      _selectedSubjectName = subjects.first;
      stateChanged = true;
    } else if (_selectedSubjectName != null &&
        !subjects.contains(_selectedSubjectName)) {
      _selectedSubjectName = null;
      stateChanged = true;
    }

    if (stateChanged) {
      setState(() {});
      _updateSelection(provider);
    }
  }

  void _updateSelection(AttendanceProvider provider) {
    // If all three filters are selected, try to find the matching class
    if (_selectedClassName != null &&
        _selectedSectionName != null &&
        _selectedSubjectName != null) {
      try {
        final match = provider.availableClasses.firstWhere(
          (c) =>
              c.className == _selectedClassName &&
              c.sectionName == _selectedSectionName &&
              c.subjectName == _selectedSubjectName,
        );
        if (provider.selectedClass != match) {
          provider.setSelectedClass(match);
        }
      } catch (e) {
        // No match found
        if (provider.selectedClass != null) {
          provider.setSelectedClass(null);
        }
      }
    } else {
      if (provider.selectedClass != null) {
        provider.setSelectedClass(null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
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
          ..sort(); // Optional: Sort alphabetically


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

    // 3. Subjects (Filtered by Class AND Section)
    final subjects =
        (_selectedClassName == null || _selectedSectionName == null)
              ? <String>[]
              : provider.availableClasses
                  .where(
                    (c) =>
                        (c.className ?? 'Class') == _selectedClassName &&
                        c.sectionName == _selectedSectionName,
                  )
                  .map((c) => c.subjectName ?? 'Unknown Subject')
                  .toSet()
                  .toList()
          ..sort();

    return CustomMainScreenWithAppbar(
      title: 'Attendance',
      appBarConfig: AppBarConfig.teacher(
        userInitials: userInitials,
        userName: user?.name ?? 'Teacher',
        designation: user?.teacher?.designation ?? 'Faculty',
        employeeId: user?.teacher?.employeeId ?? 'N/A',
        onNotificationIconPressed: () {},
      ),
      floatingActionButton:
          (provider.selectedClass != null && !provider.isLoading)
              ? FloatingActionButton.extended(
                onPressed: () async {
                  final teacherUuid = user?.uuid;
                  final teacherId = user?.teacher?.id;

                  if (teacherUuid != null && teacherId != null) {
                    final success = await provider.saveAttendance(
                      teacherUuid,
                      teacherId,
                    );
                    if (context.mounted) {
                      if (success) {
                        showCustomSnackbar(
                          message: 'Attendance saved successfully',
                          type: SnackbarType.success,
                        );
                      } else {
                        showCustomSnackbar(
                          message: provider.error ?? 'Failed to save',
                          type: SnackbarType.error,
                        );
                      }
                    }
                  }
                },
                backgroundColor: CustomAppColors.primaryBlue,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'Save Attendance',
                  style: TextStyle(color: Colors.white),
                ),
              )
              : null,
      child: Column(
        children: [
          // Filter Header (Date, Class, Section, Subject)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                // 1. Date (Flex 1)
                Expanded(
                  flex: 3,
                  child: _CompactDatePicker(
                    date: provider.selectedDate,
                    onDateSelected: provider.setSelectedDate,
                    compact: true,
                  ),
                ),
                const SizedBox(width: 8),

                // 2. Class (Flex 2)
                Expanded(
                  flex: 2,
                  child: _GenericSelector<String>(
                    label: 'Class',
                    selectedValue: _selectedClassName,
                    items: classNames,
                    isLoading: isLoadingClasses,
                    itemLabelBuilder: (s) => 'Class $s', // Add prefix
                    onItemSelected: (val) {
                      setState(() {
                        _selectedClassName = val;
                        _selectedSectionName = null;
                        _selectedSubjectName = null;
                        // Reset provider
                        _updateSelection(provider);
                        _checkAutoSelections(provider);
                      });
                    },
                    placeholder: 'Class',
                    iconData: Icons.class_,
                    compact: true,
                  ),
                ),
                const SizedBox(width: 8),

                // 3. Section (Flex 2)
                Expanded(
                  flex: 2,
                  child: _GenericSelector<String>(
                    label: 'Section',
                    selectedValue: _selectedSectionName,
                    items: sections,
                    isLoading: isLoadingClasses,
                    itemLabelBuilder: (s) => 'Sec $s', // Add prefix
                    onItemSelected: (val) {
                      setState(() {
                        _selectedSectionName = val;
                        _selectedSubjectName = null;
                        _updateSelection(provider);
                        _checkAutoSelections(provider);
                      });
                    },
                    placeholder: 'Sec',
                    iconData: Icons.view_module,
                    isDisabled: _selectedClassName == null,
                    compact: true,
                  ),
                ),
                const SizedBox(width: 8),

                // 4. Subject (Flex 3)
                Expanded(
                  flex: 3,
                  child: _GenericSelector<String>(
                    label: 'Subject',
                    selectedValue: _selectedSubjectName,
                    items: subjects,
                    isLoading: isLoadingClasses,
                    itemLabelBuilder: (s) => s,
                    onItemSelected: (val) {
                      setState(() {
                        _selectedSubjectName = val;
                        _updateSelection(provider);
                        _checkAutoSelections(provider);
                      });
                    },
                    placeholder: 'Subject',
                    iconData: Icons.book,
                    isDisabled: _selectedSectionName == null,
                    compact: true,
                  ),
                ),
              ],
            ),
          ),

          // Summary & Bulk Actions
          if (provider.selectedClass != null && provider.students.isNotEmpty)
            _AttendanceSummaryBar(
              summary: provider.summary,
              onMarkAllPresent: provider.markAllPresent,
              onMarkAllAbsent: provider.markAllAbsent,
            ),

          // Main Content
          Expanded(
            child:
                provider.isLoading && provider.students.isEmpty
                    ? const UnifiedLoader()
                    : provider.selectedClass == null
                    ? _buildEmptyState('Select a Subject and Section to view')
                    : provider.students.isEmpty
                    ? _buildEmptyState('No students found in this class')
                    : _StudentList(
                      students: provider.students,
                      onToggle: provider.toggleStudentAttendance,
                    ),
          ),

          // Bottom padding for FAB
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

// Generic Selector Widget
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
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          (isLoading || isDisabled)
              ? null
              : () => _showSelectionDialog(context),
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
              color: (isDisabled) ? Colors.grey : CustomAppColors.primaryBlue,
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
  }

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

// Compact Date Picker (Reused)
class _CompactDatePicker extends StatelessWidget {
  const _CompactDatePicker({
    required this.date,
    required this.onDateSelected,
    this.compact = false,
  });

  final DateTime date;
  final ValueChanged<DateTime> onDateSelected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (context.mounted && selected != null) {
          onDateSelected(selected);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month,
              color: CustomAppColors.primaryBlue,
              size: compact ? 16 : 18,
            ),
            SizedBox(width: compact ? 6 : 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Date',
                    style: TextStyle(
                      fontSize: compact ? 9 : 10,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(date),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: compact ? 11 : 13,
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
  }
}

// Student List
class _StudentList extends StatelessWidget {
  const _StudentList({required this.students, required this.onToggle});

  final List<StudentAttendance> students;
  final Function(String) onToggle;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final student = students[index];
        final isPresent = student.status == AttendanceStatus.present;

        return InkWell(
          onTap: () => onToggle(student.id),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color:
                    isPresent
                        ? Colors.transparent
                        : CustomAppColors.danger.withOpacity(0.3),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  backgroundColor:
                      isPresent
                          ? CustomAppColors.primaryBlue.withOpacity(0.1)
                          : Colors.grey.shade100,
                  radius: 22,
                  child: Text(
                    student.initials,
                    style: TextStyle(
                      color:
                          isPresent
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
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Toggle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isPresent
                            ? CustomAppColors.success
                            : CustomAppColors.danger,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: (isPresent
                                ? CustomAppColors.success
                                : CustomAppColors.danger)
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPresent ? Icons.check_circle : Icons.cancel,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isPresent ? 'Present' : 'Absent',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Attendance Summary Bar
class _AttendanceSummaryBar extends StatelessWidget {
  const _AttendanceSummaryBar({
    required this.summary,
    required this.onMarkAllPresent,
    required this.onMarkAllAbsent,
  });

  final AttendanceSummary summary;
  final VoidCallback onMarkAllPresent;
  final VoidCallback onMarkAllAbsent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              _buildSummaryItem(
                'Total',
                summary.totalStudents.toString(),
                Colors.black87,
                Icons.people_outline,
              ),
              const SizedBox(width: 8),
              _buildSummaryItem(
                'Present',
                summary.present.toString(),
                CustomAppColors.success,
                Icons.check_circle_outline,
              ),
              const SizedBox(width: 8),
              _buildSummaryItem(
                'Absent',
                summary.absent.toString(),
                CustomAppColors.danger,
                Icons.cancel_outlined,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onMarkAllPresent,
                  icon: const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: CustomAppColors.success,
                  ),
                  label: const Text(
                    'Mark All Present',
                    style: TextStyle(
                      color: CustomAppColors.success,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: CustomAppColors.success.withOpacity(0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onMarkAllAbsent,
                  icon: const Icon(
                    Icons.cancel,
                    size: 16,
                    color: CustomAppColors.danger,
                  ),
                  label: const Text(
                    'Mark All Absent',
                    style: TextStyle(
                      color: CustomAppColors.danger,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: CustomAppColors.danger.withOpacity(0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
