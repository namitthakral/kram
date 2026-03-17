import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/extensions.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_search_bar.dart';
import '../providers/teacher_classes_provider.dart';
import '../widgets/class_card_widget.dart';
import '../widgets/class_filter_widget.dart';
import '../widgets/class_view_options_widget.dart';

class MyClassesScreen extends StatefulWidget {
  const MyClassesScreen({super.key});

  @override
  State<MyClassesScreen> createState() => _MyClassesScreenState();
}

class _MyClassesScreenState extends State<MyClassesScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final loginProvider = context.read<LoginProvider>();
    final userUuid = loginProvider.currentUser?.uuid;
    final teacherId = loginProvider.currentUser?.teacher?.id;
    if (userUuid != null) {
      await context.read<TeacherClassesProvider>().loadTeacherClasses(
        userUuid,
        teacherId: teacherId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final classesProvider = context.watch<TeacherClassesProvider>();
    final user = loginProvider.currentUser;
    final teacher = user?.teacher;

    final userInitials = UserUtils.getInitials(user?.name ?? 'Teacher');
    final userName = user?.name ?? 'Teacher';
    final designation = teacher?.designation ?? 'Faculty';
    final employeeId = teacher?.employeeId ?? 'N/A';

    return CustomMainScreenWithAppbar(
      title: 'My Classes',
      appBarConfig: AppBarConfig.teacher(
        userInitials: userInitials,
        userName: userName,
        designation: designation,
        employeeId: employeeId,
        showBackButton: true,
        onNotificationIconPressed: () {},
      ),
      child: Column(
        children: [
          // Create Actions
          // Create Actions
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: ElevatedButton.icon(
          //           onPressed: () {
          //             context
          //                 .pushNamed('create_assignment')
          //                 .then((_) => _loadData());
          //           },
          //           icon: const Icon(Icons.assignment_add, size: 20),
          //           label: const Text('Create Assignment'),
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: CustomAppColors.primary,
          //             foregroundColor: Colors.white,
          //             padding: const EdgeInsets.symmetric(vertical: 12),
          //             shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(8),
          //             ),
          //             elevation: 0,
          //           ),
          //         ),
          //       ),
          //       const SizedBox(width: 12),
          //       Expanded(
          //         child: ElevatedButton.icon(
          //           onPressed: () {
          //             context.pushNamed('create_exam').then((_) => _loadData());
          //           },
          //           icon: const Icon(Icons.quiz, size: 20),
          //           label: const Text('Create Exam'),
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: const Color(0xFFf59e0b),
          //             foregroundColor: Colors.white,
          //             padding: const EdgeInsets.symmetric(vertical: 12),
          //             shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(8),
          //             ),
          //             elevation: 0,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // Search, Filter, and View Options
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: CustomSearchBar(
                    hintText: context.translate('search_classes'),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Filter Button
                OutlinedButton.icon(
                  onPressed:
                      () => ClassFilterWidget.show(context, classesProvider),
                  icon: Icon(
                    Icons.filter_list,
                    size: 20,
                    color:
                        _hasActiveFilters(classesProvider)
                            ? CustomAppColors.primary
                            : null,
                  ),
                  label: Text(
                    context.translate('filter'),
                    style: TextStyle(
                      color:
                          _hasActiveFilters(classesProvider)
                              ? CustomAppColors.primary
                              : null,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    side: BorderSide(
                      color:
                          _hasActiveFilters(classesProvider)
                              ? CustomAppColors.primary
                              : Colors.grey.shade300,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // View Options
                ClassViewOptionsWidget(
                  isGridView: classesProvider.isGridView,
                  onViewModeChanged: classesProvider.setGridView,
                  sortOption: classesProvider.sortOption,
                  onSortChanged: classesProvider.setSortOption,
                ),
              ],
            ),
          ),

          // Active Filters Chips
          if (_hasActiveFilters(classesProvider))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (classesProvider.selectedSubjectFilter != null)
                      _buildFilterChip(
                        context,
                        'Subject: ${classesProvider.selectedSubjectFilter}',
                        () => classesProvider.setSubjectFilter(null),
                      ),
                    if (classesProvider.selectedSectionFilter != null)
                      _buildFilterChip(
                        context,
                        'Section: ${classesProvider.selectedSectionFilter}',
                        () => classesProvider.setSectionFilter(null),
                      ),
                    if (classesProvider.showOnlyClassTeacher)
                      _buildFilterChip(
                        context,
                        'Class Teacher Only',
                        () => classesProvider.setShowOnlyClassTeacher(false),
                      ),
                    TextButton.icon(
                      onPressed: classesProvider.clearFilters,
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Clear All'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Content
          Expanded(
            child: Consumer<TeacherClassesProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return _buildErrorState(provider.error!);
                }

                if (provider.allClasses.isEmpty) {
                  return _buildEmptyState('No classes assigned');
                }

                // Apply search filter
                final filteredClasses =
                    provider.classes.where((classData) {
                      if (_searchQuery.isEmpty) return true;
                      final query = _searchQuery.toLowerCase();
                      return classData.displayName.toLowerCase().contains(
                            query,
                          ) ||
                          classData.subjectName.toLowerCase().contains(query) ||
                          classData.sectionName.toLowerCase().contains(query);
                    }).toList();

                if (filteredClasses.isEmpty) {
                  return _buildEmptyState('No classes found');
                }

                final classTeacherClasses =
                    filteredClasses.where((c) => c.isClassTeacher).toList();
                final subjectTeacherClasses =
                    filteredClasses.where((c) => !c.isClassTeacher).toList();

                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (classTeacherClasses.isNotEmpty)
                          _buildSection(
                            context,
                            'My Class',
                            classTeacherClasses,
                            provider.isGridView,
                          ),
                        if (subjectTeacherClasses.isNotEmpty)
                          _buildSection(
                            context,
                            'My Subjects',
                            subjectTeacherClasses,
                            provider.isGridView,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List classes,
    bool isGridView,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: CustomAppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1e293b),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                classes.length.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
      if (isGridView) _buildGridView(classes) else _buildListView(classes),
      const SizedBox(height: 12),
    ],
  );

  Widget _buildListView(List classes) => ListView.builder(
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    padding: EdgeInsets.zero,
    itemCount: classes.length,
    itemBuilder: (context, index) {
      final classData = classes[index];
      return ClassCardWidget(
        classSection: classData,
        onTap: () => _navigateToClassDetails(classData),
        onCreateExam: () => _navigateToCreateExam(classData),
        onCreateAssignment: () => _navigateToCreateAssignment(classData),
        onMarkAttendance: () => _navigateToMarkAttendance(classData),
      );
    },
  );

  Widget _buildGridView(List classes) => GridView.builder(
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    padding: EdgeInsets.zero,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: context.isMobile ? 2 : 3,
      childAspectRatio: 0.85,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
    ),
    itemCount: classes.length,
    itemBuilder: (context, index) {
      final classData = classes[index];
      return ClassCardWidget(
        classSection: classData,
        onTap: () => _navigateToClassDetails(classData),
        onCreateExam: () => _navigateToCreateExam(classData),
        onCreateAssignment: () => _navigateToCreateAssignment(classData),
        onMarkAttendance: () => _navigateToMarkAttendance(classData),
        viewMode: ClassCardViewMode.grid,
      );
    },
  );

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    VoidCallback onRemove,
  ) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: Chip(
      label: Text(label),
      onDeleted: onRemove,
      deleteIcon: const Icon(Icons.close, size: 16),
      backgroundColor: CustomAppColors.primary.withValues(alpha: 0.1),
      labelStyle: const TextStyle(
        color: CustomAppColors.primary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    ),
  );

  Widget _buildErrorState(String error) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 16),
        Text('Error: $error'),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
      ],
    ),
  );

  Widget _buildEmptyState(String message) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.class_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 24),
        Text(
          message,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1e293b),
          ),
        ),
      ],
    ),
  );

  bool _hasActiveFilters(TeacherClassesProvider provider) =>
      provider.selectedSubjectFilter != null ||
      provider.selectedSectionFilter != null ||
      provider.showOnlyClassTeacher;

  void _navigateToClassDetails(classData) {
    context.pushNamed(
      'class_detail',
      pathParameters: {
        'className': classData.displayName,
        'sectionId': classData.id.toString(),
      },
      queryParameters: {'courseId': classData.courseId.toString()},
    );
  }

  void _navigateToCreateExam(classData) {
    // Navigate to create exam with pre-filled class context
    context
        .pushNamed(
          'create_exam',
          extra: {
            'courseId': classData.courseId,
            'sectionId': classData.id,
            'subjectId': classData.subjectId,
          },
        )
        .then((_) => _loadData());
  }

  void _navigateToCreateAssignment(classData) {
    // Navigate to create assignment with pre-filled class context
    context
        .pushNamed(
          'create_assignment',
          extra: {
            'courseId': classData.courseId,
            'sectionId': classData.id,
            'subjectId': classData.subjectId,
          },
        )
        .then((_) => _loadData());
  }

  void _navigateToMarkAttendance(classData) {
    // Navigate to mark attendance (class teacher feature)
    context.pushNamed(
      'mark_attendance',
      extra: {'sectionId': classData.id, 'className': classData.displayName},
    );
  }
}
