import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
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
    if (uuid == null) return;

    final assignmentProvider = context.read<AssignmentProvider>();
    await assignmentProvider.loadCourses(uuid);

    final examProvider = context.read<ExaminationProvider>();
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.examinationId == null
            ? 'Create Examination'
            : 'Edit Examination',
      ),
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExamNameField(),
          const SizedBox(height: 16),
          _buildExamTypeDropdown(),
          const SizedBox(height: 16),
          _buildCourseDropdown(),
          const SizedBox(height: 16),
          _buildSemesterDropdown(),
          const SizedBox(height: 16),
          _buildMarksFields(),
          const SizedBox(height: 16),
          _buildDurationField(),
          const SizedBox(height: 16),
          _buildExamDateField(),
          const SizedBox(height: 16),
          _buildTimeFields(),
          const SizedBox(height: 16),
          _buildVenueField(),
          const SizedBox(height: 16),
          _buildInstructionsField(),
          const SizedBox(height: 16),
          _buildStatusDropdown(),
          const SizedBox(height: 24),
          _buildSubmitButton(),
        ],
      ),
    ),
  );

  Widget _buildExamNameField() => TextFormField(
    controller: _examNameController,
    decoration: const InputDecoration(
      labelText: 'Exam Name *',
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.quiz),
      hintText: 'e.g., Midterm Examination',
    ),
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Please enter exam name';
      }
      if (value.length < 3) {
        return 'Exam name must be at least 3 characters';
      }
      return null;
    },
  );

  Widget _buildExamTypeDropdown() => DropdownButtonFormField<String>(
    initialValue: _examType,
    decoration: const InputDecoration(
      labelText: 'Exam Type *',
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.category),
    ),
    items: const [
      DropdownMenuItem(value: 'QUIZ', child: Text('Quiz')),
      DropdownMenuItem(value: 'MIDTERM', child: Text('Midterm')),
      DropdownMenuItem(value: 'FINAL', child: Text('Final')),
      DropdownMenuItem(value: 'PRACTICAL', child: Text('Practical')),
      DropdownMenuItem(value: 'OTHER', child: Text('Other')),
    ],
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
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a course';
            }
            return null;
          },
        ),
  );

  Widget _buildSemesterDropdown() => Consumer<ExaminationProvider>(
    builder: (context, provider, child) {
      // For now, hardcode semester ID 1 since we don't have semester API
      return DropdownButtonFormField<int>(
        initialValue: _selectedSemesterId ?? 1,
        decoration: const InputDecoration(
          labelText: 'Semester *',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_month),
        ),
        items: const [
          DropdownMenuItem(value: 1, child: Text('Spring 2025')),
          DropdownMenuItem(value: 2, child: Text('Fall 2024')),
        ],
        onChanged: (semesterId) {
          setState(() {
            _selectedSemesterId = semesterId;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a semester';
          }
          return null;
        },
      );
    },
  );

  Widget _buildMarksFields() => Row(
    children: [
      Expanded(
        child: TextFormField(
          controller: _totalMarksController,
          decoration: const InputDecoration(
            labelText: 'Total Marks *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.grade),
            hintText: 'e.g., 100',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Required';
            }
            final marks = int.tryParse(value);
            if (marks == null || marks <= 0) {
              return 'Invalid';
            }
            return null;
          },
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: TextFormField(
          controller: _passingMarksController,
          decoration: const InputDecoration(
            labelText: 'Passing Marks *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.check_circle),
            hintText: 'e.g., 40',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Required';
            }
            final marks = int.tryParse(value);
            if (marks == null || marks <= 0) {
              return 'Invalid';
            }
            final totalMarks = int.tryParse(_totalMarksController.text);
            if (totalMarks != null && marks > totalMarks) {
              return 'Too high';
            }
            return null;
          },
        ),
      ),
    ],
  );

  Widget _buildDurationField() => TextFormField(
    controller: _durationController,
    decoration: const InputDecoration(
      labelText: 'Duration (minutes) *',
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.timer),
      hintText: 'e.g., 60',
    ),
    keyboardType: TextInputType.number,
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Please enter duration';
      }
      final duration = int.tryParse(value);
      if (duration == null || duration <= 0) {
        return 'Please enter a valid duration';
      }
      return null;
    },
  );

  Widget _buildExamDateField() => InkWell(
    onTap: () => _selectExamDate(context),
    child: InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Exam Date *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
      ),
      child: Text(
        _examDate != null
            ? DateFormat('MMM dd, yyyy').format(_examDate!)
            : 'Select exam date',
        style: TextStyle(color: _examDate != null ? null : Colors.grey),
      ),
    ),
  );

  Widget _buildTimeFields() => Row(
    children: [
      Expanded(
        child: InkWell(
          onTap: () => _selectTime(context, isStartTime: true),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Start Time',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.access_time),
            ),
            child: Text(
              _startTime != null ? _startTime!.format(context) : 'Select time',
              style: TextStyle(color: _startTime != null ? null : Colors.grey),
            ),
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: InkWell(
          onTap: () => _selectTime(context, isStartTime: false),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'End Time',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.access_time),
            ),
            child: Text(
              _endTime != null ? _endTime!.format(context) : 'Select time',
              style: TextStyle(color: _endTime != null ? null : Colors.grey),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildVenueField() => TextFormField(
    controller: _venueController,
    decoration: const InputDecoration(
      labelText: 'Venue (Optional)',
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.location_on),
      hintText: 'e.g., Room 101',
    ),
  );

  Widget _buildInstructionsField() => TextFormField(
    controller: _instructionsController,
    decoration: const InputDecoration(
      labelText: 'Instructions (Optional)',
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.list),
      hintText: 'Special instructions for students',
    ),
    maxLines: 3,
  );

  Widget _buildStatusDropdown() => DropdownButtonFormField<String>(
    initialValue: _status,
    decoration: const InputDecoration(
      labelText: 'Status *',
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.info),
    ),
    items: const [
      DropdownMenuItem(value: 'SCHEDULED', child: Text('Scheduled')),
      DropdownMenuItem(value: 'ONGOING', child: Text('Ongoing')),
      DropdownMenuItem(value: 'COMPLETED', child: Text('Completed')),
      DropdownMenuItem(value: 'CANCELLED', child: Text('Cancelled')),
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
              widget.examinationId == null
                  ? 'Create Examination'
                  : 'Update Examination',
              style: const TextStyle(fontSize: 16),
            ),
  );

  Future<void> _selectExamDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _examDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _examDate = picked;
      });
    }
  }

  Future<void> _selectTime(
    BuildContext context, {
    required bool isStartTime,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          isStartTime
              ? (_startTime ?? TimeOfDay.now())
              : (_endTime ?? TimeOfDay.now()),
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_examDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an exam date')),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.examinationId == null
                  ? 'Examination created successfully'
                  : 'Examination updated successfully',
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
