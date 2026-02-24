import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
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
  int _selectedRoleId = 1;

  static const Map<int, String> _roles = {
    1: 'Student',
    2: 'Teacher',
    3: 'Parent',
    4: 'Staff',
    5: 'Admin',
  };

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
      maxWidth: 500,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              label: context.translate('first_name'),
              hintText: context.translate('first_name'),
              controller: _firstNameController,
              validator: (v) =>
                  (v == null || v.trim().isEmpty)
                      ? context.translate('please_enter_first_name')
                      : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: context.translate('last_name'),
              hintText: context.translate('last_name'),
              controller: _lastNameController,
              validator: (v) =>
                  (v == null || v.trim().isEmpty)
                      ? context.translate('please_enter_last_name')
                      : null,
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
              validator: (v) =>
                  (v == null || v.trim().isEmpty)
                      ? context.translate('please_enter_phone')
                      : null,
            ),
            const SizedBox(height: 16),
            FormFieldLabel(label: context.translate('role'), required: true),
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
          ],
        ),
      ),
      onConfirm: () async {
        if (!(_formKey.currentState?.validate() ?? false)) return;
        final provider = context.read<UserManagementProvider>();
        final success = await provider.createUser({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'roleId': _selectedRoleId,
        });
        if (!context.mounted) return;
        if (success) {
          Navigator.of(context).pop();
          showCustomSnackbar(
            message: context.translate('user_created_successfully'),
            type: SnackbarType.success,
          );
        } else {
          showCustomSnackbar(
            message: provider.error ?? context.translate('failed_to_create_user'),
            type: SnackbarType.error,
          );
        }
      },
      onCancel: () => Navigator.of(context).pop(),
    );
  }
}
