import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../provider/login_signup/login_provider.dart';
import '../../provider/profile/change_password_provider.dart';
import '../../utils/app_bar_config_helper.dart';
import '../../utils/custom_images.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/extensions.dart';
import '../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../widgets/custom_widgets/custom_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Reset provider state when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChangePasswordProvider>().reset();
    });
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<ChangePasswordProvider>();
    await provider.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) {
      return;
    }

    if (provider.isPasswordChanged) {
      showCustomSnackbar(
        message: 'Password changed successfully',
        type: SnackbarType.success,
      );
      // Clear the form
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      // Go back after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    } else if (provider.error != null) {
      showCustomSnackbar(
        message: provider.error!,
        type: SnackbarType.warning,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChangePasswordProvider>();
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text(context.translate('user_not_found'))),
      );
    }

    return Scaffold(
      body: CustomMainScreenWithAppbar(
        title: context.translate('Change Password'),
        appBarConfig: AppBarConfigHelper.getConfigForUser(
          user,
          onNotificationIconPressed: () {},
          isProfileScreen: true,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: context.translate('Current Password'),
                hintText: context.translate('Enter current password'),
                prefixButtonIcon: ButtonIcon(icon: CustomImages.iconLock),
                suffixButtonIcon: ButtonIcon(
                  icon: _obscureCurrentPassword
                      ? CustomImages.iconVisible
                      : CustomImages.iconVisibleOff,
                  onIconTapped: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                validator: _validatePassword,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: context.translate('New Password'),
                hintText: context.translate('Enter new password'),
                prefixButtonIcon: ButtonIcon(icon: CustomImages.iconLock),
                suffixButtonIcon: ButtonIcon(
                  icon: _obscureNewPassword
                      ? CustomImages.iconVisible
                      : CustomImages.iconVisibleOff,
                  onIconTapped: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                validator: _validatePassword,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: context.translate('Confirm Password'),
                hintText: context.translate('Confirm new password'),
                prefixButtonIcon: ButtonIcon(icon: CustomImages.iconLock),
                suffixButtonIcon: ButtonIcon(
                  icon: _obscureConfirmPassword
                      ? CustomImages.iconVisible
                      : CustomImages.iconVisibleOff,
                  onIconTapped: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                validator: _validateConfirmPassword,
              ),
            ],
          ),
        ),
      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: provider.isLoading ? null : _handleChangePassword,
        icon: provider.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.check),
        label: Text(provider.isLoading ? 'Updating...' : 'Update Password'),
        backgroundColor:
            provider.isLoading ? AppTheme.blue500.withValues(alpha: 0.6) : AppTheme.blue500,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }
}
