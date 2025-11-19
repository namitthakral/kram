import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';

class PersonalInfoTab extends StatefulWidget {
  const PersonalInfoTab({super.key});

  @override
  State<PersonalInfoTab> createState() => _PersonalInfoTabState();
}

class _PersonalInfoTabState extends State<PersonalInfoTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _genderController;
  late TextEditingController _nationalityController;
  late TextEditingController _bloodGroupController;

  /// Collect form data for saving
  Map<String, dynamic> getFormData() {
    final data = <String, dynamic>{};

    // Combine first and last name
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      data['name'] = '$firstName $lastName'.trim();
    }

    if (_dateOfBirthController.text.isNotEmpty) {
      data['dateOfBirth'] = _dateOfBirthController.text;
    }

    if (_genderController.text.isNotEmpty) {
      data['gender'] = _genderController.text;
    }

    if (_nationalityController.text.isNotEmpty) {
      data['nationality'] = _nationalityController.text;
    }

    if (_bloodGroupController.text.isNotEmpty) {
      data['bloodGroup'] = _bloodGroupController.text;
    }

    return data;
  }

  /// Validate the form
  bool validateForm() => _formKey.currentState?.validate() ?? false;

  @override
  void initState() {
    super.initState();
    final user = context.read<LoginProvider>().currentUser;
    final nameParts = user?.name.split(' ') ?? [];

    _firstNameController = TextEditingController(
      text: nameParts.isNotEmpty ? nameParts.first : '',
    );
    _lastNameController = TextEditingController(
      text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
    );
    _dateOfBirthController = TextEditingController();
    _genderController = TextEditingController();
    _nationalityController = TextEditingController();
    _bloodGroupController = TextEditingController(
      text: user?.student?.bloodGroup ?? '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _genderController.dispose();
    _nationalityController.dispose();
    _bloodGroupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            context,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      context,
                      label: context.translate('first_name'),
                      controller: _firstNameController,
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      context,
                      label: context.translate('last_name'),
                      controller: _lastNameController,
                      icon: Icons.person_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField(
                context,
                label: context.translate('date_of_birth'),
                controller: _dateOfBirthController,
                icon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 20),
              _buildDropdownField(
                context,
                label: context.translate('gender'),
                value:
                    _genderController.text.isEmpty
                        ? null
                        : _genderController.text,
                items: [
                  context.translate('male'),
                  context.translate('female'),
                  context.translate('other'),
                  context.translate('prefer_not_to_say'),
                ],
                onChanged: (value) {
                  setState(() {
                    _genderController.text = value ?? '';
                  });
                },
                icon: Icons.wc_outlined,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                context,
                label: context.translate('nationality'),
                controller: _nationalityController,
                icon: Icons.flag_outlined,
              ),
              const SizedBox(height: 20),
              _buildDropdownField(
                context,
                label: context.translate('blood_group'),
                value:
                    _bloodGroupController.text.isEmpty
                        ? null
                        : _bloodGroupController.text,
                items: const ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
                onChanged: (value) {
                  setState(() {
                    _bloodGroupController.text = value ?? '';
                  });
                },
                icon: Icons.bloodtype_outlined,
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildInfoCard(
    BuildContext context, {
    required List<Widget> children,
  }) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.slate100),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.slate800,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20, color: AppTheme.slate500),
          filled: true,
          fillColor: AppTheme.slate100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.slate100),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.slate100),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.blue500, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    ],
  );

  Widget _buildDropdownField(
    BuildContext context, {
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData icon,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.slate800,
        ),
      ),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        initialValue: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20, color: AppTheme.slate500),
          filled: true,
          fillColor: AppTheme.slate100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.slate100),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.slate100),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.blue500, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        items:
            items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
      ),
    ],
  );

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder:
          (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppTheme.blue500,
                onSurface: AppTheme.slate800,
              ),
            ),
            child: child!,
          ),
    );

    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = picked.toString().split(' ')[0];
      });
    }
  }
}
