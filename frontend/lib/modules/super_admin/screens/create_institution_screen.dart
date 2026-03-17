import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../utils/custom_colors.dart';
import '../../../utils/extensions.dart';
import '../../../provider/super_admin/super_admin_provider.dart';

class CreateInstitutionScreen extends StatefulWidget {
  const CreateInstitutionScreen({super.key});

  @override
  State<CreateInstitutionScreen> createState() =>
      _CreateInstitutionScreenState();
}

class _CreateInstitutionScreenState extends State<CreateInstitutionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _establishedYearController = TextEditingController();
  final _accreditationController = TextEditingController();

  String _selectedType = 'SCHOOL';
  bool _isSubmitting = false;

  static const List<String> _institutionTypes = [
    'SCHOOL',
    'COLLEGE',
    'UNIVERSITY',
    'INSTITUTE',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _establishedYearController.dispose();
    _accreditationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'type': _selectedType,
    };

    final code = _codeController.text.trim();
    if (code.isNotEmpty) data['code'] = code.toUpperCase();

    if (_addressController.text.trim().isNotEmpty) {
      data['address'] = _addressController.text.trim();
    }
    if (_cityController.text.trim().isNotEmpty) {
      data['city'] = _cityController.text.trim();
    }
    if (_stateController.text.trim().isNotEmpty) {
      data['state'] = _stateController.text.trim();
    }
    if (_countryController.text.trim().isNotEmpty) {
      data['country'] = _countryController.text.trim();
    }
    if (_postalCodeController.text.trim().isNotEmpty) {
      data['postalCode'] = _postalCodeController.text.trim();
    }
    if (_phoneController.text.trim().isNotEmpty) {
      data['phone'] = _phoneController.text.trim();
    }
    if (_emailController.text.trim().isNotEmpty) {
      data['email'] = _emailController.text.trim();
    }
    if (_websiteController.text.trim().isNotEmpty) {
      data['website'] = _websiteController.text.trim();
    }
    if (_establishedYearController.text.trim().isNotEmpty) {
      data['establishedYear'] = int.parse(
        _establishedYearController.text.trim(),
      );
    }
    if (_accreditationController.text.trim().isNotEmpty) {
      data['accreditation'] = _accreditationController.text.trim();
    }

    final provider = context.read<SuperAdminProvider>();
    final success = await provider.createInstitution(data);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Institution created successfully!'),
          backgroundColor: CustomAppColors.success,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to create institution'),
          backgroundColor: CustomAppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.translate('Create Institution')),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('Basic Information'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _nameController,
              label: 'Institution Name *',
              hint: 'e.g. Thakral Public School',
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Name is required';
                if (v.trim().length < 2) return 'Minimum 2 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Type *',
              value: _selectedType,
              items: _institutionTypes,
              onChanged: (v) => setState(() => _selectedType = v!),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _codeController,
              label: 'Code (2-4 uppercase letters)',
              hint: 'e.g. TPS (auto-generated if empty)',
              maxLength: 4,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                UpperCaseTextFormatter(),
              ],
              validator: (v) {
                if (v != null && v.isNotEmpty && v.length < 2) {
                  return 'Minimum 2 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 28),
            _buildSectionHeader('Address'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _addressController,
              label: 'Address',
              hint: 'Street address',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _cityController,
                    label: 'City',
                    hint: 'e.g. Panipat',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _stateController,
                    label: 'State',
                    hint: 'e.g. Haryana',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _countryController,
                    label: 'Country',
                    hint: 'e.g. India',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _postalCodeController,
                    label: 'Postal Code',
                    hint: 'e.g. 132103',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),
            _buildSectionHeader('Contact'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone',
              hint: 'e.g. 9999269284',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'e.g. info@school.in',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                  if (!emailRegex.hasMatch(v)) return 'Invalid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _websiteController,
              label: 'Website',
              hint: 'e.g. https://school.in',
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 28),
            _buildSectionHeader('Additional'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _establishedYearController,
                    label: 'Established Year',
                    hint: 'e.g. 2026',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: (v) {
                      if (v != null && v.isNotEmpty) {
                        final year = int.tryParse(v);
                        if (year == null || year < 1800 || year > 2100) {
                          return 'Invalid year';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _accreditationController,
                    label: 'Accreditation',
                    hint: 'e.g. CBSE',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomAppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: CustomAppColors.slate300,
                ),
                child:
                    _isSubmitting
                        ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
                          'Create Institution',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );

  Widget _buildSectionHeader(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: CustomAppColors.slate800,
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    maxLength: maxLength,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: CustomAppColors.slate300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: CustomAppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
  );

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) => DropdownButtonFormField<String>(
    initialValue: value,
    onChanged: onChanged,
    items:
        items
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(e[0] + e.substring(1).toLowerCase()),
              ),
            )
            .toList(),
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: CustomAppColors.slate300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: CustomAppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
  );
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => TextEditingValue(
    text: newValue.text.toUpperCase(),
    selection: newValue.selection,
  );
}
