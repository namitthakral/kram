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
  const AddStudentDialog({super.key, this.courses = const []});

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
  final _addressController = TextEditingController();

  // Parent/Guardian Controllers
  final _fatherNameController = TextEditingController();
  final _fatherEmailController = TextEditingController();
  final _fatherMobileController = TextEditingController();

  final _motherNameController = TextEditingController();
  final _motherEmailController = TextEditingController();
  final _motherMobileController = TextEditingController();

  final _guardianNameController = TextEditingController();
  final _guardianEmailController = TextEditingController();
  final _guardianMobileController = TextEditingController();

  bool _guardianSameAsParent = false;
  String? _guardianParentType; // 'father' or 'mother'
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
      final list = await CoursesService().getAllCourses(
        institutionId: institutionId,
      );
      if (mounted) {
        setState(() {
          _courses = list;
          _loadingCourses = false;
        });
      }
    } on Exception catch (_) {
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
      // Use smart API selection - automatically chooses between simple and complex
      final names = await CoursesService().getCourseSectionNames(courseId);
      if (mounted) {
        setState(() {
          _sections = names;
          _loadingSections = false;
        });
      }
    } on Exception catch (_) {
      if (mounted) {
        setState(() {
          _sections = [];
          _loadingSections = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();

    // Parent/Guardian controllers
    _fatherNameController.dispose();
    _fatherEmailController.dispose();
    _fatherMobileController.dispose();
    _motherNameController.dispose();
    _motherEmailController.dispose();
    _motherMobileController.dispose();
    _guardianNameController.dispose();
    _guardianEmailController.dispose();
    _guardianMobileController.dispose();

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

    // Validate parent information
    final hasFather = _fatherNameController.text.trim().isNotEmpty;
    final hasMother = _motherNameController.text.trim().isNotEmpty;
    final hasGuardian =
        !_guardianSameAsParent &&
        _guardianNameController.text.trim().isNotEmpty;

    if (!hasFather && !hasMother && !hasGuardian) {
      showCustomSnackbar(
        message: 'Please provide at least one parent/guardian information',
        type: SnackbarType.error,
      );
      return;
    }

    // Validate guardian selection if "same as parent" is checked
    if (_guardianSameAsParent && _guardianParentType == null) {
      showCustomSnackbar(
        message: 'Please select which parent is the guardian',
        type: SnackbarType.error,
      );
      return;
    }

    // Validate that selected guardian parent has information
    if (_guardianSameAsParent) {
      if (_guardianParentType == 'father' && !hasFather) {
        showCustomSnackbar(
          message:
              'Please provide father information if father is the guardian',
          type: SnackbarType.error,
        );
        return;
      }
      if (_guardianParentType == 'mother' && !hasMother) {
        showCustomSnackbar(
          message:
              'Please provide mother information if mother is the guardian',
          type: SnackbarType.error,
        );
        return;
      }
    }

    try {
      final adminService = AdminService();
      final body = <String, dynamic>{
        'firstName': _firstNameController.text.trim(),
        'lastName':
            _lastNameController.text.trim().isEmpty
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
          'admissionDate':
              (_selectedAdmissionDate ?? DateTime.now())
                  .toIso8601String()
                  .split('T')
                  .first,
          // Parent/Guardian Information
          if (_fatherNameController.text.trim().isNotEmpty)
            'fatherInfo': {
              'name': _fatherNameController.text.trim(),
              if (_fatherEmailController.text.trim().isNotEmpty)
                'email': _fatherEmailController.text.trim(),
              if (_fatherMobileController.text.trim().isNotEmpty)
                'mobile': _fatherMobileController.text.trim(),
            },
          if (_motherNameController.text.trim().isNotEmpty)
            'motherInfo': {
              'name': _motherNameController.text.trim(),
              if (_motherEmailController.text.trim().isNotEmpty)
                'email': _motherEmailController.text.trim(),
              if (_motherMobileController.text.trim().isNotEmpty)
                'mobile': _motherMobileController.text.trim(),
            },
          if (!_guardianSameAsParent &&
              _guardianNameController.text.trim().isNotEmpty)
            'guardianInfo': {
              'name': _guardianNameController.text.trim(),
              if (_guardianEmailController.text.trim().isNotEmpty)
                'email': _guardianEmailController.text.trim(),
              if (_guardianMobileController.text.trim().isNotEmpty)
                'mobile': _guardianMobileController.text.trim(),
            },
          'guardianSameAsParent': _guardianSameAsParent,
          if (_guardianSameAsParent && _guardianParentType != null)
            'guardianParentType': _guardianParentType,
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
    } on Exception catch (e) {
      if (!mounted) return;
      showCustomSnackbar(
        message: e.toString().replaceFirst('Exception: ', ''),
        type: SnackbarType.error,
      );
    } finally {}
  }

  @override
  Widget build(BuildContext context) => CustomFormDialog(
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
                    validator:
                        (v) =>
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
                    validator:
                        (v) =>
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
                    onDateSelected:
                        (d) => setState(() => _selectedAdmissionDate = d),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Student Email and Phone
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
                    label: context.translate('phone_number'),
                    hintText: context.translate('enter_phone_number'),
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty)
                                ? context.translate('please_enter_phone')
                                : null,
                  ),
                ),
              ],
            ),

            // Parent/Guardian Information Section
            const SizedBox(height: 24),
            Text(
              'Parent/Guardian Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Father Information
            Text(
              'Father Information',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Father Name',
                    hintText: 'Enter father name',
                    controller: _fatherNameController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    label: 'Father Email',
                    hintText: 'Enter father email',
                    controller: _fatherEmailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v != null &&
                          v.trim().isNotEmpty &&
                          !v.contains('@')) {
                        return 'Please enter valid email';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Father Mobile',
              hintText: 'Enter father mobile number',
              controller: _fatherMobileController,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            // Mother Information
            Text(
              'Mother Information',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Mother Name',
                    hintText: 'Enter mother name',
                    controller: _motherNameController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    label: 'Mother Email',
                    hintText: 'Enter mother email',
                    controller: _motherEmailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v != null &&
                          v.trim().isNotEmpty &&
                          !v.contains('@')) {
                        return 'Please enter valid email';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Mother Mobile',
              hintText: 'Enter mother mobile number',
              controller: _motherMobileController,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            // Guardian Logic
            CheckboxListTile(
              title: const Text('Guardian is same as Father/Mother'),
              value: _guardianSameAsParent,
              onChanged: (value) {
                setState(() {
                  _guardianSameAsParent = value ?? false;
                  if (!_guardianSameAsParent) {
                    _guardianParentType = null;
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            if (_guardianSameAsParent) ...[
              const SizedBox(height: 8),
              Text(
                'Select Guardian',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Father'),
                      value: 'father',
                      groupValue: _guardianParentType,
                      onChanged: (value) {
                        setState(() {
                          _guardianParentType = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Mother'),
                      value: 'mother',
                      groupValue: _guardianParentType,
                      onChanged: (value) {
                        setState(() {
                          _guardianParentType = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],

            if (!_guardianSameAsParent) ...[
              const SizedBox(height: 16),
              Text(
                'Guardian Information',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Guardian Name',
                      hintText: 'Enter guardian name',
                      controller: _guardianNameController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Guardian Email',
                      hintText: 'Enter guardian email',
                      controller: _guardianEmailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v != null &&
                            v.trim().isNotEmpty &&
                            !v.contains('@')) {
                          return 'Please enter valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Guardian Mobile',
                hintText: 'Enter guardian mobile number',
                controller: _guardianMobileController,
                keyboardType: TextInputType.phone,
              ),
            ],
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

  Widget _buildClassDropdown(BuildContext context) {
    final courses = _courses;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.translate('class'),
          style: const TextStyle(
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
              hint: Text(
                _loadingCourses
                    ? context.translate('loading')
                    : context.translate('select_class'),
              ),
              items: [
                DropdownMenuItem<int?>(
                  child: Text(context.translate('select_class')),
                ),
                ...courses.map((c) {
                  final id = c['id'] as int?;
                  final name =
                      c['name'] as String? ??
                      c['subjectName'] as String? ??
                      '${c['id']}';
                  return DropdownMenuItem<int?>(
                    value: id,
                    child: Text(name.toString()),
                  );
                }),
              ],
              onChanged:
                  _loadingCourses
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

  Widget _buildSectionDropdown(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.translate('section'),
        style: const TextStyle(
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
            hint: Text(
              _loadingSections
                  ? context.translate('loading')
                  : _sections.isEmpty && _selectedCourseId != null
                  ? 'No sections available - create class sections first'
                  : context.translate('select_section'),
            ),
            items:
                _sections.isEmpty
                    ? [
                      DropdownMenuItem<String?>(
                        enabled: false,
                        child: Text(
                          _selectedCourseId == null
                              ? context.translate('select_course_first')
                              : 'No sections available',
                          style: const TextStyle(color: AppTheme.slate500),
                        ),
                      ),
                    ]
                    : [
                      DropdownMenuItem<String?>(
                        child: Text(context.translate('select_section')),
                      ),
                      ..._sections.map(
                        (s) =>
                            DropdownMenuItem<String?>(value: s, child: Text(s)),
                      ),
                    ],
            onChanged:
                _loadingSections || _sections.isEmpty
                    ? null
                    : (v) => setState(() => _selectedSection = v),
          ),
        ),
      ),
    ],
  );
}
