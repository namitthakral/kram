import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
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
    if (uuid == null) return;

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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.assignmentId == null ? 'Create Assignment' : 'Edit Assignment',
      ),
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCourseDropdown(),
          const SizedBox(height: 16),
          _buildSectionDropdown(),
          const SizedBox(height: 16),
          _buildTitleField(),
          const SizedBox(height: 16),
          _buildDescriptionField(),
          const SizedBox(height: 16),
          _buildInstructionsField(),
          const SizedBox(height: 16),
          _buildMaxMarksField(),
          const SizedBox(height: 16),
          _buildDateFields(),
          const SizedBox(height: 16),
          _buildStatusDropdown(),
          const SizedBox(height: 24),
          _buildSubmitButton(),
        ],
      ),
    ),
  );

  Widget _buildCourseDropdown() => Consumer<AssignmentProvider>(
    builder:
        (context, provider, child) => DropdownButtonFormField<Course>(
          initialValue: _selectedCourse,
          decoration: const InputDecoration(
            labelText: 'Course *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.book),
          ),
          items:
              provider.courses
                  .map(
                    (course) => DropdownMenuItem(
                      value: course,
                      child: Text(
                        '${course.courseCode} - ${course.courseName}',
                      ),
                    ),
                  )
                  .toList(),
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
              return 'Please select a course';
            }
            return null;
          },
        ),
  );

  Widget _buildSectionDropdown() => Consumer<AssignmentProvider>(
    builder:
        (context, provider, child) => DropdownButtonFormField<Section>(
          initialValue: _selectedSection,
          decoration: const InputDecoration(
            labelText: 'Section (Optional)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.class_),
            hintText: 'Leave empty for all sections',
          ),
          items:
              provider.sections
                  .map(
                    (section) => DropdownMenuItem(
                      value: section,
                      child: Text('Section ${section.sectionName}'),
                    ),
                  )
                  .toList(),
          onChanged: (section) {
            setState(() {
              _selectedSection = section;
            });
          },
        ),
  );

  Widget _buildTitleField() => TextFormField(
    controller: _titleController,
    decoration: const InputDecoration(
      labelText: 'Assignment Title *',
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.title),
      hintText: 'e.g., Chapter 5 Homework',
    ),
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Please enter a title';
      }
      if (value.length < 3) {
        return 'Title must be at least 3 characters';
      }
      return null;
    },
  );

  Widget _buildDescriptionField() => TextFormField(
    controller: _descriptionController,
    decoration: const InputDecoration(
      labelText: 'Description *',
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.description),
      hintText: 'Describe what students need to do',
    ),
    maxLines: 3,
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Please enter a description';
      }
      return null;
    },
  );

  Widget _buildInstructionsField() => TextFormField(
    controller: _instructionsController,
    decoration: const InputDecoration(
      labelText: 'Instructions (Optional)',
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.list),
      hintText: 'Additional instructions or guidelines',
    ),
    maxLines: 3,
  );

  Widget _buildMaxMarksField() => TextFormField(
    controller: _maxMarksController,
    decoration: const InputDecoration(
      labelText: 'Maximum Marks *',
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.grade),
      hintText: 'e.g., 100',
    ),
    keyboardType: TextInputType.number,
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Please enter maximum marks';
      }
      final marks = int.tryParse(value);
      if (marks == null || marks <= 0) {
        return 'Please enter a valid positive number';
      }
      return null;
    },
  );

  Widget _buildDateFields() => Row(
    children: [
      Expanded(
        child: InkWell(
          onTap: () => _selectDate(context, isAssignedDate: true),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Assigned Date *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(
              _assignedDate != null
                  ? DateFormat('MMM dd, yyyy').format(_assignedDate!)
                  : 'Select date',
              style: TextStyle(
                color: _assignedDate != null ? null : Colors.grey,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: InkWell(
          onTap: () => _selectDate(context, isAssignedDate: false),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Due Date *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.event),
            ),
            child: Text(
              _dueDate != null
                  ? DateFormat('MMM dd, yyyy').format(_dueDate!)
                  : 'Select date',
              style: TextStyle(color: _dueDate != null ? null : Colors.grey),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildStatusDropdown() => DropdownButtonFormField<String>(
    initialValue: _status,
    decoration: const InputDecoration(
      labelText: 'Status *',
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.info),
    ),
    items: const [
      DropdownMenuItem(value: 'DRAFT', child: Text('Draft')),
      DropdownMenuItem(value: 'PUBLISHED', child: Text('Published')),
      DropdownMenuItem(value: 'CLOSED', child: Text('Closed')),
    ],
    onChanged: (value) {
      if (value != null) {
        setState(() {
          _status = value;
        });
      }
    },
  );

  Widget _buildSubmitButton() => ElevatedButton(
    onPressed: _isLoading ? null : _submitForm,
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
    ),
    child:
        _isLoading
            ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
            : Text(
              widget.assignmentId == null
                  ? 'Create Assignment'
                  : 'Update Assignment',
              style: const TextStyle(fontSize: 16),
            ),
  );

  Future<void> _loadSections(int courseId) async {
    final loginProvider = context.read<LoginProvider>();
    final user = loginProvider.currentUser;
    final uuid = user?.uuid;
    if (uuid == null) return;

    final provider = context.read<AssignmentProvider>();
    await provider.loadSectionsForCourse(uuid, courseId);
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isAssignedDate,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          isAssignedDate
              ? (_assignedDate ?? DateTime.now())
              : (_dueDate ?? DateTime.now().add(const Duration(days: 7))),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isAssignedDate) {
          _assignedDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_assignedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an assigned date')),
      );
      return;
    }

    if (_dueDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a due date')));
      return;
    }

    if (_dueDate!.isBefore(_assignedDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Due date must be after assigned date')),
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
                  ? 'Assignment created successfully'
                  : 'Assignment updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'An error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
