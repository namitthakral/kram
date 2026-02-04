import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../provider/teachers_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_dialog.dart';
import '../../../widgets/custom_widgets/custom_form_dialog.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_tab_bar.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../../../widgets/custom_widgets/unified_loader.dart';
import '../models/template_models.dart';
import '../providers/attendance_provider.dart';
import '../providers/timetable_provider.dart';

enum TimetableTab { weeklySchedule, timeSlots }

class TimetableManagementScreen extends StatefulWidget {
  const TimetableManagementScreen({super.key});

  @override
  State<TimetableManagementScreen> createState() =>
      _TimetableManagementScreenState();
}

class _TimetableManagementScreenState extends State<TimetableManagementScreen> {
  // Current selected tab
  TimetableTab _selectedTab = TimetableTab.weeklySchedule;

  // Filter States
  String? _selectedClassName;
  String? _selectedSectionName;

  // Data State
  List<dynamic> timeSlots = [];
  bool isLoadingData = false;

  // Timetable Data: time slot index -> day -> subject period
  final Map<int, Map<String, SubjectPeriod?>> timetableData = {};

  // Track entry IDs for update/delete operations: "slotIndex_day" -> entryId
  final Map<String, int> entryIds = {};

  // Days of the week (API expects uppercase)
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  // Track which time slots are merged (lunch/break)
  final Map<int, String> mergedSlots = {};

  // Academic context (hardcoded for now - TODO: get from settings)
  final int _academicYearId = 1;
  final int _semesterId = 1;

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
    final institutionId = loginProvider.currentUser?.teacher?.institutionId;

    if (userUuid != null) {
      // Load available classes using AttendanceProvider as it already has the logic
      await context.read<AttendanceProvider>().loadInitialData(userUuid);
      if (mounted) {
        _checkAutoSelections(context.read<AttendanceProvider>());
      }
    }

