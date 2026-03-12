import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/extensions.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../../../widgets/custom_widgets/academic_year_dropdown.dart';
import '../../teacher/services/teacher_service.dart';
import '../services/admin_service.dart';

class EditTeacherDialog extends StatefulWidget {
  const EditTeacherDialog({super.key, required this.teacher});
  final Map<String, dynamic> teacher;

  @override
  State<EditTeacherDialog> createState() => _EditTeacherDialogState();
}

class _EditTeacherDialogState extends State<EditTeacherDialog> {
  final _formKey = GlobalKey<FormState>();
  final TeacherService _teacherService = TeacherService();
  final AdminService _adminService = AdminService();

  late final TextEditingController _designationController;
  // id → display name for selected subjects
  final Map<int, String> _selectedSubjects = {};
  List<Map<String, dynamic>> _allSubjects = [];
  int? _selectedAcademicYearId;
  late final TextEditingController _qualificationController;
  late final TextEditingController _experienceController;

  late String _employmentType;
  late String _status;
  bool _isSaving = false;

  final List<String> _employmentTypes = ['FULL_TIME', 'PART_TIME', 'CONTRACT'];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
    final t = widget.teacher;
    _designationController = TextEditingController(text: t['designation'] as String? ?? '');
    
    // Pre-populate subjects from teacherSubjects
    final subjects = t['teacherSubjects'] as List<dynamic>? ?? [];
    for (var ts in subjects) {
      final s = ts['subject'] as Map<String, dynamic>?;
      if (s != null && s['id'] != null) {
        _selectedSubjects[s['id'] as int] = s['subjectName'] as String? ?? 'Subject';
        // Take the academic year from the first subject if not set (usually they are all for the same year in this view)
        _selectedAcademicYearId ??= ts['academicYearId'] as int?;
      }
    }

