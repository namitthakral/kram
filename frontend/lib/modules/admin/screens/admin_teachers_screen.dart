import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';
import '../../../utils/router_service.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../../../modules/teacher/services/teacher_service.dart';

class AdminTeachersScreen extends StatefulWidget {
  const AdminTeachersScreen({super.key});

  @override
  State<AdminTeachersScreen> createState() => _AdminTeachersScreenState();
}

class _AdminTeachersScreenState extends State<AdminTeachersScreen> {
  final TeacherService _teacherService = TeacherService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _teachers = [];
  bool _isLoading = true;
  String? _error;
  bool _gridView = true;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTeachers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await _teacherService.getAllTeachers(page: 1, limit: 100);
      final data = res['data'] as List<dynamic>?;
      if (mounted) {
        setState(() {
          _teachers = data ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _teachers = [];
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> get _filteredTeachers {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _teachers;
    return _teachers.where((t) {
      final user = t['user'] as Map<String, dynamic>?;
      final name = (user?['name'] as String? ?? '').toLowerCase();
      final email = (user?['email'] as String? ?? '').toLowerCase();
      final designation = (t['designation'] as String? ?? '').toLowerCase();
      final specialization = (t['specialization'] as String? ?? '').toLowerCase();
      return name.contains(query) ||
          email.contains(query) ||
          designation.contains(query) ||
          specialization.contains(query);
    }).toList();
  }

  int get _activeCount =>
      _teachers.where((t) {
        final user = t['user'] as Map<String, dynamic>?;
        return (user?['status'] as String? ?? 'ACTIVE') == 'ACTIVE';
      }).length;

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final userInitials = UserUtils.getInitials(user?.name ?? 'AD');
    final userName = user?.name ?? 'Admin';
    final filtered = _filteredTeachers;

    return CustomMainScreenWithAppbar(
      title: context.translate('teachers'),
      appBarConfig: AppBarConfig.admin(
        userInitials: userInitials,
        userName: userName,
        institutionName: context.translate('kram_institution'),
        onNotificationIconPressed: () {},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.translate('teachers_management'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.translate('manage_all_teaching_staff'),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.slate500,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: Text(context.translate('export')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.slate600,
                        side: BorderSide(color: AppTheme.slate200),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showAddTeacher(context),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: Text(context.translate('add_teacher')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.blue500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: _searchController,
                        hintText: context.translate('search_teachers_by_name'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildViewToggle(context),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _loadTeachers,
                              child: Text(context.translate('retry')),
                            ),
                          ],
                        ),
                      )
                    : filtered.isEmpty
                        ? Center(
                            child: Text(
                              context.translate('no_teachers_found'),
                              style: TextStyle(color: AppTheme.slate500),
                            ),
                          )
                        : _gridView
                            ? _buildGrid(filtered)
                            : _buildTable(filtered),
          ),
          _buildSummaryBar(context),
        ],
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.slate100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segmentChip(
            context,
            label: context.translate('grid_view'),
            selected: _gridView,
            onTap: () => setState(() => _gridView = true),
          ),
          _segmentChip(
            context,
            label: context.translate('table_view'),
            selected: !_gridView,
            onTap: () => setState(() => _gridView = false),
          ),
        ],
      ),
    );
  }

  Widget _segmentChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? AppTheme.blue500 : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : AppTheme.slate600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List<dynamic> teachers) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 800 ? 3 : 2;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: teachers.length,
          itemBuilder: (context, index) => _teacherCard(teachers[index]),
        );
      },
    );
  }

  Widget _teacherCard(dynamic t) {
    final user = t['user'] as Map<String, dynamic>?;
    final name = user?['name'] as String? ?? 'Teacher';
    final initials = UserUtils.getInitials(name);
    final designation =
        t['designation'] as String? ?? t['specialization'] as String? ?? '—';
    final phone = user?['phone'] as String? ?? user?['email'] as String? ?? '—';
    final status = user?['status'] as String? ?? 'ACTIVE';
    final joinedAt = user?['createdAt'] as String?;
    final dateStr = joinedAt != null
        ? joinedAt.toString().split('T').first
        : '—';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.slate200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.blue500.withValues(alpha: 0.2),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.blue600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppTheme.slate800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'ACTIVE'
                        ? AppTheme.blue50
                        : AppTheme.slate100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status == 'ACTIVE'
                        ? context.translate('active')
                        : status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: status == 'ACTIVE'
                          ? AppTheme.blue600
                          : AppTheme.slate600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _infoRow(Icons.work_outline_rounded, designation),
            const SizedBox(height: 6),
            _infoRow(Icons.phone_outlined, phone.toString()),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 20),
                  onPressed: () => _viewProfile(t),
                  tooltip: context.translate('view_details'),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () {},
                  tooltip: context.translate('edit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.slate500),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: AppTheme.slate600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTable(List<dynamic> teachers) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppTheme.slate200),
        ),
        child: DataTable(
          columns: [
            DataColumn(label: Text(context.translate('name'))),
            DataColumn(label: Text(context.translate('designation'))),
            DataColumn(label: Text(context.translate('phone_number'))),
            DataColumn(label: Text(context.translate('status'))),
            DataColumn(label: Text(context.translate('actions'))),
          ],
          rows: teachers.map((t) {
            final user = t['user'] as Map<String, dynamic>?;
            final name = user?['name'] as String? ?? '—';
            final designation =
                t['designation'] as String? ?? t['specialization'] as String? ?? '—';
            final phone = user?['phone'] as String? ?? user?['email'] as String? ?? '—';
            final status = user?['status'] as String? ?? 'ACTIVE';
            return DataRow(
              cells: [
                DataCell(Text(name)),
                DataCell(Text(designation)),
                DataCell(Text(phone)),
                DataCell(Text(status)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined, size: 20),
                        onPressed: () => _viewProfile(t),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryBar(BuildContext context) {
    final total = _teachers.length;
    final active = _activeCount;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.slate100,
        border: Border(top: BorderSide(color: AppTheme.slate200)),
      ),
      child: Row(
        children: [
          _summaryChip(context.translate('total_teachers'), '$total'),
          const SizedBox(width: 24),
          _summaryChip(context.translate('active_teachers'), '$active'),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.slate600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.slate200),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppTheme.slate800,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddTeacher(BuildContext context) {
    context.router.router.push('/admin-users');
  }

  void _viewProfile(dynamic t) {
    final user = t['user'] as Map<String, dynamic>?;
    final uuid = user?['uuid'] as String?;
    if (uuid != null) {
      context.router.router.push('/profile');
    }
  }
}
