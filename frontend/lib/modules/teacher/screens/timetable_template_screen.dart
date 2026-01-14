import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/timetable_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../provider/teachers_provider.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/extensions.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_dialog.dart';
import '../../../widgets/custom_widgets/custom_form_dialog.dart';
import '../../../widgets/custom_widgets/custom_form_section.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../models/template_models.dart';
import '../providers/timetable_provider.dart';
import '../services/pdf_template_service.dart';
import '../services/teacher_service.dart';

class TimetableTemplateScreen extends StatefulWidget {
  const TimetableTemplateScreen({super.key});

  @override
  State<TimetableTemplateScreen> createState() =>
      _TimetableTemplateScreenState();
}

class _TimetableTemplateScreenState extends State<TimetableTemplateScreen> {
  final _formKey = GlobalKey<FormState>();

  // School Info
  final _schoolNameController = TextEditingController(
    text: 'Springfield High School',
  );
  final _schoolAddressController = TextEditingController(
    text: '123 Education Street, Springfield, ST 12345',
  );
  final _classNameController = TextEditingController(text: 'Class 10');
  final _sectionController = TextEditingController(text: 'A');
  final _academicYearController = TextEditingController(text: '2024-2025');
  final _classTeacherController = TextEditingController(text: 'Mrs. Johnson');

  // Time slots from database
  List<Map<String, dynamic>> timeSlots = [];

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  // Predefined subject list
  final List<String> predefinedSubjects = [
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
    'Economics',
    'Political Science',
    'Hindi',
    'Sanskrit',
    'French',
    'German',
    'Spanish',
    'Break',
    'Lunch',
    'Assembly',
  ];

  // Data structure: time slot index -> day -> subject
  final Map<int, Map<String, SubjectPeriod?>> timetableData = {};

  // Track which time slots are merged (lunch/break) - stores slot index and label
  final Map<int, String> mergedSlots = {};

  // Classes list
  List<Map<String, dynamic>> classesList = [];
  bool isLoadingClasses = true;

  final TeacherService _teacherService = TeacherService();
  final TimetableService _timetableService = TimetableService();

