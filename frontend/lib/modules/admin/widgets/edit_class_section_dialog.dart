import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../../teacher/services/teacher_service.dart';
import '../providers/class_section_management_provider.dart';

class EditClassSectionDialog extends StatefulWidget {
  final Map<String, dynamic> section;

  const EditClassSectionDialog({
    super.key,
    required this.section,
  });

  @override
  State<EditClassSectionDialog> createState() => _EditClassSectionDialogState();
}

class _EditClassSectionDialogState extends State<EditClassSectionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _sectionNameController;
  late final TextEditingController _maxCapacityController;
  late final TextEditingController _roomController;
  late final TextEditingController _scheduleController;

  late String _selectedStatus;
  int? _selectedTeacherId;
  List<dynamic> _teachers = [];
  bool _loadingTeachers = false;

  final List<String> _statusOptions = ['ACTIVE', 'INACTIVE'];
  final TeacherService _teacherService = TeacherService();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadTeachers();
  }

  void _initializeControllers() {
    _sectionNameController = TextEditingController(text: widget.section['sectionName'] ?? '');
    _maxCapacityController = TextEditingController(text: widget.section['maxCapacity']?.toString() ?? '');
    _roomController = TextEditingController(text: widget.section['room'] ?? '');
    _scheduleController = TextEditingController(text: widget.section['schedule'] ?? '');

    _selectedStatus = widget.section['status'] ?? 'ACTIVE';
    
    // Initialize teacher selection
    final teacher = widget.section['teacher'] as Map<String, dynamic>?;
    _selectedTeacherId = teacher?['id'] as int?;
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
    } catch (e) {
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
  void dispose() {
    _sectionNameController.dispose();
    _maxCapacityController.dispose();
    _roomController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subject = widget.section['subject'] as Map<String, dynamic>?;
    final subjectName = subject?['subjectName'] ?? 'Unknown Subject';
    final semester = widget.section['semester'] as Map<String, dynamic>?;
    final semesterName = semester?['semesterName'] ?? 'Unknown Semester';
    final teacher = widget.section['teacher'] as Map<String, dynamic>?;
    final teacherUser = teacher?['user'] as Map<String, dynamic>?;
    final teacherName = teacherUser?['name'] ?? 'No Teacher Assigned';

    return Dialog(
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
                  const Icon(Icons.edit, color: AppTheme.blue500),
                  const SizedBox(width: 8),
                  Text(
                    context.translate('edit_class_section'),
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Display subject and semester (read-only)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.translate('subject'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subjectName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.translate('semester'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              semesterName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.translate('teacher'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              teacherName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Section Name
                      CustomTextField(
                        controller: _sectionNameController,
                        label: context.translate('section_name'),
                        hintText: context.translate('enter_section_name'),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? context.translate('section_name_required')
                            : null,
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

                      // Schedule
                      CustomTextField(
                        controller: _scheduleController,
                        label: context.translate('schedule'),
                        hintText: context.translate('enter_schedule'),
                      ),
                      const SizedBox(height: 16),

                      // Status
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: context.translate('status'),
                          border: const OutlineInputBorder(),
                        ),
                        items: _statusOptions.map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          )).toList(),
                        onChanged: (value) => setState(() => _selectedStatus = value!),
                      ),
                      const SizedBox(height: 16),

                      // Teacher Dropdown (Optional)
                      DropdownButtonFormField<int>(
                        value: _selectedTeacherId,
                        decoration: InputDecoration(
                          labelText: context.translate('teacher'),
                          border: const OutlineInputBorder(),
                          helperText: 'Optional - assign teacher later if needed',
                          suffixIcon: _loadingTeachers 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : null,
                        ),
                        hint: _loadingTeachers
                            ? const Text('Loading teachers...')
                            : _teachers.isEmpty
                                ? const Text('No teachers available')
                                : const Text('Select teacher (optional)'),
                        items: _loadingTeachers
                            ? []
                            : [
                                const DropdownMenuItem<int>(
                                  value: null,
                                  child: Text('No teacher assigned'),
                                ),
                                ..._teachers.map((teacher) => DropdownMenuItem<int>(
                                  value: teacher['id'] as int,
                                  child: Text(teacher['user']?['name'] ?? 'Unknown Teacher'),
                                )),
                              ],
                        onChanged: _loadingTeachers
                            ? null
                            : (value) => setState(() {
                                _selectedTeacherId = value;
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
                    builder: (context, provider, child) => ElevatedButton(
                        onPressed: provider.isUpdating ? null : _updateClassSection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.blue500,
                          foregroundColor: Colors.white,
                        ),
                        child: provider.isUpdating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(context.translate('update_class_section')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateClassSection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final sectionData = <String, dynamic>{
      'sectionName': _sectionNameController.text.trim(),
      'status': _selectedStatus,
    };

    if (_maxCapacityController.text.trim().isNotEmpty) {
      sectionData['maxCapacity'] = int.tryParse(_maxCapacityController.text.trim());
    }

    if (_roomController.text.trim().isNotEmpty) {
      sectionData['roomNumber'] = _roomController.text.trim();
    }

    if (_scheduleController.text.trim().isNotEmpty) {
      sectionData['schedule'] = _scheduleController.text.trim();
    }

    if (_selectedTeacherId != null) {
      sectionData['teacherId'] = _selectedTeacherId;
    }

    final provider = context.read<ClassSectionManagementProvider>();
    final success = await provider.updateClassSection(widget.section['id'] as int, sectionData);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('class_section_updated_successfully')),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}