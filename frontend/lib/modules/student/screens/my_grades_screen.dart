import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../provider/login_signup/login_provider.dart';
import '../../../../utils/custom_colors.dart';
import '../../../../utils/user_utils.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../providers/student_provider.dart';

class MyGradesScreen extends StatelessWidget {
  const MyGradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final studentProvider = context.watch<StudentProvider>();

    final user = loginProvider.currentUser;
    final userInitials = user != null ? UserUtils.getInitials(user.name) : 'ST';
    final userName = user?.name ?? 'Student';

    final className = studentProvider.studentClassName;
    final section = studentProvider.studentSection;
    final gradeLabel =
        className.isNotEmpty ? '$className $section' : 'Class N/A';
    final rollNumber = user?.student?.rollNumber ?? 'N/A';

    // Dynamic Data
    final stats = studentProvider.dashboardStats;
    final gpa = stats?['gpa'] ?? 'N/A';
    final subjects = studentProvider.enrolledSubjects;

    return CustomMainScreenWithAppbar(
      title: 'My Grades',
      appBarConfig: AppBarConfig.student(
        userInitials: userInitials,
        userName: userName,
        grade: gradeLabel,
        rollNumber: rollNumber,
        gpa: gpa.toString(),
        onNotificationIconPressed: () {},
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildGpaCard(context, gpa.toString()),
            const SizedBox(height: 20),
            Expanded(
              child:
                  subjects.isEmpty
                      ? const Center(child: Text('No academic records found'))
                      : ListView.builder(
                        itemCount: subjects.length,
                        itemBuilder: (context, index) {
                          final subject = subjects[index];
                          return _buildSubjectGradeCard(
                            context,
                            subject['subjectName'] ?? 'Unknown Subject',
                            subject['grade'] ?? '-',
                            subject['percentage'] != null
                                ? '${subject['percentage']}%'
                                : '-',
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGpaCard(BuildContext context, String gpa) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          CustomAppColors.primary,
          CustomAppColors.primary.withValues(alpha: 0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: CustomAppColors.primary.withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overall GPA',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          gpa,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Excellent Performance', // Ideally this should be dynamic too based on GPA
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );

  Widget _buildSubjectGradeCard(
    BuildContext context,
    String subject,
    String grade,
    String percentage,
  ) {
    Color gradeColor;
    if (grade.startsWith('A')) {
      gradeColor = CustomAppColors.primary;
    } else if (grade.startsWith('B')) {
      gradeColor = Colors.blue;
    } else if (grade.startsWith('C')) {
      gradeColor = Colors.orange;
    } else {
      gradeColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: gradeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              grade,
              style: TextStyle(
                color: gradeColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          subject,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: const Text('Final Exam'),
        trailing: Text(
          percentage,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
