import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
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
      final teacherId = loginProvider.currentUser?.teacher?.id;
      // Create fresh state
      final provider = context.read<AttendanceProvider>();
      provider.reset();
      provider.setMode('marking'); // Set to marking mode for teachers
      await provider.loadInitialData(
        userUuid,
        teacherId: teacherId,
      );
      if (mounted) {
        _checkAutoSelections(context.read<AttendanceProvider>());
      }
    }
  }

  void _checkAutoSelections(AttendanceProvider provider) {
    if (!mounted) return;

    var stateChanged = false;

    // 1. Auto-select Course if only one available
    if (_selectedClassName == null && provider.availableCourses.length == 1) {
      _selectedClassName = provider.availableCourses.first.name;
      stateChanged = true;
    }

    // 2. Auto-select Section if course is selected and only one section available
    if (_selectedClassName != null && _selectedSectionName == null) {
      final selectedCourse = provider.availableCourses
          .firstWhere((c) => c.name == _selectedClassName, orElse: () => 
              CourseInfo(id: 0, name: '', code: '', totalStudents: 0, sections: []));
      
      if (selectedCourse.sections.length == 1) {
        _selectedSectionName = selectedCourse.sections.first.name;
        stateChanged = true;
      }
    }

    if (stateChanged) {
      setState(() {});
      _updateSelection(provider);
    }
  }

  void _updateSelection(AttendanceProvider provider) {
    // Step 1: Select course if class name is selected
    if (_selectedClassName != null) {
      final course = provider.availableCourses
          .firstWhere((c) => c.name == _selectedClassName, orElse: () => 
              CourseInfo(id: 0, name: '', code: '', totalStudents: 0, sections: []));
      
      if (course.id != 0 && provider.selectedCourse?.id != course.id) {
        provider.setSelectedCourse(course);
      }
    } else {
      if (provider.selectedCourse != null) {
        provider.setSelectedCourse(null);
      }
      return;
    }

    // Step 2: Select section if section name is selected
    if (_selectedSectionName != null) {
      if (provider.selectedSection != _selectedSectionName) {
        provider.setSelectedSection(_selectedSectionName);
      }
    } else {
      if (provider.selectedSection != null) {
        provider.setSelectedSection(null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final userInitials = UserUtils.getInitials(user?.name ?? 'Teacher');

    // Check loading state for initial courses load
    final isLoadingCourses =
        provider.isLoading && provider.availableCourses.isEmpty;

    // --- Derived Lists Logic ---

    // 1. Available Course Names
    final courseNames = provider.availableCourses.map((c) => c.name).toList()
      ..sort();

    // 2. Available Sections for Selected Course
    final sections = _selectedClassName != null
        ? provider.availableCourses
            .firstWhere((c) => c.name == _selectedClassName, orElse: () => 
                CourseInfo(id: 0, name: '', code: '', totalStudents: 0, sections: []))
            .sections
            .map((s) => s.name)
            .toList()
        : <String>[];

    return CustomMainScreenWithAppbar(
      title: 'Mark Attendance',
      appBarConfig: user?.teacher != null 
        ? AppBarConfig.teacher(
            userInitials: userInitials,
            userName: user?.name ?? 'Teacher',
            designation: user?.teacher?.designation ?? 'Faculty',
            employeeId: user?.teacher?.employeeId ?? 'N/A',
            onNotificationIconPressed: () {},
          )
        : AppBarConfig.admin(
            userInitials: userInitials,
            userName: user?.name ?? 'Admin',
            institutionName: user?.institution?.name ?? 'School',
            onNotificationIconPressed: () {},
          ),
      floatingActionButton:
          (provider.selectedCourse != null && !provider.isLoading)
              ? FloatingActionButton.extended(
                onPressed: () async {
                  final userUuid = user?.uuid;
                  final teacherId = user?.teacher?.id;

                  if (userUuid != null) {
                    // For teacher users, use their teacher ID
                    final success = await provider.saveAttendance(
                      userUuid,
                      teacherId ?? 0,
                      institutionType: user?.institution?.type,
                    );
                    if (context.mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Attendance saved successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(provider.error ?? 'Failed to save'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error: User information missing'),
                        backgroundColor: Colors.red,
                      ),
                    );
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

                // 2. Course/Class (Flex 3)
                Expanded(
                  flex: 3,
                  child: _GenericSelector<String>(
                    label: 'Class',
                    selectedValue: _selectedClassName,
                    items: courseNames,
                    isLoading: isLoadingCourses,
                    itemLabelBuilder: (s) => s,
                    onItemSelected: (val) {
                      setState(() {
                        _selectedClassName = val;
                        _selectedSectionName = null; // Reset section when class changes
                      });
                      _updateSelection(provider);
                    },
                    placeholder: 'Select Class',
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
                    isLoading: isLoadingCourses,
                    itemLabelBuilder: (s) => 'Sec $s',
                    onItemSelected: (val) {
                      setState(() {
                        _selectedSectionName = val;
                      });
                      _updateSelection(provider);
                    },
                    placeholder: _selectedClassName == null ? 'Select Class First' : 'All Sections',
                    iconData: Icons.view_module,
                    isDisabled: _selectedClassName == null,
                    compact: true,
                  ),
                ),
              ],
            ),
          ),

        // Summary & Bulk Actions
        if (provider.selectedCourse != null && provider.students.isNotEmpty)
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
                    : provider.selectedCourse == null
                    ? _buildEmptyState('Select a Class to mark attendance')
                    : provider.students.isEmpty
                    ? _buildEmptyState('No students found in this class')
                    : _StudentList(
                      students: provider.students,
                      onUpdateStatus: provider.updateStudentAttendance,
                    ),
          ),

          // Bottom padding for FAB
          const SizedBox(height: 80),

        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) => Center(
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
  Widget build(BuildContext context) => InkWell(
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

// Student List
class _StudentList extends StatelessWidget {
  const _StudentList({required this.students, required this.onUpdateStatus});

  final List<StudentAttendance> students;
  final Function(String, AttendanceStatus) onUpdateStatus;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: students.length,
    separatorBuilder: (_, _) => const SizedBox(height: 12),
    itemBuilder: (context, index) {
      final student = students[index];
      final isPresent = student.status == AttendanceStatus.present;
      final isLate = student.status == AttendanceStatus.late;
      final isAbsent = student.status == AttendanceStatus.absent;

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
            color:
                (isPresent || isLate)
                    ? Colors.transparent
                    : CustomAppColors.danger.withValues(alpha: 0.3),
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor:
                  (isPresent || isLate)
                      ? (isPresent
                              ? CustomAppColors.primaryBlue
                              : Colors.amber.shade700)
                          .withValues(alpha: 0.1)
                      : Colors.grey.shade100,
              radius: 22,
              child: Text(
                student.initials,
                style: TextStyle(
                  color:
                      (isPresent || isLate)
                          ? (isPresent
                              ? CustomAppColors.primaryBlue
                              : Colors.amber.shade700)
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
            // Status Buttons
            Row(
              children: [
                _StatusButton(
                  icon: Icons.check_circle,
                  color: CustomAppColors.success,
                  isSelected: isPresent,
                  onPressed:
                      () =>
                          onUpdateStatus(student.id, AttendanceStatus.present),
                ),
                const SizedBox(width: 8),
                _StatusButton(
                  icon: Icons.access_time_filled,
                  color: Colors.amber.shade700,
                  isSelected: isLate,
                  onPressed:
                      () => onUpdateStatus(student.id, AttendanceStatus.late),
                ),
                const SizedBox(width: 8),
                _StatusButton(
                  icon: Icons.cancel,
                  color: CustomAppColors.danger,
                  isSelected: isAbsent,
                  onPressed:
                      () => onUpdateStatus(student.id, AttendanceStatus.absent),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onPressed,
    borderRadius: BorderRadius.circular(12),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? color : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? color : color.withValues(alpha: 0.2),
        ),
      ),
      child: Icon(icon, color: isSelected ? Colors.white : color, size: 20),
    ),
  );
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
  Widget build(BuildContext context) => Container(
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
            const SizedBox(width: 8),
            _buildSummaryItem(
              'Late',
              summary.late.toString(),
              Colors.amber.shade700,
              Icons.access_time,
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
                    color: CustomAppColors.success.withValues(alpha: 0.5),
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
                  style: TextStyle(color: CustomAppColors.danger, fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: CustomAppColors.danger.withValues(alpha: 0.5),
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

  Widget _buildSummaryItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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
                  color: color.withValues(alpha: 0.8),
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
