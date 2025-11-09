import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/extensions.dart';

class SecurityTab extends StatefulWidget {
  const SecurityTab({super.key});

  @override
  State<SecurityTab> createState() => _SecurityTabState();
}

class _SecurityTabState extends State<SecurityTab> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _twoFactorEnabled = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
            icon: Icons.security,
            title: 'Security Settings',
            subtitle: 'Manage your account security',
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            context,
            title: 'Change Password',
            children: [
              _buildPasswordField(
                label: 'Current Password',
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureCurrentPassword = !_obscureCurrentPassword;
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                label: 'New Password',
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                label: 'Confirm New Password',
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              const SizedBox(height: 24),
              _buildPasswordStrengthIndicator(),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            context,
            title: 'Two-Factor Authentication',
            children: [
              _buildSwitchTile(
                title: 'Enable Two-Factor Authentication',
                subtitle: 'Add an extra layer of security to your account',
                value: _twoFactorEnabled,
                onChanged: (value) {
                  setState(() {
                    _twoFactorEnabled = value;
                  });
                },
              ),
              if (_twoFactorEnabled) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.info,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Scan the QR code with your authenticator app to complete setup.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.slate800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            context,
            title: 'Active Sessions',
            children: [
              _buildSessionItem(
                device: 'Chrome on Windows',
                location: 'New York, USA',
                lastActive: '2 hours ago',
                isCurrent: true,
              ),
              const SizedBox(height: 12),
              _buildSessionItem(
                device: 'Safari on iPhone',
                location: 'New York, USA',
                lastActive: '1 day ago',
                isCurrent: false,
              ),
              const SizedBox(height: 12),
              _buildSessionItem(
                device: 'Firefox on MacOS',
                location: 'Boston, USA',
                lastActive: '3 days ago',
                isCurrent: false,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // TODO: Implement logout all sessions
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.danger,
                ),
                child: const Text('Logout from all other devices'),
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
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
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppTheme.slate500),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 20,
              color: AppTheme.slate500,
            ),
            onPressed: onToggleVisibility,
          ),
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

  Widget _buildPasswordStrengthIndicator() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Password Strength',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.slate800,
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
              decoration: BoxDecoration(
                color: index < 2 ? AppTheme.warning : AppTheme.slate100,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
      const SizedBox(height: 8),
      const Text(
        'Password must be at least 8 characters with a mix of letters, numbers & symbols',
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.slate500,
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
          activeTrackColor: AppTheme.blue500,
          activeColor: Colors.white,
        ),
      ],
    ),
  );

  Widget _buildSessionItem({
    required String device,
    required String location,
    required String lastActive,
    required bool isCurrent,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isCurrent
          ? AppTheme.blue50
          : AppTheme.slate100,
      borderRadius: BorderRadius.circular(8),
      border: isCurrent
          ? Border.all(color: AppTheme.blue500.withValues(alpha: 0.3))
          : null,
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isCurrent ? AppTheme.blue500 : AppTheme.slate600,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getDeviceIcon(device),
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    device,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.slate800,
                    ),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.success,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Current',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$location • $lastActive',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.slate500,
                ),
              ),
            ],
          ),
        ),
        if (!isCurrent)
          IconButton(
            icon: const Icon(Icons.logout, size: 18, color: AppTheme.danger),
            onPressed: () {
              // TODO: Implement logout session
            },
          ),
      ],
    ),
  );

  IconData _getDeviceIcon(String device) {
    if (device.contains('iPhone') || device.contains('iPad')) {
      return Icons.phone_iphone;
    } else if (device.contains('Android')) {
      return Icons.phone_android;
    } else if (device.contains('MacOS')) {
      return Icons.laptop_mac;
    } else {
      return Icons.computer;
    }
  }
}
