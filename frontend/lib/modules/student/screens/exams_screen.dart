import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../provider/login_signup/login_provider.dart';
import '../../../../utils/custom_colors.dart';
import '../../../../utils/user_utils.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../providers/student_exams_provider.dart';
import '../providers/student_provider.dart';

class ExamsScreen extends StatelessWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();

    final user = context.watch<LoginProvider>().currentUser;
    final userInitials = user != null ? UserUtils.getInitials(user.name) : 'ST';
    final userName = user?.name ?? 'Student';

    // Get dynamic grade/class info
    final className = studentProvider.studentClassName;
    final section = studentProvider.studentSection;
    final grade =
        (className.isNotEmpty || section.isNotEmpty)
            ? '$className $section'.trim()
            : 'Class N/A';

    final rollNumber = user?.student?.rollNumber ?? 'N/A';

    // Get GPA from dashboard stats
    final statsData = studentProvider.dashboardStats;
    final gpa = statsData?['gpa']?.toString();

    return ChangeNotifierProvider(
      create: (context) {
        final provider = StudentExamsProvider();
        if (user != null) {
          provider.loadExaminations(user);
        }
        return provider;
      },
      child: CustomMainScreenWithAppbar(
        title: 'Exams & Question Papers',
        appBarConfig: AppBarConfig.student(
          userInitials: userInitials,
          userName: userName,
          grade: grade,
          rollNumber: rollNumber,
          gpa: gpa,
          onNotificationIconPressed: () {},
        ),
        child: Consumer<StudentExamsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(child: Text('Error: ${provider.error}'));
            }

            if (provider.examinations.isEmpty) {
              return const Center(child: Text('No examinations found'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.examinations.length,
              itemBuilder: (context, index) {
                final exam = provider.examinations[index];
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
                                color: CustomAppColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                exam.subject,
                                style: const TextStyle(
                                  color: CustomAppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              exam.date,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          exam.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            // Format time string to AM/PM
                            Text(
                              '${_formatTime(exam.startTime)} (${exam.duration ?? 0} mins)',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const Spacer(),
                            Text(
                              'Marks: ${exam.totalMarks}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status: ${exam.status}',
                              style: TextStyle(
                                color: _getStatusColor(exam.status),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (exam.id == 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Invalid Exam ID'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                // Navigate to question paper view
                                context.pushNamed(
                                  'student_question_paper',
                                  pathParameters: {
                                    'examId': exam.id.toString(),
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.description_outlined,
                                size: 16,
                              ),
                              label: const Text('View Paper'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CustomAppColors.primary,
                                foregroundColor: Colors.white,
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'ONGOING':
        return Colors.blue;
      case 'SCHEDULED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return 'N/A';
    try {
      // Handle both ISO string and HH:mm format
      DateTime date;
      if (timeString.contains('T')) {
        date = DateTime.parse(timeString).toLocal();
      } else {
        // Fallback for HH:mm if backend change hasn't propagated or for old data
        final now = DateTime.now();
        final parts = timeString.split(':');
        date = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
      }
      return DateFormat.jm().format(date);
    } on Exception {
      return timeString;
    }
  }
}
