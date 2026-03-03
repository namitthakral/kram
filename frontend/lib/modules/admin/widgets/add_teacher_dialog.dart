import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/admin_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';

class AddTeacherDialog extends StatefulWidget {
  const AddTeacherDialog({super.key});

  @override
  State<AddTeacherDialog> createState() => _AddTeacherDialogState();
}

class _AddTeacherDialogState extends State<AddTeacherDialog> {
  final _formKey = GlobalKey<FormState>();
  final AdminService _adminService = AdminService();

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _specialtyController = TextEditingController();

  String _selectedGender = 'MALE';
  bool _isCreating = false;

  final List<String> _genderOptions = ['MALE', 'FEMALE', 'OTHER'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_add, color: AppTheme.blue500),
                  const SizedBox(width: 8),
                  Text(
                    context.translate('add_teacher'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Basic Information
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _firstNameController,
                              label: context.translate('first_name'),
                              hintText: context.translate('enter_first_name'),
                              validator: (value) => value == null || value.trim().isEmpty
                                  ? context.translate('first_name_required')
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _lastNameController,
                              label: context.translate('last_name'),
                              hintText: context.translate('enter_last_name'),
                              validator: (value) => value == null || value.trim().isEmpty
                                  ? context.translate('last_name_required')
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Email and Phone
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _emailController,
                              label: context.translate('email'),
                              hintText: context.translate('enter_email'),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return context.translate('email_required');
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return context.translate('invalid_email');
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _phoneController,
                              label: context.translate('phone'),
                              hintText: context.translate('enter_phone'),
                              keyboardType: TextInputType.phone,
                              validator: (value) => value == null || value.trim().isEmpty
                                  ? context.translate('phone_required')
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Gender
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          labelText: context.translate('gender'),
                          border: const OutlineInputBorder(),
                        ),
                        items: _genderOptions.map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(context.translate(gender.toLowerCase())),
                          )).toList(),
                        onChanged: (value) => setState(() => _selectedGender = value!),
                      ),
                      const SizedBox(height: 16),

                      // Address
                      CustomTextField(
                        controller: _addressController,
                        label: context.translate('address'),
                        hintText: context.translate('enter_address'),
                        maxLines: 3,
                        validator: (value) => value == null || value.trim().isEmpty
                            ? context.translate('address_required')
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Professional Information
                      CustomTextField(
                        controller: _qualificationController,
                        label: context.translate('qualification'),
                        hintText: 'e.g., M.Sc. Computer Science',
                        validator: (value) => value == null || value.trim().isEmpty
                            ? context.translate('qualification_required')
                            : null,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _experienceController,
                              label: context.translate('experience_years'),
                              hintText: 'e.g., 5',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return context.translate('experience_required');
                                }
                                if (int.tryParse(value) == null) {
                                  return context.translate('invalid_number');
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _specialtyController,
                              label: context.translate('specialty'),
                              hintText: 'e.g., Mathematics, Physics',
                            ),
                          ),
                        ],
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
                    onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
                    child: Text(context.translate('cancel')),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isCreating ? null : _createTeacher,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.blue500,
                      foregroundColor: Colors.white,
                    ),
                    child: _isCreating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(context.translate('create_teacher')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createTeacher() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isCreating = true);

    try {
      final loginProvider = context.read<LoginProvider>();
      final user = loginProvider.currentUser;
      final institutionId = user?.institutionId;

      if (institutionId == null) {
        throw Exception('Institution ID not found');
      }

      final teacherData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'gender': _selectedGender,
        'address': _addressController.text.trim(),
        'institutionId': institutionId,
        'roleId': 5, // Teacher role ID
        'teacherData': {
          'qualification': _qualificationController.text.trim(),
          'experienceYears': int.parse(_experienceController.text.trim()),
          'specialization': _specialtyController.text.trim().isNotEmpty 
              ? _specialtyController.text.trim() 
              : null,
        },
      };

      final response = await _adminService.createInstitutionalUser(teacherData);

      if (mounted) {
        if (response['success'] == true) {
          Navigator.of(context).pop(true); // Return true to indicate success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translate('teacher_created_successfully')),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to create teacher'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create teacher: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
}