    _qualificationController = TextEditingController(text: t['qualification'] as String? ?? '');
    _experienceController = TextEditingController(
      text: (t['experienceYears'] != null) ? t['experienceYears'].toString() : '',
    );
    _employmentType = (t['employmentType'] as String?) ?? 'FULL_TIME';
    // Normalize in case the stored value isn't in our list
    if (!_employmentTypes.contains(_employmentType)) {
      _employmentType = 'FULL_TIME';
    }
    final user = t['user'] as Map<String, dynamic>?;
    _status = (user?['status'] as String?) ?? 'ACTIVE';
    if (_status != 'ACTIVE' && _status != 'INACTIVE') _status = 'ACTIVE';
  }

  @override
  void dispose() {
    _designationController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  bool _isLoadingSubjects = false;
  Future<void> _loadSubjects() async {
    setState(() => _isLoadingSubjects = true);
    try {
      final subjects = await _adminService.getSubjects(status: 'ACTIVE');
      if (mounted) {
        setState(() {
          _allSubjects = subjects.cast<Map<String, dynamic>>();
        });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _isLoadingSubjects = false);
    }
  }

  String get _teacherName {
    final user = widget.teacher['user'] as Map<String, dynamic>?;
    return user?['name'] as String? ?? 'Teacher';
  }

  String get _teacherUuid {
    final user = widget.teacher['user'] as Map<String, dynamic>?;
    return user?['uuid'] as String? ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final initials = UserUtils.getInitials(_teacherName);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 640),
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
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppTheme.blue500.withValues(alpha: 0.15),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.blue600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Teacher',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.slate800,
                          ),
                        ),
                        Text(
                          _teacherName,
                          style: TextStyle(fontSize: 13, color: AppTheme.slate500),
                        ),
                      ],
                    ),
                  ),
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
                      CustomTextField(
                        controller: _designationController,
                        label: 'Designation',
                        hintText: 'e.g., Senior Lecturer, HOD',
                      ),
                      const SizedBox(height: 14),
                      AcademicYearDropdown(
                        value: _selectedAcademicYearId,
                        onChanged: (v) => setState(() => _selectedAcademicYearId = v),
                      ),
                      const SizedBox(height: 14),
                      _buildSubjectSelector(),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _qualificationController,
                        label: 'Qualification',
                        hintText: 'e.g., M.Sc. Computer Science',
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _experienceController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                labelText: 'Experience (years)',
                                hintText: 'e.g., 5',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              ),
                              validator: (v) {
                                if (v != null && v.trim().isNotEmpty) {
                                  if (int.tryParse(v) == null) return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _employmentType,
                              decoration: InputDecoration(
                                labelText: 'Employment Type',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                              ),
                              items: _employmentTypes.map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(t.replaceAll('_', ' ')),
                              )).toList(),
                              onChanged: (v) => setState(() => _employmentType = v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // ── Status toggle ─────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _StatusToggle(
                              value: _status,
                              onChanged: (v) => setState(() => _status = v),
                            ),
                          ),
                        ],
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
                    onPressed: _isSaving ? null : _saveTeacher,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.blue500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
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

  Future<void> _saveTeacher() async {
    if (!_formKey.currentState!.validate()) return;
    final uuid = _teacherUuid;
    if (uuid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teacher UUID not found'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final data = <String, dynamic>{
        if (_designationController.text.trim().isNotEmpty)
          'designation': _designationController.text.trim(),
        'subjectIds': _selectedSubjects.keys.toList(),
        if (_selectedAcademicYearId != null)
          'academicYearId': _selectedAcademicYearId,
        if (_qualificationController.text.trim().isNotEmpty)
          'qualification': _qualificationController.text.trim(),
        if (_experienceController.text.trim().isNotEmpty)
          'experienceYears': int.parse(_experienceController.text.trim()),
        'employmentType': _employmentType,
        'userStatus': _status,
      };
      await _teacherService.updateTeacher(uuid, data);
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teacher updated successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update teacher: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildSubjectSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subjects (Specialization)',
          style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.slate600, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.slate200),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: null,
              isExpanded: true,
              hint: _isLoadingSubjects
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                      _allSubjects.isEmpty ? 'No subjects available' : 'Select subjects...',
                      style: TextStyle(color: AppTheme.slate500, fontSize: 14),
                    ),
              items: _allSubjects.map((s) {
                final id = s['id'] as int;
                final name = s['subjectName'] as String;
                final isSelected = _selectedSubjects.containsKey(id);
                return DropdownMenuItem<int>(
                  value: id,
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                        size: 16,
                        color: isSelected ? AppTheme.blue500 : AppTheme.slate500,
                      ),
                      const SizedBox(width: 10),
                      Text(name, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (id) {
                if (id == null) return;
                setState(() {
                  if (_selectedSubjects.containsKey(id)) {
                    _selectedSubjects.remove(id);
                  } else {
                    final s = _allSubjects.firstWhere((x) => x['id'] == id);
                    _selectedSubjects[id] = s['subjectName'] as String;
                  }
                });
              },
            ),
          ),
        ),
        if (_selectedSubjects.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedSubjects.entries.map((e) {
              return Chip(
                label: Text(e.value, style: const TextStyle(fontSize: 12)),
                onDeleted: () => setState(() => _selectedSubjects.remove(e.key)),
                backgroundColor: AppTheme.blue500.withValues(alpha: 0.1),
                side: BorderSide(color: AppTheme.blue500.withValues(alpha: 0.2)),
                deleteIconColor: AppTheme.blue500,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

// ── Status toggle widget ─────────────────────────────────────────────

class _StatusToggle extends StatelessWidget {
  const _StatusToggle({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isActive = value == 'ACTIVE';
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      child: Row(
        children: [
          _chip(
            label: 'Active',
            selected: isActive,
            color: const Color(0xFF10b981),
            onTap: () => onChanged('ACTIVE'),
          ),
          const SizedBox(width: 8),
          _chip(
            label: 'Inactive',
            selected: !isActive,
            color: const Color(0xFFef4444),
            onTap: () => onChanged('INACTIVE'),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(
            color: selected ? color : AppTheme.slate200,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? color : AppTheme.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
