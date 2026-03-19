import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/courses_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../providers/admin_students_provider.dart';

class EditStudentDialog extends StatefulWidget {
  const EditStudentDialog({required this.student, super.key});
  final Map<String, dynamic> student;

  @override
  State<EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<EditStudentDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _rollNumberController;
  late TextEditingController _sectionController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _medicalConditionsController;

  // Parent/Guardian Controllers
  late TextEditingController _fatherNameController;
  late TextEditingController _fatherEmailController;
  late TextEditingController _fatherMobileController;

  late TextEditingController _motherNameController;
  late TextEditingController _motherEmailController;
  late TextEditingController _motherMobileController;

  late TextEditingController _guardianNameController;
  late TextEditingController _guardianEmailController;
  late TextEditingController _guardianMobileController;

  String? _selectedStudentType;
  String? _selectedResidentialStatus;
  bool _transportRequired = false;

  // Course selection
  int? _selectedCourseId;
  List<Map<String, dynamic>> _courses = [];
  bool _loadingCourses = false;

  final List<String> _studentTypes = ['REGULAR', 'SCHOLARSHIP', 'TRANSFER'];
  final List<String> _residentialStatuses = ['DAY_SCHOLAR', 'HOSTELLER'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _loadingCourses = true);
    try {
      final coursesService = CoursesService();
      final courses = await coursesService.getAllCourses();
      setState(() {
        _courses = courses.cast<Map<String, dynamic>>();
        _loadingCourses = false;
      });
    } on Exception catch (e) {
      setState(() => _loadingCourses = false);
    }
  }

  void _initializeControllers() {
    final student = widget.student;

    _rollNumberController = TextEditingController(
      text: student['rollNumber'] as String? ?? '',
    );
    _sectionController = TextEditingController(
      text: student['section'] as String? ?? '',
    );
    _bloodGroupController = TextEditingController(
      text: student['bloodGroup'] as String? ?? '',
    );
    _medicalConditionsController = TextEditingController(
      text: student['medicalConditions'] as String? ?? '',
    );

    _selectedStudentType = student['studentType'] as String? ?? 'REGULAR';
    _selectedResidentialStatus =
        student['residentialStatus'] as String? ?? 'DAY_SCHOLAR';
    _transportRequired = student['transportRequired'] as bool? ?? false;

    // Initialize course selection
    final course = student['course'] as Map<String, dynamic>?;
    _selectedCourseId = course?['id'] as int?;

    // Initialize parent controllers
    _initializeParentControllers();
  }

  void _initializeParentControllers() {
    final parents = widget.student['parents'] as List<dynamic>? ?? [];

    // Initialize all controllers with empty values
    _fatherNameController = TextEditingController();
    _fatherEmailController = TextEditingController();
    _fatherMobileController = TextEditingController();

    _motherNameController = TextEditingController();
    _motherEmailController = TextEditingController();
    _motherMobileController = TextEditingController();

    _guardianNameController = TextEditingController();
    _guardianEmailController = TextEditingController();
    _guardianMobileController = TextEditingController();

    // Find and populate parent data
    Map<String, dynamic>? father;
    Map<String, dynamic>? mother;
    Map<String, dynamic>? guardian;

    for (final parent in parents) {
      final parentMap = parent as Map<String, dynamic>;
      final relation = parentMap['relation'] as String?;

      switch (relation) {
        case 'FATHER':
          father = parentMap;
          break;
        case 'MOTHER':
          mother = parentMap;
          break;
        case 'GUARDIAN':
          guardian = parentMap;
          break;
      }
    }

    // Populate father info
    if (father != null) {
      final fatherUser = father['user'] as Map<String, dynamic>?;
      _fatherNameController.text = fatherUser?['name'] as String? ?? '';
      _fatherEmailController.text = fatherUser?['email'] as String? ?? '';
      _fatherMobileController.text = fatherUser?['phone'] as String? ?? '';
    }

    // Populate mother info
    if (mother != null) {
      final motherUser = mother['user'] as Map<String, dynamic>?;
      _motherNameController.text = motherUser?['name'] as String? ?? '';
      _motherEmailController.text = motherUser?['email'] as String? ?? '';
      _motherMobileController.text = motherUser?['phone'] as String? ?? '';
    }

    // Initialize guardian controllers (for potential future use)
    if (guardian != null) {
      final guardianUser = guardian['user'] as Map<String, dynamic>?;
      _guardianNameController.text = guardianUser?['name'] as String? ?? '';
      _guardianEmailController.text = guardianUser?['email'] as String? ?? '';
      _guardianMobileController.text = guardianUser?['phone'] as String? ?? '';
    }
  }

  @override
  void dispose() {
    _rollNumberController.dispose();
    _sectionController.dispose();
    _bloodGroupController.dispose();
    _medicalConditionsController.dispose();

    // Parent/Guardian controllers
    _fatherNameController.dispose();
    _fatherEmailController.dispose();
    _fatherMobileController.dispose();
    _motherNameController.dispose();
    _motherEmailController.dispose();
    _motherMobileController.dispose();
    _guardianNameController.dispose();
    _guardianEmailController.dispose();
    _guardianMobileController.dispose();

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
    if (_selectedCourseId != null) {
      studentData['courseId'] = _selectedCourseId;
    }
    // Note: Parent information is displayed but not editable in this version
    // Parent editing functionality can be added in a future update
    if (_bloodGroupController.text.isNotEmpty) {
      studentData['bloodGroup'] = _bloodGroupController.text;
    }
    if (_medicalConditionsController.text.isNotEmpty) {
      studentData['medicalConditions'] = _medicalConditionsController.text;
    }

    studentData['studentType'] = _selectedStudentType;
    studentData['residentialStatus'] = _selectedResidentialStatus;
    studentData['transportRequired'] = _transportRequired;

    final response = await provider.updateStudent(userUuid, studentData);

    if (response != null && mounted) {
      Navigator.of(context).pop();

      // Check if roll number was auto-generated
      final updatedStudent = response['data'];
      final newRollNumber = updatedStudent?['rollNumber'] as String?;
      final hadRollNumber =
          widget.student['rollNumber'] != null &&
          (widget.student['rollNumber'] as String).isNotEmpty;

      if (newRollNumber != null &&
          !hadRollNumber &&
          _rollNumberController.text.isEmpty) {
        _showSuccessSnackBar(
          'Student updated successfully. Roll number $newRollNumber was automatically generated.',
        );
      } else {
        _showSuccessSnackBar('Student updated successfully');
      }
    } else if (mounted) {
      _showErrorSnackBar(provider.error ?? 'Failed to update student');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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
                // Course selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Course',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          _loadingCourses
                              ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                              : DropdownButton<int>(
                                value: _selectedCourseId,
                                isExpanded: true,
                                underline: const SizedBox(),
                                hint: const Text('Select Course'),
                                items:
                                    _courses
                                        .map(
                                          (course) => DropdownMenuItem<int>(
                                            value: course['id'] as int,
                                            child: Text(
                                              course['name'] as String,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (v) {
                                  setState(() => _selectedCourseId = v);
                                },
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _sectionController,
                  label: 'Section',
                  hintText: 'Enter section (e.g., A, B, C)',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStudentType,
                  decoration: const InputDecoration(
                    labelText: 'Student Type',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      _studentTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (value) => setState(() => _selectedStudentType = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedResidentialStatus,
                  decoration: const InputDecoration(
                    labelText: 'Residential Status',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      _residentialStatuses
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.replaceAll('_', ' ')),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (value) =>
                          setState(() => _selectedResidentialStatus = value),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Transport Required'),
                  value: _transportRequired,
                  onChanged:
                      (value) =>
                          setState(() => _transportRequired = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 16),

                // Parent/Guardian Information (Read-only)
                _buildParentInformationSection(),
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
          builder:
              (context, provider, child) => ElevatedButton(
                onPressed: provider.isLoading ? null : _updateStudent,
                child:
                    provider.isLoading
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

  Widget _buildParentInformationSection() {
    final parents = widget.student['parents'] as List<dynamic>? ?? [];

    if (parents.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parent/Guardian Information',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'No parent/guardian information available',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Parent/Guardian Information',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        ...parents.map((parent) {
          final parentMap = parent as Map<String, dynamic>;
          final relation = parentMap['relation'] as String? ?? '';
          final isPrimary = parentMap['isPrimaryContact'] as bool? ?? false;
          final user = parentMap['user'] as Map<String, dynamic>?;

          if (user == null) return const SizedBox.shrink();

          final firstName = user['firstName'] as String? ?? '';
          final lastName = user['lastName'] as String? ?? '';
          final name = '$firstName $lastName'.trim();
          final email = user['email'] as String? ?? '';
          final phone = user['phone'] as String? ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isPrimary ? Colors.blue.shade50 : Colors.grey.shade50,
              border: Border.all(
                color: isPrimary ? Colors.blue.shade200 : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _formatRelation(relation),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (isPrimary) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Primary Contact',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                if (name.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(child: Text(name)),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                if (email.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.email, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(child: Text(email)),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                if (phone.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(child: Text(phone)),
                    ],
                  ),
                ],
              ],
            ),
          );
        }),

        const SizedBox(height: 8),
        Text(
          'Note: Parent information is read-only. Contact administrator to update parent details.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _formatRelation(String relation) {
    switch (relation.toUpperCase()) {
      case 'FATHER':
        return 'Father';
      case 'MOTHER':
        return 'Mother';
      case 'GUARDIAN':
        return 'Guardian';
      case 'OTHER':
        return 'Other';
      default:
        return relation;
    }
  }
}
