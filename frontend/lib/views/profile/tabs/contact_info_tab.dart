import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';

class ContactInfoTab extends StatefulWidget {
  const ContactInfoTab({super.key});

  @override
  State<ContactInfoTab> createState() => _ContactInfoTabState();
}

class _ContactInfoTabState extends State<ContactInfoTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _alternatePhoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;
  late TextEditingController _emergencyContactNameController;
  late TextEditingController _emergencyContactPhoneController;

  @override
  void initState() {
    super.initState();
    final user = context.read<LoginProvider>().currentUser;

    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _alternatePhoneController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _postalCodeController = TextEditingController();
    _countryController = TextEditingController();
    _emergencyContactNameController = TextEditingController(
      text: user?.student?.emergencyContactName ?? '',
    );
    _emergencyContactPhoneController = TextEditingController(
      text: user?.student?.emergencyContactPhone ?? '',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _alternatePhoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LoginProvider>().currentUser;
    final isStudent = user?.student != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              icon: Icons.contact_mail,
              title: context.translate('contact_information'),
              subtitle: context.translate('manage_contact_details'),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              context,
              title: context.translate('primary_contact'),
              children: [
                _buildTextField(
                  context,
                  label: context.translate('email_address'),
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        context,
                        label: context.translate('phone_number'),
                        controller: _phoneController,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        context,
                        label: context.translate('alternate_phone'),
                        controller: _alternatePhoneController,
                        icon: Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              context,
              title: context.translate('address_details'),
              children: [
                _buildTextField(
                  context,
                  label: context.translate('street_address'),
                  controller: _addressController,
                  icon: Icons.home_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        context,
                        label: context.translate('city'),
                        controller: _cityController,
                        icon: Icons.location_city_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        context,
                        label: context.translate('state_province'),
                        controller: _stateController,
                        icon: Icons.map_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        context,
                        label: context.translate('postal_code'),
                        controller: _postalCodeController,
                        icon: Icons.markunread_mailbox_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        context,
                        label: context.translate('country'),
                        controller: _countryController,
                        icon: Icons.public_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (isStudent) ...[
              const SizedBox(height: 24),
              _buildInfoCard(
                context,
                title: context.translate('emergency_contact'),
                children: [
                  _buildTextField(
                    context,
                    label: context.translate('emergency_contact_name'),
                    controller: _emergencyContactNameController,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    context,
                    label: context.translate('emergency_contact_phone'),
                    controller: _emergencyContactPhoneController,
                    icon: Icons.phone_in_talk_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

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

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
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
}
