import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/courses_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../../teacher/services/teacher_service.dart';
import '../providers/class_section_management_provider.dart';

class CreateClassSectionDialog extends StatefulWidget {
  const CreateClassSectionDialog({super.key});

  @override
  State<CreateClassSectionDialog> createState() =>
      _CreateClassSectionDialogState();
}

class _CreateClassSectionDialogState extends State<CreateClassSectionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _sectionNameController = TextEditingController();
  final _maxCapacityController = TextEditingController();
  final _roomController = TextEditingController();
  final _scheduleController = TextEditingController();

  final CoursesService _coursesService = CoursesService();
  final TeacherService _teacherService = TeacherService();

  List<dynamic> _courses = [];
  List<dynamic> _teachers = [];

  int? _selectedCourseId;
  int? _selectedTeacherId;
  String _selectedStatus = 'ACTIVE';

  bool _loadingCourses = false;
  bool _loadingTeachers = false;

  final List<String> _statusOptions = ['ACTIVE', 'INACTIVE'];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _sectionNameController.dispose();
    _maxCapacityController.dispose();
    _roomController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final loginProvider = context.read<LoginProvider>();
    final user = loginProvider.currentUser;
    final institutionId = user?.institutionId;

    if (institutionId != null) {
      await _loadCourses(institutionId);
      _loadTeachers();
    }
  }

  Future<void> _loadCourses(int institutionId) async {
    setState(() => _loadingCourses = true);
    try {
      final courses = await _coursesService.getAllCourses(
        institutionId: institutionId,
        status: 'ACTIVE',
      );
      setState(() => _courses = courses);
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load courses: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _loadingCourses = false);
    }
  }

  Future<void> _loadTeachers() async {
    try {
      setState(() => _loadingTeachers = true);

      final response = await _teacherService.getAllTeachers(limit: 100);
      final teachersList = response['data'] as List<dynamic>? ?? [];

      setState(() {
        _teachers = teachersList;
        _loadingTeachers = false;
      });
    } on Exception catch (e) {
      setState(() {
        _teachers = [];
        _loadingTeachers = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load teachers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Dialog(
    child: Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.class_, color: AppTheme.blue500),
                const SizedBox(width: 8),
                Text(
                  context.translate('create_new_class_section'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Information message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Smart section creation: Automatically uses simple divisions for school courses (Class I, Grade 5) or complex sections for university courses (B.Sc., M.Tech) based on course type.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Course Dropdown
                    DropdownButtonFormField<int>(
                      initialValue: _selectedCourseId,
                      decoration: InputDecoration(
                        labelText: context.translate('course'),
                        border: const OutlineInputBorder(),
                      ),
                      hint:
                          _loadingCourses
                              ? const Text('Loading courses...')
                              : Text(context.translate('select_course')),
                      items:
                          _courses
                              .map(
                                (course) => DropdownMenuItem<int>(
                                  value: course['id'] as int,
                                  child: Text(
                                    course['name'] ?? 'Unknown Course',
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged:
                          _loadingCourses
                              ? null
                              : (value) {
                                setState(() {
                                  _selectedCourseId = value;
                                });
                              },
                      validator:
                          (value) =>
                              value == null
                                  ? context.translate('course_required')
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    // Section Name
                    CustomTextField(
                      controller: _sectionNameController,
                      label: context.translate('section_name'),
                      hintText: context.translate('enter_section_name'),
                      validator:
                          (value) =>
                              value == null || value.trim().isEmpty
                                  ? context.translate('section_name_required')
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    // Teacher Dropdown (Optional)
                    DropdownButtonFormField<int>(
                      initialValue: _selectedTeacherId,
                      decoration: InputDecoration(
                        labelText: context.translate('teacher'),
                        border: const OutlineInputBorder(),
                        helperText: 'Optional - assign teacher later if needed',
                        suffixIcon:
                            _loadingTeachers
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : null,
                      ),
                      hint:
                          _loadingTeachers
                              ? const Text('Loading teachers...')
                              : _teachers.isEmpty
                              ? const Text('No teachers available')
                              : Text(
                                context.translate('select_teacher_optional'),
                              ),
                      items:
                          _loadingTeachers
                              ? []
                              : [
                                const DropdownMenuItem<int>(
                                  child: Text('No teacher assigned'),
                                ),
                                ..._teachers.map(
                                  (teacher) => DropdownMenuItem<int>(
                                    value: teacher['id'] as int,
                                    child: Text(
                                      '${teacher['user']?['firstName'] ?? ''} ${teacher['user']?['lastName'] ?? ''}'
                                              .trim()
                                              .isEmpty
                                          ? 'Unknown Teacher'
                                          : '${teacher['user']?['firstName'] ?? ''} ${teacher['user']?['lastName'] ?? ''}'
                                              .trim(),
                                    ),
                                  ),
                                ),
                              ],
                      onChanged:
                          _loadingTeachers || _teachers.isEmpty
                              ? null
                              : (value) => setState(() {
                                _selectedTeacherId = value;
                              }),
                    ),
                    const SizedBox(height: 16),

                    // Max Capacity
                    CustomTextField(
                      controller: _maxCapacityController,
                      label: context.translate('max_capacity'),
                      hintText: context.translate('enter_max_capacity'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Room
                    CustomTextField(
                      controller: _roomController,
                      label: context.translate('room'),
                      hintText: context.translate('enter_room'),
                    ),
                    const SizedBox(height: 16),

                    // Schedule (Optional)
                    CustomTextField(
                      controller: _scheduleController,
                      label: 'Schedule (Optional)',
                      hintText: 'e.g., Mon-Fri 9:00-10:00 AM',
                    ),
                    const SizedBox(height: 16),

                    // Status
                    DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      decoration: InputDecoration(
                        labelText: context.translate('status'),
                        border: const OutlineInputBorder(),
                      ),
                      items:
                          _statusOptions
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) => setState(() {
                            _selectedStatus = value!;
                          }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.translate('cancel')),
                ),
                const SizedBox(width: 16),
                Consumer<ClassSectionManagementProvider>(
                  builder:
                      (context, provider, child) => ElevatedButton(
                        onPressed:
                            provider.isCreating ? null : _createClassSection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.blue500,
                          foregroundColor: Colors.white,
                        ),
                        child:
                            provider.isCreating
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Text(
                                  context.translate('create_class_section'),
                                ),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _createClassSection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final sectionData = <String, dynamic>{
      'courseId': _selectedCourseId,
      'sectionName': _sectionNameController.text.trim(),
      'status': _selectedStatus,
    };

    if (_selectedTeacherId != null) {
      sectionData['teacherId'] = _selectedTeacherId;
    }

    if (_maxCapacityController.text.trim().isNotEmpty) {
      sectionData['maxCapacity'] = int.tryParse(
        _maxCapacityController.text.trim(),
      );
    }

    if (_roomController.text.trim().isNotEmpty) {
      sectionData['roomNumber'] = _roomController.text.trim();
    }

    try {
      // Use the provider to create the section (this will automatically refresh the list)
      final provider = context.read<ClassSectionManagementProvider>();
      final success = await provider.createClassSection(sectionData);

      if (mounted) {
        Navigator.of(context).pop();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Class section created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Failed to create class section'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create class section: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
