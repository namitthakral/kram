import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../providers/class_section_management_provider.dart';
import '../widgets/create_class_section_dialog.dart';
import '../widgets/edit_class_section_dialog.dart';

class ClassSectionManagementScreen extends StatefulWidget {
  const ClassSectionManagementScreen({super.key});

  @override
  State<ClassSectionManagementScreen> createState() => _ClassSectionManagementScreenState();
}

class _ClassSectionManagementScreenState extends State<ClassSectionManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClassSections();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClassSections() async {
    final loginProvider = context.read<LoginProvider>();
    final user = loginProvider.currentUser;
    final institutionId = user?.institutionId;

    if (mounted) {
      await context.read<ClassSectionManagementProvider>().fetchClassSections(
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
      title: context.translate('class_section_management'),
      appBarConfig: AppBarConfig.admin(
        userInitials: userInitials,
        userName: userName,
        institutionName: user?.institution?.name ?? '',
        onNotificationIconPressed: () {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateClassSectionDialog(context),
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
                    hintText: context.translate('search_class_sections'),
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
            child: Consumer<ClassSectionManagementProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.classSections.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.classSections.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(provider.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadClassSections,
                          child: Text(context.translate('retry')),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.classSections.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.class_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.translate('no_class_sections_found'),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.translate('create_first_class_section'),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filter class sections based on search query
                final filteredSections = provider.classSections.where((section) {
                  if (_searchQuery.isEmpty) return true;
                  final sectionName = (section['sectionName'] ?? '').toString().toLowerCase();
                  final subjectName = (section['subject']?['subjectName'] ?? '').toString().toLowerCase();
                  final courseName = (section['subject']?['course']?['name'] ?? '').toString().toLowerCase();
                  final teacherName = (section['teacher']?['user']?['name'] ?? '').toString().toLowerCase();
                  return sectionName.contains(_searchQuery) ||
                      subjectName.contains(_searchQuery) ||
                      courseName.contains(_searchQuery) ||
                      teacherName.contains(_searchQuery);
                }).toList();

                if (filteredSections.isEmpty) {
                  return Center(
                    child: Text(context.translate('no_class_sections_match_search')),
                  );
                }

                return ListView.builder(
                  itemCount: filteredSections.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final section = filteredSections[index] as Map<String, dynamic>;
                    return _buildClassSectionCard(context, section, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSectionCard(
    BuildContext context,
    Map<String, dynamic> section,
    ClassSectionManagementProvider provider,
  ) {
    final sectionName = section['sectionName'] ?? 'Unknown Section';
    final subject = section['subject'] as Map<String, dynamic>?;
    final subjectName = subject?['subjectName'] ?? 'Unknown Subject';
    final subjectCode = subject?['subjectCode'] ?? '';
    final course = subject?['course'] as Map<String, dynamic>?;
    final courseName = course?['name'] ?? '';
    final semester = section['semester'] as Map<String, dynamic>?;
    final semesterName = semester?['semesterName'] ?? '';
    final teacher = section['teacher'] as Map<String, dynamic>?;
    final teacherUser = teacher?['user'] as Map<String, dynamic>?;
    final teacherName = teacherUser?['name'] ?? 'No Teacher Assigned';
    final maxCapacity = section['maxCapacity']?.toString() ?? '';
    final room = section['room'] ?? '';
    final schedule = section['schedule'] ?? '';
    final status = section['status'] ?? 'ACTIVE';

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
                          Text(
                            '$subjectName - Section $sectionName',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (subjectCode.isNotEmpty) ...[
                            const SizedBox(width: 8),
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
                                subjectCode,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.blue600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (courseName.isNotEmpty)
                        Text(
                          courseName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (semesterName.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          semesterName,
                          style: const TextStyle(
                            fontSize: 12,
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
                        _showEditClassSectionDialog(context, section);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(context, section, provider);
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
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  teacherName,
                  style: const TextStyle(fontSize: 14),
                ),
                if (maxCapacity.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Capacity: $maxCapacity',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
            if (room.isNotEmpty || schedule.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (room.isNotEmpty) ...[
                    Icon(Icons.room, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      room,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                  if (room.isNotEmpty && schedule.isNotEmpty) const SizedBox(width: 16),
                  if (schedule.isNotEmpty) ...[
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      schedule,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
            ],
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

  void _showCreateClassSectionDialog(BuildContext context) => showDialog(
    context: context,
    builder: (context) => const CreateClassSectionDialog(),
  );

  void _showEditClassSectionDialog(BuildContext context, Map<String, dynamic> section) => showDialog(
    context: context,
    builder: (context) => EditClassSectionDialog(section: section),
  );

  void _showDeleteConfirmation(
    BuildContext context,
    Map<String, dynamic> section,
    ClassSectionManagementProvider provider,
  ) {
    final sectionName = section['sectionName'] ?? 'this section';
    final subjectName = section['subject']?['subjectName'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.translate('delete_class_section')),
        content: Text(
          context.translate('delete_class_section_confirmation').replaceAll(
            '{sectionName}',
            '$subjectName - Section $sectionName',
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
              final success = await provider.deleteClassSection(section['id'] as int);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.translate('class_section_deleted_successfully')),
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