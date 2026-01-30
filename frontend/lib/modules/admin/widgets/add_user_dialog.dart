import 'package:flutter/material.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedRole;
  String? _selectedDepartment;
  String _selectedStatus = 'Active';

  // Permissions
  bool _viewStudents = false;
  bool _editMarks = false;
  bool _manageAttendance = false;
  bool _manageFees = false;
  bool _generateReports = false;
  bool _systemSettings = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Collect form data
      final userData = {
        'fullName': _fullNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'role': _selectedRole,
        'department': _selectedDepartment,
        'status': _selectedStatus,
        'permissions': {
          'viewStudents': _viewStudents,
          'editMarks': _editMarks,
          'manageAttendance': _manageAttendance,
          'manageFees': _manageFees,
          'generateReports': _generateReports,
          'systemSettings': _systemSettings,
        },
      };

      Navigator.of(context).pop(userData);
    }
  }

  @override
  Widget build(BuildContext context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New System User',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a new user account with specific roles and permissions',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Full Name and Email
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'Full Name',
                              controller: _fullNameController,
                              hint: 'Enter full name',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter full name';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: 'Email Address',
                              controller: _emailController,
                              hint: 'user@school.edu',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter valid email';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Row 2: Role and Department
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: 'Role',
                              value: _selectedRole,
                              hint: 'Select role',
                              items: const [
                                'Teacher',
                                'Admin',
                                'Staff',
                                'Parent',
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedRole = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Department',
                              value: _selectedDepartment,
                              hint: 'Select department',
                              items: const [
                                'Science',
                                'Mathematics',
                                'English',
                                'Social Studies',
                                'Physical Education',
                                'Arts',
                                'Administration',
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedDepartment = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Row 3: Phone and Status
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'Phone Number',
                              controller: _phoneController,
                              hint: '+1 (555) 123-4567',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Status',
                              value: _selectedStatus,
                              hint: 'Active',
                              items: const [
                                'Active',
                                'Inactive',
                                'Suspended',
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value ?? 'Active';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Permissions Section
                      Text(
                        'Permissions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),

                      // Permissions Grid
                      _buildPermissionsGrid(),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _handleSubmit,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add User'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.purple, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );

  Widget _buildDropdown({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey[400]),
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.purple, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );

  Widget _buildPermissionsGrid() => Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPermissionSwitch(
                label: 'View Students',
                value: _viewStudents,
                onChanged: (value) => setState(() => _viewStudents = value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPermissionSwitch(
                label: 'Edit Marks',
                value: _editMarks,
                onChanged: (value) => setState(() => _editMarks = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildPermissionSwitch(
                label: 'Manage Attendance',
                value: _manageAttendance,
                onChanged: (value) => setState(() => _manageAttendance = value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPermissionSwitch(
                label: 'Manage Fees',
                value: _manageFees,
                onChanged: (value) => setState(() => _manageFees = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildPermissionSwitch(
                label: 'Generate Reports',
                value: _generateReports,
                onChanged: (value) => setState(() => _generateReports = value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPermissionSwitch(
                label: 'System Settings',
                value: _systemSettings,
                onChanged: (value) => setState(() => _systemSettings = value),
              ),
            ),
          ],
        ),
      ],
    );

  Widget _buildPermissionSwitch({
    required String label,
    required bool value,
    required void Function(bool) onChanged,
  }) => Row(
      children: [
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: Colors.purple[200],
          activeThumbColor: Colors.purple,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
}
