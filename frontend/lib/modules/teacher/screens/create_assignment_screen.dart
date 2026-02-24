import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_date_picker_field.dart';
import '../../../widgets/custom_widgets/custom_dropdown_field.dart';
import '../../../widgets/custom_widgets/custom_form_section.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../models/assignment_models.dart';
import '../models/template_models.dart';
import '../providers/assignment_provider.dart';
import '../widgets/manual_question_template_widget.dart';

/// Screen for creating a new assignment
/// Follows the project's design patterns and UI theme
class CreateAssignmentScreen extends StatefulWidget {
  const CreateAssignmentScreen({super.key, this.assignmentId});
  final int? assignmentId;

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _marksController = TextEditingController(text: '25');

  Course? _selectedCourse;
  Subject? _selectedSubject;

  DateTime? _dueDate;

  bool _isLoading = false;
  String _status = 'DRAFT';

  // Assignment type: 'pdf', 'manual', or 'description_only'
  String _assignmentType = 'description_only';

  // Manual template data
  List<QuestionSection>? _manualTemplateSections;

  @override
  void initState() {
    super.initState();
    // In edit mode show loading immediately so first build is cheap and push doesn't block.
    if (widget.assignmentId != null) {
      _isLoading = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final loginProvider = context.read<LoginProvider>();
    final provider = context.read<AssignmentProvider>();
    final teacherId = loginProvider.currentUser?.teacher?.id;

    if (teacherId != null) {
      await provider.loadCourses();
      if (mounted) _checkAutoSelection(provider);
    }

    // Load assignment data if editing
    if (widget.assignmentId != null) {
      _loadAssignmentData(provider, loginProvider.currentUser?.uuid);
    }
  }

  Future<void> _loadAssignmentData(
    AssignmentProvider provider,
    String? uuid,
  ) async {
    if (uuid == null) return;

    try {
      setState(() => _isLoading = true);
      await Future<void>.delayed(Duration.zero); // Yield so loading UI paints
      final assignment = await provider.getAssignment(
        uuid,
        widget.assignmentId!,
      );

      if (mounted) {
        // COMPREHENSIVE DEBUG LOGGING
        debugPrint('=== ASSIGNMENT EDIT MODE DEBUG ===');
        debugPrint('Assignment ID: ${assignment.id}');
        debugPrint('Assignment.courseId (subjectId): ${assignment.courseId}');
        debugPrint(
          'Assignment.referenceCourseId: ${assignment.referenceCourseId}',
        );
        debugPrint('Assignment.sectionId: ${assignment.sectionId}');
        debugPrint('Assignment.sectionName: ${assignment.sectionName}');
        debugPrint('Assignment.courseName: ${assignment.courseName}');
        debugPrint(
          'Available courses: ${provider.courses.map((c) => 'id=${c.id}, name=${c.courseName}').join(', ')}',
        );
        debugPrint('=================================');

        _titleController.text = assignment.title;
        _descriptionController.text = assignment.description;
        _instructionsController.text = assignment.instructions ?? '';
        _marksController.text = assignment.maxMarks.toString();

        setState(() {
          _dueDate = assignment.dueDate;
          _status = assignment.status;
        });

        // Pre-fill dropdowns logic
        // We need to find which course contains the subject with assignment.courseId (subjectId)
        Course? matchedCourse;

        Subject? matchedSubject;

        // Strategy: Load all courses, then for each course, load its details and check if it contains our subject
        debugPrint(
          'Looking for course that contains subject with ID: ${assignment.courseId}',
        );

        for (final course in provider.courses) {
          await Future<void>.delayed(Duration.zero); // Yield to UI
          await provider.loadDetailsForCourse(course.id);

          // Check if this course has the subject we're looking for
          try {
            final foundSubject = provider.subjects.firstWhere(
              (s) => s.id == assignment.courseId,
            );

            // Found it! This is the right course
            matchedCourse = course;
            matchedSubject = foundSubject;
            debugPrint(
              'Found course: ${course.courseName} contains subject: ${foundSubject.name}',
            );
            break;
          } on Exception {
            // This course doesn't have our subject, continue searching
            debugPrint(
              'Course ${course.courseName} does not contain subject ${assignment.courseId}',
            );
            continue;
          }
        }

        if (matchedCourse != null && mounted) {
          setState(() {
            _selectedCourse = matchedCourse;
            _selectedSubject = matchedSubject;
          });
        } else {
          debugPrint(
            'ERROR: Could not find course containing subject ${assignment.courseId}',
          );
        }

        setState(() => _isLoading = false);
      }
    } on Exception catch (e) {
      if (mounted) {
        showCustomSnackbar(
          message: 'Failed to load assignment: $e',
          type: SnackbarType.error,
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkAutoSelection(AssignmentProvider provider) async {
    if (!mounted) return;

    var stateChanged = false;

    // 1. Auto-select Course
    if (_selectedCourse == null && provider.courses.length == 1) {
      _selectedCourse = provider.courses.first;
      stateChanged = true;
      // Load details for the single course immediately
      await provider.loadDetailsForCourse(_selectedCourse!.id);
    }

    // 3. Auto-select Subject - use object from provider's list
    if (_selectedCourse != null &&
        _selectedSubject == null &&
        provider.subjects.length == 1) {
      _selectedSubject = provider.subjects.first;
      stateChanged = true;
    }

    if (stateChanged && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    _marksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // In edit mode, show minimal loading UI until data is loaded so first frame is cheap.
    if (widget.assignmentId != null && _isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Assignment')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final teacher = user?.teacher;

    final userInitials = UserUtils.getInitials(user?.name ?? 'Teacher');
    final userName = user?.name ?? 'Teacher';
    final designation = teacher?.designation ?? 'Teacher';
    final employeeId = teacher?.employeeId ?? 'N/A';

    return CustomMainScreenWithAppbar(
      title:
          widget.assignmentId == null ? 'Create Assignment' : 'Edit Assignment',
      appBarConfig: AppBarConfig.teacher(
        userInitials: userInitials,
        userName: userName,
        designation: designation,
        employeeId: employeeId,
        onNotificationIconPressed: () {},
      ),
      floatingActionButton: _buildFloatingActionButton(),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            // Assignment Details Section
            CustomFormSection(
              title: 'Assignment Details',
              subtitle: 'Enter the assignment information',
              icon: Icons.edit_note,
              children: [
                // Assignment Title
                CustomTextField(
                  label: 'Assignment Title',
                  controller: _titleController,
                  hintText: 'e.g., Essay on Climate Change',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter assignment title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                CustomTextField(
                  label: 'Description',
                  controller: _descriptionController,
                  hintText: 'Describe the assignment requirements...',
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Instructions Field (Visible always or populated by manual)
                CustomTextField(
                  label: 'Instructions / Questions',
                  controller: _instructionsController,
                  hintText: 'Enter detailed instructions or questions...',
                  maxLines: 6,
                ),
                const SizedBox(height: 16),

                // Total Marks
                CustomTextField(
                  label: 'Total Marks',
                  controller: _marksController,
                  hintText: '25',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter total marks';
                    }
                    final marks = int.tryParse(value);
                    if (marks == null || marks <= 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Course & Class Section
            CustomFormSection(
              title: 'Subject & Class',
              subtitle: 'Select the target subject and class',
              icon: Icons.class_,
              children: [
                _buildCourseDropdown(),
                const SizedBox(height: 16),

                _buildSubjectDropdown(),
              ],
            ),

            const SizedBox(height: 16),

            // Schedule & Status Section (Side-by-Side)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomFormSection(
                      title: 'Schedule',
                      subtitle: 'Set assignment and due dates',
                      icon: Icons.calendar_today,
                      children: [
                        // Dates in a Row for compact layout
                        Row(
                          children: [
                            Expanded(
                              child: CustomDatePickerField(
                                label: 'Due Date',
                                selectedDate: _dueDate,
                                hintText: 'dd/mm/yyyy',
                                onDateSelected: (date) {
                                  setState(() {
                                    _dueDate = date;
                                  });
                                },
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (widget.assignmentId != null) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: CustomFormSection(
                        title: 'Status',
                        subtitle: 'Set assignment status',
                        icon: Icons.info_outline,
                        children: [_buildStatusDropdown()],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Assignment Type Section
            CustomFormSection(
              title: 'Assignment Type',
              subtitle: 'Choose how to create the assignment',
              icon: Icons.assignment,
              children: [
                // Assignment type options
                _buildAssignmentTypeOption(
                  value: 'description_only',
                  icon: Icons.description,
                  title: 'Description Only',
                  subtitle: 'Just use the description field above',
                ),
                const SizedBox(height: 12),
                _buildAssignmentTypeOption(
                  value: 'manual',
                  icon: Icons.edit_note,
                  title: 'Manual Question Paper',
                  subtitle: 'Create questions using template (no header)',
                ),

                const SizedBox(height: 16),

                // Show template builder if manual is selected
                if (_assignmentType == 'manual') ...[
                  ElevatedButton.icon(
                    onPressed: _openManualTemplateBuilder,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      backgroundColor: AppTheme.blue500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.edit_note, size: 20),
                    label: Text(
                      _manualTemplateSections == null
                          ? 'Create Questions'
                          : 'Edit Questions (${_getTotalQuestions()} questions)',
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeBase,
                        fontWeight: AppTheme.fontWeightMedium,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Create question paper without header (manual process)',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeSm,
                      color: AppTheme.slate500,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() => DecoratedBox(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF155dfc).withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: FloatingActionButton.extended(
      onPressed: _isLoading ? null : _submitForm,
      backgroundColor: const Color(0xFF155dfc),
      elevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon:
          _isLoading
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
              : Icon(
                widget.assignmentId == null
                    ? Icons.add
                    : Icons.check_circle_outline,
                color: Colors.white,
              ),
      label: Text(
        widget.assignmentId == null ? 'Create Assignment' : 'Update Assignment',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );

  Widget _buildCourseDropdown() {
    final provider = context.watch<AssignmentProvider>();
    return DropDownFormField<Course>(
      label: 'Course',
      value: _selectedCourse,
      hintText: 'Select course',
      items: provider.courses,
      displayText: (course) => '${course.courseCode} - ${course.courseName}',
      onChanged: (course) async {
        setState(() {
          _selectedCourse = course;
          _selectedSubject = null;
        });
        if (course != null) {
          await provider.loadDetailsForCourse(course.id);
          if (context.mounted) _checkAutoSelection(provider);
        }
      },
      validator: (value) => value == null ? 'Please select a course' : null,
    );
  }

  Widget _buildSubjectDropdown() {
    final provider = context.watch<AssignmentProvider>();
    return DropDownFormField<Subject>(
      label: 'Subject',
      value: _selectedSubject,
      hintText: 'Select subject',
      isEnabled: _selectedCourse != null,
      items: provider.subjects,
      displayText: (subject) => subject.name,
      onChanged: (subject) {
        setState(() {
          _selectedSubject = subject;
        });
      },
      validator: (value) => value == null ? 'Please select a subject' : null,
    );
  }

  Widget _buildStatusDropdown() => DropDownFormField<String>(
    label: 'Status',
    value: _status,
    hintText: 'Select status',
    items: const ['DRAFT', 'PUBLISHED', 'CLOSED'],
    displayText: (status) => status, // Capitalize or format as needed
    onChanged: (value) {
      if (value != null) {
        setState(() => _status = value);
      }
    },
  );

  Widget _buildAssignmentTypeOption({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) => InkWell(
    onTap: () {
      setState(() {
        _assignmentType = value;
        if (value != 'manual') {
          _manualTemplateSections = null;
        }
      });
    },
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color:
              _assignmentType == value
                  ? AppTheme.blue500
                  : CustomAppColors.lightGrey01,
          width: _assignmentType == value ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color:
            _assignmentType == value
                ? AppTheme.blue500.withValues(alpha: 0.05)
                : CustomAppColors.slate50,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (_assignmentType == value
                      ? AppTheme.blue500
                      : AppTheme.slate600)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color:
                  _assignmentType == value
                      ? AppTheme.blue500
                      : AppTheme.slate600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeBase,
                    fontWeight: AppTheme.fontWeightMedium,
                    color:
                        _assignmentType == value
                            ? AppTheme.blue500
                            : AppTheme.slate800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeSm,
                    color: AppTheme.slate500,
                  ),
                ),
              ],
            ),
          ),
          if (_assignmentType == value)
            const Icon(Icons.check_circle, color: AppTheme.blue500, size: 20),
        ],
      ),
    ),
  );

  Future<void> _openManualTemplateBuilder() async {
    final result = await Navigator.push<List<QuestionSection>>(
      context,
      MaterialPageRoute(
        builder:
            (context) => ManualQuestionTemplateWidget(
              existingSections: _manualTemplateSections,
              subjectName: _selectedSubject?.name ?? 'Subject',
            ),
      ),
    );

    if (result != null) {
      setState(() {
        _manualTemplateSections = result;
      });

      // Generate instructions text from template
      final buffer = StringBuffer();
      for (final section in result) {
        buffer.writeln('--- ${section.sectionName} ---');
        if (section.description != null && section.description!.isNotEmpty) {
          buffer.writeln(section.description);
        }
        buffer.writeln();
        for (var i = 0; i < section.questions.length; i++) {
          final q = section.questions[i];
          final marks = q.customMarks ?? section.marksPerQuestion;
          buffer.writeln('${i + 1}. ${q.questionText} ($marks marks)');
        }
        buffer.writeln();
      }
      _instructionsController.text = buffer.toString();
    }
  }

  int _getTotalQuestions() {
    if (_manualTemplateSections == null) {
      return 0;
    }
    return _manualTemplateSections!.fold(
      0,
      (sum, section) => sum + section.questions.length,
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Additional validation
    if (_selectedCourse == null) {
      showCustomSnackbar(
        message: 'Please select a course',
        type: SnackbarType.warning,
      );
      return;
    }

    if (_selectedSubject == null) {
      showCustomSnackbar(
        message: 'Please select a subject',
        type: SnackbarType.warning,
      );
      return;
    }

    if (_dueDate == null) {
      showCustomSnackbar(
        message: 'Please select a due date',
        type: SnackbarType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    final loginProvider = context.read<LoginProvider>();
    final provider = context.read<AssignmentProvider>();
    final uuid = loginProvider.currentUser?.uuid;

    if (uuid == null) {
      setState(() => _isLoading = false);
      if (mounted) {
        showCustomSnackbar(
          message: 'User not found',
          type: SnackbarType.warning,
        );
      }
      return;
    }

    // Prepare instructions based on assignment type
    String? instructions = _instructionsController.text.trim();
    if (instructions.isEmpty) {
      if (_assignmentType == 'manual' && _manualTemplateSections != null) {
        // Fallback to regenerating if text field was cleared but template exists
        // (Logic reused from above, simplified here for brevity or just rely on controller)
      } else {
        instructions = null;
      }
    }

    final dto = CreateAssignmentDto(
      subjectId: _selectedSubject!.id,

      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      instructions: instructions,
      maxMarks: int.parse(_marksController.text.trim()),

      dueDate: _dueDate!,
      status: _status,
    );

    final success =
        widget.assignmentId == null
            ? await provider.createAssignment(uuid, dto)
            : await provider.updateAssignment(
              uuid,
              widget.assignmentId!,
              UpdateAssignmentDto(
                title: dto.title,
                description: dto.description,
                instructions: dto.instructions,
                maxMarks: dto.maxMarks,
                dueDate: dto.dueDate,
                status: dto.status,
              ),
            );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        showCustomSnackbar(
          message:
              widget.assignmentId == null
                  ? 'Assignment created successfully'
                  : 'Assignment updated successfully',
          type: SnackbarType.success,
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        showCustomSnackbar(
          message:
              provider.error ??
              (widget.assignmentId == null
                  ? 'Failed to create assignment'
                  : 'Failed to update assignment'),
          type: SnackbarType.warning,
        );
      }
    }
  }
}
