import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/extensions.dart';
import '../../../utils/router_service.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_form_dialog.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../services/admin_service.dart';

class InstitutionSettingsScreen extends StatefulWidget {
  const InstitutionSettingsScreen({super.key});

  @override
  State<InstitutionSettingsScreen> createState() =>
      _InstitutionSettingsScreenState();
}

class _InstitutionSettingsScreenState extends State<InstitutionSettingsScreen> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  Map<String, dynamic>? _schoolInfo;
  Map<String, dynamic>? _idConfig;
  String? _error;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final loginProvider = context.read<LoginProvider>();
      final institutionId = loginProvider.currentUser?.institutionId;

      if (institutionId != null) {
        final results = await Future.wait<dynamic>([
          _adminService.getInstitutionProfile(institutionId),
          _adminService.getIdConfig(institutionId),
        ]);

        if (!mounted) return;

        setState(() {
          _schoolInfo = results[0] as Map<String, dynamic>?;
          _idConfig = results[1] as Map<String, dynamic>?;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          _error = 'Institution ID not found';
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final userInitials = UserUtils.getInitials(user?.name ?? 'AD');
    final userName = user?.name ?? 'Admin';

    return CustomMainScreenWithAppbar(
      title: context.translate('institution_settings'),
      appBarConfig: AppBarConfig.admin(
        showBackButton: true,
        userInitials: userInitials,
        userName: userName,
        institutionName: user?.institution?.name ?? '',
        onNotificationIconPressed: () {},
      ),
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: Text(context.translate('retry')),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(context.translate('school_info')),
                    const SizedBox(height: 12),
                    _buildSchoolInfoSection(),
                    const SizedBox(height: 32),
                    _buildSectionHeader(context.translate('id_configuration')),
                    const SizedBox(height: 16),
                    if (_idConfig != null) ...[
                      _buildConfigItem(
                        'Admission ID Format',
                        _idConfig!['admissionNumberFormat'],
                      ),
                      _buildConfigItem(
                        'Teacher Employee ID Format',
                        _idConfig!['teacherEmployeeIdFormat'],
                      ),
                      _buildConfigItem(
                        'Roll No Format',
                        _idConfig!['rollNumberFormat'],
                      ),
                    ],
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _showEditConfigDialog(context),
                        icon: const Icon(Icons.edit),
                        label: Text(context.translate('edit_configuration')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.blue500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader(context.translate('academic_settings')),
                    const SizedBox(height: 12),
                    _buildAcademicSection(context, loginProvider),
                    const SizedBox(height: 32),
                    _buildSectionHeader(context.translate('system')),
                    const SizedBox(height: 12),
                    _buildSystemSection(context),
                    const SizedBox(height: 32),
                    _buildSectionHeader(context.translate('branding')),
                    const SizedBox(height: 12),
                    _buildBrandingSection(context),
                  ],
                ),
              ),
    );
  }

  void _showEditConfigDialog(BuildContext context) {
    final institutionId =
        context.read<LoginProvider>().currentUser?.institutionId;
    if (institutionId == null) return;

    final admissionController = TextEditingController(
      text: _idConfig?['admissionNumberFormat']?.toString() ?? '',
    );
    final employeeController = TextEditingController(
      text: _idConfig?['teacherEmployeeIdFormat']?.toString() ?? '',
    );
    final rollNoController = TextEditingController(
      text: _idConfig?['rollNumberFormat']?.toString() ?? '',
    );

    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => CustomFormDialog(
            title: context.translate('edit_configuration'),
            subtitle:
                'ID format patterns for admission, employee, and roll number',
            headerIcon: Icons.settings_applications_rounded,
            cancelText: context.translate('cancel'),
            confirmColor: AppTheme.blue500,
            maxWidth: 500,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  label: 'Admission ID Format',
                  hintText: 'e.g. ADM-YYYY-NNNN',
                  controller: admissionController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Teacher Employee ID Format',
                  hintText: 'e.g. EMP-NNNN',
                  controller: employeeController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Roll No Format',
                  hintText: 'e.g. RNNN',
                  controller: rollNoController,
                ),
              ],
            ),
            onConfirm: () async {
              if (_isSaving) return;
              if (!mounted) return;

              setState(() => _isSaving = true);

              try {
                final result = await _adminService
                    .updateIdConfig(institutionId, {
                      'admissionNumberFormat': admissionController.text.trim(),
                      'teacherEmployeeIdFormat': employeeController.text.trim(),
                      'rollNumberFormat': rollNoController.text.trim(),
                    });

                if (!mounted) return;

                // Close modal using the dialog context
                Navigator.of(dialogContext).pop();

                // Show success message
                showCustomSnackbar(
                  message: 'Configuration saved successfully',
                  type: SnackbarType.success,
                );

                // Reload data in background without blocking
                _loadData();
              } on Exception catch (e) {
                if (!mounted) return;

                showCustomSnackbar(
                  message: e.toString().replaceFirst('Exception: ', ''),
                  type: SnackbarType.error,
                );
              } finally {
                if (mounted) {
                  setState(() => _isSaving = false);
                }
              }
            },
            onCancel: () => Navigator.of(dialogContext).pop(),
          ),
    ).then((_) {
      admissionController.dispose();
      employeeController.dispose();
      rollNoController.dispose();
    });
  }

  Widget _buildSchoolInfoSection() {
    final info = _schoolInfo;
    if (info == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildConfigItem(context.translate('name'), info['name']),
        _buildConfigItem(context.translate('address'), info['address']),
        _buildConfigItem(context.translate('city'), info['city']),
        _buildConfigItem(context.translate('state'), info['state']),
        _buildConfigItem(context.translate('country'), info['country']),
        _buildConfigItem(context.translate('phone_number'), info['phone']),
        _buildConfigItem(context.translate('email'), info['email']),
        _buildConfigItem('Website', info['website']),
        _buildConfigItem(
          context.translate('established_year'),
          info['establishedYear'],
        ),
        _buildConfigItem('Accreditation', info['accreditation']),
        const SizedBox(height: 12),
        Center(
          child: ElevatedButton.icon(
            onPressed: () => _showEditSchoolInfoDialog(context),
            icon: const Icon(Icons.edit),
            label: Text(context.translate('edit_school_info')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.blue500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAcademicSection(
    BuildContext context,
    LoginProvider loginProvider,
  ) => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: AppTheme.slate100,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.translate('grading_and_terms'),
            style: const TextStyle(
              fontSize: AppTheme.fontSizeSm,
              color: AppTheme.slate600,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.router.router.push('/grading-config'),
            icon: const Icon(Icons.grid_view_rounded, size: 20),
            label: Text(context.translate('grading_config')),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.blue500,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.router.router.push('/academic-management'),
            icon: const Icon(Icons.calendar_month_rounded, size: 20),
            label: Text(
              context.translate(
                loginProvider.isSchool
                    ? 'years_and_terms'
                    : 'years_and_semesters',
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.blue500,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildSystemSection(BuildContext context) => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: AppTheme.slate100,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConfigItem(context.translate('timezone'), 'IST (Asia/Kolkata)'),
          _buildConfigItem(context.translate('date_format'), 'DD/MM/YYYY'),
          _buildConfigItem(context.translate('currency'), 'INR (₹)'),
          Text(
            context.translate('system_settings_coming_soon'),
            style: const TextStyle(
              fontSize: AppTheme.fontSizeXs,
              color: AppTheme.slate500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildBrandingSection(BuildContext context) => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: AppTheme.slate100,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.image_rounded, color: AppTheme.slate500, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              context.translate('branding_coming_soon'),
              style: const TextStyle(
                fontSize: AppTheme.fontSizeSm,
                color: AppTheme.slate600,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  void _showEditSchoolInfoDialog(BuildContext context) {
    final institutionId =
        context.read<LoginProvider>().currentUser?.institutionId;
    if (institutionId == null) return;
    final info = _schoolInfo ?? {};

    final nameController = TextEditingController(
      text: info['name']?.toString() ?? '',
    );
    final addressController = TextEditingController(
      text: info['address']?.toString() ?? '',
    );
    final cityController = TextEditingController(
      text: info['city']?.toString() ?? '',
    );
    final stateController = TextEditingController(
      text: info['state']?.toString() ?? '',
    );
    final countryController = TextEditingController(
      text: info['country']?.toString() ?? '',
    );
    final phoneController = TextEditingController(
      text: info['phone']?.toString() ?? '',
    );
    final emailController = TextEditingController(
      text: info['email']?.toString() ?? '',
    );
    final websiteController = TextEditingController(
      text: info['website']?.toString() ?? '',
    );
    final establishedController = TextEditingController(
      text: info['establishedYear']?.toString() ?? '',
    );
    final accreditationController = TextEditingController(
      text: info['accreditation']?.toString() ?? '',
    );

    CustomFormDialog.show<void>(
      context: context,
      title: context.translate('edit_school_info'),
      subtitle: context.translate('school_info_subtitle'),
      headerIcon: Icons.school_rounded,
      confirmText: context.translate('save'),
      cancelText: context.translate('cancel'),
      confirmColor: AppTheme.blue500,
      maxWidth: 500,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              label: context.translate('name'),
              controller: nameController,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: context.translate('address'),
              controller: addressController,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: context.translate('city'),
              controller: cityController,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: context.translate('state'),
              controller: stateController,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: context.translate('country'),
              controller: countryController,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: context.translate('phone_number'),
              controller: phoneController,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: context.translate('email'),
              controller: emailController,
            ),
            const SizedBox(height: 12),
            CustomTextField(label: 'Website', controller: websiteController),
            const SizedBox(height: 12),
            CustomTextField(
              label: context.translate('established_year'),
              controller: establishedController,
              hintText: 'e.g. 1990',
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Accreditation',
              controller: accreditationController,
            ),
          ],
        ),
      ),
      onConfirm: () async {
        if (_isSaving) return;
        setState(() => _isSaving = true);
        try {
          final year = int.tryParse(establishedController.text.trim());
          await _adminService.updateInstitutionProfile(institutionId, {
            'name': nameController.text.trim(),
            'address':
                addressController.text.trim().isEmpty
                    ? null
                    : addressController.text.trim(),
            'city':
                cityController.text.trim().isEmpty
                    ? null
                    : cityController.text.trim(),
            'state':
                stateController.text.trim().isEmpty
                    ? null
                    : stateController.text.trim(),
            'country':
                countryController.text.trim().isEmpty
                    ? null
                    : countryController.text.trim(),
            'phone':
                phoneController.text.trim().isEmpty
                    ? null
                    : phoneController.text.trim(),
            'email':
                emailController.text.trim().isEmpty
                    ? null
                    : emailController.text.trim(),
            'website':
                websiteController.text.trim().isEmpty
                    ? null
                    : websiteController.text.trim(),
            'establishedYear': year,
            'accreditation':
                accreditationController.text.trim().isEmpty
                    ? null
                    : accreditationController.text.trim(),
          });
          if (mounted) {
            Navigator.of(context).pop();
            _loadData();
            showCustomSnackbar(
              message: context.translate('school_info_saved'),
              type: SnackbarType.success,
            );
          }
        } on Exception catch (e) {
          if (mounted) {
            showCustomSnackbar(
              message: e.toString().replaceFirst('Exception: ', ''),
              type: SnackbarType.error,
            );
          }
        } finally {
          if (mounted) setState(() => _isSaving = false);
        }
      },
      onCancel: () => Navigator.of(context).pop(),
    ).then((_) {
      _disposeControllers(
        nameController,
        addressController,
        cityController,
        stateController,
        countryController,
        phoneController,
        emailController,
        websiteController,
        establishedController,
        accreditationController,
      );
    });
  }

  void _disposeControllers(
    TextEditingController a,
    TextEditingController b,
    TextEditingController c,
    TextEditingController d,
    TextEditingController e,
    TextEditingController f,
    TextEditingController g,
    TextEditingController h,
    TextEditingController i,
    TextEditingController j,
  ) {
    a.dispose();
    b.dispose();
    c.dispose();
    d.dispose();
    e.dispose();
    f.dispose();
    g.dispose();
    h.dispose();
    i.dispose();
    j.dispose();
  }

  Widget _buildSectionHeader(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: AppTheme.fontSizeLg,
      fontWeight: AppTheme.fontWeightBold,
      color: AppTheme.slate800,
    ),
  );

  Widget _buildConfigItem(String label, value) => Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: AppTheme.fontWeightSemibold,
            color: AppTheme.slate600,
            fontSize: AppTheme.fontSizeSm,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.slate100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.slate200),
          ),
          child: Text(
            value?.toString() ?? 'Not Configured',
            style: const TextStyle(
              fontSize: AppTheme.fontSizeBase,
              fontFamily: 'monospace',
              color: AppTheme.slate800,
            ),
          ),
        ),
      ],
    ),
  );
}
