import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/extensions.dart';
import '../../../models/academic_year.dart';
import '../../../models/semester.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../services/admin_service.dart';
import '../widgets/add_semester_dialog.dart';

class AcademicYearManagementScreen extends StatefulWidget {
  const AcademicYearManagementScreen({super.key});

  @override
  State<AcademicYearManagementScreen> createState() =>
      _AcademicYearManagementScreenState();
}

class _AcademicYearManagementScreenState
    extends State<AcademicYearManagementScreen> {
  final AdminService _adminService = AdminService();
  List<AcademicYear> _years = [];
  final Map<int, List<Semester>> _semesters = {};
  final Map<int, bool> _loadingSemesters = {};
  bool _isLoadingYears = true;
  bool _isSchool = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadYears();
  }

  Future<void> _loadYears() async {
    if (!mounted) return;
    setState(() {
      _isLoadingYears = true;
      _error = null;
    });

    try {
      final loginProvider = context.read<LoginProvider>();
      _isSchool = loginProvider.currentUser?.institution?.type == 'SCHOOL';
      
      final years = await _adminService.getAcademicYears();
      if (!mounted) return;
      setState(() {
        _years = years;
        _isLoadingYears = false;
      });
      
      // Load semesters for each year
      for (final year in years) {
        _loadSemesters(year.id);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoadingYears = false;
      });
    }
  }

  Future<void> _loadSemesters(int yearId) async {
    if (!mounted) return;
    setState(() => _loadingSemesters[yearId] = true);
    try {
      final semesters = await _adminService.getSemesters(yearId);
      if (!mounted) return;
      setState(() {
        _semesters[yearId] = semesters;
      });
    } catch (e) {
      debugPrint('Error loading semesters for year $yearId: $e');
    } finally {
      if (mounted) {
        setState(() => _loadingSemesters[yearId] = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final userInitials = UserUtils.getInitials(user?.name ?? 'AD');
    final userName = user?.name ?? 'Admin';

    return CustomMainScreenWithAppbar(
      title: 'Academic Management',
      appBarConfig: AppBarConfig.admin(
        userInitials: userInitials,
        userName: userName,
        institutionName: user?.institution?.name ?? '',
        onNotificationIconPressed: () {},
      ),
      child: _isLoadingYears
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: AppTheme.danger)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadYears,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _years.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 64, color: AppTheme.slate200),
                          const SizedBox(height: 16),
                          const Text('No academic years found', style: TextStyle(color: AppTheme.slate500)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _years.length,
                      itemBuilder: (context, index) {
                        final year = _years[index];
                        return _buildYearCard(year);
                      },
                    ),
    );
  }

  Widget _buildYearCard(AcademicYear year) {
    final semesters = _semesters[year.id] ?? [];
    final isLoading = _loadingSemesters[year.id] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.slate200),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: year.status.toUpperCase() == 'ACTIVE',
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        title: Row(
          children: [
            Text(
              year.yearName,
              style: const TextStyle(
                fontWeight: AppTheme.fontWeightBold,
                fontSize: AppTheme.fontSizeLg,
                color: AppTheme.slate800,
              ),
            ),
            const SizedBox(width: 12),
            _buildStatusBadge(year.status),
          ],
        ),
        subtitle: Text(
          '${DateFormat('MMM yyyy').format(year.startDate)} - ${DateFormat('MMM yyyy').format(year.endDate)}',
          style: const TextStyle(color: AppTheme.slate500, fontSize: AppTheme.fontSizeSm),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isSchool ? 'Terms' : 'Semesters',
                      style: const TextStyle(
                        fontWeight: AppTheme.fontWeightSemibold,
                        color: AppTheme.slate700,
                        fontSize: AppTheme.fontSizeBase,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddSemesterDialog(year),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: Text(context.translate(_isSchool ? 'add_term' : 'add_semester')),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.blue600,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isLoading)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ))
                else if (semesters.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.slate50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.slate100),
                    ),
                    child: const Center(
                      child: Text(
                        'No semesters defined for this year',
                        style: TextStyle(color: AppTheme.slate500, fontSize: AppTheme.fontSizeSm),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: semesters.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final semester = semesters[index];
                      return _buildSemesterTile(semester);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterTile(Semester semester) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.slate50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.slate200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.blue500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _isSchool ? 'T${semester.semesterNumber}' : 'S${semester.semesterNumber}',
              style: const TextStyle(
                fontWeight: AppTheme.fontWeightBold,
                color: AppTheme.blue600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  semester.semesterName,
                  style: const TextStyle(
                    fontWeight: AppTheme.fontWeightSemibold,
                    color: AppTheme.slate800,
                    fontSize: AppTheme.fontSizeBase,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${DateFormat('dd MMM').format(semester.startDate)} - ${DateFormat('dd MMM yyyy').format(semester.endDate)}',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeXs,
                    color: AppTheme.slate500,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusToggle(semester),
        ],
      ),
    );
  }

  Widget _buildStatusToggle(Semester semester) {
    return PopupMenuButton<String>(
      onSelected: (newStatus) => _updateSemesterStatus(semester, newStatus),
      itemBuilder: (context) => [
        _buildStatusMenuItem('UPCOMING', AppTheme.info),
        _buildStatusMenuItem('ACTIVE', AppTheme.success),
        _buildStatusMenuItem('COMPLETED', AppTheme.slate400),
      ],
      child: _buildStatusBadge(semester.status),
    );
  }

  PopupMenuItem<String> _buildStatusMenuItem(String status, Color color) {
    return PopupMenuItem<String>(
      value: status,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            status,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeSm,
              fontWeight: AppTheme.fontWeightMedium,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateSemesterStatus(Semester semester, String newStatus) async {
    if (semester.status.toUpperCase() == newStatus.toUpperCase()) return;

    try {
      await _adminService.updateSemester(semester.id, {'status': newStatus});
      
      if (newStatus.toUpperCase() == 'ACTIVE') {
        // Reload everything because another semester in ANY academic year 
        // might have been set to COMPLETED by the backend
        _loadYears();
      } else {
        _loadSemesters(semester.academicYearId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $newStatus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        color = AppTheme.success;
        break;
      case 'INACTIVE':
        color = AppTheme.slate400;
        break;
      case 'UPCOMING':
        color = AppTheme.info;
        break;
      default:
        color = AppTheme.slate400;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: AppTheme.fontWeightBold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Future<void> _showAddSemesterDialog(AcademicYear year) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddSemesterDialog(
        academicYearId: year.id,
        academicYearName: year.yearName,
      ),
    );

    if (result == true) {
      _loadSemesters(year.id);
    }
  }
}
