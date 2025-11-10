import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';

class ProfessionalInfoTab extends StatefulWidget {
  const ProfessionalInfoTab({super.key});

  @override
  State<ProfessionalInfoTab> createState() => _ProfessionalInfoTabState();
}

class _ProfessionalInfoTabState extends State<ProfessionalInfoTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _employeeIdController;
  late TextEditingController _designationController;
  late TextEditingController _specializationController;
  late TextEditingController _qualificationController;
  late TextEditingController _experienceYearsController;
  late TextEditingController _joinDateController;
  late TextEditingController _employmentTypeController;
  late TextEditingController _officeLocationController;
  late TextEditingController _officeHoursController;
  late TextEditingController _researchInterestsController;

  @override
  void initState() {
    super.initState();
    final teacher = context.read<LoginProvider>().currentUser?.teacher;

    _employeeIdController = TextEditingController(
      text: teacher?.employeeId ?? '',
    );
    _designationController = TextEditingController(
      text: teacher?.designation ?? '',
    );
    _specializationController = TextEditingController(
      text: teacher?.specialization ?? '',
    );
    _qualificationController = TextEditingController(
      text: teacher?.qualification ?? '',
    );
    _experienceYearsController = TextEditingController(
      text: teacher?.experienceYears.toString() ?? '',
    );
    _joinDateController = TextEditingController(
      text: teacher?.joinDate?.toString().split(' ')[0] ?? '',
    );
    _employmentTypeController = TextEditingController(
      text: teacher?.employmentType ?? '',
    );
    _officeLocationController = TextEditingController(
      text: teacher?.officeLocation ?? '',
    );
    _officeHoursController = TextEditingController(
      text: teacher?.officeHours ?? '',
    );
    _researchInterestsController = TextEditingController(
      text: teacher?.researchInterests ?? '',
    );
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _designationController.dispose();
    _specializationController.dispose();
    _qualificationController.dispose();
    _experienceYearsController.dispose();
    _joinDateController.dispose();
    _employmentTypeController.dispose();
    _officeLocationController.dispose();
    _officeHoursController.dispose();
    _researchInterestsController.dispose();
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
            title: context.translate('employment_details'),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      context,
                      label: context.translate('employee_id'),
                      controller: _employeeIdController,
                      icon: Icons.badge_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      context,
                      label: context.translate('designation'),
                      controller: _designationController,
                      icon: Icons.work_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      context,
                      label: context.translate('employment_type'),
                      value:
                          _employmentTypeController.text.isEmpty
                              ? null
                              : _employmentTypeController.text,
                      items: [
                        context.translate('full_time'),
                        context.translate('part_time'),
                        context.translate('contract'),
                        context.translate('temporary'),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _employmentTypeController.text = value ?? '';
                        });
                      },
                      icon: Icons.business_center_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      context,
                      label: context.translate('join_date'),
                      controller: _joinDateController,
                      icon: Icons.calendar_today_outlined,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            context,
            title: context.translate('academic_credentials'),
            children: [
              _buildTextField(
                context,
                label: context.translate('qualification'),
                controller: _qualificationController,
                icon: Icons.school_outlined,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      context,
                      label: context.translate('specialization'),
                      controller: _specializationController,
                      icon: Icons.stars_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      context,
                      label:
                          '${context.translate('experience')} (${context.translate('years')})',
                      controller: _experienceYearsController,
                      icon: Icons.work_history_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            context,
            title: context.translate('office_information'),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      context,
                      label: context.translate('office_location'),
                      controller: _officeLocationController,
                      icon: Icons.location_on_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      context,
                      label: context.translate('office_hours'),
                      controller: _officeHoursController,
                      icon: Icons.access_time_outlined,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            context,
            title: context.translate('research_and_interests'),
            children: [
              _buildTextField(
                context,
                label: context.translate('research_interests'),
                controller: _researchInterestsController,
                icon: Icons.science_outlined,
                maxLines: 4,
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.slate800,
          ),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    ),
  );

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
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
        keyboardType: keyboardType,
        maxLines: maxLines,
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
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 16 : 14,
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
        _joinDateController.text = picked.toString().split(' ')[0];
      });
    }
  }
}
