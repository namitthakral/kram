import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../modules/admin/services/admin_service.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/custom_widgets/custom_form_dialog.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';

/// Dialog for super admin to create an admin user for a specific institution.
class CreateInstitutionAdminDialog extends StatefulWidget {
  const CreateInstitutionAdminDialog({
    required this.institutionId,
    required this.institutionName,
    super.key,
  });

  final int institutionId;
  final String institutionName;

  @override
  State<CreateInstitutionAdminDialog> createState() =>
      _CreateInstitutionAdminDialogState();
}

class _CreateInstitutionAdminDialogState
    extends State<CreateInstitutionAdminDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final customPassword = _passwordController.text.trim();

    try {
      final adminService = AdminService();
      final userData = <String, dynamic>{
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'roleId': 2, // admin
        'institutionId': widget.institutionId,
        if (_phoneController.text.trim().isNotEmpty)
          'phoneNumber': _phoneController.text.trim(),
      };

      // Only include password if user provided one
      if (customPassword.isNotEmpty) {
        userData['password'] = customPassword;
      }

      await adminService.createInstitutionalUser(userData);

      if (!mounted) return;
      Navigator.of(context).pop(true);
      showCustomSnackbar(
        message: 'Admin created for ${widget.institutionName}',
        type: SnackbarType.success,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      showCustomSnackbar(
        message: e.toString().replaceFirst('Exception: ', ''),
        type: SnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomFormDialog(
      title: 'Create Admin',
      subtitle: widget.institutionName,
      headerIcon: Icons.admin_panel_settings_rounded,
      confirmText: _isSubmitting ? 'Creating...' : context.translate('create'),
      cancelText: context.translate('cancel'),
      confirmColor: AppTheme.blue500,
      maxWidth: 500,
      content: Form(
        key: _formKey,
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
              hintText: 'admin@school.in',
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.blue50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppTheme.blue500),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This admin will be able to manage all users, '
                      'students, teachers, and data for ${widget.institutionName}.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.slate600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onConfirm: _isSubmitting ? null : _submit,
      onCancel: () => Navigator.of(context).pop(),
    );
  }
}
