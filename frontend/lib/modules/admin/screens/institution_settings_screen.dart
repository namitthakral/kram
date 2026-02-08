import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../services/admin_service.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/user_utils.dart';

class InstitutionSettingsScreen extends StatefulWidget {
  const InstitutionSettingsScreen({super.key});

  @override
  State<InstitutionSettingsScreen> createState() => _InstitutionSettingsScreenState();
}

class _InstitutionSettingsScreenState extends State<InstitutionSettingsScreen> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  Map<String, dynamic>? _idConfig;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final loginProvider = context.read<LoginProvider>();
      final institutionId = loginProvider.currentUser?.institutionId;

      if (institutionId != null) {
        final config = await _adminService.getIdConfig(institutionId);
        setState(() {
          _idConfig = config;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Institution ID not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final userInitials = UserUtils.getInitials(user?.name ?? 'AD');
    final userName = user?.name ?? 'Admin';

    return CustomMainScreenWithAppbar(
      title: context.translate('institution_settings'),
      appBarConfig: AppBarConfig.admin(
        userInitials: userInitials,
        userName: userName,
        institutionName: context.translate('edverse_institution'),
        onNotificationIconPressed: () {},
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      ElevatedButton(onPressed: _loadData, child: Text(context.translate('retry'))),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(context.translate('id_configuration')),
                      const SizedBox(height: 16),
                      if (_idConfig != null) ...[
                        _buildConfigItem('Admission ID Format', _idConfig!['admissionIdFormat']),
                        _buildConfigItem('Employee ID Format', _idConfig!['employeeIdFormat']),
                        _buildConfigItem('Roll No Format', _idConfig!['rollNoFormat']),
                      ],
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Logic to edit config
                          },
                          icon: const Icon(Icons.edit),
                          label: Text(context.translate('edit_configuration')),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildConfigItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Text(
              value?.toString() ?? 'Not Configured',
              style: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
