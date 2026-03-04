import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/courses_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/custom_widgets/custom_form_dialog.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../providers/user_management_provider.dart';

class CreateUserDialog extends StatefulWidget {
  const CreateUserDialog({super.key});

  @override
  State<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Teacher-specific
  final _designationController = TextEditingController();
  final _qualificationController = TextEditingController();

  // Student-specific
  int? _selectedCourseId;
  final _sectionController = TextEditingController();
  List<Map<String, dynamic>> _courses = [];
  bool _loadingCourses = false;

  // Parent-specific
  final _childKramidController = TextEditingController();
  String _parentRelation = 'FATHER';

  // Staff-specific
  final _staffDesignationController = TextEditingController();
  final _staffDepartmentController = TextEditingController();
  String _staffType = 'ADMINISTRATIVE';

  bool _showPassword = false;

  /// DB role IDs: 2=admin, 3=student, 4=parent, 5=teacher, 7=staff
  int _selectedRoleId = 5;

  static const Map<int, String> _roles = {
    2: 'Admin',
    3: 'Student',
    4: 'Parent',
    5: 'Teacher',
    7: 'Staff',
  };

  static const List<String> _parentRelations = [
    'FATHER',
    'MOTHER',
    'GUARDIAN',
    'OTHER',
  ];

  static const List<String> _staffTypes = [
    'ADMINISTRATIVE',
    'TECHNICAL',
    'SUPPORT',
    'SECURITY',
    'MAINTENANCE',
    'TRANSPORT',
    'CLEANING',
    'CAFETERIA',
    'MEDICAL',
  ];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _loadingCourses = true);
    try {
      final coursesService = CoursesService();
      final courses = await coursesService.getAllCourses();
      setState(() {
        _courses = courses.cast<Map<String, dynamic>>();
        _loadingCourses = false;
      });
    } catch (e) {
      setState(() => _loadingCourses = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load courses: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _designationController.dispose();
    _qualificationController.dispose();
    _sectionController.dispose();
    _childKramidController.dispose();
    _staffDesignationController.dispose();
    _staffDepartmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomFormDialog(
      title: context.translate('create_user'),
      headerIcon: Icons.person_add_rounded,
      confirmText: context.translate('create'),
      cancelText: context.translate('cancel'),
      confirmColor: AppTheme.blue500,
      maxWidth: 520,
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
                      hintText: context.translate('first_name'),
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
              CustomTextField(
                label: context.translate('email'),
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
              const SizedBox(height: 16),
              CustomTextField(
                label: context.translate('phone_number'),
                hintText: context.translate('phone_number'),
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => setState(() => _showPassword = !_showPassword),
                child: Row(
                  children: [
                    Icon(
                      _showPassword
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppTheme.slate500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _showPassword
                          ? 'Hide custom password'
                          : 'Set custom password (optional)',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.slate500,
                      ),
                    ),
                  ],
                ),
              ),
              if (_showPassword) ...[
                const SizedBox(height: 8),
                CustomTextField(
                  label: 'Password',
                  hintText: 'Min 8 chars, Aa1@',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (v) {
                    if (!_showPassword || v == null || v.isEmpty) return null;
                    if (v.length < 8) return 'Minimum 8 characters';
                    final regex = RegExp(
                      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])',
                    );
                    if (!regex.hasMatch(v)) {
                      return 'Need: A-Z, a-z, 0-9, @\$!%*?&';
                    }
                    return null;
                  },
                ),
              ],
              if (!_showPassword) ...[
                const SizedBox(height: 4),
                Text(
                  'A temporary password will be auto-generated (NAME+YEAR)',
                  style: TextStyle(fontSize: 12, color: AppTheme.slate500),
                ),
              ],
              const SizedBox(height: 16),
              FormFieldLabel(
                label: context.translate('role'),
                required: true,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.slate200),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedRoleId,
                    isExpanded: true,
                    items: _roles.entries
                        .map(
                          (e) => DropdownMenuItem<int>(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedRoleId = v);
                    },
                  ),
                ),
              ),

              // Teacher-specific fields
              if (_selectedRoleId == 5) ...[
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Designation',
                        hintText: 'e.g. Professor, Lecturer',
                        controller: _designationController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Qualification',
                        hintText: 'e.g. M.Sc., Ph.D.',
                        controller: _qualificationController,
                      ),
                    ),
                  ],
                ),
              ],

              // Student-specific fields
              if (_selectedRoleId == 3) ...[
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Course *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _loadingCourses
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : DropdownButton<int>(
                                    value: _selectedCourseId,
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    hint: const Text('Select Course'),
                                    items: _courses
                                        .map(
                                          (course) => DropdownMenuItem<int>(
                                            value: course['id'] as int,
                                            child: Text(course['name'] as String),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) {
                                      setState(() => _selectedCourseId = v);
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Section',
                        hintText: 'e.g. A, B, C',
                        controller: _sectionController,
                      ),
                    ),
                  ],
                ),
              ],

              // Parent-specific fields
              if (_selectedRoleId == 4) ...[
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Child Kram ID *',
                  hintText: 'Enter student\'s Kram ID',
                  controller: _childKramidController,
                  validator: (v) {
                    if (_selectedRoleId == 4 &&
                        (v == null || v.trim().isEmpty)) {
                      return 'Child Kram ID is required for parent';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                FormFieldLabel(label: 'Relation', required: true),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.slate200),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _parentRelation,
                      isExpanded: true,
                      items: _parentRelations
                          .map(
                            (r) => DropdownMenuItem<String>(
                              value: r,
                              child: Text(
                                r[0] + r.substring(1).toLowerCase(),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _parentRelation = v);
                      },
                    ),
                  ),
                ),
              ],

              // Staff-specific fields
              if (_selectedRoleId == 7) ...[
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Designation *',
                        hintText: 'Enter staff designation',
                        controller: _staffDesignationController,
                        validator: (v) {
                          if (_selectedRoleId == 7 &&
                              (v == null || v.trim().isEmpty)) {
                            return 'Designation is required for staff';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Department',
                        hintText: 'Enter department',
                        controller: _staffDepartmentController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FormFieldLabel(label: 'Staff Type', required: true),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.slate200),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _staffType,
                      isExpanded: true,
                      items: _staffTypes
                          .map(
                            (type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(
                                type[0] + type.substring(1).toLowerCase(),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _staffType = v);
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      onConfirm: () async {
        if (!(_formKey.currentState?.validate() ?? false)) return;

        final loginProvider = context.read<LoginProvider>();
        final institutionId = loginProvider.currentUser?.institutionId;
        if (institutionId == null) {
          showCustomSnackbar(
            message: 'Institution not found for current user',
            type: SnackbarType.error,
          );
          return;
        }

        // Only send password if user explicitly provided one
        // Otherwise, let backend auto-generate temporary password (NAME+YEAR)
        final customPassword = _passwordController.text.trim();

        final userData = <String, dynamic>{
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'roleId': _selectedRoleId,
          'institutionId': institutionId,
        };

        // Only include password if user provided one
        if (customPassword.isNotEmpty) {
          userData['password'] = customPassword;
        }

        final phone = _phoneController.text.trim();
        if (phone.isNotEmpty) userData['phoneNumber'] = phone;

        // Teacher data
        if (_selectedRoleId == 5) {
          final teacherData = <String, dynamic>{};
          final designation = _designationController.text.trim();
          final qualification = _qualificationController.text.trim();
          if (designation.isNotEmpty) teacherData['designation'] = designation;
          if (qualification.isNotEmpty) {
            teacherData['qualification'] = qualification;
          }
          // Always send teacherData for teacher role, even if empty
          userData['teacherData'] = teacherData;
        }

        // Student data
        if (_selectedRoleId == 3) {
          final studentData = <String, dynamic>{};
          if (_selectedCourseId != null) {
            studentData['courseId'] = _selectedCourseId;
          }
          final section = _sectionController.text.trim();
          if (section.isNotEmpty) {
            studentData['section'] = section;
          }
          userData['studentData'] = studentData;
        }

        // Parent data
        if (_selectedRoleId == 4) {
          userData['parentData'] = {
            'childKramid': _childKramidController.text.trim(),
            'relation': _parentRelation,
            'isPrimaryContact': true,
          };
        }

        // Staff data
        if (_selectedRoleId == 7) {
          final staffData = <String, dynamic>{
            'staffType': _staffType,
            'designation': _staffDesignationController.text.trim(),
          };
          final department = _staffDepartmentController.text.trim();
          if (department.isNotEmpty) staffData['department'] = department;
          // Always send staffData for staff role
          userData['staffData'] = staffData;
        }

        final provider = context.read<UserManagementProvider>();
        final success = await provider.createUser(userData);
        if (!context.mounted) return;
        if (success) {
          Navigator.of(context).pop();
          showCustomSnackbar(
            message: context.translate('user_created_successfully'),
            type: SnackbarType.success,
          );
        } else {
          showCustomSnackbar(
            message:
                provider.error ?? context.translate('failed_to_create_user'),
            type: SnackbarType.error,
          );
        }
      },
      onCancel: () => Navigator.of(context).pop(),
    );
  }
}
