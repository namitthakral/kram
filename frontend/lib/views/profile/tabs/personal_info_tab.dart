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
          _buildSectionHeader(
            context,
            icon: Icons.person,
            title: 'Personal Information',
            subtitle: 'Update your personal details',
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            context,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'First Name',
                      controller: _firstNameController,
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      label: 'Last Name',
                      controller: _lastNameController,
                      icon: Icons.person_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Date of Birth',
                controller: _dateOfBirthController,
                icon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 20),
              _buildDropdownField(
                label: 'Gender',
                value: _genderController.text.isEmpty
                    ? null
                    : _genderController.text,
                items: const ['Male', 'Female', 'Other', 'Prefer not to say'],
                onChanged: (value) {
                  setState(() {
                    _genderController.text = value ?? '';
                  });
                },
                icon: Icons.wc_outlined,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Nationality',
                controller: _nationalityController,
                icon: Icons.flag_outlined,
              ),
              const SizedBox(height: 20),
              _buildDropdownField(
                label: 'Blood Group',
                value: _bloodGroupController.text.isEmpty
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

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.blue50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.blue500, size: 24),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.textTheme.titleLg.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.slate800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: context.textTheme.bodySm.copyWith(
                color: AppTheme.slate500,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildInfoCard(BuildContext context, {required List<Widget> children}) =>
      Container(
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

  Widget _buildTextField({
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    ],
  );

  Widget _buildDropdownField({
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
        value: value,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item),
        )).toList(),
      ),
    ],
  );

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.blue500,
            onPrimary: Colors.white,
            surface: Colors.white,
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