    if (institutionId != null) {
      // Load time slots
      await context.read<TimetableProvider>().loadTimeSlots(
        institutionId: institutionId,
        isActive: true,
      );

      // Initialize timetable data structure
      if (mounted) {
        final provider = context.read<TimetableProvider>();
        if (provider.timeSlots != null) {
          setState(() {
            timeSlots = provider.timeSlots!;
            _initializeTimetableData();
          });
        }
      }
    }
  }

  void _initializeTimetableData() {
    timetableData.clear();
    mergedSlots.clear();
    entryIds.clear();

    for (var i = 0; i < timeSlots.length; i++) {
      final slot = timeSlots[i];
      final slotType = slot['slotType'] as String?;

      // Check if this is a merged slot (break/lunch)
      if (slotType == 'BREAK' || slotType == 'LUNCH') {
        mergedSlots[i] = (slot['slotName'] as String?) ?? slotType ?? 'Break';
      }

      timetableData[i] = {};
      for (final day in days) {
        timetableData[i]![day] = null;
      }
    }
  }

  void _checkAutoSelections(AttendanceProvider provider) {
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
  }

  Future<void> _updateSelection(AttendanceProvider provider) async {
    // If both class and section are selected, we can load the timetable
    if (_selectedClassName != null && _selectedSectionName != null) {
      // Find the matching class info to get courseId
      try {
        final match = provider.availableClasses.firstWhere(
          (c) =>
              c.className == _selectedClassName &&
              c.sectionName == _selectedSectionName,
        );

        final courseId = match.courseId;
        final section = match.sectionName;
        final institutionId =
            context.read<LoginProvider>().currentUser?.teacher?.institutionId;

        // Load Timetable Entries
        if (institutionId != null) {
          await context.read<TimetableProvider>().loadAllEntries(
            institutionId: institutionId,
            academicYearId: _academicYearId,
            semesterId: _semesterId,
            courseId: courseId,
            section: section,
          );

          // Parse loaded entries into timetableData
          if (mounted) {
            _parseLoadedEntries();
          }
        }
      } catch (e) {
        debugPrint('Error locating class info: $e');
      }
    }
  }

  /// Parse loaded timetable entries into the timetableData structure
  void _parseLoadedEntries() {
    final entries = context.read<TimetableProvider>().allEntries;
    debugPrint(
      '📋 Parsing timetable entries: ${entries?.length ?? 0} entries found',
    );

    if (entries == null || entries.isEmpty) {
      debugPrint('⚠️ No entries to parse');
      return;
    }

    for (final entry in entries) {
      try {
        // Handle nested timeSlot object
        final timeSlot = entry['timeSlot'] as Map<String, dynamic>?;
        final timeSlotId = timeSlot?['id'] as int?;

        final dayOfWeek = entry['dayOfWeek'] as String?;
        final entryId = entry['id'] as int?;

        debugPrint(
          'Processing entry: timeSlotId=$timeSlotId, day=$dayOfWeek, id=$entryId',
        );

        if (timeSlotId == null || dayOfWeek == null) {
          debugPrint('⚠️ Skipping entry - missing timeSlotId or dayOfWeek');
          continue;
        }

        // Find the slot index
        final slotIndex = timeSlots.indexWhere(
          (slot) => slot['id'] == timeSlotId,
        );
        if (slotIndex == -1) {
          debugPrint(
            '⚠️ Skipping entry - timeSlotId $timeSlotId not found in timeSlots',
          );
          continue;
        }

        // Convert day from API format (MONDAY) to UI format (Monday)
        final dayName = _convertDayFromApi(dayOfWeek);
        if (!days.contains(dayName)) {
          debugPrint('⚠️ Skipping entry - day $dayName not in days list');
          continue;
        }

        // Extract subject and teacher info
        final subject = entry['subject'] as Map<String, dynamic>?;
        final teacher = entry['teacher'] as Map<String, dynamic>?;
        final room = entry['room'] as Map<String, dynamic>?;

        // Note: API uses 'subjectName' not 'name' for subjects
        final subjectName =
            subject?['subjectName'] as String? ??
            subject?['name'] as String? ??
            'Unknown';
        final teacherName = teacher?['name'] as String?;
        final roomName = room?['roomName'] as String?;
        final subjectId = subject?['id'] as int?;
        final teacherId = teacher?['id'] as int?;
        final roomId = room?['id'] as int?;

        debugPrint(
          '✅ Adding entry: slot=$slotIndex, day=$dayName, subject=$subjectName, teacher=$teacherName',
        );

        // Create SubjectPeriod
        timetableData[slotIndex]![dayName] = SubjectPeriod(
          subject: subjectName,
          teacher: teacherName,
          room: roomName,
          subjectId: subjectId,
          teacherId: teacherId,
          roomId: roomId,
        );

        // Track entry ID for updates
        if (entryId != null) {
          entryIds['${slotIndex}_$dayName'] = entryId;
        }
      } catch (e) {
        debugPrint('❌ Error parsing entry: $e');
      }
    }

    debugPrint('✅ Parsing complete. Calling setState()');
    setState(() {});
  }

  /// Convert day from API format (MONDAY) to UI format (Monday)
  String _convertDayFromApi(String apiDay) {
    final normalized = apiDay.toLowerCase();
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();
    final timetableProvider = context.watch<TimetableProvider>();
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final userInitials = UserUtils.getInitials(user?.name ?? 'Teacher');

    final isLoadingClasses =
        attendanceProvider.isLoading &&
        attendanceProvider.availableClasses.isEmpty;

    // --- Derived Lists Logic ---
    final classNames =
        attendanceProvider.availableClasses
            .map((c) => c.className ?? 'Class')
            .toSet()
            .toList()
          ..sort();

    final sections =
        _selectedClassName == null
              ? <String>[]
              : attendanceProvider.availableClasses
                  .where((c) => (c.className ?? 'Class') == _selectedClassName)
                  .map((c) => c.sectionName)
                  .toSet()
                  .toList()
          ..sort();

    return CustomMainScreenWithAppbar(
      title: 'Timetable Management',
      appBarConfig: AppBarConfig.teacher(
        userInitials: userInitials,
        userName: user?.name ?? 'Teacher',
        designation: user?.teacher?.designation ?? 'Faculty',
        employeeId: user?.teacher?.employeeId ?? 'N/A',
        onNotificationIconPressed: () {},
      ),
      child: Column(
        children: [
          // Filter Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                // Class Selector
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
                        _updateSelection(attendanceProvider);
                        _checkAutoSelections(attendanceProvider);
                      });
                    },
                    placeholder: 'Class',
                    iconData: Icons.class_,
                    compact: true,
                  ),
                ),
                const SizedBox(width: 8),

                // Section Selector
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
                        _updateSelection(attendanceProvider);
                        _checkAutoSelections(attendanceProvider);
                      });
                    },
                    placeholder: 'Sec',
                    iconData: Icons.view_module,
                    isDisabled: _selectedClassName == null,
                    compact: true,
                  ),
                ),
              ],
            ),
          ),

          // Custom Tab Bar
          CustomTabBar<TimetableTab>(
            tabs: const [
              TabItem(
                value: TimetableTab.weeklySchedule,
                label: 'Weekly Schedule',
                icon: Icons.calendar_view_week,
              ),
              TabItem(
                value: TimetableTab.timeSlots,
                label: 'Time Slots',
                icon: Icons.schedule,
              ),
            ],
            selectedValue: _selectedTab,
            onTabSelected: (tab) {
              setState(() {
                _selectedTab = tab;
              });
            },
          ),

          // Tab Content
          Expanded(
            child:
                _selectedTab == TimetableTab.weeklySchedule
                    ? _buildWeeklyScheduleTab(timetableProvider)
                    : _buildTimeSlotsTab(timetableProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyScheduleTab(TimetableProvider provider) {
    if (_selectedClassName == null || _selectedSectionName == null) {
      return _buildEmptyState('Select Class and Section to view schedule');
    }

    if (provider.isLoadingTimetable) {
      return const UnifiedLoader();
    }

    if (timeSlots.isEmpty) {
      return _buildEmptyState(
        'No time slots available. Please add time slots first.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(child: _buildTimetableGrid()),
    );
  }

  Widget _buildTimetableGrid() => Table(
    border: TableBorder.all(color: Colors.grey.shade300),
    defaultColumnWidth: const FixedColumnWidth(140),
    children: [
      // Header row
      TableRow(
        decoration: const BoxDecoration(color: CustomAppColors.primaryBlue),
        children: [_buildHeaderCell('Time'), ...days.map(_buildHeaderCell)],
      ),
      // Time slot rows
      ...List.generate(timeSlots.length, (slotIndex) {
        // Check if this slot is merged (break/lunch)
        if (mergedSlots.containsKey(slotIndex)) {
          return TableRow(
            decoration: BoxDecoration(color: Colors.amber[50]),
            children: [
              _buildTimeCell(_formatTimeSlot(timeSlots[slotIndex])),
              // Create merged cell appearance by filling all day cells with same content
              ...List.generate(
                days.length,
                (dayIndex) => _buildMergedCell(
                  mergedSlots[slotIndex]!,
                  isFirst: dayIndex == 0,
                  isLast: dayIndex == days.length - 1,
                ),
              ),
            ],
          );
        }

        // Regular row with individual cells
        return TableRow(
          children: [
            _buildTimeCell(_formatTimeSlot(timeSlots[slotIndex])),
            ...days.map((day) => _buildPeriodCell(slotIndex, day)),
          ],
        );
      }),
    ],
  );

  Widget _buildMergedCell(
    String label, {
    required bool isFirst,
    required bool isLast,
  }) => Container(
    padding: const EdgeInsets.all(12),
    height: 60,
    decoration: BoxDecoration(
      border: Border(
        left:
            isFirst
                ? BorderSide.none
                : const BorderSide(color: Colors.transparent),
        right:
            isLast
                ? BorderSide.none
                : const BorderSide(color: Colors.transparent),
      ),
    ),
    child: Center(
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.orange,
          fontSize: 14,
        ),
      ),
    ),
  );

  Widget _buildHeaderCell(String text) => Container(
    padding: const EdgeInsets.all(12),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    ),
  );

  Widget _buildTimeCell(String time) => Container(
    padding: const EdgeInsets.all(12),
    color: Colors.grey.shade100,
    child: Text(
      time,
      textAlign: TextAlign.center,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
    ),
  );

  Widget _buildPeriodCell(int slotIndex, String day) {
    final period = timetableData[slotIndex]![day];

    return InkWell(
      onTap: () => _editPeriod(slotIndex, day),
      child: Container(
        padding: const EdgeInsets.all(8),
        height: 80,
        child:
            period != null
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      period.subject,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (period.teacher != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        period.teacher!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                )
                : Center(
                  child: Icon(Icons.add, color: Colors.grey[400], size: 20),
                ),
      ),
    );
  }

  String _formatTimeSlot(Map<String, dynamic> slot) {
    final startTime = _formatTime(slot['startTime']);
    final endTime = _formatTime(slot['endTime']);
    return '$startTime - $endTime';
  }

  Widget _buildTimeSlotsTab(TimetableProvider provider) {
    if (provider.isLoadingTimeSlots) {
      return const UnifiedLoader();
    }

    final slots = provider.timeSlots ?? [];

    if (slots.isEmpty) {
      return _buildEmptyState(
        'No time slots found',
        action: _buildAddTimeSlotButton(),
      );
    }

    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: slots.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final slot = slots[index];
            return _buildTimeSlotCard(slot);
          },
        ),
        Positioned(bottom: 16, right: 16, child: _buildAddTimeSlotButton()),
      ],
    );
  }

  Widget _buildTimeSlotCard(Map<String, dynamic> slot) {
    final startTime = _formatTime(slot['startTime']);
    final endTime = _formatTime(slot['endTime']);
    final isMerged = slot['slotType'] == 'BREAK' || slot['slotType'] == 'LUNCH';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          slot['slotName'] ?? 'Unnamed Slot',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$startTime - $endTime • ${isMerged ? 'Merged (${slot['slotType']})' : 'Lecture'}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
              onPressed: () => _showEditTimeSlotDialog(slot),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _confirmDeleteTimeSlot(slot),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTimeSlotButton() => FloatingActionButton(
      onPressed: _showAddTimeSlotDialog,
      backgroundColor: CustomAppColors.primaryBlue,
      child: const Icon(Icons.add, color: Colors.white),
    );

  String _formatTime(String? timeStr) {
    if (timeStr == null) return '--:--';
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
    } catch (e) {
      return timeStr;
    }
    return timeStr;
  }

  Widget _buildEmptyState(String message, {Widget? action}) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey.shade500)),
          if (action != null) ...[const SizedBox(height: 16), action],
        ],
      ),
    );

  // --- Period Save/Delete Methods ---

  /// Save or update a period entry to the backend
  Future<void> _savePeriodEntry(
    int slotIndex,
    String day,
    String subject,
    int? teacherId,
  ) async {
    try {
      final loginProvider = context.read<LoginProvider>();
      final attendanceProvider = context.read<AttendanceProvider>();
      final timetableProvider = context.read<TimetableProvider>();

      final institutionId = loginProvider.currentUser?.teacher?.institutionId;
      if (institutionId == null) {
        if (mounted) {
          showCustomSnackbar(
            message: 'Institution ID not found',
            type: SnackbarType.error,
          );
        }
        return;
      }

      // Get course info
      final match = attendanceProvider.availableClasses.firstWhere(
        (c) =>
            c.className == _selectedClassName &&
            c.sectionName == _selectedSectionName,
      );

      final courseId = match.courseId;
      final section = match.sectionName;

      // Get time slot ID
      final timeSlot = timeSlots[slotIndex];
      final timeSlotId = timeSlot['id'] as int?;

      if (timeSlotId == null) {
        if (mounted) {
          showCustomSnackbar(
            message: 'Time slot ID not found',
            type: SnackbarType.error,
          );
        }
        return;
      }

      // Check if we're updating or creating
      final entryKey = '${slotIndex}_$day';
      final existingEntryId = entryIds[entryKey];

      final entryData = {
        'institutionId': institutionId,
        'academicYearId': _academicYearId,
        'semesterId': _semesterId,
        'courseId': courseId,
        'section': section,
        'dayOfWeek': _convertDayToApi(day),
        'timeSlotId': timeSlotId,
        'subjectId': null, // TODO: Add subject selection with IDs
        'teacherId': teacherId,
        'roomId': null, // TODO: Add room selection
        'isActive': true,
      };

      bool success;
      if (existingEntryId != null) {
        // Update existing entry
        success = await timetableProvider.updateTimetableEntry(
          existingEntryId,
          entryData,
        );
      } else {
        // Create new entry
        final createdEntry = await timetableProvider.createTimetableEntry(
          entryData,
        );
        success = createdEntry != null;

        // Track the new entry ID from the response
        if (success) {
          final newEntryId = createdEntry['id'] as int?;
          if (newEntryId != null) {
            entryIds[entryKey] = newEntryId;
            debugPrint('Tracked new entry ID: $newEntryId for $entryKey');
          }
        }
      }

      if (mounted) {
        if (success) {
          showCustomSnackbar(
            message:
                existingEntryId != null ? 'Period updated' : 'Period saved',
            type: SnackbarType.success,
          );
        } else {
          showCustomSnackbar(
            message: timetableProvider.createError ?? 'Failed to save period',
            type: SnackbarType.error,
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving period: $e');
      if (mounted) {
        showCustomSnackbar(
          message: 'Error saving period: $e',
          type: SnackbarType.error,
        );
      }
    }
  }

  /// Delete a period entry from the backend
  Future<void> _deletePeriodEntry(int slotIndex, String day) async {
    try {
      final entryKey = '${slotIndex}_$day';
      final existingEntryId = entryIds[entryKey];

      if (existingEntryId == null) {
        // No entry to delete, just clear local state
        return;
      }

      final timetableProvider = context.read<TimetableProvider>();
      final success = await timetableProvider.deleteTimetableEntry(
        existingEntryId,
      );

      if (success) {
        // Remove from tracking
        entryIds.remove(entryKey);
        if (mounted) {
          showCustomSnackbar(
            message: 'Period cleared',
            type: SnackbarType.success,
          );
        }
      } else {
        if (mounted) {
          showCustomSnackbar(
            message: timetableProvider.createError ?? 'Failed to clear period',
            type: SnackbarType.error,
          );
        }
      }
    } catch (e) {
      debugPrint('Error deleting period: $e');
      if (mounted) {
        showCustomSnackbar(
          message: 'Error clearing period: $e',
          type: SnackbarType.error,
        );
      }
    }
  }

  /// Convert day from UI format (Monday) to API format (MONDAY)
  String _convertDayToApi(String uiDay) => uiDay.toUpperCase();

  // --- Period Editing Dialog ---

  Future<void> _editPeriod(int slotIndex, String day) async {
    final teachersProvider = context.read<TeachersProvider>();

    // Ensure teachers are loaded before opening dialog
    if (teachersProvider.teachers == null) {
      await teachersProvider.loadTeachers();
    }

    if (!mounted) return;

    final teachersList = teachersProvider.teachers ?? [];
    final currentPeriod = timetableData[slotIndex]![day];

    // Predefined subject list
    final predefinedSubjects = [
      'Mathematics',
      'Physics',
      'Chemistry',
      'Biology',
      'English',
      'History',
      'Geography',
      'Computer Science',
      'Physical Education',
      'Art',
      'Music',
    ];

    var selectedSubject = currentPeriod?.subject;
    if (selectedSubject != null &&
        !predefinedSubjects.contains(selectedSubject)) {
      selectedSubject = 'Custom';
    }

    final customSubjectController = TextEditingController(
      text:
          (currentPeriod?.subject != null &&
                  !predefinedSubjects.contains(currentPeriod!.subject))
              ? currentPeriod.subject
              : '',
    );

    var selectedTeacher = currentPeriod?.teacher;
    final customTeacherController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => CustomFormDialog(
                  title: 'Edit Period',
                  subtitle: '$day ${_formatTimeSlot(timeSlots[slotIndex])}',
                  headerIcon: Icons.schedule,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () async {
                              setState(() {
                                timetableData[slotIndex]![day] = null;
                              });
                              Navigator.pop(context);
                              // Delete from backend
                              await _deletePeriodEntry(slotIndex, day);
                            },
                            icon: const Icon(Icons.clear, size: 18),
                            label: const Text('Clear Period'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      FormDropdownField<String>(
                        label: 'Subject',
                        value: selectedSubject,
                        items: [
                          ...predefinedSubjects.map(
                            (subject) => DropdownMenuItem(
                              value: subject,
                              child: Text(subject),
                            ),
                          ),
                          const DropdownMenuItem(
                            value: 'Custom',
                            child: Text('Custom / Other'),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            selectedSubject = value;
                          });
                        },
                      ),
                      if (selectedSubject == 'Custom') ...[
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: customSubjectController,
                          label: 'Enter Custom Subject',
                          prefixButtonIcon: ButtonIcon(
                            icon: 'assets/images/icons/edit.svg',
                            color: AppTheme.slate500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      FormDropdownField<String>(
                        label: 'Teacher (Optional)',
                        key: ValueKey('teacher_$selectedTeacher'),
                        value:
                            teachersList.any(
                                  (t) => t['name'] == selectedTeacher,
                                )
                                ? selectedTeacher
                                : null,
                        hint: 'Select a teacher',
                        items: [
                          ...teachersList.map(
                            (teacher) => DropdownMenuItem(
                              value: teacher['name'] as String,
                              child: Text(teacher['name'] as String),
                            ),
                          ),
                          const DropdownMenuItem(
                            value: 'Custom',
                            child: Text('Other / Custom'),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            selectedTeacher = value;
                          });
                        },
                      ),
                      if (selectedTeacher == 'Custom') ...[
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: customTeacherController,
                          label: 'Enter Teacher Name',
                          prefixButtonIcon: ButtonIcon(
                            icon: 'assets/images/icons/person.svg',
                            color: AppTheme.slate500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  onConfirm: () async {
                    String? finalSubject;
                    if (selectedSubject == 'Custom') {
                      finalSubject = customSubjectController.text.trim();
                    } else {
                      finalSubject = selectedSubject;
                    }

                    String? finalTeacher;
                    if (selectedTeacher == 'Custom') {
                      finalTeacher =
                          customTeacherController.text.trim().isEmpty
                              ? null
                              : customTeacherController.text.trim();
                    } else {
                      finalTeacher = selectedTeacher;
                    }

                    if (finalSubject != null && finalSubject.isNotEmpty) {
                      // Find teacher ID from list
                      int? foundTeacherId;
                      if (finalTeacher != null) {
                        final teacherData = teachersList.firstWhere(
                          (t) => t['name'] == finalTeacher,
                          orElse: () => <String, dynamic>{},
                        );
                        foundTeacherId = teacherData['id'] as int?;
                      }

                      // Update local state first
                      setState(() {
                        timetableData[slotIndex]![day] = SubjectPeriod(
                          subject: finalSubject!,
                          teacher: finalTeacher,
                          teacherId: foundTeacherId,
                        );
                      });

                      // Close dialog
                      Navigator.pop(context);

                      // Save to backend
                      await _savePeriodEntry(
                        slotIndex,
                        day,
                        finalSubject,
                        foundTeacherId,
                      );
                    }
                  },
                ),
          ),
    );
  }

  // --- Dialogs ---

  Future<void> _showAddTimeSlotDialog() async {
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    var isMerged = false;
    final slotNameController = TextEditingController();
    final mergedLabelController = TextEditingController(text: 'Lunch');

    await showDialog<void>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => CustomFormDialog(
                  title: 'Add Time Slot',
                  subtitle: 'Define a new period for the timetable',
                  headerIcon: Icons.access_time,
                  confirmText: 'Add',
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(
                        controller: slotNameController,
                        label: 'Slot Name (e.g., Period 1)',
                        prefixButtonIcon: ButtonIcon(
                          icon: 'assets/images/icons/label.svg',
                          color: AppTheme.slate500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Start Time'),
                        subtitle: Text(
                          startTime != null
                              ? startTime!.format(context)
                              : 'Tap to select',
                        ),
                        leading: const Icon(Icons.access_time),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              startTime = picked;
                            });
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        title: const Text('End Time'),
                        subtitle: Text(
                          endTime != null
                              ? endTime!.format(context)
                              : 'Tap to select',
                        ),
                        leading: const Icon(Icons.access_time),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: startTime ?? TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              endTime = picked;
                            });
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      FormCheckboxField(
                        label: 'Break/Lunch Period',
                        subtitle:
                            'Merge cells across all days for break or lunch',
                        value: isMerged,
                        onChanged: (value) {
                          setDialogState(() {
                            isMerged = value ?? false;
                          });
                        },
                      ),
                      if (isMerged) ...[
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: mergedLabelController,
                          label: 'Label (e.g., Lunch, Break)',
                          prefixButtonIcon: ButtonIcon(
                            icon: 'assets/images/icons/label.svg',
                            color: AppTheme.slate500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  onConfirm: () async {
                    if (startTime != null && endTime != null) {
                      final slotName = slotNameController.text.trim();
                      if (slotName.isEmpty && !isMerged) {
                        showCustomSnackbar(
                          message: 'Please enter a slot name',
                          type: SnackbarType.warning,
                        );
                        return;
                      }

                      final loginProvider = context.read<LoginProvider>();
                      final institutionId =
                          loginProvider.currentUser?.teacher?.institutionId;

                      if (institutionId == null) {
                        showCustomSnackbar(
                          message: 'Institution information not found',
                          type: SnackbarType.warning,
                        );
                        return;
                      }

                      // Calculate duration in minutes
                      final startMinutes =
                          startTime!.hour * 60 + startTime!.minute;
                      final endMinutes = endTime!.hour * 60 + endTime!.minute;
                      final duration = endMinutes - startMinutes;

                      // Determine slot type
                      final slotType =
                          isMerged
                              ? (mergedLabelController.text
                                      .trim()
                                      .toLowerCase()
                                      .contains('lunch')
                                  ? 'LUNCH'
                                  : 'BREAK')
                              : 'LECTURE';

                      // Format time for database (HH:mm:ss)
                      final startTimeStr =
                          '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00';
                      final endTimeStr =
                          '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00';

                      final timeSlotData = {
                        'institutionId': institutionId,
                        'slotName':
                            isMerged
                                ? mergedLabelController.text.trim()
                                : slotName,
                        'startTime': startTimeStr,
                        'endTime': endTimeStr,
                        'slotType': slotType,
                        'duration': duration,
                        'isActive': true,
                      };

                      final success = await context
                          .read<TimetableProvider>()
                          .createTimeSlot(timeSlotData);

                      if (!mounted) return;

                      if (success) {
                        // Reload time slots
                        await context.read<TimetableProvider>().loadTimeSlots(
                          institutionId: institutionId,
                          isActive: true,
                        );
                        Navigator.pop(context);
                        showCustomSnackbar(
                          message: 'Time slot created successfully',
                          type: SnackbarType.success,
                        );
                      } else {
                        showCustomSnackbar(
                          message:
                              context.read<TimetableProvider>().createError ??
                              'Failed to create time slot',
                          type: SnackbarType.error,
                        );
                      }
                    }
                  },
                ),
          ),
    );
  }

  Future<void> _showEditTimeSlotDialog(Map<String, dynamic> slot) async {
    final startTimeStr = slot['startTime'] as String?;
    final endTimeStr = slot['endTime'] as String?;

    // Parse existing times from database format (HH:mm:ss)
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    if (startTimeStr != null) {
      try {
        final parts = startTimeStr.split(':');
        if (parts.length >= 2) {
          startTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      } catch (e) {
        debugPrint('Error parsing start time: $e');
      }
    }
    if (endTimeStr != null) {
      try {
        final parts = endTimeStr.split(':');
        if (parts.length >= 2) {
          endTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      } catch (e) {
        debugPrint('Error parsing end time: $e');
      }
    }

    var isMerged = slot['slotType'] == 'BREAK' || slot['slotType'] == 'LUNCH';
    final slotNameController = TextEditingController(
      text: slot['slotName'] ?? '',
    );
    final mergedLabelController = TextEditingController(
      text: isMerged ? (slot['slotName'] ?? 'Lunch') : 'Lunch',
    );

    await showDialog<void>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => CustomFormDialog(
                  title: 'Edit Time Slot',
                  subtitle: 'Modify the period timing',
                  headerIcon: Icons.edit,
                  confirmColor: AppTheme.blue500,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isMerged)
                        CustomTextField(
                          controller: slotNameController,
                          label: 'Slot Name',
                          prefixButtonIcon: ButtonIcon(
                            icon: 'assets/images/icons/label.svg',
                            color: AppTheme.slate500,
                          ),
                        ),
                      if (!isMerged) const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Start Time'),
                        subtitle: Text(
                          startTime != null
                              ? startTime!.format(context)
                              : 'Tap to select',
                        ),
                        leading: const Icon(Icons.access_time),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: startTime ?? TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              startTime = picked;
                            });
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        title: const Text('End Time'),
                        subtitle: Text(
                          endTime != null
                              ? endTime!.format(context)
                              : 'Tap to select',
                        ),
                        leading: const Icon(Icons.access_time),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: endTime ?? TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              endTime = picked;
                            });
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      FormCheckboxField(
                        label: 'Break/Lunch Period',
                        subtitle:
                            'Merge cells across all days for break or lunch',
                        value: isMerged,
                        onChanged: (value) {
                          setDialogState(() {
                            isMerged = value ?? false;
                          });
                        },
                      ),
                      if (isMerged) ...[
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: mergedLabelController,
                          label: 'Label (e.g., Lunch, Break)',
                          prefixButtonIcon: ButtonIcon(
                            icon: 'assets/images/icons/label.svg',
                            color: AppTheme.slate500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  onConfirm: () async {
                    if (startTime != null && endTime != null) {
                      // Format time for database (HH:mm:ss)
                      final startTimeStr =
                          '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00';
                      final endTimeStr =
                          '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00';

                      // Calculate duration
                      final startMinutes =
                          startTime!.hour * 60 + startTime!.minute;
                      final endMinutes = endTime!.hour * 60 + endTime!.minute;
                      final duration = endMinutes - startMinutes;

                      // Determine slot type
                      final slotType =
                          isMerged
                              ? (mergedLabelController.text
                                      .trim()
                                      .toLowerCase()
                                      .contains('lunch')
                                  ? 'LUNCH'
                                  : 'BREAK')
                              : 'LECTURE';

                      final updateData = {
                        'startTime': startTimeStr,
                        'endTime': endTimeStr,
                        'slotType': slotType,
                        'duration': duration,
                      };

                      if (isMerged) {
                        updateData['slotName'] =
                            mergedLabelController.text.trim().isEmpty
                                ? 'Lunch'
                                : mergedLabelController.text.trim();
                      } else {
                        updateData['slotName'] = slotNameController.text.trim();
                      }

                      final slotId = slot['id'] as int;
                      final success = await context
                          .read<TimetableProvider>()
                          .updateTimeSlot(slotId, updateData);

                      if (!mounted) return;

                      if (success) {
                        final institutionId =
                            context
                                .read<LoginProvider>()
                                .currentUser
                                ?.teacher
                                ?.institutionId;
                        if (institutionId != null) {
                          await context.read<TimetableProvider>().loadTimeSlots(
                            institutionId: institutionId,
                            isActive: true,
                          );
                        }
                        Navigator.pop(context);
                        showCustomSnackbar(
                          message: 'Time slot updated successfully',
                          type: SnackbarType.success,
                        );
                      } else {
                        showCustomSnackbar(
                          message:
                              context.read<TimetableProvider>().createError ??
                              'Failed to update time slot',
                          type: SnackbarType.error,
                        );
                      }
                    }
                  },
                ),
          ),
    );
  }

  Future<void> _confirmDeleteTimeSlot(Map<String, dynamic> slot) async {
    final slotName = slot['slotName'] as String? ?? 'this time slot';

    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'Remove Time Slot',
      message:
          'Are you sure you want to remove the time slot "$slotName"? All periods in this slot will be deleted.',
      confirmText: 'Remove',
      cancelText: 'Cancel',
      confirmColor: AppTheme.danger,
      icon: Icons.delete_outline,
      iconColor: AppTheme.danger,
    );

    if (confirmed == true) {
      final slotId = slot['id'] as int;
      final success = await context.read<TimetableProvider>().deleteTimeSlot(
        slotId,
      );

      if (!mounted) return;

      if (success) {
        final institutionId =
            context.read<LoginProvider>().currentUser?.teacher?.institutionId;
        if (institutionId != null) {
          await context.read<TimetableProvider>().loadTimeSlots(
            institutionId: institutionId,
            isActive: true,
          );
        }
        showCustomSnackbar(
          message: 'Time slot removed successfully',
          type: SnackbarType.success,
        );
      } else {
        showCustomSnackbar(
          message:
              context.read<TimetableProvider>().createError ??
              'Failed to remove time slot',
          type: SnackbarType.error,
        );
      }
    }
  }
}

// Reuse Generic Selector from AttendanceViewScreen (copy-pasted for independence or moved to shared widget)
// For now, I'll copy a simplified version or assume it's moved.
// Given the instruction to build a unified UI, I'll define it here locally if not available globally.

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
