import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/super_admin_models.dart';
import '../../modules/super_admin/widgets/create_institution_admin_dialog.dart';
import '../../provider/login_signup/login_provider.dart';
import '../../provider/super_admin/super_admin_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/extensions.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/router_service.dart';
import '../../utils/user_utils.dart';
import '../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class SuperAdminInstitutionsScreen extends StatefulWidget {
  const SuperAdminInstitutionsScreen({super.key});

  @override
  State<SuperAdminInstitutionsScreen> createState() =>
      _SuperAdminInstitutionsScreenState();
}

class _SuperAdminInstitutionsScreenState
    extends State<SuperAdminInstitutionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  String? _selectedType;
  int _currentPage = 1;
  final int _itemsPerPage = 20;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInstitutions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadInstitutions() {
    final superAdminProvider = context.read<SuperAdminProvider>();
    superAdminProvider.loadInstitutions(
      page: _currentPage,
      limit: _itemsPerPage,
      search: _searchController.text.isEmpty ? null : _searchController.text,
      status: _selectedStatus,
      type: _selectedType,
    );
  }

  void _onFilterChanged() {
    setState(() {
      _currentPage = 1;
    });
    _loadInstitutions();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadInstitutions();
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final superAdminProvider = context.watch<SuperAdminProvider>();
    final user = loginProvider.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.router.goToLogin();
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userInitials = UserUtils.getInitials(user.name);
    final userName = user.name;

    return CustomMainScreenWithAppbar(
      title: context.translate('Institutions Management'),
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
      child: Column(
        children: [
          // Filters Section
          _buildFiltersSection(context, superAdminProvider),

          // Content Section
          Expanded(child: _buildContentSection(context, superAdminProvider)),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(
    BuildContext context,
    SuperAdminProvider provider,
  ) {
    final isMobile = context.isMobile;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: context.translate('Search institutions...'),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onFilterChanged();
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (_) => _onFilterChanged(),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _onFilterChanged,
                icon: const Icon(Icons.search),
                label: Text(context.translate('Search')),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Filter Dropdowns
          if (isMobile)
            Column(
              children: [
                _buildStatusFilter(context),
                const SizedBox(height: 12),
                _buildTypeFilter(context),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _buildStatusFilter(context)),
                const SizedBox(width: 16),
                Expanded(child: _buildTypeFilter(context)),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = null;
                      _selectedType = null;
                      _searchController.clear();
                      _currentPage = 1;
                    });
                    _loadInstitutions();
                  },
                  icon: const Icon(Icons.clear_all),
                  label: Text(context.translate('Clear Filters')),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(BuildContext context) =>
      DropdownButtonFormField<String>(
        initialValue: _selectedStatus,
        decoration: InputDecoration(
          labelText: context.translate('Status'),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: [
          DropdownMenuItem(child: Text(context.translate('All Status'))),
          DropdownMenuItem(
            value: 'ACTIVE',
            child: Text(context.translate('Active')),
          ),
          DropdownMenuItem(
            value: 'INACTIVE',
            child: Text(context.translate('Inactive')),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _selectedStatus = value;
          });
          _onFilterChanged();
        },
      );

  Widget _buildTypeFilter(BuildContext context) =>
      DropdownButtonFormField<String>(
        initialValue: _selectedType,
        decoration: InputDecoration(
          labelText: context.translate('Type'),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: [
          DropdownMenuItem(child: Text(context.translate('All Types'))),
          DropdownMenuItem(
            value: 'SCHOOL',
            child: Text(context.translate('School')),
          ),
          DropdownMenuItem(
            value: 'COLLEGE',
            child: Text(context.translate('College')),
          ),
          DropdownMenuItem(
            value: 'UNIVERSITY',
            child: Text(context.translate('University')),
          ),
          DropdownMenuItem(
            value: 'INSTITUTE',
            child: Text(context.translate('Institute')),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _selectedType = value;
          });
          _onFilterChanged();
        },
      );

  Widget _buildContentSection(
    BuildContext context,
    SuperAdminProvider provider,
  ) {
    if (provider.isLoadingInstitutions && provider.institutions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hasError) {
      return _buildErrorWidget(context, provider);
    }

    if (provider.institutions.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        // Results Summary
        _buildResultsSummary(context, provider),

        // Institutions List
        Expanded(child: _buildInstitutionsList(context, provider)),

        // Pagination
        _buildPagination(context, provider),
      ],
    );
  }

  Widget _buildResultsSummary(
    BuildContext context,
    SuperAdminProvider provider,
  ) {
    final meta = provider.institutionsMeta;
    if (meta == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.translate(
              'Showing ${provider.institutions.length} of ${meta.total} institutions',
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (provider.isLoadingInstitutions)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildInstitutionsList(
    BuildContext context,
    SuperAdminProvider provider,
  ) {
    final isMobile = context.isMobile;

    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: provider.institutions.length,
        itemBuilder: (context, index) {
          final institution = provider.institutions[index];
          return _buildInstitutionCard(institution);
        },
      );
    } else {
      return _buildInstitutionsGrid(provider);
    }
  }


  Widget _buildInstitutionsGrid(SuperAdminProvider provider) =>
      GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: context.isMobile ? 1 : (context.isTablet ? 2 : 3),
          childAspectRatio: context.isMobile ? 1.2 : 1.1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: provider.institutions.length,
        itemBuilder: (context, index) {
          final institution = provider.institutions[index];
          return _buildInstitutionCard(institution);
        },
      );

  Widget _buildInstitutionCard(InstitutionOverview institution) => Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        institution.status == 'ACTIVE'
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          institution.status == 'ACTIVE'
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                  child: Text(
                    institution.status,
                    style: TextStyle(
                      color:
                          institution.status == 'ACTIVE'
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  institution.code,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Institution name and type
            Text(
              institution.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            Text(
              _capitalizeString(institution.type),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 12),

            // Admin information
            if (institution.adminName != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            institution.adminName!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (institution.adminEmail != null)
                            Text(
                              institution.adminEmail!,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'No Admin Assigned',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatChip(
                  'Users',
                  institution.totalUsers.toString(),
                  Colors.blue,
                ),
                _buildStatChip(
                  'Active',
                  institution.activeUsers.toString(),
                  Colors.green,
                ),
                _buildStatChip(
                  'Health',
                  '${institution.healthPercentage.toStringAsFixed(0)}%',
                  Colors.purple,
                ),
              ],
            ),

            const Spacer(),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        () => _showCreateAdminDialog(context, institution),
                    icon: const Icon(Icons.person_add, size: 16),
                    label: const Text('Admin', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewInstitutionDetails(institution),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green.shade700,
                      side: BorderSide(color: Colors.green.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  Widget _buildStatChip(String label, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _getDarkerColor(color),
          ),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: color)),
      ],
    ),
  );

  Color _getDarkerColor(Color color) {
    if (color == Colors.blue) return Colors.blue.shade800;
    if (color == Colors.green) return Colors.green.shade800;
    if (color == Colors.purple) return Colors.purple.shade800;
    if (color == Colors.orange) return Colors.orange.shade800;
    if (color == Colors.red) return Colors.red.shade800;
    // Default to a darker version
    return Color.fromRGBO(
      (color.red * 0.6).round(),
      (color.green * 0.6).round(),
      (color.blue * 0.6).round(),
      1.0,
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final isActive = status == 'ACTIVE';
    return Chip(
      label: Text(
        context.translate(_capitalizeString(status.toLowerCase())),
        style: TextStyle(
          color: isActive ? Colors.green[800] : Colors.red[800],
          fontSize: 12,
        ),
      ),
      backgroundColor: isActive ? Colors.green[100] : Colors.red[100],
    );
  }

  String _capitalizeString(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) => Row(
    children: [
      Icon(icon, size: 16, color: Theme.of(context).primaryColor),
      const SizedBox(width: 4),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            context.translate(label),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ],
  );

  Widget _buildPagination(BuildContext context, SuperAdminProvider provider) {
    final meta = provider.institutionsMeta;
    if (meta == null || meta.totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed:
                _currentPage > 1
                    ? () => _onPageChanged(_currentPage - 1)
                    : null,
            icon: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: 16),
          Text(
            context.translate('Page $_currentPage of ${meta.totalPages}'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed:
                _currentPage < meta.totalPages
                    ? () => _onPageChanged(_currentPage + 1)
                    : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, SuperAdminProvider provider) =>
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              provider.error ?? context.translate('An error occurred'),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInstitutions,
              child: Text(context.translate('Retry')),
            ),
          ],
        ),
      );

  Widget _buildEmptyState(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.business, size: 64, color: Theme.of(context).disabledColor),
        const SizedBox(height: 16),
        Text(
          context.translate('No institutions found'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          context.translate('Try adjusting your search or filters'),
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  void _showCreateAdminDialog(
    BuildContext context,
    InstitutionOverview institution,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => CreateInstitutionAdminDialog(
            institutionId: institution.id,
            institutionName: institution.name,
          ),
    );
  }

  void _viewInstitutionDetails(InstitutionOverview institution) {
    // TODO: Navigate to institution details page
    // For now, show a simple dialog with institution info
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Institution Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Code: ${institution.code}'),
                Text('Name: ${institution.name}'),
                Text('Type: ${institution.type}'),
                Text('Status: ${institution.status}'),
                Text('Total Users: ${institution.totalUsers}'),
                Text('Active Users: ${institution.activeUsers}'),
                Text('Students: ${institution.students}'),
                Text('Teachers: ${institution.teachers}'),
                Text('Staff: ${institution.staff}'),
                Text('Parents: ${institution.parents}'),
                Text('Health: ${institution.formattedHealthPercentage}'),
                Text(
                  'Created: ${institution.createdAt.toString().split(' ')[0]}',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
