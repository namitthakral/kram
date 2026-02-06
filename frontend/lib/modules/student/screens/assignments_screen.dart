import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../provider/login_signup/login_provider.dart';
import '../../../../utils/custom_colors.dart';
import '../../../../utils/user_utils.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../models/student_dashboard_models.dart';
import '../providers/student_assignment_provider.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

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
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const ColoredBox(
                color: Colors.white,
                child: TabBar(
                  labelColor: CustomAppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: CustomAppColors.primary,
                  tabs: [Tab(text: 'Pending'), Tab(text: 'Completed')],
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

                    return TabBarView(
                      children: [
                        _buildAssignmentList(
                          context,
                          provider.pendingAssignments,
                          false,
                        ),
                        _buildAssignmentList(
                          context,
                          provider.completedAssignments,
                          true,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
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
      return const Center(child: Text('No assignments found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final item = assignments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
                    Text(
                      'Due: ${item.dueDate}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.status == AssignmentStatus.pending
                          ? 'Pending'
                          : (item.grade != null
                              ? 'Graded: ${item.grade}'
                              : 'Submitted'),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    if (!isCompleted)
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomAppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Submit'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
