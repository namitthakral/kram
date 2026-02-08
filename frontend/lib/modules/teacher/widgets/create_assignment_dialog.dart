import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../widgets/custom_widgets/custom_date_picker_field.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../models/assignment_models.dart';
import '../models/template_models.dart';
import '../providers/assignment_provider.dart';
import 'manual_question_template_widget.dart';

/// Dialog for creating a new assignment
/// Follows the project's design patterns and UI theme
class CreateAssignmentDialog extends StatefulWidget {
  const CreateAssignmentDialog({super.key});

  @override
  State<CreateAssignmentDialog> createState() => _CreateAssignmentDialogState();
}

class _CreateAssignmentDialogState extends State<CreateAssignmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _marksController = TextEditingController(text: '25');

  Subject? _selectedSubject;
  Course? _selectedCourse;


  DateTime? _dueDate;
  bool _isLoading = false;

  // File attachment
  PlatformFile? _selectedFile;

  // Assignment type: 'pdf', 'manual', or 'description_only'
  String _assignmentType = 'description_only';

  // Manual template data
  List<QuestionSection>? _manualTemplateSections;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<AssignmentProvider>();
    // Updated to use the new loadCourses method which takes no arguments
    await provider.loadCourses();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _marksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Container(
      constraints: const BoxConstraints(maxWidth: 700),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildForm(),
            ),
          ),
          _buildActions(),
        ],
      ),
    ),
  );

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: CustomAppColors.slate50,
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.blue500.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.assignment,
            color: AppTheme.blue500,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Assignment',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeXl,
                  fontWeight: AppTheme.fontWeightBold,
                  color: AppTheme.slate800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Assign homework or projects to students',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeSm,
                  color: AppTheme.slate600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 20),
          color: AppTheme.slate600,
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    ),
  );

  Widget _buildForm() => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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

        // Course and Section in a row
        // Course Dropdown
        _buildCourseDropdown(),
        const SizedBox(height: 16),

        // Subject dropdown
        _buildSubjectDropdown(),
        const SizedBox(height: 16),

        // Due Date
        CustomDatePickerField(
          label: 'Due Date',
          selectedDate: _dueDate,
          hintText: 'dd/mm/yyyy',
          onDateSelected: (date) {
            setState(() {
              _dueDate = date;
            });
          },
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
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

        // Attachments (optional)
        _buildAttachmentsSection(),
      ],
    ),
  );

  Widget _buildCourseDropdown() {
    final provider = context.watch<AssignmentProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Course',
          style: TextStyle(
            fontWeight: AppTheme.fontWeightBold,
            fontSize: AppTheme.fontSizeSm,
            color: AppTheme.slate800,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: CustomAppColors.lightGrey01),
            borderRadius: BorderRadius.circular(15),
            color: CustomAppColors.slate50,
          ),
          child: DropdownButton<Course>(
            isExpanded: true,
            value: _selectedCourse,
            underline: const SizedBox(),
            hint: const Text(
              'Select course',
              style: TextStyle(
                fontSize: AppTheme.fontSizeBase,
                color: CustomAppColors.grey01,
              ),
            ),
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            style: const TextStyle(
              fontSize: AppTheme.fontSizeBase,
              color: AppTheme.slate800,
            ),
            items:
                provider.courses
                    .map(
                      (course) => DropdownMenuItem<Course>(
                        value: course,
                        child: Text(
                          '${course.courseCode} - ${course.courseName}',
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (course) async {
              setState(() {
                _selectedCourse = course;
                _selectedSubject = null;
              });

              // Load sections and subjects for the selected course
              if (course != null) {
                await provider.loadDetailsForCourse(course.id);
              }
            },
          ),
        ),
      ],
    );
  }



  Widget _buildSubjectDropdown() {
    final provider = context.watch<AssignmentProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subject',
          style: TextStyle(
            fontWeight: AppTheme.fontWeightBold,
            fontSize: AppTheme.fontSizeSm,
            color: AppTheme.slate800,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: CustomAppColors.lightGrey01),
            borderRadius: BorderRadius.circular(15),
            color: CustomAppColors.slate50,
          ),
          child: DropdownButton<Subject>(
            isExpanded: true,
            value: _selectedSubject,
            underline: const SizedBox(),
            hint: const Text(
              'Select subject',
              style: TextStyle(
                fontSize: AppTheme.fontSizeBase,
                color: CustomAppColors.grey01,
              ),
            ),
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            style: const TextStyle(
              fontSize: AppTheme.fontSizeBase,
              color: AppTheme.slate800,
            ),
            items:
                provider.subjects
                    .map(
                      (subject) => DropdownMenuItem<Subject>(
                        value: subject,
                        child: Text(subject.name),
                      ),
                    )
                    .toList(),
            onChanged:
                _selectedCourse == null
                    ? null
                    : (subject) {
                      setState(() {
                        _selectedSubject = subject;
                      });
                    },
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Assignment Type',
        style: TextStyle(
          fontWeight: AppTheme.fontWeightBold,
          fontSize: AppTheme.fontSizeSm,
          color: AppTheme.slate800,
        ),
      ),
      const SizedBox(height: 12),

      // Assignment type options
      _buildAssignmentTypeOption(
        value: 'description_only',
        icon: Icons.description,
        title: 'Description Only',
        subtitle: 'Just use the description field above',
      ),
      const SizedBox(height: 12),
      _buildAssignmentTypeOption(
        value: 'pdf',
        icon: Icons.picture_as_pdf,
        title: 'Upload PDF/File',
        subtitle: 'Attach a PDF or document file',
      ),
      const SizedBox(height: 12),
      _buildAssignmentTypeOption(
        value: 'manual',
        icon: Icons.edit_note,
        title: 'Manual Question Paper',
        subtitle: 'Create questions using template (no header)',
      ),

      const SizedBox(height: 16),

      // Show file picker if PDF is selected
      if (_assignmentType == 'pdf') ...[
        InkWell(
          onTap: _pickFile,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    _selectedFile != null
                        ? AppTheme.blue500
                        : CustomAppColors.lightGrey01,
              ),
              borderRadius: BorderRadius.circular(15),
              color: CustomAppColors.slate50,
            ),
            child: Row(
              children: [
                Icon(
                  _selectedFile != null
                      ? Icons.check_circle
                      : Icons.attach_file,
                  color:
                      _selectedFile != null
                          ? AppTheme.blue500
                          : AppTheme.slate600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedFile != null ? _selectedFile!.name : 'Choose file',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeBase,
                      color:
                          _selectedFile != null
                              ? AppTheme.slate800
                              : AppTheme.slate600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_selectedFile != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      setState(() {
                        _selectedFile = null;
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Supported formats: PDF, DOC, DOCX, images',
          style: TextStyle(
            fontSize: AppTheme.fontSizeSm,
            color: AppTheme.slate500,
          ),
        ),
      ],

      // Show template builder if manual is selected
      if (_assignmentType == 'manual') ...[
        ElevatedButton.icon(
          onPressed: _openManualTemplateBuilder,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
        // Clear previous selections
        if (value != 'pdf') {
          _selectedFile = null;
        }
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

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
        showCustomSnackbar(
          message: 'File selected: ${result.files.first.name}',
          type: SnackbarType.success,
        );
      }
    } on Exception catch (e) {
      showCustomSnackbar(
        message: 'Error picking file: $e',
        type: SnackbarType.warning,
      );
    }
  }

  Future<void> _openManualTemplateBuilder() async {
    final result = await Navigator.push<List<QuestionSection>>(
      context,
      MaterialPageRoute(
        builder:
            (context) => ManualQuestionTemplateWidget(
              existingSections: _manualTemplateSections,
              subjectName: _selectedCourse?.courseName ?? 'Subject',
            ),
      ),
    );

    if (result != null) {
      setState(() {
        _manualTemplateSections = result;
      });
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

  Widget _buildActions() => Container(
    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: AppTheme.slate500),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontSize: AppTheme.fontSizeBase,
              fontWeight: AppTheme.fontWeightMedium,
              color: AppTheme.slate600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: AppTheme.blue500,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon:
              _isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Icon(Icons.add, size: 20),
          label: Text(
            _isLoading ? 'Creating...' : 'Create Assignment',
            style: const TextStyle(
              fontSize: AppTheme.fontSizeBase,
              fontWeight: AppTheme.fontWeightMedium,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );

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

    final dto = CreateAssignmentDto(
      subjectId: _selectedSubject!.id,

      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      maxMarks: int.parse(_marksController.text.trim()),
      dueDate: _dueDate!,
    );

    final success = await provider.createAssignment(uuid, dto);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        showCustomSnackbar(
          message: 'Assignment created successfully',
          type: SnackbarType.success,
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        showCustomSnackbar(
          message: provider.error ?? 'Failed to create assignment',
          type: SnackbarType.error,
        );
      }
    }
  }
}
