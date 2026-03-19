import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/unified_loader.dart';
import '../../teacher/models/attendance_models.dart';
import '../../teacher/providers/attendance_provider.dart';

class AdminAttendanceViewScreen extends StatefulWidget {
  const AdminAttendanceViewScreen({super.key});

  @override
  State<AdminAttendanceViewScreen> createState() => _AdminAttendanceViewScreenState();
}

class _AdminAttendanceViewScreenState extends State<AdminAttendanceViewScreen> {
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
      // Create fresh state
      final provider = context.read<AttendanceProvider>();
      provider.reset();
      provider.setMode('viewing'); // Set to viewing mode for admins
      await provider.loadInitialData(
        userUuid,
        // Admin users don't need teacherId filtering
        teacherId: null,
      );
      if (mounted) {
        _checkAutoSelections(context.read<AttendanceProvider>());
      }
    }
  }

  void _checkAutoSelections(AttendanceProvider provider) {
    // Auto-select first course if only one available
    if (provider.availableCourses.length == 1 && _selectedClassName == null) {
      final course = provider.availableCourses.first;
      setState(() {
        _selectedClassName = course.name;
      });
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
    final userInitials = UserUtils.getInitials(user?.name ?? 'Admin');

    // 1. Available Course Names
    final courseNames = provider.availableCourses.map((c) => c.name).toList();
    final isLoadingCourses = provider.isLoading && provider.availableCourses.isEmpty;

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
      title: 'Attendance Overview',
      appBarConfig: AppBarConfig.admin(
        userInitials: userInitials,
        userName: user?.name ?? 'Admin',
        institutionName: user?.institution?.name ?? 'School',
        onNotificationIconPressed: () {},
      ),
      // No FAB needed for viewing mode
      child: Column(
        children: [
          // Filter Header (Date, Class, Section)
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

        // Attendance Summary (read-only)
        if (provider.selectedCourse != null && provider.attendanceRecords.isNotEmpty)
            _AttendanceSummaryDisplay(
              records: provider.attendanceRecords,
            ),

          // Main Content
          Expanded(
            child:
                provider.isLoading && provider.attendanceRecords.isEmpty
                    ? const UnifiedLoader()
                    : provider.selectedCourse == null
                    ? _buildEmptyState('Select a Class to view attendance')
                    : provider.attendanceRecords.isEmpty
                    ? _buildEmptyState('No attendance records found for this date')
                    : _AttendanceRecordsList(
                      records: provider.attendanceRecords,
                      showSectionInfo: provider.selectedSection == null,
                    ),
          ),
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

/// Compact Date Picker Widget
class _CompactDatePicker extends StatelessWidget {
  const _CompactDatePicker({
    required this.date,
    required this.onDateSelected,
    this.compact = false,
  });

  final DateTime date;
  final Function(DateTime) onDateSelected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 8 : 12,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: compact ? 16 : 20,
              color: Colors.grey.shade600,
            ),
            SizedBox(width: compact ? 6 : 8),
            Expanded(
              child: Text(
                DateFormat('MMM dd, yyyy').format(date),
                style: TextStyle(
                  fontSize: compact ? 12 : 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: CustomAppColors.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != date) {
      onDateSelected(picked);
    }
  }
}

/// Generic Selector Widget
class _GenericSelector<T> extends StatelessWidget {
  const _GenericSelector({
    required this.label,
    required this.selectedValue,
    required this.items,
    required this.itemLabelBuilder,
    required this.onItemSelected,
    required this.placeholder,
    required this.iconData,
    this.isLoading = false,
    this.isDisabled = false,
    this.compact = false,
  });

  final String label;
  final T? selectedValue;
  final List<T> items;
  final String Function(T) itemLabelBuilder;
  final Function(T?) onItemSelected;
  final String placeholder;
  final IconData iconData;
  final bool isLoading;
  final bool isDisabled;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
        ],
        InkWell(
          onTap: isDisabled || isLoading ? null : () => _showSelector(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 12,
              vertical: compact ? 8 : 12,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDisabled 
                    ? Colors.grey.shade300 
                    : Colors.grey.shade400,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isDisabled 
                  ? Colors.grey.shade100 
                  : Colors.white,
            ),
            child: Row(
              children: [
                Icon(
                  iconData,
                  size: compact ? 14 : 16,
                  color: isDisabled 
                      ? Colors.grey.shade400 
                      : Colors.grey.shade600,
                ),
                SizedBox(width: compact ? 4 : 6),
                Expanded(
                  child: isLoading
                      ? SizedBox(
                          height: compact ? 12 : 16,
                          width: compact ? 12 : 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.grey.shade400,
                            ),
                          ),
                        )
                      : Text(
                          selectedValue != null
                              ? itemLabelBuilder(selectedValue!)
                              : placeholder,
                          style: TextStyle(
                            fontSize: compact ? 11 : 13,
                            color: selectedValue != null
                                ? Colors.grey.shade800
                                : Colors.grey.shade500,
                            fontWeight: selectedValue != null
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: compact ? 16 : 20,
                  color: isDisabled 
                      ? Colors.grey.shade400 
                      : Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSelector(BuildContext context) {
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(iconData, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Select $label',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (selectedValue != null)
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onItemSelected(null);
                      },
                      child: const Text('Clear'),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Items
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'No ${label.toLowerCase()} available',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isSelected = item == selectedValue;
                        return ListTile(
                          leading: Icon(
                            isSelected ? Icons.check_circle : Icons.circle_outlined,
                            color: isSelected 
                                ? CustomAppColors.primaryBlue 
                                : Colors.grey.shade400,
                          ),
                          title: Text(
                            itemLabelBuilder(item),
                            style: TextStyle(
                              fontWeight: isSelected 
                                  ? FontWeight.w600 
                                  : FontWeight.normal,
                              color: isSelected 
                                  ? CustomAppColors.primaryBlue 
                                  : Colors.grey.shade800,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            onItemSelected(item);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget to display attendance records (read-only)
class _AttendanceRecordsList extends StatelessWidget {
  const _AttendanceRecordsList({
    required this.records,
    required this.showSectionInfo,
  });

  final List<AttendanceRecord> records;
  final bool showSectionInfo;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: records.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final record = records[index];
        return _AttendanceRecordCard(
          record: record,
          showSectionInfo: showSectionInfo,
        );
      },
    );
  }
}

/// Individual attendance record card
class _AttendanceRecordCard extends StatelessWidget {
  const _AttendanceRecordCard({
    required this.record,
    required this.showSectionInfo,
  });

  final AttendanceRecord record;
  final bool showSectionInfo;

  @override
  Widget build(BuildContext context) {
    final statusColor = Color(int.parse(record.statusColor.replaceFirst('#', '0xFF')));
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          
          // Student info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.studentName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (record.admissionNumber != null) ...[
                      Text(
                        'ID: ${record.admissionNumber}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (showSectionInfo) ...[
                      Text(
                        'Section ${record.sectionName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                if (record.remarks != null && record.remarks!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    record.remarks!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Status and time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  record.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              if (record.markedAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${record.markedAt!.hour.toString().padLeft(2, '0')}:${record.markedAt!.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Summary display for attendance records (read-only)
class _AttendanceSummaryDisplay extends StatelessWidget {
  const _AttendanceSummaryDisplay({
    required this.records,
  });

  final List<AttendanceRecord> records;

  @override
  Widget build(BuildContext context) {
    final present = records.where((r) => r.status.toUpperCase() == 'PRESENT').length;
    final absent = records.where((r) => r.status.toUpperCase() == 'ABSENT').length;
    final late = records.where((r) => r.status.toUpperCase() == 'LATE').length;
    final excused = records.where((r) => r.status.toUpperCase() == 'EXCUSED').length;
    final total = records.length;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            label: 'Total',
            value: total.toString(),
            color: Colors.grey.shade700,
          ),
          _SummaryItem(
            label: 'Present',
            value: present.toString(),
            color: const Color(0xFF22c55e),
          ),
          _SummaryItem(
            label: 'Absent',
            value: absent.toString(),
            color: const Color(0xFFef4444),
          ),
          if (late > 0)
            _SummaryItem(
              label: 'Late',
              value: late.toString(),
              color: const Color(0xFFf59e0b),
            ),
          if (excused > 0)
            _SummaryItem(
              label: 'Excused',
              value: excused.toString(),
              color: const Color(0xFF3b82f6),
            ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}