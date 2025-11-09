import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../utils/custom_images.dart';
import '../../utils/extensions.dart';
import '../../widgets/custom_widgets/custom_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.slate800),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        context.translate('Change Password'),
        style: context.textTheme.h3.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.slate800,
        ),
      ),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            label: context.translate('Current Password'),
            hintText: context.translate('Enter current password'),
            prefixButtonIcon: ButtonIcon(icon: CustomImages.iconLock),
            suffixButtonIcon: ButtonIcon(icon: CustomImages.iconVisible),
            controller: _currentPasswordController,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: context.translate('New Password'),
            hintText: context.translate('Enter new password'),
            prefixButtonIcon: ButtonIcon(icon: CustomImages.iconLock),
            suffixButtonIcon: ButtonIcon(icon: CustomImages.iconVisible),
            controller: _newPasswordController,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: context.translate('Confirm Password'),
            hintText: context.translate('Confirm new password'),
            prefixButtonIcon: ButtonIcon(icon: CustomImages.iconLock),
            suffixButtonIcon: ButtonIcon(icon: CustomImages.iconVisible),
            controller: _confirmPasswordController,
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () {
        // Handle password change
      },
      icon: const Icon(Icons.check),
      label: const Text('Update Password'),
      backgroundColor: AppTheme.blue500,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
  );
}
