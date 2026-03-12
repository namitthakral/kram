import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/courses_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../services/admin_service.dart';

class EditSubjectDialog extends StatefulWidget {
  const EditSubjectDialog({super.key, required this.subject});
  final Map<String, dynamic> subject;

  @override
  State<EditSubjectDialog> createState() => _EditSubjectDialogState();
}

class _EditSubjectDialogState extends State<EditSubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final AdminService _adminService = AdminService();
  final CoursesService _coursesService = CoursesService();

  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _creditsController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _theoryHoursController;
  late final TextEditingController _practicalHoursController;

  late String _selectedType;
  late String _selectedStatus;
  int? _selectedCourseId;
  bool _isSaving = false;

  List<Map<String, dynamic>> _courses = [];
  bool _loadingCourses = true;

  final List<String> _subjectTypes = ['CORE', 'ELECTIVE', 'MINOR', 'MAJOR'];
  final List<String> _statuses = ['ACTIVE', 'INACTIVE'];

  InputDecoration _inputDecoration(String label, String hint) => InputDecoration(
    labelText: label,
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );

  @override
  void initState() {
    super.initState();
    final s = widget.subject;
    _nameController = TextEditingController(text: s['subjectName'] as String? ?? '');
    _codeController = TextEditingController(text: s['subjectCode'] as String? ?? '');
    _creditsController = TextEditingController(text: (s['credits'] ?? '').toString());
    _descriptionController = TextEditingController(text: s['description'] as String? ?? '');
    _theoryHoursController = TextEditingController(
      text: s['theoryHours'] != null ? s['theoryHours'].toString() : '',
    );
    _practicalHoursController = TextEditingController(
      text: s['practicalHours'] != null ? s['practicalHours'].toString() : '',
    );
    _selectedType = (s['subjectType'] as String?) ?? 'CORE';
    _selectedStatus = (s['status'] as String?) ?? 'ACTIVE';

    // Pre-select the course if it exists
    final existingCourse = s['course'] as Map<String, dynamic>?;
    if (existingCourse != null) {
      _selectedCourseId = existingCourse['id'] as int?;
    } else if (s['courseId'] != null) {
      _selectedCourseId = s['courseId'] as int?;
    }

    _loadCourses();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _creditsController.dispose();
    _descriptionController.dispose();
    _theoryHoursController.dispose();
    _practicalHoursController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    try {
      final list = await _coursesService.getAllCourses();
      if (mounted) {
        setState(() {
          _courses = list.cast<Map<String, dynamic>>();
          _loadingCourses = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingCourses = false);
    }
  }

  String _courseName(Map<String, dynamic> c) =>
      c['name'] as String? ?? c['courseName'] as String? ?? 'Course';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 760),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.blue500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit_rounded, color: AppTheme.blue500, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text('Edit Subject', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.slate800)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Name + Code
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: CustomTextField(
                              controller: _nameController,
                              label: 'Subject Name',
                              hintText: 'e.g., Data Structures',
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _codeController,
                              label: 'Subject Code',
                              hintText: 'e.g., CS201',
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Course Dropdown
                      _buildCourseDropdown(context),
                      const SizedBox(height: 14),

                      // Credits + Type
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _creditsController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: _inputDecoration('Credits / Marks', 'e.g., 4'),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Required';
                                if (int.tryParse(v) == null || int.parse(v) < 1) return 'Enter ≥ 1';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedType,
                              decoration: _inputDecoration('Subject Type', ''),
                              items: _subjectTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (v) => setState(() => _selectedType = v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _theoryHoursController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: _inputDecoration('Theory Hours/Week', 'e.g., 3'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _practicalHoursController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: _inputDecoration('Practical Hours/Week', 'e.g., 2'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: _inputDecoration('Status', ''),
                        items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => _selectedStatus = v!),
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _descriptionController,
                        label: 'Description (optional)',
                        hintText: 'Brief description of the subject',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    child: Text(context.translate('cancel')),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveSubject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.blue500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Save Changes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseDropdown(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.slate200),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.school_outlined, size: 20, color: AppTheme.slate500),
          const SizedBox(width: 8),
          Expanded(
            child: _loadingCourses
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Row(children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 10),
                      Text('Loading courses…', style: TextStyle(fontSize: 14)),
                    ]),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: _selectedCourseId,
                      isExpanded: true,
                      hint: Text('Select Course (optional)', style: TextStyle(color: AppTheme.slate500, fontSize: 14)),
                      items: [
                        // ── "Manage Courses" shortcut ──
                        DropdownMenuItem<int?>(
                          value: -1,
                          child: Row(
                            children: [
                              Icon(Icons.add_circle_outline_rounded, size: 16, color: AppTheme.blue500),
                              const SizedBox(width: 8),
                              Text(
                                'Manage Courses…',
                                style: TextStyle(
                                  color: AppTheme.blue500,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ..._courses.map((c) {
                          final id = c['id'] as int? ?? 0;
                          return DropdownMenuItem<int?>(
                            value: id,
                            child: Text(_courseName(c), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                          );
                        }),
                      ],
                      onChanged: (v) {
                        if (v == -1) {
                          Navigator.of(context).pop();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            // ignore: use_build_context_synchronously
                            GoRouter.of(context).push('/courses');
                          });
                          return;
                        }
                        setState(() => _selectedCourseId = v);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSubject() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final subjectId = widget.subject['id'] as int;
      final data = <String, dynamic>{
        'subjectName': _nameController.text.trim(),
        'subjectCode': _codeController.text.trim(),
        'credits': int.parse(_creditsController.text.trim()),
        'subjectType': _selectedType,
        'status': _selectedStatus,
        'courseId': _selectedCourseId, // null is valid (unlinks course)
        if (_descriptionController.text.trim().isNotEmpty)
          'description': _descriptionController.text.trim(),
        if (_theoryHoursController.text.trim().isNotEmpty)
          'theoryHours': int.parse(_theoryHoursController.text.trim()),
        if (_practicalHoursController.text.trim().isNotEmpty)
          'practicalHours': int.parse(_practicalHoursController.text.trim()),
      };
      await _adminService.updateSubject(subjectId, data);
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subject updated successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update subject: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
