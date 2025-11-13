import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/custom_widgets/custom_date_picker_field.dart';
import '../../../widgets/custom_widgets/custom_dropdown_field.dart';
import '../../../widgets/custom_widgets/custom_form_section.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../models/assignment_models.dart';
import '../providers/assignment_provider.dart';

/// Screen for creating or editing an assignment
class AssignmentFormScreen extends StatefulWidget {
  const AssignmentFormScreen({super.key, this.assignmentId});
  final int? assignmentId;

  @override
  State<AssignmentFormScreen> createState() => _AssignmentFormScreenState();
}

class _AssignmentFormScreenState extends State<AssignmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _maxMarksController = TextEditingController();

  Course? _selectedCourse;
  Section? _selectedSection;
  DateTime? _assignedDate;
  DateTime? _dueDate;
  String _status = 'DRAFT';
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

    final provider = context.read<AssignmentProvider>();
    await provider.loadCourses(uuid);

    // TODO: If editing, load assignment data
    if (widget.assignmentId != null) {
      // Load assignment details and populate form
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    _maxMarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return CustomMainScreenWithAppbar(
      title:
          widget.assignmentId == null
              ? context.translate('create_assignment')
              : context.translate('edit_assignment'),
      bottomWidget: _buildSubmitButton(),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.only(bottom: isMobile ? 16 : 24),
          children: [
            // Course & Section Section
            CustomFormSection(
              title: context.translate('course_section'),
              subtitle: context.translate('select_course_section_desc'),
              icon: Icons.school_outlined,
              children: [
                _buildCourseDropdown(),
                const SizedBox(height: 16),
                _buildSectionDropdown(),
              ],
            ),
            const SizedBox(height: 16),

            // Assignment Details Section
            CustomFormSection(
              title: context.translate('assignment_details'),
              subtitle: context.translate('enter_assignment_info'),
              icon: Icons.assignment_outlined,
              children: [
                _buildTitleField(),
                const SizedBox(height: 16),
                _buildDescriptionField(),
                const SizedBox(height: 16),
                _buildInstructionsField(),
                const SizedBox(height: 16),
                _buildMaxMarksField(),
              ],
            ),
            const SizedBox(height: 20),

            // Schedule Section
            CustomFormSection(
              title: context.translate('schedule'),
              subtitle: context.translate('set_assignment_dates'),
              icon: Icons.calendar_today_outlined,
              children: [_buildDateFields()],
            ),
            const SizedBox(height: 20),

            // Status Section
            CustomFormSection(
              title: context.translate('status'),
              subtitle: context.translate('set_assignment_status'),
              icon: Icons.info_outline,
              children: [_buildStatusDropdown()],
            ),
          ],
        ),
      ),
    );
  }

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
              _selectedSection = null; // Reset section when course changes
            });
            if (course != null) {
              _loadSections(course.id);
            }
          },
          validator: (value) {
            if (value == null) {
              return context.translate('please_select_course');
            }
            return null;
          },
        ),
  );

  Widget _buildSectionDropdown() => Consumer<AssignmentProvider>(
    builder:
        (context, provider, child) => DropDownFormField<Section>(
          label: context.translate('section_optional'),
          value: _selectedSection,
          hintText: context.translate('leave_empty_all_sections'),
          //prefixIcon: const Icon(Icons.class_),
          items: provider.sections,
          displayText: (section) => 'Section ${section.sectionName}',
          onChanged: (section) {
            setState(() {
              _selectedSection = section;
            });
          },
        ),
  );

  Widget _buildTitleField() => CustomTextField(
    label: context.translate('assignment_title_required'),
    controller: _titleController,
    hintText: context.translate('assignment_title_hint'),
    //prefixIcon: const Icon(Icons.title),
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return context.translate('please_enter_title');
      }
      if (value.length < 3) {
        return context.translate('title_min_3_chars');
      }
      return null;
    },
  );

  Widget _buildDescriptionField() => CustomTextField(
    label: context.translate('description_required'),
    controller: _descriptionController,
    hintText: context.translate('assignment_description_hint'),
    //prefixIcon: const Icon(Icons.description),
    maxLines: 3,
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return context.translate('please_enter_description');
      }
      return null;
    },
  );

  Widget _buildInstructionsField() => CustomTextField(
    label: context.translate('instructions_optional'),
    controller: _instructionsController,
    hintText: context.translate('instructions_hint'),
    // //prefixIcon: const Icon(Icons.list),
    maxLines: 3,
  );

  Widget _buildMaxMarksField() => CustomTextField(
    label: context.translate('maximum_marks_required'),
    controller: _maxMarksController,
    hintText: context.translate('marks_hint'),
    //prefixIcon: const Icon(Icons.grade),
    keyboardType: TextInputType.number,
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return context.translate('please_enter_max_marks');
      }
      final marks = int.tryParse(value);
      if (marks == null || marks <= 0) {
        return context.translate('enter_valid_positive_number');
      }
      return null;
    },
  );

  Widget _buildDateFields() => Row(
    children: [
      Expanded(
        child: CustomDatePickerField(
          label: context.translate('assigned_date_required'),
          selectedDate: _assignedDate,
          hintText: context.translate('select_date'),
          onDateSelected: (date) {
            setState(() {
              _assignedDate = date;
            });
          },
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: CustomDatePickerField(
          label: context.translate('due_date_required'),
          selectedDate: _dueDate,
          hintText: context.translate('select_date'),
          onDateSelected: (date) {
            setState(() {
              _dueDate = date;
            });
          },
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        ),
      ),
    ],
  );

  Widget _buildStatusDropdown() => DropDownFormField<String>(
    label: context.translate('status_required'),
    value: _status,
    hintText: context.translate('select_status'),
    //prefixIcon: const Icon(Icons.info),
    items: const ['DRAFT', 'PUBLISHED', 'CLOSED'],
    displayText: (value) {
      switch (value) {
        case 'DRAFT':
          return context.translate('draft');
        case 'PUBLISHED':
          return context.translate('published');
        case 'CLOSED':
          return context.translate('closed');
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
                  widget.assignmentId == null
                      ? context.translate('create_assignment')
                      : context.translate('update_assignment'),
                  style: TextStyle(fontSize: isMobile ? 14 : 16),
                ),
      ),
    );
  }

  Future<void> _loadSections(int courseId) async {
    final loginProvider = context.read<LoginProvider>();
    final user = loginProvider.currentUser;
    final uuid = user?.uuid;
    if (uuid == null) {
      return;
    }

    final provider = context.read<AssignmentProvider>();
    await provider.loadSectionsForCourse(uuid, courseId);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_assignedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('please_select_assigned_date')),
        ),
      );
      return;
    }

    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.translate('please_select_due_date'))),
      );
      return;
    }

    if (_dueDate!.isBefore(_assignedDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.translate('due_date_after_assigned'))),
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

    final provider = context.read<AssignmentProvider>();

    final dto = CreateAssignmentDto(
      courseId: _selectedCourse!.id,
      sectionId: _selectedSection?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      instructions:
          _instructionsController.text.trim().isNotEmpty
              ? _instructionsController.text.trim()
              : null,
      maxMarks: int.parse(_maxMarksController.text.trim()),
      assignedDate: _assignedDate!,
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
                title: _titleController.text.trim(),
                description: _descriptionController.text.trim(),
                instructions:
                    _instructionsController.text.trim().isNotEmpty
                        ? _instructionsController.text.trim()
                        : null,
                maxMarks: int.parse(_maxMarksController.text.trim()),
                assignedDate: _assignedDate,
                dueDate: _dueDate,
                status: _status,
              ),
            );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.assignmentId == null
                  ? context.translate('assignment_created_success')
                  : context.translate('assignment_updated_success'),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.error ?? context.translate('error_occurred'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
