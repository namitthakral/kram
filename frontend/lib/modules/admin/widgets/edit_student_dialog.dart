import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../providers/admin_students_provider.dart';

class EditStudentDialog extends StatefulWidget {
  final Map<String, dynamic> student;

  const EditStudentDialog({
    super.key,
    required this.student,
  });

  @override
  State<EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<EditStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _rollNumberController;
  late TextEditingController _sectionController;
  late TextEditingController _gradeLevelController;
  late TextEditingController _emergencyContactNameController;
  late TextEditingController _emergencyContactPhoneController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _medicalConditionsController;

  String? _selectedStudentType;
  String? _selectedResidentialStatus;
  bool _transportRequired = false;

  final List<String> _studentTypes = ['REGULAR', 'SCHOLARSHIP', 'TRANSFER'];
  final List<String> _residentialStatuses = ['DAY_SCHOLAR', 'HOSTELLER'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final student = widget.student;
    
    _rollNumberController = TextEditingController(
      text: student['rollNumber'] as String? ?? '',
    );
    _sectionController = TextEditingController(
      text: student['section'] as String? ?? '',
    );
    _gradeLevelController = TextEditingController(
      text: student['gradeLevel'] as String? ?? '',
    );
    _emergencyContactNameController = TextEditingController(
      text: student['emergencyContactName'] as String? ?? '',
    );
    _emergencyContactPhoneController = TextEditingController(
      text: student['emergencyContactPhone'] as String? ?? '',
    );
    _bloodGroupController = TextEditingController(
      text: student['bloodGroup'] as String? ?? '',
    );
    _medicalConditionsController = TextEditingController(
      text: student['medicalConditions'] as String? ?? '',
    );

    _selectedStudentType = student['studentType'] as String? ?? 'REGULAR';
    _selectedResidentialStatus = student['residentialStatus'] as String? ?? 'DAY_SCHOLAR';
    _transportRequired = student['transportRequired'] as bool? ?? false;
  }

  @override
  void dispose() {
    _rollNumberController.dispose();
    _sectionController.dispose();
    _gradeLevelController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _bloodGroupController.dispose();
    _medicalConditionsController.dispose();
    super.dispose();
  }

  Future<void> _updateStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<AdminStudentsProvider>();
    final user = widget.student['user'] as Map<String, dynamic>?;
    final userUuid = user?['uuid'] as String?;

    if (userUuid == null) {
      _showErrorSnackBar('Student ID not found');
      return;
    }

    final studentData = <String, dynamic>{};
    
    // Only include fields that have values
    if (_rollNumberController.text.isNotEmpty) {
      studentData['rollNumber'] = _rollNumberController.text;
    }
    if (_sectionController.text.isNotEmpty) {
      studentData['section'] = _sectionController.text;
    }
    if (_gradeLevelController.text.isNotEmpty) {
      studentData['gradeLevel'] = _gradeLevelController.text;
    }
    if (_emergencyContactNameController.text.isNotEmpty) {
      studentData['emergencyContactName'] = _emergencyContactNameController.text;
    }
    if (_emergencyContactPhoneController.text.isNotEmpty) {
      studentData['emergencyContactPhone'] = _emergencyContactPhoneController.text;
    }
    if (_bloodGroupController.text.isNotEmpty) {
      studentData['bloodGroup'] = _bloodGroupController.text;
    }
    if (_medicalConditionsController.text.isNotEmpty) {
      studentData['medicalConditions'] = _medicalConditionsController.text;
    }
    
    studentData['studentType'] = _selectedStudentType;
    studentData['residentialStatus'] = _selectedResidentialStatus;
    studentData['transportRequired'] = _transportRequired;

    final success = await provider.updateStudent(userUuid, studentData);
    
    if (success && mounted) {
      Navigator.of(context).pop();
      _showSuccessSnackBar('Student updated successfully');
    } else if (mounted) {
      _showErrorSnackBar(provider.error ?? 'Failed to update student');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.student['user'] as Map<String, dynamic>?;
    final studentName = user?['name'] as String? ?? 'Student';

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.edit, color: AppTheme.blue500),
          const SizedBox(width: 8),
          Text('Edit $studentName'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: _rollNumberController,
                  label: 'Roll Number',
                  hintText: 'Enter roll number',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _sectionController,
                  label: 'Section',
                  hintText: 'Enter section (e.g., A, B, C)',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _gradeLevelController,
                  label: 'Grade Level',
                  hintText: 'Enter grade level',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedStudentType,
                  decoration: const InputDecoration(
                    labelText: 'Student Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _studentTypes.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    )).toList(),
                  onChanged: (value) => setState(() => _selectedStudentType = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedResidentialStatus,
                  decoration: const InputDecoration(
                    labelText: 'Residential Status',
                    border: OutlineInputBorder(),
                  ),
                  items: _residentialStatuses.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.replaceAll('_', ' ')),
                    )).toList(),
                  onChanged: (value) => setState(() => _selectedResidentialStatus = value),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Transport Required'),
                  value: _transportRequired,
                  onChanged: (value) => setState(() => _transportRequired = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emergencyContactNameController,
                  label: 'Emergency Contact Name',
                  hintText: 'Enter emergency contact name',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emergencyContactPhoneController,
                  label: 'Emergency Contact Phone',
                  hintText: 'Enter emergency contact phone',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _bloodGroupController,
                  label: 'Blood Group',
                  hintText: 'Enter blood group (e.g., A+, B-, O+)',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _medicalConditionsController,
                  label: 'Medical Conditions',
                  hintText: 'Enter any medical conditions',
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.translate('cancel')),
        ),
        Consumer<AdminStudentsProvider>(
          builder: (context, provider, child) => ElevatedButton(
            onPressed: provider.isLoading ? null : _updateStudent,
            child: provider.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(context.translate('update')),
          ),
        ),
      ],
    );
  }
}