import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/custom_widgets/custom_form_dialog.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../../admin/services/admin_service.dart';

class CreateInstitutionAdminDialog extends StatefulWidget {
  const CreateInstitutionAdminDialog({
    required this.institutionId,
    required this.institutionName,
    super.key,
    this.currentAdmin,
  });
  final int institutionId;
  final String institutionName;
  final Map<String, dynamic>? currentAdmin;

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
  final _searchController = TextEditingController();

  bool _isSubmitting = false;
  bool _showPassword = false;
  bool _isSearching = false;
  List<dynamic> _searchResults = [];
  String? _selectedUserUuid;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    if (widget.currentAdmin != null) {
      _selectUser(widget.currentAdmin!);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.length < 3) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
      return;
    }

    debugPrint('Search query: $query');
    if (mounted) {
      setState(() => _isSearching = true);
    }

    try {
      final adminService = AdminService();
      final response = await adminService.getAllUsers(search: query);
      debugPrint('Search response: $response');

      if (mounted) {
        setState(() {
          _searchResults = response['data']?['users'] ?? [];
          _isSearching = false;
        });
        debugPrint('Found ${_searchResults.length} users');

        if (_searchResults.length == 1) {
          _selectUser(_searchResults.first);
        }
      }
    } on Exception catch (e) {
      debugPrint('Search error: $e');
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _searchUsers(value);
    });
  }

  void _selectUser(Map<String, dynamic> user) {
    setState(() {
      _selectedUserUuid = user['uuid'];
      _firstNameController.text = user['firstName'] ?? '';
      _lastNameController.text = user['lastName'] ?? '';
      _emailController.text = user['email'] ?? '';
      _phoneController.text = user['phone'] ?? '';
      _searchResults = [];
      _searchController.clear();
    });
  }

  void _clearSelectedUser() {
    setState(() {
      _selectedUserUuid = null;
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _phoneController.clear();
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSubmitting = true);

    final customPassword = _passwordController.text.trim();

    try {
      final adminService = AdminService();

      if (_selectedUserUuid != null) {
        // Update existing user to assign to institution and set role to admin (2)
        final updateData = <String, dynamic>{
          'institutionId': widget.institutionId,
          'roleId': 2,
        };
        await adminService.updateUser(_selectedUserUuid!, updateData);
      } else {
        // Create new user
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
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
      showCustomSnackbar(
        message:
            'Admin ${_selectedUserUuid != null ? "assigned" : "created"} for ${widget.institutionName}',
        type: SnackbarType.success,
      );
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      showCustomSnackbar(
        message: e.toString().replaceFirst('Exception: ', ''),
        type: SnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) => CustomFormDialog(
    title: 'Create Admin',
    subtitle: widget.institutionName,
    headerIcon: Icons.admin_panel_settings_rounded,
    confirmText:
        _isSubmitting
            ? 'Processing...'
            : (_selectedUserUuid != null
                ? 'Assign Admin'
                : context.translate('create')),
    cancelText: context.translate('cancel'),
    confirmColor: AppTheme.blue500,
    maxWidth: 500,
    content: Form(
      key: _formKey,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search field
              CustomTextField(
                label: 'Search Existing User',
                hintText: 'Enter name or email to pick...',
                controller: _searchController,
                onChanged: _onSearchChanged,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon:
                    _isSearching
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(4.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.blue500,
                            ),
                          ),
                        )
                        : (_searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchResults = []);
                              },
                            )
                            : null),
              ),
              const SizedBox(height: 16),
              if (_selectedUserUuid != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.blue500.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.blue500.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 16,
                        color: AppTheme.blue500,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Existing user selected. Their details will be updated.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.blue500.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: _clearSelectedUser,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: context.translate('first_name'),
                      hintText: context.translate('first_name'),
                      controller: _firstNameController,
                      isEnabled: _selectedUserUuid == null,
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
                      isEnabled: _selectedUserUuid == null,
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
              CustomTextField(
                label: context.translate('email'),
                hintText: 'admin@school.in',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                isEnabled: _selectedUserUuid == null,
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
                isEnabled: _selectedUserUuid == null,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              if (_selectedUserUuid == null) ...[
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
                        style: const TextStyle(
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
                      if (!_showPassword || v == null || v.isEmpty) {
                        return null;
                      }
                      if (v.length < 8) {
                        return 'Minimum 8 characters';
                      }
                      final regex = RegExp(
                        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])',
                      );
                      if (!regex.hasMatch(v)) {
                        return r'Need: A-Z, a-z, 0-9, @$!%*?&';
                      }
                      return null;
                    },
                  ),
                ],
                if (!_showPassword) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'A temporary password will be auto-generated (NAME+YEAR)',
                    style: TextStyle(fontSize: 12, color: AppTheme.slate500),
                  ),
                ],
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
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppTheme.blue500,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This admin will be able to manage all users, '
                        'students, teachers, and data for ${widget.institutionName}.',
                        style: const TextStyle(
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
          if (_searchResults.isNotEmpty)
            Positioned(
              top: 86,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  constraints: const BoxConstraints(maxHeight: 320),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.slate200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Text(
                          'Matching Users',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: AppTheme.fontWeightMedium,
                            color: AppTheme.slate500,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _searchResults.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final user = _searchResults[index];
                            return ListTile(
                              dense: false,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              title: Text(
                                '${user['firstName']} ${user['lastName']}',
                                style: const TextStyle(
                                  fontWeight: AppTheme.fontWeightMedium,
                                ),
                              ),
                              subtitle: Text(
                                user['email'] ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.slate500,
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.blue50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  user['role']?['roleName'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.blue600,
                                    fontWeight: AppTheme.fontWeightMedium,
                                  ),
                                ),
                              ),
                              onTap: () => _selectUser(user),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
    onConfirm: _isSubmitting ? null : _submit,
    onCancel: () => Navigator.of(context).pop(),
  );
}