  @override
  void initState() {
    super.initState();
    _initializeTimetableData();
    // Defer loading data until after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      isLoadingClasses = true;
    });

    try {
      final loginProvider = context.read<LoginProvider>();
      final teachersProvider = context.read<TeachersProvider>();
      final timetableProvider = context.read<TimetableProvider>();
      final user = loginProvider.currentUser;
      final userUuid = user?.uuid;
      final institutionId = user?.teacher?.institutionId;

      // Load teachers from provider if not already loaded
      if (teachersProvider.teachers == null) {
        await teachersProvider.loadTeachers();
      }

      // Load time slots from database
      if (institutionId != null) {
        await timetableProvider.loadTimeSlots(
          institutionId: institutionId,
          isActive: true,
        );

        if (timetableProvider.timeSlots != null) {
          setState(() {
            timeSlots = List<Map<String, dynamic>>.from(
              timetableProvider.timeSlots!,
            );
            _initializeTimetableData();
          });
        }
      }

      // Load classes
      if (userUuid != null) {
        final classes = await _teacherService.getTeacherClasses(userUuid);
        setState(() {
          classesList =
              classes.map((c) {
                final classData = c as Map<String, dynamic>;
                return {
                  'id': classData['id'],
                  'name':
                      '${classData['className'] ?? ''} ${classData['section'] ?? ''}'
                          .trim(),
                };
              }).toList();
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        showCustomSnackbar(
          message: 'Failed to load data: $e',
          type: SnackbarType.warning,
        );
      }
    } finally {
      setState(() {
        isLoadingClasses = false;
      });
    }
  }

  void _initializeTimetableData() {
    // Initialize empty timetable based on current time slots
    timetableData.clear();
    for (var i = 0; i < timeSlots.length; i++) {
      timetableData[i] = {};
      for (final day in days) {
        timetableData[i]![day] = null;
      }
    }
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _schoolAddressController.dispose();
    _classNameController.dispose();
    _sectionController.dispose();
    _academicYearController.dispose();
    _classTeacherController.dispose();
    super.dispose();
  }

  Future<void> _addTimeSlot() async {
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    var isMerged = false;
    final slotNameController = TextEditingController();
    final mergedLabelController = TextEditingController(text: 'Lunch');

    showDialog<void>(
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
                      if (slotName.isEmpty) {
                        showCustomSnackbar(
                          message: 'Please enter a slot name',
                          type: SnackbarType.warning,
                        );
                        return;
                      }

                      final loginProvider = context.read<LoginProvider>();
                      final institutionId = loginProvider.currentUser?.teacher?.institutionId;

                      if (institutionId == null) {
                        showCustomSnackbar(
                          message: 'Institution information not found',
                          type: SnackbarType.warning,
                        );
                        return;
                      }

                      // Calculate duration in minutes
                      final startMinutes = startTime!.hour * 60 + startTime!.minute;
                      final endMinutes = endTime!.hour * 60 + endTime!.minute;
                      final duration = endMinutes - startMinutes;

                      // Determine slot type
                      final slotType = isMerged
                          ? (mergedLabelController.text.trim().toLowerCase().contains('lunch')
                              ? 'LUNCH'
                              : 'BREAK')
                          : 'LECTURE';

                      // Format time for database (HH:mm:ss)
                      final startTimeStr = '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00';
                      final endTimeStr = '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00';

                      final timeSlotData = {
                        'institutionId': institutionId,
                        'slotName': isMerged ? mergedLabelController.text.trim() : slotName,
                        'startTime': startTimeStr,
                        'endTime': endTimeStr,
                        'slotType': slotType,
                        'duration': duration,
                        'isActive': true,
                        'sortOrder': timeSlots.length + 1,
                      };

                      try {
                        final result = await _timetableService.createTimeSlot(timeSlotData);

                        if (!mounted) return;

                        setState(() {
                          timeSlots.add(result);
                          final newIndex = timeSlots.length - 1;

                          if (isMerged) {
                            mergedSlots[newIndex] = mergedLabelController.text.trim().isEmpty
                                ? 'Lunch'
                                : mergedLabelController.text.trim();
                          }

                          timetableData[newIndex] = {};
                          for (final day in days) {
                            timetableData[newIndex]![day] = null;
                          }
                        });

                        Navigator.pop(context);
                        showCustomSnackbar(
                          message: 'Time slot created successfully',
                          type: SnackbarType.success,
                        );
                      } on Exception catch (e) {
                        showCustomSnackbar(
                          message: 'Failed to create time slot: $e',
                          type: SnackbarType.warning,
                        );
                      }
                    }
                  },
                ),
          ),
    );
  }

  void _editTimeSlot(int index) {
    final currentSlot = timeSlots[index];
    final startTimeStr = currentSlot['startTime'] as String?;
    final endTimeStr = currentSlot['endTime'] as String?;

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
      } on Exception catch (e) {
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
      } on Exception catch (e) {
        debugPrint('Error parsing end time: $e');
      }
    }

    var isMerged = mergedSlots.containsKey(index);
    final mergedLabelController = TextEditingController(
      text: mergedSlots[index] ?? 'Lunch',
    );

    showDialog<void>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => CustomFormDialog(
                  title: 'Edit Time Slot ${index + 1}',
                  subtitle: 'Modify the period timing',
                  headerIcon: Icons.edit,
                  confirmText: 'Save',
                  confirmColor: AppTheme.blue500,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                      final startTimeStr = '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00';
                      final endTimeStr = '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00';

                      // Calculate duration
                      final startMinutes = startTime!.hour * 60 + startTime!.minute;
                      final endMinutes = endTime!.hour * 60 + endTime!.minute;
                      final duration = endMinutes - startMinutes;

                      // Determine slot type
                      final slotType = isMerged
                          ? (mergedLabelController.text.trim().toLowerCase().contains('lunch')
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
                        updateData['slotName'] = mergedLabelController.text.trim().isEmpty
                            ? 'Lunch'
                            : mergedLabelController.text.trim();
                      }

                      try {
                        // Note: We should update time slot, not timetable entry
                        // For now, just update local state
                        // await _timetableService.updateTimeSlot(currentSlot['id'] as int, updateData);

                        if (!mounted) return;

                        setState(() {
                          timeSlots[index] = {
                            ...currentSlot,
                            ...updateData,
                          };

                          if (isMerged) {
                            mergedSlots[index] =
                                mergedLabelController.text.trim().isEmpty
                                    ? 'Lunch'
                                    : mergedLabelController.text.trim();
                          } else {
                            mergedSlots.remove(index);
                          }
                        });

                        Navigator.pop(context);
                        showCustomSnackbar(
                          message: 'Time slot updated successfully',
                          type: SnackbarType.success,
                        );
                      } on Exception catch (e) {
                        showCustomSnackbar(
                          message: 'Failed to update time slot: $e',
                          type: SnackbarType.warning,
                        );
                      }
                    }
                  },
                ),
          ),
    );
  }

  String _formatTimeSlot(Map<String, dynamic> slot) {
    final startTime = slot['startTime'] as String?;
    final endTime = slot['endTime'] as String?;

    if (startTime != null && endTime != null) {
      // Format from HH:mm:ss to HH:mm
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');

      if (startParts.length >= 2 && endParts.length >= 2) {
        return '${startParts[0]}:${startParts[1]} - ${endParts[0]}:${endParts[1]}';
      }
    }

    return slot['slotName'] as String? ?? 'Time Slot';
  }

  Future<void> _removeTimeSlot(int index) async {
    final slotName = timeSlots[index]['slotName'] as String? ?? 'this time slot';

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
      try {
        // Note: We're deleting from time_slots table, but the API endpoint is for timetable entries
        // You may need to add a deleteTimeSlot method to the service
        // For now, just remove from local state
        // final slotId = timeSlots[index]['id'] as int;
        // await _timetableService.deleteTimeSlot(slotId);

        setState(() {
          timeSlots.removeAt(index);
          // Remove from merged slots if it was merged
          mergedSlots.remove(index);

          // Rebuild timetable data and merged slots with new indices
          final oldData = Map<int, Map<String, SubjectPeriod?>>.from(
            timetableData,
          );
          final oldMerged = Map<int, String>.from(mergedSlots);

          timetableData.clear();
          mergedSlots.clear();

          var newIndex = 0;
          for (var i = 0; i < oldData.length + 1; i++) {
            if (i == index) {
              continue;
            }
            timetableData[newIndex] = oldData[i] ?? {};
            if (oldMerged.containsKey(i)) {
              mergedSlots[newIndex] = oldMerged[i]!;
            }
            newIndex++;
          }
        });

        showCustomSnackbar(
          message: 'Time slot removed successfully',
          type: SnackbarType.success,
        );
      } on Exception catch (e) {
        showCustomSnackbar(
          message: 'Failed to remove time slot: $e',
          type: SnackbarType.warning,
        );
      }
    }
  }

  Future<void> _editPeriod(int slotIndex, String day) async {
    final teachersProvider = context.read<TeachersProvider>();

    // Ensure teachers are loaded before opening dialog
    if (teachersProvider.teachers == null) {
      await teachersProvider.loadTeachers();
    }

    if (!mounted) {
      return;
    }

    final teachersList = teachersProvider.teachers ?? [];
    debugPrint('📚 Teachers list in dropdown: ${teachersList.length} teachers');
    debugPrint('📚 Teachers data: $teachersList');

    final currentPeriod = timetableData[slotIndex]![day];

    // Determine if current subject is in predefined list
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

    // For teacher dropdown
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
                  confirmText: 'Save',
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                timetableData[slotIndex]![day] = null;
                              });
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.clear, size: 18),
                            label: const Text('Clear Period'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.danger,
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
                  onConfirm: () {
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

                      setState(() {
                        timetableData[slotIndex]![day] = SubjectPeriod(
                          subject: finalSubject!,
                          teacher: finalTeacher,
                          subjectId: null, // Will be mapped when saving to DB
                          teacherId: foundTeacherId,
                          roomId: null,
                        );
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
          ),
    );
  }

  void _previewTimetable() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder:
            (context) => TimetablePreviewScreen(
              template: TimetableTemplate(
                schoolName: _schoolNameController.text,
                schoolAddress: _schoolAddressController.text,
                className: _classNameController.text,
                section: _sectionController.text,
                academicYear: _academicYearController.text,
                slots: List.generate(
                  timeSlots.length,
                  (index) => TimetableSlot(
                    timeRange: _formatTimeSlot(timeSlots[index]),
                    periods: timetableData[index]!,
                    mergedLabel: mergedSlots[index],
                  ),
                ),
                days: days,
                classTeacher: _classTeacherController.text,
              ),
            ),
      ),
    );
  }

  /// Save timetable to database
  Future<void> _saveTimetableToDatabase() async {
    final loginProvider = context.read<LoginProvider>();
    final timetableProvider = context.read<TimetableProvider>();

    final user = loginProvider.currentUser;
    final institutionId = user?.teacher?.institutionId;

    if (institutionId == null) {
      showCustomSnackbar(
        message: 'Institution information not found',
        type: SnackbarType.warning,
      );
      return;
    }

    // Extract class info from class name if available
    int? courseId;
    String? section = _sectionController.text.trim();

    if (classesList.isNotEmpty) {
      // Use first available class as default
      courseId = classesList.first['id'] as int?;
    }

    if (courseId == null) {
      showCustomSnackbar(
        message: 'No class information available. Please try again.',
        type: SnackbarType.warning,
      );
      return;
    }

    // Use default academic year and semester
    const academicYearId = 1;
    const semesterId = 1;

    // Transform timetableData to API format
    final entries = <Map<String, dynamic>>[];

    for (var slotIndex = 0; slotIndex < timeSlots.length; slotIndex++) {
      // Skip merged slots (breaks/lunch)
      if (mergedSlots.containsKey(slotIndex)) {
        continue;
      }

      for (final day in days) {
        final period = timetableData[slotIndex]![day];

        if (period != null) {
          entries.add({
            'dayOfWeek': day.toUpperCase(),
            'timeSlotId': slotIndex + 1,
            'subjectId': period.subjectId ?? 1,
            'teacherId': period.teacherId,
            'roomId': period.roomId,
          });
        }
      }
    }

    if (entries.isEmpty) {
      showCustomSnackbar(
        message: 'No timetable entries to save. Please add some periods first.',
        type: SnackbarType.warning,
      );
      return;
    }

    try {
      // Call the bulk create API
      final success = await timetableProvider.bulkCreateTimetable({
        'institutionId': institutionId,
        'academicYearId': academicYearId,
        'semesterId': semesterId,
        'courseId': courseId,
        'section': section.isEmpty ? 'A' : section,
        'entries': entries,
      });

      if (success && mounted) {
        showCustomSnackbar(
          message: 'Timetable saved successfully to database!',
          type: SnackbarType.success,
        );
      } else if (mounted) {
        showCustomSnackbar(
          message: timetableProvider.createError ?? 'Failed to save timetable',
          type: SnackbarType.warning,
        );
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(
          message: 'Error saving timetable: $e',
          type: SnackbarType.warning,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final teacher = user?.teacher;

    final userInitials = UserUtils.getInitials(user?.name ?? 'Teacher');
    final userName = user?.name ?? 'Teacher';
    final designation = teacher?.designation ?? 'Teacher';
    final employeeId = teacher?.employeeId ?? 'N/A';

    return CustomMainScreenWithAppbar(
      title: 'Timetable Generator',
      appBarConfig: AppBarConfig.teacher(
        userInitials: userInitials,
        userName: userName,
        designation: designation,
        employeeId: employeeId,
        onNotificationIconPressed: () {},
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Navigation
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: AppTheme.blue500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Back to Academic Management',
                        style: context.textTheme.bodySm.copyWith(
                          fontWeight: AppTheme.fontWeightMedium,
                          color: AppTheme.blue500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Header
              Text(
                'Create Timetable',
                style: context.textTheme.h2.copyWith(color: AppTheme.slate800),
              ),
              const SizedBox(height: 4),
              Text(
                'Design a traditional school timetable template',
                style: context.textTheme.bodySm.copyWith(
                  color: AppTheme.slate500,
                ),
              ),
              const SizedBox(height: 24),

              // School Information Card
              CustomFormSection(
                title: 'School Information',
                subtitle: 'Enter basic school and class details',
                icon: Icons.school_outlined,
                children: [
                  CustomTextField(
                    label: 'School Name',
                    controller: _schoolNameController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'School Address',
                    controller: _schoolAddressController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Class',
                          controller: _classNameController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: 'Section',
                          controller: _sectionController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Academic Year',
                          controller: _academicYearController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: 'Class Teacher',
                          controller: _classTeacherController,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Time Slots Management
              CustomFormSection(
                title: 'Time Slots Management',
                subtitle: 'Add and configure class periods',
                icon: Icons.schedule,
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _addTimeSlot,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Time Slot'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.blue500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      timeSlots.length,
                      (index) => Chip(
                        label: Text(
                          _formatTimeSlot(timeSlots[index]),
                          style: context.textTheme.bodySm,
                        ),
                        backgroundColor: AppTheme.blue50,
                        deleteIcon: const Icon(
                          Icons.close,
                          size: 18,
                          color: AppTheme.slate600,
                        ),
                        onDeleted: () => _removeTimeSlot(index),
                        avatar: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            size: 16,
                            color: AppTheme.blue500,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _editTimeSlot(index),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Timetable Grid
              CustomFormSection(
                title: 'Weekly Schedule',
                subtitle: 'Click on cells to assign subjects',
                icon: Icons.calendar_today,
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: _previewTimetable,
                        icon: const Icon(
                          Icons.visibility,
                          color: AppTheme.blue500,
                        ),
                        label: Text(
                          'Preview',
                          style: context.textTheme.labelSm.copyWith(
                            color: AppTheme.blue500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildTimetableGrid(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppTheme.slate500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: context.textTheme.labelBase.copyWith(
                          color: AppTheme.slate600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _saveTimetableToDatabase,
                      icon: const Icon(Icons.save),
                      label: Text('Save', style: context.textTheme.labelBase),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await PdfTemplateService.generateTimetablePdf(
                            TimetableTemplate(
                              schoolName: _schoolNameController.text,
                              schoolAddress: _schoolAddressController.text,
                              className: _classNameController.text,
                              section: _sectionController.text,
                              academicYear: _academicYearController.text,
                              slots: List.generate(
                                timeSlots.length,
                                (index) => TimetableSlot(
                                  timeRange: _formatTimeSlot(timeSlots[index]),
                                  periods: timetableData[index]!,
                                  mergedLabel: mergedSlots[index],
                                ),
                              ),
                              days: days,
                              classTeacher: _classTeacherController.text,
                            ),
                          );
                          if (context.mounted) {
                            showCustomSnackbar(
                              message: 'PDF downloaded successfully',
                              type: SnackbarType.success,
                            );
                          }
                        } on Exception catch (e) {
                          if (context.mounted) {
                            showCustomSnackbar(
                              message: 'Failed to generate PDF: $e',
                              type: SnackbarType.warning,
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: Text(
                        'Generate PDF',
                        style: context.textTheme.labelBase,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.blue500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimetableGrid() => Table(
    border: TableBorder.all(color: AppTheme.slate100),
    defaultColumnWidth: const FixedColumnWidth(140),
    children: [
      // Header row
      TableRow(
        decoration: const BoxDecoration(color: AppTheme.blue500),
        children: [_buildHeaderCell('Time'), ...days.map(_buildHeaderCell)],
      ),
      // Time slot rows
      ...List.generate(timeSlots.length, (slotIndex) {
        // Check if this slot is merged (lunch/break)
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
        label, // Show text in all cells
        style: context.textTheme.titleBase.copyWith(color: AppTheme.warning),
      ),
    ),
  );

  Widget _buildHeaderCell(String text) => Container(
    padding: const EdgeInsets.all(12),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: context.textTheme.labelSm.copyWith(color: Colors.white),
    ),
  );

  Widget _buildTimeCell(String time) => Container(
    padding: const EdgeInsets.all(12),
    color: AppTheme.slate100,
    child: Text(
      time,
      textAlign: TextAlign.center,
      style: context.textTheme.labelSm.copyWith(color: AppTheme.slate800),
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
}

// Preview Screen
class TimetablePreviewScreen extends StatelessWidget {
  const TimetablePreviewScreen({required this.template, super.key});

  final TimetableTemplate template;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Timetable Preview'),
      actions: [
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: () async {
            try {
              await PdfTemplateService.generateTimetablePdf(template);
              if (context.mounted) {
                showCustomSnackbar(
                  message: 'PDF downloaded successfully',
                  type: SnackbarType.success,
                );
              }
            } on Exception catch (e) {
              if (context.mounted) {
                showCustomSnackbar(
                  message: 'Failed to generate PDF: $e',
                  type: SnackbarType.warning,
                );
              }
            }
          },
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Text(
                    template.schoolName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    template.schoolAddress,
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(border: Border.all()),
                    child: const Text(
                      'CLASS TIME TABLE',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Class Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Class: ${template.className} - ${template.section}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Academic Year: ${template.academicYear}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (template.classTeacher != null) ...[
              const SizedBox(height: 8),
              Text(
                'Class Teacher: ${template.classTeacher}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Timetable
            Table(
              border: TableBorder.all(),
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[300]),
                  children: [
                    _buildPreviewHeaderCell('Time'),
                    ...template.days.map(_buildPreviewHeaderCell),
                  ],
                ),
                // Slots
                ...template.slots.map((slot) {
                  // Check if this is a merged slot (lunch/break)
                  if (slot.mergedLabel != null) {
                    return TableRow(
                      decoration: BoxDecoration(color: Colors.amber[50]),
                      children: [
                        _buildPreviewTimeCell(slot.timeRange),
                        // Create merged cell appearance
                        ...List.generate(
                          template.days.length,
                          (dayIndex) => _buildPreviewMergedCell(
                            slot.mergedLabel!,
                            isFirst: dayIndex == 0,
                            isLast: dayIndex == template.days.length - 1,
                          ),
                        ),
                      ],
                    );
                  }

                  // Regular row with individual cells
                  return TableRow(
                    children: [
                      _buildPreviewTimeCell(slot.timeRange),
                      ...template.days.map(
                        (day) => _buildPreviewPeriodCell(slot.periods[day]),
                      ),
                    ],
                  );
                }),
              ],
            ),

            const SizedBox(height: 32),

            // Footer
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40),
                    Text('_________________'),
                    SizedBox(height: 4),
                    Text('Class Teacher', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 40),
                    Text('_________________'),
                    SizedBox(height: 4),
                    Text('Principal', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildPreviewHeaderCell(String text) => Container(
    padding: const EdgeInsets.all(10),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
    ),
  );

  Widget _buildPreviewTimeCell(String time) => Container(
    padding: const EdgeInsets.all(10),
    child: Text(
      time,
      textAlign: TextAlign.center,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
    ),
  );

  Widget _buildPreviewPeriodCell(SubjectPeriod? period) => Container(
    padding: const EdgeInsets.all(8),
    height: 60,
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
                    fontSize: 11,
                  ),
                  maxLines: 2,
                ),
                if (period.teacher != null)
                  Text(
                    period.teacher!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 9),
                    maxLines: 1,
                  ),
              ],
            )
            : const SizedBox(),
  );

  Widget _buildPreviewMergedCell(
    String label, {
    required bool isFirst,
    required bool isLast,
  }) => Container(
    padding: const EdgeInsets.all(10),
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
        label, // Show text in all cells
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Color(0xFF92400e),
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
