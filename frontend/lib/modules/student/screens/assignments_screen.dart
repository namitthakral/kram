import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../provider/login_signup/login_provider.dart';
import '../../../../utils/custom_colors.dart';
import '../../../../utils/user_utils.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../../widgets/custom_widgets/custom_tab_bar.dart';
import '../models/student_dashboard_models.dart';
import '../providers/student_assignment_provider.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LoginProvider>().currentUser;
    final userInitials = user != null ? UserUtils.getInitials(user.name) : 'ST';
    final userName = user?.name ?? 'Student';
    final grade = user?.student?.gradeLevel ?? 'Class 10';
    final rollNumber = user?.student?.rollNumber ?? '23';

    return ChangeNotifierProvider(
      create: (context) {
        final provider = StudentAssignmentProvider();
        if (user != null) {
          provider.loadAssignments(user);
        }
        return provider;
      },
      child: CustomMainScreenWithAppbar(
        title: 'Assignments',
        appBarConfig: AppBarConfig.student(
          userInitials: userInitials,
          userName: userName,
          grade: grade,
          rollNumber: rollNumber,
          onNotificationIconPressed: () {},
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomTabBar<int>(
                tabs: [
                  TabItem(
                    value: 0,
                    label: 'Pending',
                    icon: Icons.pending_actions,
                  ),
                  TabItem(value: 1, label: 'Completed', icon: Icons.task_alt),
                ],
                selectedValue: _selectedTabIndex,
                onTabSelected: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                backgroundColor: Colors.white,
                selectedTabColor: CustomAppColors.primary,
                unselectedTabColor: Colors.grey.shade100,
                selectedIconColor: Colors.white,
                unselectedIconColor: Colors.grey,
              ),
            ),
            Expanded(
              child: Consumer<StudentAssignmentProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return Center(child: Text('Error: ${provider.error}'));
                  }

                  final assignments =
                      _selectedTabIndex == 0
                          ? provider.pendingAssignments
                          : provider.completedAssignments;

                  return _buildAssignmentList(
                    context,
                    assignments,
                    _selectedTabIndex == 1,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentList(
    BuildContext context,
    List<Assignment> assignments,
    bool isCompleted,
  ) {
    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.task_alt : Icons.assignment_outlined,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isCompleted
                  ? 'No completed assignments'
                  : 'No pending assignments',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final item = assignments[index];
        return _AssignmentCard(item: item, isCompleted: isCompleted);
      },
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.item, required this.isCompleted});

  final Assignment item;
  final bool isCompleted;

  Color _getStatusColor(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.submitted:
        return Colors.blue;
      case AssignmentStatus.graded:
        return Colors.green;
      case AssignmentStatus.pending:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          context.goNamed(
            'student_assignment_detail',
            pathParameters: {'id': item.id.toString()},
            extra: item,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: CustomAppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.subject,
                      style: const TextStyle(
                        color: CustomAppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        item.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: _getStatusColor(item.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Due: ${item.dueDate}',
                          style: TextStyle(
                            color: _getStatusColor(item.status),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.status == AssignmentStatus.pending
                              ? 'Pending'
                              : (item.grade != null
                                  ? 'Graded: ${item.grade}'
                                  : 'Submitted'),
                          style: TextStyle(
                            color: _getStatusColor(item.status),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (item.score != null) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Score',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.score!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.goNamed(
                        'student_assignment_detail',
                        pathParameters: {'id': item.id.toString()},
                        extra: item,
                      );
                    },
                    icon: Icon(
                      !isCompleted ? Icons.upload_file : Icons.visibility,
                      size: 16,
                    ),
                    label: Text(!isCompleted ? 'Submit' : 'View'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomAppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
