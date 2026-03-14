import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/courses_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../services/admin_service.dart';

class AddSubjectDialog extends StatefulWidget {
  const AddSubjectDialog({super.key});

  @override
  State<AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final AdminService _adminService = AdminService();
  final CoursesService _coursesService = CoursesService();

  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _creditsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _theoryHoursController = TextEditingController();
  final _practicalHoursController = TextEditingController();

  String _selectedType = 'CORE';
  int? _selectedCourseId;
  bool _isCreating = false;

  // Course dropdown state
  List<Map<String, dynamic>> _courses = [];
  bool _loadingCourses = true;

  final List<String> _subjectTypes = ['CORE', 'ELECTIVE', 'MINOR', 'MAJOR'];

  InputDecoration _inputDecoration(String label, String hint) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      );

  @override
  void initState() {
    super.initState();
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
      final list = await _coursesService.getAllCourses(status: 'ACTIVE');
      if (mounted) {
        setState(() {
          _courses = list.cast<Map<String, dynamic>>();
          _loadingCourses = false;
        });
      }
    } on Exception catch (_) {
      if (mounted) setState(() => _loadingCourses = false);
    }
  }

  String _courseName(Map<String, dynamic> c) =>
      c['name'] as String? ?? c['courseName'] as String? ?? 'Course';

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
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
                  child: const Icon(
                    Icons.book_rounded,
                    color: AppTheme.blue500,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Add Subject',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate800,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Name + Code row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: CustomTextField(
                            controller: _nameController,
                            label: 'Subject Name',
                            hintText: 'e.g., Data Structures',
                            validator:
                                (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Required'
                                        : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _codeController,
                            label: 'Subject Code (optional)',
                            hintText: 'e.g., CS201',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Course Dropdown
                    _buildCourseDropdown(),
                    const SizedBox(height: 14),

                    // Credits + Type row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _creditsController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: _inputDecoration(
                              'Credits / Marks (optional)',
                              'e.g., 4',
                            ),
                            validator: (v) {
                              if (v != null && v.trim().isNotEmpty) {
                                if (int.tryParse(v) == null || int.parse(v) < 1) {
                                  return 'Enter ≥ 1';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedType,
                            decoration: _inputDecoration('Subject Type', ''),
                            items:
                                _subjectTypes
                                    .map(
                                      (t) => DropdownMenuItem(
                                        value: t,
                                        child: Text(t),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (v) => setState(() => _selectedType = v!),
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
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: _inputDecoration(
                              'Theory Hours/Week',
                              'e.g., 3',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _practicalHoursController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: _inputDecoration(
                              'Practical Hours/Week',
                              'e.g., 2',
                            ),
                          ),
                        ),
                      ],
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
                  onPressed:
                      _isCreating ? null : () => Navigator.of(context).pop(),
                  child: Text(context.translate('cancel')),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isCreating ? null : _createSubject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.blue500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child:
                      _isCreating
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text('Add Subject'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildCourseDropdown() => Container(
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
          child:
              _loadingCourses
                  ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Loading courses…',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  )
                  : DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: _selectedCourseId,
                      isExpanded: true,
                      hint: const Text(
                        'Select Course (optional)',
                        style: TextStyle(
                          color: AppTheme.slate500,
                          fontSize: 14,
                        ),
                      ),
                      items: [
                        // ── "Manage Courses" shortcut ──
                        const DropdownMenuItem<int?>(
                          value: -1,
                          child: Row(
                            children: [
                              Icon(
                                Icons.add_circle_outline_rounded,
                                size: 16,
                                color: AppTheme.blue500,
                              ),
                              SizedBox(width: 8),
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
                            child: Text(
                              _courseName(c),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }),
                      ],
                      onChanged: (v) {
                        if (v == -1) {
                          // Navigate to courses page
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

  Future<void> _createSubject() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isCreating = true);
    try {
      final data = <String, dynamic>{
        'subjectName': _nameController.text.trim(),
        if (_codeController.text.trim().isNotEmpty)
          'subjectCode': _codeController.text.trim(),
        if (_creditsController.text.trim().isNotEmpty)
          'credits': int.parse(_creditsController.text.trim()),
        'subjectType': _selectedType,
        if (_selectedCourseId != null) 'courseId': _selectedCourseId,
        if (_descriptionController.text.trim().isNotEmpty)
          'description': _descriptionController.text.trim(),
        if (_theoryHoursController.text.trim().isNotEmpty)
          'theoryHours': int.parse(_theoryHoursController.text.trim()),
        if (_practicalHoursController.text.trim().isNotEmpty)
          'practicalHours': int.parse(_practicalHoursController.text.trim()),
      };
      await _adminService.createSubject(data);
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subject created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create subject: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }
}
