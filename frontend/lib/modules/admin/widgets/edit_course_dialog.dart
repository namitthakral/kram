import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../providers/course_management_provider.dart';

class EditCourseDialog extends StatefulWidget {
  final Map<String, dynamic> course;

  const EditCourseDialog({
    super.key,
    required this.course,
  });

  @override
  State<EditCourseDialog> createState() => _EditCourseDialogState();
}

class _EditCourseDialogState extends State<EditCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _durationController;
  late final TextEditingController _totalSemestersController;
  bool _isSchool = false;

  late String _selectedDegreeType;
  late String _selectedDurationUnit;
  late String _selectedStatus;

  final List<String> _degreeTypes = [
    'BACHELORS',
    'MASTERS',
    'DIPLOMA',
    'CERTIFICATE',
    'PHD',
    'OTHER',
    'SCHOOL',
  ];

  final List<String> _durationUnits = ['Years', 'Months'];
  final List<String> _statusOptions = ['ACTIVE', 'INACTIVE'];

  @override
  void initState() {
    super.initState();
    _checkInstitutionType();
    _initializeControllers();
  }

  void _checkInstitutionType() {
    final loginProvider = context.read<LoginProvider>();
    setState(() {
      _isSchool = loginProvider.currentUser?.institution?.type == 'SCHOOL';
    });
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.course['name'] ?? '');
    _codeController = TextEditingController(text: widget.course['code'] ?? '');
    _descriptionController = TextEditingController(text: widget.course['description'] ?? '');
    _durationController = TextEditingController(text: widget.course['duration']?.toString() ?? '');
    _totalSemestersController = TextEditingController(text: widget.course['totalSemesters']?.toString() ?? '');

    _selectedDegreeType = widget.course['degreeType'] ?? 'BACHELORS';
    _selectedDurationUnit = widget.course['durationUnit'] ?? 'Years';
    _selectedStatus = widget.course['status'] ?? 'ACTIVE';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _totalSemestersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    context.translate('edit_course'),
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
                      CustomTextField(
                        controller: _nameController,
                        label: context.translate('course_name'),
                        hintText: context.translate('enter_course_name'),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? context.translate('course_name_required')
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _codeController,
                        label: context.translate('course_code'),
                        hintText: context.translate('enter_course_code'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedDegreeType,
                        decoration: InputDecoration(
                          labelText: context.translate('degree_type'),
                          border: const OutlineInputBorder(),
                        ),
                        items: _degreeTypes.map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          )).toList(),
                        onChanged: (value) => setState(() => _selectedDegreeType = value!),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _descriptionController,
                        label: context.translate('description'),
                        hintText: context.translate('enter_course_description'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _durationController,
                              label: context.translate('duration'),
                              hintText: context.translate('enter_duration'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedDurationUnit,
                              decoration: InputDecoration(
                                labelText: context.translate('duration_unit'),
                                border: const OutlineInputBorder(),
                              ),
                              items: _durationUnits.map((unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                )).toList(),
                              onChanged: (value) => setState(() => _selectedDurationUnit = value!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _totalSemestersController,
                        label: context.translate(_isSchool ? 'total_terms' : 'total_semesters'),
                        hintText: context.translate(_isSchool ? 'enter_total_terms' : 'enter_total_semesters'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
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
                  Consumer<CourseManagementProvider>(
                    builder: (context, provider, child) => ElevatedButton(
                        onPressed: provider.isUpdating ? null : _updateCourse,
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
                            : Text(context.translate('update_course')),
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

  Future<void> _updateCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final courseData = <String, dynamic>{
      'name': _nameController.text.trim(),
      'degreeType': _selectedDegreeType,
      'status': _selectedStatus,
    };

    if (_codeController.text.trim().isNotEmpty) {
      courseData['code'] = _codeController.text.trim();
    }

    if (_descriptionController.text.trim().isNotEmpty) {
      courseData['description'] = _descriptionController.text.trim();
    }

    if (_durationController.text.trim().isNotEmpty) {
      courseData['duration'] = int.tryParse(_durationController.text.trim());
      courseData['durationUnit'] = _selectedDurationUnit;
    }

    if (_totalSemestersController.text.trim().isNotEmpty) {
      courseData['totalSemesters'] = int.tryParse(_totalSemestersController.text.trim());
    }

    final provider = context.read<CourseManagementProvider>();
    final success = await provider.updateCourse(widget.course['id'] as int, courseData);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('course_updated_successfully')),
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