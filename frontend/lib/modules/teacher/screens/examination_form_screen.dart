import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/extensions.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_date_picker_field.dart';
import '../../../widgets/custom_widgets/custom_dropdown_field.dart';
import '../../../widgets/custom_widgets/custom_form_section.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../../../widgets/custom_widgets/custom_time_picker_field.dart';
import '../models/assignment_models.dart';
import '../models/examination_models.dart';
import '../providers/assignment_provider.dart';
import '../providers/examination_provider.dart';

/// Screen for creating or editing an examination
class ExaminationFormScreen extends StatefulWidget {
  const ExaminationFormScreen({super.key, this.examinationId});
  final int? examinationId;

  @override
  State<ExaminationFormScreen> createState() => _ExaminationFormScreenState();
}

class _ExaminationFormScreenState extends State<ExaminationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _examNameController = TextEditingController();
  final _totalMarksController = TextEditingController();
  final _passingMarksController = TextEditingController();
  final _durationController = TextEditingController();
  final _venueController = TextEditingController();
  final _instructionsController = TextEditingController();

  Course? _selectedCourse;
  int? _selectedSemesterId;
  String _examType = 'QUIZ';
  DateTime? _examDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _status = 'SCHEDULED';
  bool _isLoading = false;

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

    final assignmentProvider = context.read<AssignmentProvider>();
    final examProvider = context.read<ExaminationProvider>();

    await assignmentProvider.loadCourses(uuid);
    await examProvider.loadSemesters();

    // TODO: If editing, load examination data
    if (widget.examinationId != null) {
      // Load examination details and populate form
    }
  }

  @override
  void dispose() {
    _examNameController.dispose();
    _totalMarksController.dispose();
    _passingMarksController.dispose();
    _durationController.dispose();
    _venueController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final teacher = user?.teacher;

    // Use real user data
    final userInitials = UserUtils.getInitials(user?.name ?? 'Teacher');
    final userName = user?.name ?? 'Teacher';
    final designation = teacher?.designation ?? 'Teacher';
    final employeeId = teacher?.employeeId ?? 'N/A';

    return CustomMainScreenWithAppbar(
      title:
          widget.examinationId == null
              ? context.translate('create_examination')
              : context.translate('edit_examination'),
      appBarConfig: AppBarConfig.teacher(
        userInitials: userInitials,
        userName: userName,
        designation: designation,
        employeeId: employeeId,
        onNotificationIconPressed: () {
          // Notification handler to be implemented
        },
      ),
      bottomWidget: _buildSubmitButton(),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.only(bottom: isMobile ? 16 : 24),
          children: [
            // Back Navigation Link
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
                      color: Color(0xFF155dfc),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.translate('back_to_examinations'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF155dfc),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Basic Information Section
            CustomFormSection(
              title: context.translate('basic_information'),
              subtitle: context.translate('enter_exam_basic_info'),
              icon: Icons.quiz_outlined,
              children: [
                _buildExamNameField(),
                const SizedBox(height: 16),
                _buildExamTypeDropdown(),
              ],
            ),
            const SizedBox(height: 20),

            // Course & Semester Section
            CustomFormSection(
              title: context.translate('course_semester'),
              subtitle: context.translate('select_course_semester'),
              icon: Icons.school_outlined,
              children: [
                _buildCourseDropdown(),
                const SizedBox(height: 16),
                _buildSemesterDropdown(),
              ],
            ),
            const SizedBox(height: 20),

            // Marks & Duration Section
            CustomFormSection(
              title: context.translate('marks_duration'),
              subtitle: context.translate('set_marks_duration'),
              icon: Icons.grade_outlined,
              children: [
                _buildMarksFields(),
                const SizedBox(height: 16),
                _buildDurationField(),
              ],
            ),
            const SizedBox(height: 20),

            // Schedule Section
            CustomFormSection(
              title: context.translate('schedule'),
              subtitle: context.translate('set_exam_schedule'),
              icon: Icons.calendar_today_outlined,
              children: [
                _buildExamDateField(),
                const SizedBox(height: 16),
                _buildTimeFields(),
              ],
            ),
            const SizedBox(height: 20),

            // Venue & Instructions Section
            CustomFormSection(
              title: context.translate('venue_instructions'),
              subtitle: context.translate('add_venue_instructions'),
              icon: Icons.location_on_outlined,
              children: [
                _buildVenueField(),
                const SizedBox(height: 16),
                _buildInstructionsField(),
              ],
            ),
            const SizedBox(height: 20),

            // Status Section
            CustomFormSection(
              title: context.translate('status'),
              subtitle: context.translate('set_exam_status'),
              icon: Icons.info_outline,
              children: [_buildStatusDropdown()],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamNameField() => CustomTextField(
    label: context.translate('exam_name_required'),
    controller: _examNameController,
    hintText: context.translate('exam_name_hint'),
    //prefixIcon: const Icon(Icons.quiz),
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return context.translate('please_enter_exam_name');
      }
      if (value.length < 3) {
        return context.translate('exam_name_min_3_chars');
      }
      return null;
    },
  );

  Widget _buildExamTypeDropdown() => DropDownFormField<String>(
    label: context.translate('exam_type_required'),
    value: _examType,
    hintText: context.translate('select_exam_type'),
    //prefixIcon: const Icon(Icons.category),
    items: const ['QUIZ', 'MIDTERM', 'FINAL', 'PRACTICAL', 'OTHER'],
    displayText: (value) {
      switch (value) {
        case 'QUIZ':
          return context.translate('quiz');
        case 'MIDTERM':
          return context.translate('midterm');
        case 'FINAL':
          return context.translate('final_exam');
        case 'PRACTICAL':
          return context.translate('practical');
        case 'OTHER':
          return context.translate('exam_type_other');
        default:
          return value;
      }
    },
    onChanged: (value) {
      if (value != null) {
        setState(() {
          _examType = value;
        });
      }
    },
  );

  Widget _buildCourseDropdown() => Consumer<AssignmentProvider>(
    builder:
        (context, provider, child) => DropDownFormField<Course>(
          label: context.translate('course_required'),
          value: _selectedCourse,
          hintText: context.translate('select_course'),
          //prefixIcon: const Icon(Icons.book),
          items: provider.courses,
          displayText:
              (course) => '${course.courseCode} - ${course.courseName}',
          onChanged: (course) {
            setState(() {
              _selectedCourse = course;
            });
          },
          validator: (value) {
            if (value == null) {
              return context.translate('please_select_course');
            }
            return null;
          },
        ),
  );

  Widget _buildSemesterDropdown() => Consumer<ExaminationProvider>(
    builder:
        (context, provider, child) => DropDownFormField<int>(
          label: context.translate('semester_required'),
          value: _selectedSemesterId ?? 1,
          hintText: context.translate('select_semester'),
          //prefixIcon: const Icon(Icons.calendar_month),
          items: const [1, 2],
          displayText: (value) {
            switch (value) {
              case 1:
                return 'Spring 2025';
              case 2:
                return 'Fall 2024';
              default:
                return 'Semester $value';
            }
          },
          onChanged: (semesterId) {
            setState(() {
              _selectedSemesterId = semesterId;
            });
          },
          validator: (value) {
            if (value == null) {
              return context.translate('please_select_semester');
            }
            return null;
          },
        ),
  );

  Widget _buildMarksFields() => Row(
    children: [
      Expanded(
        child: CustomTextField(
          label: context.translate('total_marks_required'),
          controller: _totalMarksController,
          hintText: context.translate('marks_hint'),
          //prefixIcon: const Icon(Icons.grade),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.translate('required');
            }
            final marks = int.tryParse(value);
            if (marks == null || marks <= 0) {
              return context.translate('invalid');
            }
            return null;
          },
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: CustomTextField(
          label: context.translate('passing_marks_required'),
          controller: _passingMarksController,
          hintText: context.translate('passing_marks_hint'),
          //prefixIcon: const Icon(Icons.check_circle),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.translate('required');
            }
            final marks = int.tryParse(value);
            if (marks == null || marks <= 0) {
              return context.translate('invalid');
            }
            final totalMarks = int.tryParse(_totalMarksController.text);
            if (totalMarks != null && marks > totalMarks) {
              return context.translate('too_high');
            }
            return null;
          },
        ),
      ),
    ],
  );

  Widget _buildDurationField() => CustomTextField(
    label: context.translate('duration_minutes_required'),
    controller: _durationController,
    hintText: context.translate('duration_hint'),
    //prefixIcon: const Icon(Icons.timer),
    keyboardType: TextInputType.number,
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return context.translate('please_enter_duration');
      }
      final duration = int.tryParse(value);
      if (duration == null || duration <= 0) {
        return context.translate('enter_valid_duration');
      }
      return null;
    },
  );

  Widget _buildExamDateField() => CustomDatePickerField(
    label: context.translate('exam_date_required'),
    selectedDate: _examDate,
    hintText: context.translate('select_exam_date'),
    onDateSelected: (date) {
      setState(() {
        _examDate = date;
      });
    },
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );

  Widget _buildTimeFields() => Row(
    children: [
      Expanded(
        child: CustomTimePickerField(
          label: context.translate('start_time'),
          selectedTime: _startTime,
          hintText: context.translate('select_time'),
          onTimeSelected: (time) {
            setState(() {
              _startTime = time;
            });
          },
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: CustomTimePickerField(
          label: context.translate('end_time'),
          selectedTime: _endTime,
          hintText: context.translate('select_time'),
          onTimeSelected: (time) {
            setState(() {
              _endTime = time;
            });
          },
        ),
      ),
    ],
  );

  Widget _buildVenueField() => CustomTextField(
    label: context.translate('venue_optional'),
    controller: _venueController,
    hintText: context.translate('venue_hint'),
    //prefixIcon: const Icon(Icons.location_on),
  );

  Widget _buildInstructionsField() => CustomTextField(
    label: context.translate('instructions_optional'),
    controller: _instructionsController,
    hintText: context.translate('special_instructions_hint'),
    // //prefixIcon: const Icon(Icons.list),
    maxLines: 3,
  );

  Widget _buildStatusDropdown() => DropDownFormField<String>(
    label: context.translate('status_required'),
    value: _status,
    hintText: context.translate('select_status'),
    //prefixIcon: const Icon(Icons.info),
    items: const ['SCHEDULED', 'ONGOING', 'COMPLETED', 'CANCELLED'],
    displayText: (value) {
      switch (value) {
        case 'SCHEDULED':
          return context.translate('scheduled');
        case 'ONGOING':
          return context.translate('ongoing');
        case 'COMPLETED':
          return context.translate('completed');
        case 'CANCELLED':
          return context.translate('cancelled');
        default:
          return value;
      }
    },
    onChanged: (value) {
      if (value != null) {
        setState(() {
          _status = value;
        });
      }
    },
  );

  Widget _buildSubmitButton() {
    final isMobile = context.isMobile;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 14 : 16,
            horizontal: 24,
          ),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  widget.examinationId == null
                      ? context.translate('create_examination')
                      : context.translate('update_examination'),
                  style: TextStyle(fontSize: isMobile ? 14 : 16),
                ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_examDate == null) {
      showCustomSnackbar(
        message: context.translate('please_select_exam_date'),
        type: SnackbarType.warning,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final loginProvider = context.read<LoginProvider>();
    final user = loginProvider.currentUser;
    final uuid = user?.uuid;
    if (uuid == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final provider = context.read<ExaminationProvider>();

    // Combine date and time if provided
    DateTime? startDateTime;
    DateTime? endDateTime;

    if (_startTime != null) {
      startDateTime = DateTime(
        _examDate!.year,
        _examDate!.month,
        _examDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
    }

    if (_endTime != null) {
      endDateTime = DateTime(
        _examDate!.year,
        _examDate!.month,
        _examDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );
    }

    final dto = CreateExaminationDto(
      courseId: _selectedCourse!.id,
      semesterId: _selectedSemesterId ?? 1,
      examName: _examNameController.text.trim(),
      examType: _examType,
      totalMarks: int.parse(_totalMarksController.text.trim()),
      passingMarks: int.parse(_passingMarksController.text.trim()),
      durationMinutes: int.parse(_durationController.text.trim()),
      examDate: _examDate!,
      startTime: startDateTime,
      endTime: endDateTime,
      venue:
          _venueController.text.trim().isNotEmpty
              ? _venueController.text.trim()
              : null,
      instructions:
          _instructionsController.text.trim().isNotEmpty
              ? _instructionsController.text.trim()
              : null,
      status: _status,
    );

    final success =
        widget.examinationId == null
            ? await provider.createExamination(uuid, dto)
            : await provider.updateExamination(
              uuid,
              widget.examinationId!,
              UpdateExaminationDto(
                examName: _examNameController.text.trim(),
                examType: _examType,
                totalMarks: int.parse(_totalMarksController.text.trim()),
                passingMarks: int.parse(_passingMarksController.text.trim()),
                durationMinutes: int.parse(_durationController.text.trim()),
                examDate: _examDate,
                startTime: startDateTime,
                endTime: endDateTime,
                venue:
                    _venueController.text.trim().isNotEmpty
                        ? _venueController.text.trim()
                        : null,
                instructions:
                    _instructionsController.text.trim().isNotEmpty
                        ? _instructionsController.text.trim()
                        : null,
                status: _status,
              ),
            );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        showCustomSnackbar(
          message: widget.examinationId == null
              ? context.translate('examination_created_success')
              : context.translate('examination_updated_success'),
          type: SnackbarType.success,
        );
        Navigator.pop(context);
      } else {
        showCustomSnackbar(
          message: provider.error ?? context.translate('error_occurred'),
          type: SnackbarType.warning,
        );
      }
    }
  }
}
