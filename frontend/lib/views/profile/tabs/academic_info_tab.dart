import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';

class AcademicInfoTab extends StatefulWidget {
  const AcademicInfoTab({super.key});

  @override
  State<AcademicInfoTab> createState() => _AcademicInfoTabState();
}

class _AcademicInfoTabState extends State<AcademicInfoTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _admissionNumberController;
  late TextEditingController _rollNumberController;
  late TextEditingController _gradeLevelController;
  late TextEditingController _sectionController;
  late TextEditingController _admissionDateController;
  late TextEditingController _currentYearController;
  late TextEditingController _currentSemesterController;
  bool _transportRequired = false;

  @override
  void initState() {
    super.initState();
    final student = context.read<LoginProvider>().currentUser?.student;

    _admissionNumberController = TextEditingController(
      text: student?.admissionNumber ?? '',
    );
    _rollNumberController = TextEditingController(text: student?.rollNumber ?? '');
    _gradeLevelController = TextEditingController(text: student?.gradeLevel ?? '');
    _sectionController = TextEditingController(text: student?.section ?? '');
    _admissionDateController = TextEditingController(
      text: student?.admissionDate?.toString().split(' ')[0] ?? '',
    );
    _currentYearController = TextEditingController(
      text: student?.currentYear?.toString() ?? '',
    );
    _currentSemesterController = TextEditingController(
      text: student?.currentSemester?.toString() ?? '',
    );
    _transportRequired = student?.transportRequired ?? false;
  }

  @override
  void dispose() {
    _admissionNumberController.dispose();
    _rollNumberController.dispose();
    _gradeLevelController.dispose();
    _sectionController.dispose();
    _admissionDateController.dispose();
    _currentYearController.dispose();
    _currentSemesterController.dispose();
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
            icon: Icons.school,
            title: 'Academic Information',
            subtitle: 'Manage your academic details',
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            context,
            title: 'Enrollment Details',
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Admission Number',
                      controller: _admissionNumberController,
                      icon: Icons.confirmation_number_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      label: 'Roll Number',
                      controller: _rollNumberController,
                      icon: Icons.numbers_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Grade Level',
                      controller: _gradeLevelController,
                      icon: Icons.grade_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      label: 'Section',
                      controller: _sectionController,
                      icon: Icons.class_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Admission Date',
                controller: _admissionDateController,
                icon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            context,
            title: 'Current Academic Status',
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Current Year',
                      controller: _currentYearController,
                      icon: Icons.calendar_view_month_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      label: 'Current Semester',
                      controller: _currentSemesterController,
                      icon: Icons.calendar_view_week_outlined,
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
            title: 'Additional Information',
            children: [
              _buildSwitchTile(
                title: 'Transport Required',
                subtitle: 'Do you require school transport?',
                value: _transportRequired,
                onChanged: (value) {
                  setState(() {
                    _transportRequired = value;
                  });
                },
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
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

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.slate100,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.slate800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.slate500,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.blue500,
        ),
      ],
    ),
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
        _admissionDateController.text = picked.toString().split(' ')[0];
      });
    }
  }
}
