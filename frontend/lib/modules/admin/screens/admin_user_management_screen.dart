import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../providers/user_management_provider.dart';
import '../widgets/create_user_dialog.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementProvider>().fetchUsers();
      context.read<UserManagementProvider>().fetchUserStats();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final userInitials = UserUtils.getInitials(user?.name ?? 'AD');
    final userName = user?.name ?? 'Admin';

    return CustomMainScreenWithAppbar(
      title: context.translate('user_management'),
      appBarConfig: AppBarConfig.admin(
        showBackButton: true,
        userInitials: userInitials,
        userName: userName,
        institutionName: user?.institution?.name ?? '',
        onNotificationIconPressed: () {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateUserDialog(context),
        backgroundColor: AppTheme.blue500,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
                    onChanged: (value) {
                      context.read<UserManagementProvider>().setSearchQuery(
                        value,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    context.read<UserManagementProvider>().setSearchQuery('');
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.slate100,
                  ),
                ),
              ],
            ),
          ),
          _buildRoleFilter(context),
          Expanded(
            child: Consumer<UserManagementProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.users.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(provider.error!),
                        ElevatedButton(
                          onPressed: () => provider.fetchUsers(),
                          child: Text(context.translate('retry')),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.users.isEmpty) {
                  return Center(
                    child: Text(context.translate('no_users_found')),
                  );
                }

                return ListView.builder(
                  itemCount: provider.users.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final userData = provider.users[index];
                    return _buildUserTile(context, userData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilter(BuildContext context) {
    final provider = context.watch<UserManagementProvider>();
    final roles = {
      null: 'All',
      2: 'Admin',
      3: 'Student',
      4: 'Parent',
      5: 'Teacher',
      6: 'Librarian',
      7: 'Staff',
      8: 'Accountant',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children:
            roles.entries.map((entry) {
              final isSelected = provider.selectedRoleFilter == entry.key;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(entry.value),
                  selected: isSelected,
                  onSelected: (selected) {
                    provider.setRoleFilter(entry.key);
                  },
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, Map<String, dynamic> userData) {
    final name =
        userData['name'] ?? '${userData['firstName']} ${userData['lastName']}';
    final email = userData['email'] ?? '';
    final role = userData['role']?['roleName'] ?? 'No Role';
    final kramid = userData['kramid'] ?? '';
    final status = userData['status'] ?? 'UNKNOWN';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Text(UserUtils.getInitials(name))),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email),
            Row(
              children: [
                Text(
                  role.toString().toUpperCase(),
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
                const SizedBox(width: 8),
                Text(kramid, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: _getStatusColor(status),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'INACTIVE':
        return Colors.grey;
      case 'LOCKED':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  void _showCreateUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateUserDialog(),
    );
  }
}
