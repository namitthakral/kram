import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/extensions.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../providers/institutions_provider.dart';
import '../widgets/create_institution_admin_dialog.dart';

class InstitutionsScreen extends StatefulWidget {
  const InstitutionsScreen({super.key});

  @override
  State<InstitutionsScreen> createState() => _InstitutionsScreenState();
}

class _InstitutionsScreenState extends State<InstitutionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstitutionsProvider>().loadInstitutions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final userInitials = UserUtils.getInitials(user?.name ?? 'SA');
    final userName = user?.name ?? 'Super Admin';

    return CustomMainScreenWithAppbar(
      title: context.translate('Institutions'),
      appBarConfig: AppBarConfig.superAdmin(
        userInitials: userInitials,
        userName: userName,
        systemName: 'Kram Platform',
        onNotificationIconPressed: () {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/institutions/create'),
        backgroundColor: CustomAppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: Consumer<InstitutionsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.institutions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.institutions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadInstitutions(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.institutions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No institutions yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first institution',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadInstitutions(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.institutions.length,
              itemBuilder: (context, index) {
                final inst = provider.institutions[index];
                return _InstitutionCard(institution: inst);
              },
            ),
          );
        },
      ),
    );
  }
}

class _InstitutionCard extends StatelessWidget {
  const _InstitutionCard({required this.institution});

  final Map<String, dynamic> institution;

  void _showAddAdminDialog(
    BuildContext context,
    Map<String, dynamic>? currentAdmin,
  ) {
    final id = institution['id'] as int?;
    final name = institution['name'] as String? ?? 'Unknown';
    if (id == null) return;

    showDialog<bool>(
      context: context,
      builder:
          (_) => CreateInstitutionAdminDialog(
            institutionId: id,
            institutionName: name,
            currentAdmin: currentAdmin,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = institution['name'] as String? ?? 'Unknown';
    final code = institution['code'] as String? ?? '';
    final type = institution['type'] as String? ?? '';
    final city = institution['city'] as String? ?? '';
    final state = institution['state'] as String? ?? '';

    final location = [city, state].where((s) => s.isNotEmpty).join(', ');
    final typeLabel =
        type.isNotEmpty ? type[0] + type.substring(1).toLowerCase() : '';

    final users = institution['users'] as List<dynamic>? ?? [];
    final currentAdmin =
        users.isNotEmpty ? users.first as Map<String, dynamic> : null;
    final adminName =
        currentAdmin != null
            ? '${currentAdmin['firstName']} ${currentAdmin['lastName']}'
            : null;
    final adminEmail =
        currentAdmin != null ? currentAdmin['email'] as String? : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: CustomAppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  code,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CustomAppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CustomAppColors.slate800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    typeLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      color: CustomAppColors.slate500,
                    ),
                  ),
                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: CustomAppColors.slate400,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            location,
                            style: const TextStyle(
                              fontSize: 13,
                              color: CustomAppColors.slate500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (currentAdmin != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: CustomAppColors.slate100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 12,
                            color: CustomAppColors.slate600,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '$adminName (${adminEmail ?? ''})',
                              style: const TextStyle(
                                fontSize: 11,
                                color: CustomAppColors.slate700,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'add_admin')
                  _showAddAdminDialog(context, currentAdmin);
              },
              itemBuilder:
                  (ctx) => [
                    PopupMenuItem(
                      value: 'add_admin',
                      child: Row(
                        children: [
                          const Icon(Icons.admin_panel_settings, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            currentAdmin != null ? 'Update Admin' : 'Add Admin',
                          ),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
      ),
    );
  }
}
