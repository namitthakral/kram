import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../provider/login_signup/login_provider.dart';
import '../../../../utils/custom_colors.dart';
import '../../../../utils/user_utils.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LoginProvider>().currentUser;
    final userInitials = user != null ? UserUtils.getInitials(user.name) : 'ST';
    final userName = user?.name ?? 'Student';
    final grade = user?.student?.gradeLevel ?? 'Class 10';
    final rollNumber = user?.student?.rollNumber ?? '23';

    return CustomMainScreenWithAppbar(
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
              child: TabBarView(
                children: [
                  _buildAssignmentList(context, false),
                  _buildAssignmentList(context, true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentList(BuildContext context, bool isCompleted) {
    final assignments =
        isCompleted
            ? [
              {
                'subject': 'History',
                'title': 'World War II Essay',
                'date': 'Submitted: Oct 10',
                'status': 'Graded: A',
              },
              {
                'subject': 'English',
                'title': 'Poetry Analysis',
                'date': 'Submitted: Oct 05',
                'status': 'Graded: B+',
              },
            ]
            : [
              {
                'subject': 'Mathematics',
                'title': 'Algebra Problem Set',
                'date': 'Due: Tomorrow',
                'status': 'Pending',
              },
              {
                'subject': 'Science',
                'title': 'Lab Report: Photosynthesis',
                'date': 'Due: Oct 25',
                'status': 'In Progress',
              },
              {
                'subject': 'Computer Science',
                'title': 'Python Project',
                'date': 'Due: Oct 30',
                'status': 'Not Started',
              },
            ];

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
                        item['subject']!,
                        style: const TextStyle(
                          color: CustomAppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      item['date']!,
                      style: TextStyle(
                        color:
                            item['date']!.contains('Tomorrow')
                                ? Colors.red
                                : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item['title']!,
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
                      item['status']!,
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
