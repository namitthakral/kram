import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../providers/course_management_provider.dart';
import '../widgets/create_course_dialog.dart';
import '../widgets/edit_course_dialog.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCourses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    final loginProvider = context.read<LoginProvider>();
    final user = loginProvider.currentUser;
    final institutionId = user?.institutionId;

    if (mounted) {
      await context.read<CourseManagementProvider>().fetchCourses(
        institutionId: institutionId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final userInitials = UserUtils.getInitials(user?.name ?? 'AD');
    final userName = user?.name ?? 'Admin';

    return CustomMainScreenWithAppbar(
      title: context.translate('course_management'),
      appBarConfig: AppBarConfig.admin(
        userInitials: userInitials,
        userName: userName,
        institutionName: user?.institution?.name ?? '',
        onNotificationIconPressed: () {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateCourseDialog(context),
        backgroundColor: AppTheme.blue500,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _searchController,
                    hintText: context.translate('search_courses'),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.slate100,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<CourseManagementProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.courses.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.courses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(provider.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadCourses,
                          child: Text(context.translate('retry')),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.courses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.translate('no_courses_found'),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.translate('create_first_course'),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filter courses based on search query
                final filteredCourses = provider.courses.where((course) {
                  if (_searchQuery.isEmpty) return true;
                  final name = (course['name'] ?? '').toString().toLowerCase();
                  final code = (course['code'] ?? '').toString().toLowerCase();
                  final degreeType = (course['degreeType'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery) ||
                      code.contains(_searchQuery) ||
                      degreeType.contains(_searchQuery);
                }).toList();

                if (filteredCourses.isEmpty) {
                  return Center(
                    child: Text(context.translate('no_courses_match_search')),
                  );
                }

                return ListView.builder(
                  itemCount: filteredCourses.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final course = filteredCourses[index] as Map<String, dynamic>;
                    return _buildCourseCard(context, course, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Map<String, dynamic> course, CourseManagementProvider provider) {
    final name = course['name'] ?? 'Unknown Course';
    final code = course['code'] ?? '';
    final degreeType = course['degreeType'] ?? '';
    final description = course['description'] ?? '';
    final duration = course['duration']?.toString() ?? '';
    final durationUnit = course['durationUnit'] ?? '';
    final totalSemesters = course['totalSemesters']?.toString() ?? '';
    final status = course['status'] ?? 'ACTIVE';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (code.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.blue50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                code,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.blue600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              degreeType,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.success,
                              ),
                            ),
                          ),
                          if (duration.isNotEmpty && durationUnit.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              '$duration $durationUnit',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                          if (totalSemesters.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              '$totalSemesters semesters',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditCourseDialog(context, course);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(context, course, provider);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 20),
                          const SizedBox(width: 8),
                          Text(context.translate('edit')),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 20, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            context.translate('delete'),
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
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
              ],
            ),
          ],
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
      default:
        return Colors.blue;
    }
  }

  void _showCreateCourseDialog(BuildContext context) => showDialog(
    context: context,
    builder: (context) => const CreateCourseDialog(),
  );

  void _showEditCourseDialog(BuildContext context, Map<String, dynamic> course) => showDialog(
    context: context,
    builder: (context) => EditCourseDialog(course: course),
  );

  void _showDeleteConfirmation(
    BuildContext context,
    Map<String, dynamic> course,
    CourseManagementProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.translate('delete_course')),
        content: Text(
          context.translate('delete_course_confirmation').replaceAll(
            '{courseName}',
            course['name'] ?? 'this course',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.translate('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.deleteCourse(course['id'] as int);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.translate('course_deleted_successfully')),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (mounted && provider.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.error!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(context.translate('delete')),
          ),
        ],
      ),
    );
  }
}