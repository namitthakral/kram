import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../services/admin_service.dart';

/// Admin screen to view and manage staff (role: staff).
class AdminStaffManagementScreen extends StatefulWidget {
  const AdminStaffManagementScreen({super.key});

  @override
  State<AdminStaffManagementScreen> createState() =>
      _AdminStaffManagementScreenState();
}

class _AdminStaffManagementScreenState extends State<AdminStaffManagementScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;
  List<dynamic> _staffList = [];
  int _page = 1;
  static const int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStaff() async {
    final institutionId =
        context.read<LoginProvider>().currentUser?.institutionId;
    if (institutionId == null) {
      setState(() {
        _error = 'Institution not found';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _adminService.getUsersByRole(
        7, // roleId 7 = staff
        page: _page,
        limit: _limit,
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );

      final data = response['data'] as List<dynamic>? ?? [];
      final meta = response['meta'] as Map<String, dynamic>? ?? {};
      setState(() {
        _staffList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
        _staffList = [];
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
      title: context.translate('staff_management'),
      appBarConfig: AppBarConfig.admin(
        userInitials: userInitials,
        userName: userName,
        institutionName: user?.institution?.name ?? '',
        onNotificationIconPressed: () {},
      ),
      isLoading: _isLoading,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _searchController,
                    hintText: context.translate('search_users'),
                    onChanged: (_) => _loadStaff(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  onPressed: _loadStaff,
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.blue500,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.danger.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.danger),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_error!, style: const TextStyle(color: AppTheme.slate800))),
                    TextButton(
                      onPressed: _loadStaff,
                      child: Text(context.translate('retry')),
                    ),
                  ],
                ),
              ),
            ),
          if (_error != null) const SizedBox(height: 16),
          Expanded(
            child: _staffList.isEmpty && !_isLoading
                ? Center(
                    child: Text(
                      context.translate('no_users_found'),
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeBase,
                        color: AppTheme.slate500,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _staffList.length,
                    itemBuilder: (context, index) {
                      final staff = _staffList[index] as Map<String, dynamic>;
                      return _buildStaffCard(context, staff);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(BuildContext context, Map<String, dynamic> staff) {
    final name = staff['name']?.toString() ??
        '${staff['firstName'] ?? ''} ${staff['lastName'] ?? ''}'.trim();
    final email = staff['email']?.toString() ?? '';
    final kramid = staff['kramid']?.toString() ?? '';
    final status = staff['status']?.toString() ?? 'UNKNOWN';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.blue500.withValues(alpha: 0.15),
            child: Text(
              UserUtils.getInitials(name),
              style: const TextStyle(
                fontWeight: AppTheme.fontWeightSemibold,
                color: AppTheme.blue500,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: AppTheme.fontWeightSemibold,
                    fontSize: AppTheme.fontSizeBase,
                    color: AppTheme.slate800,
                  ),
                ),
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeSm,
                      color: AppTheme.slate600,
                    ),
                  ),
                if (kramid.isNotEmpty)
                  Text(
                    kramid,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeXs,
                      color: AppTheme.slate500,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor(status).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _statusColor(status).withValues(alpha: 0.5)),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: AppTheme.fontSizeXs,
                fontWeight: AppTheme.fontWeightSemibold,
                color: _statusColor(status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return AppTheme.success;
      case 'INACTIVE':
        return AppTheme.slate500;
      case 'LOCKED':
        return AppTheme.danger;
      default:
        return AppTheme.blue500;
    }
  }
}
