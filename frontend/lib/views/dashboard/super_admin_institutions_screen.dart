import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../provider/login_signup/login_provider.dart';
import '../../provider/super_admin/super_admin_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/extensions.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/router_service.dart';
import '../../utils/user_utils.dart';
import '../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../models/super_admin_models.dart';
import '../../modules/super_admin/widgets/create_institution_admin_dialog.dart';

class SuperAdminInstitutionsScreen extends StatefulWidget {
  const SuperAdminInstitutionsScreen({super.key});

  @override
  State<SuperAdminInstitutionsScreen> createState() => _SuperAdminInstitutionsScreenState();
}

class _SuperAdminInstitutionsScreenState extends State<SuperAdminInstitutionsScreen> {
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
          Expanded(
            child: _buildContentSection(context, superAdminProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(BuildContext context, SuperAdminProvider provider) {
    final isMobile = context.isMobile;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
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
                    suffixIcon: _searchController.text.isNotEmpty
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

  Widget _buildStatusFilter(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: context.translate('Status'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(context.translate('All Status')),
        ),
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
  }

  Widget _buildTypeFilter(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      decoration: InputDecoration(
        labelText: context.translate('Type'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(context.translate('All Types')),
        ),
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
  }

  Widget _buildContentSection(BuildContext context, SuperAdminProvider provider) {
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
        Expanded(
          child: _buildInstitutionsList(context, provider),
        ),
        
        // Pagination
        _buildPagination(context, provider),
      ],
    );
  }

  Widget _buildResultsSummary(BuildContext context, SuperAdminProvider provider) {
    final meta = provider.institutionsMeta;
    if (meta == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.translate('Showing ${provider.institutions.length} of ${meta.total} institutions'),
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

  Widget _buildInstitutionsList(BuildContext context, SuperAdminProvider provider) {
    final isMobile = context.isMobile;
    
    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: provider.institutions.length,
        itemBuilder: (context, index) {
          final institution = provider.institutions[index];
          return _buildInstitutionCard(context, institution);
        },
      );
    } else {
      return _buildInstitutionsTable(context, provider);
    }
  }

  Widget _buildInstitutionCard(BuildContext context, InstitutionOverview institution) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        institution.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${institution.code} • ${institution.type}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(context, institution.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Users',
                    institution.totalUsers.toString(),
                    Icons.people,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Health',
                    institution.formattedHealthPercentage,
                    Icons.health_and_safety,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              institution.userSummary,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstitutionsTable(BuildContext context, SuperAdminProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text(context.translate('Code'))),
          DataColumn(label: Text(context.translate('Name'))),
          DataColumn(label: Text(context.translate('Type'))),
          DataColumn(label: Text(context.translate('Status'))),
          DataColumn(label: Text(context.translate('Total Users'))),
          DataColumn(label: Text(context.translate('Active Users'))),
          DataColumn(label: Text(context.translate('Health'))),
          DataColumn(label: Text(context.translate('Created'))),
          DataColumn(label: Text(context.translate('Actions'))),
        ],
        rows: provider.institutions.map((institution) {
          return DataRow(
            cells: [
              DataCell(Text(institution.code)),
              DataCell(
                SizedBox(
                  width: 200,
                  child: Text(
                    institution.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(Text(institution.type)),
              DataCell(_buildStatusChip(context, institution.status)),
              DataCell(Text(institution.totalUsers.toString())),
              DataCell(Text(institution.activeUsers.toString())),
              DataCell(Text(institution.formattedHealthPercentage)),
              DataCell(Text(
                institution.createdAt.toString().split(' ')[0], // Date only
              )),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.admin_panel_settings, color: Colors.blue),
                      tooltip: 'Create Admin',
                      onPressed: () => _showCreateAdminDialog(context, institution),
                    ),
                    IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.green),
                      tooltip: 'View Details',
                      onPressed: () => _viewInstitutionDetails(institution),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
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

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).primaryColor),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              context.translate(label),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPagination(BuildContext context, SuperAdminProvider provider) {
    final meta = provider.institutionsMeta;
    if (meta == null || meta.totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1 ? () => _onPageChanged(_currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: 16),
          Text(
            context.translate('Page $_currentPage of ${meta.totalPages}'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: _currentPage < meta.totalPages ? () => _onPageChanged(_currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, SuperAdminProvider provider) {
    return Center(
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
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
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
  }

  void _showCreateAdminDialog(BuildContext context, InstitutionOverview institution) {
    showDialog(
      context: context,
      builder: (context) => CreateInstitutionAdminDialog(
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
      builder: (context) => AlertDialog(
        title: Text('Institution Details'),
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
            Text('Created: ${institution.createdAt.toString().split(' ')[0]}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}