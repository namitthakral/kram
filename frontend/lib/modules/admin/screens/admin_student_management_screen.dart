import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/courses_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../providers/admin_students_provider.dart';
import '../widgets/add_student_dialog.dart';
import '../widgets/edit_student_dialog.dart';

class AdminStudentManagementScreen extends StatefulWidget {
  const AdminStudentManagementScreen({super.key});

  @override
  State<AdminStudentManagementScreen> createState() =>
      _AdminStudentManagementScreenState();
}

class _AdminStudentManagementScreenState
    extends State<AdminStudentManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _gridView = true;
  List<dynamic> _courses = [];
  List<dynamic> _sections = []; // Dynamic sections based on selected course
  bool _loadingSections = false;
  bool _initializing = true; // Prevent rendering until properly initialized

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AdminStudentsProvider>();

      // Always start with clean state - clear all filters on entry
      provider.clearAllFilters();

      // Ensure clean local state
      _sections.clear();

      // Load courses and fetch all students (no filters applied)
      await _loadCourses();
      provider.fetchStudents();

      // Mark initialization as complete
      if (mounted) {
        setState(() {
          _initializing = false;
        });
      }
    });
  }

  Future<void> _loadCourses() async {
    try {
      final list = await CoursesService().getAllCourses();
      if (mounted) setState(() => _courses = list);
    } on Exception catch (_) {}
  }

  Future<void> _loadSectionsForCourse(int? courseId) async {
    if (courseId == null) {
      setState(() {
        _sections = [];
        _loadingSections = false;
      });
      return;
    }

    setState(() => _loadingSections = true);

    try {
      final sections = await CoursesService().getCourseSections(courseId);
      if (mounted) {
        setState(() {
          _sections = sections;
          _loadingSections = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _sections = [];
          _loadingSections = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Clear local state
    _searchController.clear();
    _searchController.dispose();
    _sections.clear();
    _initializing = true; // Reset for next visit

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final userInitials = UserUtils.getInitials(user?.name ?? 'AD');
    final userName = user?.name ?? 'Admin';

    return CustomMainScreenWithAppbar(
      title: context.translate('students'),
      appBarConfig: AppBarConfig.admin(
        userInitials: userInitials,
        userName: userName,
        institutionName: user?.institution?.name ?? '',
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
                  context.translate('student_management'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.translate('manage_student_profiles'),
                  style: const TextStyle(
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
                        side: const BorderSide(color: AppTheme.slate200),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showAddStudent(context),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: Text(context.translate('add_student')),
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
                        hintText: context.translate(
                          'search_students_by_name_or_roll',
                        ),
                        onChanged:
                            (v) => context
                                .read<AdminStudentsProvider>()
                                .setSearchQuery(v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(width: 180, child: _buildClassFilter(context)),
                    const SizedBox(width: 12),
                    SizedBox(width: 160, child: _buildSectionFilter(context)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(children: [_buildViewToggle(context)]),
              ],
            ),
          ),
          Expanded(
            child: Consumer<AdminStudentsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.students.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.error != null &&
                    provider.students.isEmpty &&
                    !provider.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(provider.error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => provider.fetchStudents(),
                          child: Text(context.translate('retry')),
                        ),
                      ],
                    ),
                  );
                }
                if (provider.students.isEmpty) {
                  return Center(
                    child: Text(
                      context.translate('no_students_found'),
                      style: const TextStyle(color: AppTheme.slate500),
                    ),
                  );
                }
                if (_gridView) {
                  return _buildGrid(provider.students);
                }
                return _buildTable(provider.students);
              },
            ),
          ),
          _buildSummaryBar(context),
        ],
      ),
    );
  }

  Widget _buildClassFilter(BuildContext context) {
    final provider = context.watch<AdminStudentsProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.slate200),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child:
            _initializing
                ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Loading...'),
                    ],
                  ),
                )
                : DropdownButton<int?>(
                  value: provider.courseIdFilter,
                  isExpanded: true,
                  hint: Text(context.translate('all_classes')),
                  items: [
                    DropdownMenuItem<int?>(
                      child: Text(context.translate('all_classes')),
                    ),
                    ..._courses.map((c) {
                      final id = c['id'] as int?;
                      final name = c['name'] as String? ?? '${c['id']}';
                      return DropdownMenuItem<int?>(
                        value: id,
                        child: Text(name.toString()),
                      );
                    }),
                  ],
                  onChanged: (courseId) {
                    // Clear sections immediately to prevent stale state
                    setState(() {
                      _sections = [];
                    });
                    // Clear section filter when course changes
                    provider.setSectionFilter(null);
                    // Set course filter
                    provider.setCourseFilter(courseId);
                    // Load sections for the selected course
                    _loadSectionsForCourse(courseId);
                  },
                ),
      ),
    );
  }

  Widget _buildSectionFilter(BuildContext context) {
    final provider = context.watch<AdminStudentsProvider>();

    // Build available section values
    final availableSections = <String>[];
    if (_sections.isNotEmpty) {
      for (final section in _sections) {
        final sectionName =
            section is Map<String, dynamic>
                ? (section['sectionName'] as String? ??
                    section['section'] as String? ??
                    section['name'] as String? ??
                    section.toString())
                : section.toString();
        if (sectionName.isNotEmpty) {
          availableSections.add(sectionName);
        }
      }
    }

    final isDisabled = provider.courseIdFilter == null || _loadingSections;

    // Determine the current value - only use provider value if it's in available sections
    String? currentValue;
    if (!isDisabled && provider.sectionFilter != null) {
      if (availableSections.contains(provider.sectionFilter)) {
        currentValue = provider.sectionFilter;
      } else {
        // Clear invalid filter
        WidgetsBinding.instance.addPostFrameCallback((_) {
          provider.setSectionFilter(null);
        });
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.slate200),
        borderRadius: BorderRadius.circular(12),
        color: isDisabled ? AppTheme.slate100 : Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child:
            (_loadingSections || _initializing)
                ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Loading...'),
                    ],
                  ),
                )
                : DropdownButton<String?>(
                  key: ValueKey(
                    'section_dropdown_${provider.courseIdFilter}_${availableSections.length}',
                  ),
                  value: currentValue,
                  isExpanded: true,
                  hint: Text(
                    provider.courseIdFilter == null
                        ? 'Select course first'
                        : context.translate('all_sections'),
                    style: TextStyle(
                      color: isDisabled ? AppTheme.slate500 : null,
                    ),
                  ),
                  items:
                      isDisabled || availableSections.isEmpty
                          ? [
                            DropdownMenuItem<String?>(
                              child: Text(
                                provider.courseIdFilter == null
                                    ? 'Select course first'
                                    : 'No sections available',
                              ),
                            ),
                          ]
                          : [
                            DropdownMenuItem<String?>(
                              child: Text(context.translate('all_sections')),
                            ),
                            ...availableSections.map(
                              (sectionName) => DropdownMenuItem<String?>(
                                value: sectionName,
                                child: Text('Section $sectionName'),
                              ),
                            ),
                          ],
                  onChanged: isDisabled ? null : provider.setSectionFilter,
                ),
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppTheme.slate100,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _segmentChip(
          context,
          icon: Icons.grid_view,
          selected: _gridView,
          onTap: () => setState(() => _gridView = true),
        ),
        const SizedBox(width: 4), // Add spacing between buttons
        _segmentChip(
          context,
          icon: Icons.table_rows,
          selected: !_gridView,
          onTap: () => setState(() => _gridView = false),
        ),
      ],
    ),
  );

  Widget _segmentChip(
    BuildContext context, {
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) => Material(
    color: selected ? AppTheme.blue500 : Colors.transparent,
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Icon(
          icon,
          color: selected ? Colors.white : AppTheme.slate600,
          size: 20,
        ),
      ),
    ),
  );

  Widget _buildGrid(List<dynamic> students) => LayoutBuilder(
    builder: (context, constraints) {
      final crossCount = constraints.maxWidth > 800 ? 3 : 2;
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: students.length,
        itemBuilder: (context, index) => _studentCard(students[index]),
      );
    },
  );

  Widget _studentCard(s) {
    final user = s['user'] as Map<String, dynamic>?;
    final name = user?['name'] as String? ?? '${s['admissionNumber']}';
    final initials = UserUtils.getInitials(name);
    final course = s['course'] as Map<String, dynamic>?;
    final courseName = course?['name'] as String?;
    final section = s['section'] as String?;
    final classLabel =
        courseName != null
            ? '$courseName${section != null ? ' $section' : ''}'
            : '—';
    final parents = s['parents'] as List<dynamic>?;
    // Find the primary contact (guardian) among parents
    final guardian =
        parents?.isNotEmpty == true
            ? parents!.cast<Map<String, dynamic>>().firstWhere(
                  (p) => p['isPrimaryContact'] == true,
                  orElse:
                      () =>
                          parents.isNotEmpty
                              ? parents.first as Map<String, dynamic>
                              : <String, dynamic>{},
                )['user']
                as Map<String, dynamic>?
            : null;
    final guardianName = guardian?['name'] as String? ?? '—';
    // Get phone from student or primary parent contact
    var phone = user?['phone'] as String? ?? '';
    if (phone.isEmpty) {
      final parents = s['parents'] as List<dynamic>? ?? [];
      final primaryParent = parents.cast<Map<String, dynamic>>().firstWhere(
        (p) => p['isPrimaryContact'] == true,
        orElse:
            () =>
                parents.isNotEmpty
                    ? parents.first as Map<String, dynamic>
                    : <String, dynamic>{},
      );
      final parentUser = primaryParent['user'] as Map<String, dynamic>?;
      phone = parentUser?['phone'] as String? ?? '—';
    }
    if (phone.isEmpty) phone = '—';
    final status = user?['status'] as String? ?? 'ACTIVE';
    final admissionDate = s['admissionDate'] as String?;
    final dateStr =
        admissionDate != null ? admissionDate.toString().split('T').first : '—';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.slate200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.blue500.withValues(alpha: 0.2),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.blue600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppTheme.slate800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        status == 'ACTIVE'
                            ? AppTheme.blue50
                            : AppTheme.slate100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status == 'ACTIVE' ? context.translate('active') : status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color:
                          status == 'ACTIVE'
                              ? AppTheme.blue600
                              : AppTheme.slate600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _infoRow(Icons.school_rounded, classLabel),
            const SizedBox(height: 4),
            _infoRow(Icons.person_outline_rounded, guardianName),
            const SizedBox(height: 4),
            _infoRow(Icons.phone_outlined, phone.toString()),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  onPressed: () => _viewStudentDetails(context, s),
                  tooltip: context.translate('view_details'),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => _editStudent(context, s),
                  tooltip: context.translate('edit'),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 14, color: AppTheme.slate500),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, color: AppTheme.slate600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  Widget _buildTable(List<dynamic> students) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.slate200),
      ),
      child: DataTable(
        columns: [
          DataColumn(label: Text(context.translate('name'))),
          DataColumn(label: Text(context.translate('roll_number'))),
          DataColumn(label: Text(context.translate('class'))),
          DataColumn(label: Text(context.translate('guardian_name'))),
          DataColumn(label: Text(context.translate('phone_number'))),
          DataColumn(label: Text(context.translate('status'))),
          DataColumn(label: Text(context.translate('actions'))),
        ],
        rows:
            students.map((s) {
              final user = s['user'] as Map<String, dynamic>?;
              final name = user?['name'] as String? ?? '—';
              final course = s['course'] as Map<String, dynamic>?;
              final courseName = course?['name'] as String?;
              final section = s['section'] as String?;
              final classLabel =
                  courseName != null
                      ? '$courseName${section != null ? ' $section' : ''}'
                      : '—';
              final parents = s['parents'] as List<dynamic>?;
              // Find the primary contact (guardian) among parents
              final guardian =
                  parents?.isNotEmpty == true
                      ? parents!.cast<Map<String, dynamic>>().firstWhere(
                            (p) => p['isPrimaryContact'] == true,
                            orElse:
                                () =>
                                    parents.isNotEmpty
                                        ? parents.first as Map<String, dynamic>
                                        : <String, dynamic>{},
                          )['user']
                          as Map<String, dynamic>?
                      : null;
              final guardianName = guardian?['name'] as String? ?? '—';
              final phone = user?['phone'] as String? ?? '—';
              final status = user?['status'] as String? ?? 'ACTIVE';
              return DataRow(
                cells: [
                  DataCell(Text(name)),
                  DataCell(Text((s['rollNumber'] as String?) ?? '—')),
                  DataCell(Text(classLabel)),
                  DataCell(Text(guardianName)),
                  DataCell(Text(phone)),
                  DataCell(Text(status)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility_outlined, size: 20),
                          onPressed: () => _viewStudentDetails(context, s),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => _editStudent(context, s),
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

  Widget _buildSummaryBar(BuildContext context) {
    final provider = context.watch<AdminStudentsProvider>();
    final totalStudents = provider.totalStudents;
    final activeStudents = provider.activeStudents;
    final inactiveStudents = provider.inactiveStudents;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.slate100,
        border: Border(top: BorderSide(color: AppTheme.slate200)),
      ),
      child: Row(
        children: [
          _summaryChip(context.translate('total_students'), '$totalStudents'),
          const SizedBox(width: 24),
          _summaryChip(context.translate('active_students'), '$activeStudents'),
          const SizedBox(width: 24),
          _summaryChip(
            context.translate('inactive_students'),
            '$inactiveStudents',
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, String value) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 13, color: AppTheme.slate600),
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

  void _viewStudentDetails(BuildContext context, student) {
    final user = student['user'] as Map<String, dynamic>?;
    final name = user?['name'] as String? ?? 'Student';
    final admissionNumber = student['admissionNumber'] as String? ?? '';
    final course = student['course'] as Map<String, dynamic>?;
    final courseName = course?['name'] as String? ?? '';
    final section = student['section'] as String? ?? '';
    final rollNumber = student['rollNumber'] as String? ?? '';
    final parents = student['parents'] as List<dynamic>? ?? [];
    // Find the primary contact (guardian) among parents
    final guardian =
        parents.isNotEmpty
            ? parents.cast<Map<String, dynamic>>().firstWhere(
                  (p) => p['isPrimaryContact'] == true,
                  orElse:
                      () =>
                          parents.isNotEmpty
                              ? parents.first as Map<String, dynamic>
                              : <String, dynamic>{},
                )['user']
                as Map<String, dynamic>?
            : null;
    final guardianName = guardian?['name'] as String? ?? '';
    final phone = user?['phone'] as String? ?? '';
    final email = user?['email'] as String? ?? '';
    final status = user?['status'] as String? ?? 'ACTIVE';
    final studentType = student['studentType'] as String? ?? '';
    final residentialStatus = student['residentialStatus'] as String? ?? '';

    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.person, color: AppTheme.blue500),
                const SizedBox(width: 8),
                Text(context.translate('student_details')),
              ],
            ),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow('Name', name),
                  _detailRow('Admission Number', admissionNumber),
                  _detailRow('Roll Number', rollNumber),
                  _detailRow('Course', courseName),
                  _detailRow('Section', section),
                  _detailRow('Guardian', guardianName),
                  _detailRow('Phone', phone),
                  _detailRow('Email', email),
                  _detailRow('Status', status),
                  _detailRow('Student Type', studentType),
                  _detailRow(
                    'Residential Status',
                    residentialStatus.replaceAll('_', ' '),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.translate('close')),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _editStudent(context, student);
                },
                icon: const Icon(Icons.edit, size: 16),
                label: Text(context.translate('edit')),
              ),
            ],
          ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppTheme.slate600,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(color: AppTheme.slate800, fontSize: 13),
          ),
        ),
      ],
    ),
  );

  void _editStudent(BuildContext context, student) {
    showDialog<void>(
      context: context,
      builder: (context) => EditStudentDialog(student: student),
    );
  }

  void _showAddStudent(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AddStudentDialog(courses: _courses),
    );
  }
}
