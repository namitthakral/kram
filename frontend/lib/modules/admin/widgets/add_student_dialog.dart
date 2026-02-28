import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/courses_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/custom_widgets/custom_date_picker_field.dart';
import '../../../widgets/custom_widgets/custom_form_dialog.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../providers/admin_students_provider.dart';
import '../services/admin_service.dart';

/// Dialog to add a new student. Calls POST /admin/users with roleId=3 and studentData.
class AddStudentDialog extends StatefulWidget {
  const AddStudentDialog({
    super.key,
    this.courses = const [],
  });

  final List<dynamic> courses;

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianEmailController = TextEditingController();
  final _addressController = TextEditingController();
  int? _selectedCourseId;
  String? _selectedSection;
  DateTime? _selectedDob;
  DateTime? _selectedAdmissionDate;

  List<dynamic> _courses = [];
  List<String> _sections = [];
  bool _loadingCourses = false;
  bool _loadingSections = false;

  @override
  void initState() {
    super.initState();
    _courses = List<dynamic>.from(widget.courses);
    if (_courses.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadCourses());
    }
    _selectedAdmissionDate = DateTime.now();
  }

  Future<void> _loadCourses() async {
    final loginProvider = context.read<LoginProvider>();
    final institutionId = loginProvider.currentUser?.institutionId;
    if (institutionId == null) return;
    setState(() => _loadingCourses = true);
    try {
      final list = await CoursesService().getAllCourses(institutionId: institutionId);
      if (mounted) setState(() {
        _courses = list;
        _loadingCourses = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingCourses = false);
    }
  }

  Future<void> _loadSectionsForCourse(int courseId) async {
    setState(() {
      _loadingSections = true;
      _selectedSection = null;
      _sections = [];
    });
    try {
      final names = await CoursesService().getCourseSectionNames(courseId);
      if (mounted) setState(() {
        _sections = names.isNotEmpty ? names : ['A', 'B', 'C', 'D'];
        _loadingSections = false;
      });
    } catch (_) {
      if (mounted) setState(() {
        _sections = ['A', 'B', 'C', 'D'];
        _loadingSections = false;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _guardianNameController.dispose();
    _guardianEmailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final loginProvider = context.read<LoginProvider>();
    final institutionId = loginProvider.currentUser?.institutionId;
    if (institutionId == null) {
      showCustomSnackbar(
        message: context.translate('institution_not_found'),
        type: SnackbarType.error,
      );
      return;
    }
    try {
      final adminService = AdminService();
      final body = <String, dynamic>{
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim().isEmpty
            ? _firstNameController.text.trim()
            : _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        // Don't send password - let backend auto-generate temporary password
        'roleId': 3,
        'institutionId': institutionId,
        'studentData': <String, dynamic>{
          'courseId': _selectedCourseId,
          'section': _selectedSection,
          'emergencyContactName': _guardianNameController.text.trim().isEmpty
              ? null
              : _guardianNameController.text.trim(),
          'emergencyContactPhone': _phoneController.text.trim(),
          'emergencyContactEmail': _guardianEmailController.text.trim().isEmpty
              ? null
              : _guardianEmailController.text.trim(),
          'admissionDate': (_selectedAdmissionDate ?? DateTime.now())
              .toIso8601String()
              .split('T')
              .first,
        },
      };
      if (_selectedDob != null) {
        body['dateOfBirth'] = _selectedDob!.toIso8601String().split('T').first;
      }
      await adminService.createInstitutionalUser(body);
      if (!mounted) return;
      context.read<AdminStudentsProvider>().fetchStudents();
      Navigator.of(context).pop();
      showCustomSnackbar(
        message: context.translate('student_added_successfully'),
        type: SnackbarType.success,
      );
    } catch (e) {
      if (!mounted) return;
      showCustomSnackbar(
        message: e.toString().replaceFirst('Exception: ', ''),
        type: SnackbarType.error,
      );
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return CustomFormDialog(
      title: context.translate('add_new_student'),
      subtitle: context.translate('add_new_student_subtitle'),
      headerIcon: Icons.person_add_rounded,
      confirmText: context.translate('add_student'),
      cancelText: context.translate('cancel'),
      confirmColor: AppTheme.blue500,
      maxWidth: 560,
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: context.translate('first_name'),
                      hintText: context.translate('enter_student_name'),
                      controller: _firstNameController,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? context.translate('please_enter_first_name')
                              : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: context.translate('last_name'),
                      hintText: context.translate('last_name'),
                      controller: _lastNameController,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? context.translate('please_enter_last_name')
                              : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: context.translate('roll_number'),
                      hintText: context.translate('auto_generated'),
                      isEnabled: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildClassDropdown(context)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSectionDropdown(context)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomDatePickerField(
                      label: context.translate('date_of_birth'),
                      hintText: 'dd/mm/yyyy',
                      selectedDate: _selectedDob,
                      firstDate: DateTime(DateTime.now().year - 100),
                      lastDate: DateTime.now(),
                      onDateSelected: (d) => setState(() => _selectedDob = d),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomDatePickerField(
                      label: context.translate('admission_date'),
                      hintText: context.translate('select_date'),
                      selectedDate: _selectedAdmissionDate,
                      firstDate: DateTime(DateTime.now().year - 5),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      onDateSelected: (d) =>
                          setState(() => _selectedAdmissionDate = d),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: context.translate('guardian_name'),
                      hintText: context.translate('enter_guardian_name'),
                      controller: _guardianNameController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: context.translate('phone_number'),
                      hintText: context.translate('enter_phone_number'),
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? context.translate('please_enter_phone')
                              : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: context.translate('student_email'),
                      hintText: context.translate('email'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return context.translate('please_enter_email');
                        }
                        if (!v.contains('@')) {
                          return context.translate('please_enter_valid_email');
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: context.translate('guardian_email'),
                      hintText: context.translate('email'),
                      controller: _guardianEmailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v != null &&
                            v.trim().isNotEmpty &&
                            !v.contains('@')) {
                          return context.translate('please_enter_valid_email');
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: context.translate('address'),
                hintText: context.translate('enter_complete_address'),
                controller: _addressController,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      onConfirm: _submit,
      onCancel: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildClassDropdown(BuildContext context) {
    final courses = _courses;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.translate('class'),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.slate600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.slate200),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: _selectedCourseId,
              isExpanded: true,
              hint: Text(_loadingCourses
                  ? context.translate('loading')
                  : context.translate('select_class')),
              items: [
                DropdownMenuItem<int?>(
                    value: null, child: Text(context.translate('select_class'))),
                ...courses.map((c) {
                  final id = c['id'] as int?;
                  final name = c['name'] as String? ??
                      c['subjectName'] as String? ??
                      '${c['id']}';
                  return DropdownMenuItem<int?>(
                    value: id,
                    child: Text(name.toString()),
                  );
                }),
              ],
              onChanged: _loadingCourses
                  ? null
                  : (v) {
                      setState(() {
                        _selectedCourseId = v;
                        _selectedSection = null;
                      });
                      if (v != null) _loadSectionsForCourse(v);
                    },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.translate('section'),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.slate600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.slate200),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: _selectedSection,
              isExpanded: true,
              hint: Text(_loadingSections
                  ? context.translate('loading')
                  : context.translate('select_section')),
              items: [
                DropdownMenuItem<String?>(
                    value: null,
                    child: Text(context.translate('select_section'))),
                ..._sections.map((s) => DropdownMenuItem<String?>(
                      value: s,
                      child: Text(s),
                    )),
              ],
              onChanged: _loadingSections
                  ? null
                  : (v) => setState(() => _selectedSection = v),
            ),
          ),
        ),
      ],
    );
  }
}
