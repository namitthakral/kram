import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../provider/login_signup/login_provider.dart';
import '../../../../utils/custom_colors.dart';
import '../../../../utils/user_utils.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../models/student_dashboard_models.dart';
import '../providers/student_provider.dart';

class StudentAssignmentDetailScreen extends StatelessWidget {
  const StudentAssignmentDetailScreen({required this.assignment, super.key});

  final Assignment assignment;

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

  Widget _buildFormattedText(String text) {
    final lines = text.split('\n');
    final children = <Widget>[];

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        continue;
      }

      if (line.startsWith('---') && line.endsWith('---')) {
        // Section Header
        final title = line.replaceAll('---', '').trim();
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CustomAppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Divider(color: CustomAppColors.primary.withValues(alpha: 0.2)),
              ],
            ),
          ),
        );
      } else {
        // Regular text or question
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              line,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) => Row(
    children: [
      Icon(icon, size: 20, color: CustomAppColors.primary),
      const SizedBox(width: 8),
      Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    ],
  );

  Widget _buildInfoCard({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );

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

    final statusColor = _getStatusColor(assignment.status);

    return CustomMainScreenWithAppbar(
      title: 'Assignment Details',
      appBarConfig: AppBarConfig.student(
        userInitials: userInitials,
        userName: userName,
        grade: grade,
        rollNumber: rollNumber,
        gpa: gpa,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Card
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: CustomAppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor,
                            statusColor.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: CustomAppColors.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  assignment.subject,
                                  style: const TextStyle(
                                    color: CustomAppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 14,
                                      color: statusColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Due: ${assignment.dueDate}',
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            assignment.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Divider(height: 1, color: Colors.grey.shade200),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Status',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      assignment.status ==
                                              AssignmentStatus.pending
                                          ? 'Pending'
                                          : (assignment.grade != null
                                              ? 'Graded'
                                              : 'Submitted'),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (assignment.score != null) ...[
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.grey.shade200,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 24),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Score',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          assignment.score!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              if (assignment.grade != null) ...[
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.grey.shade200,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 24),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Grade',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          assignment.grade!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Description Section
            if (assignment.description != null &&
                assignment.description!.isNotEmpty) ...[
              _buildSectionHeader('Description', Icons.description_outlined),
              const SizedBox(height: 16),
              _buildInfoCard(
                child: Text(
                  assignment.description!,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Instructions/Questions Section
            if (assignment.instructions != null &&
                assignment.instructions!.isNotEmpty) ...[
              _buildSectionHeader(
                'Instructions / Questions',
                Icons.assignment_outlined,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                child: _buildFormattedText(assignment.instructions!),
              ),
            ] else if (assignment.description == null ||
                assignment.description!.isEmpty) ...[
              _buildSectionHeader('Instructions', Icons.info_outline),
              const SizedBox(height: 16),
              _buildInfoCard(
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.do_not_disturb_alt_rounded,
                        size: 40,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No instructions provided.',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 40),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Submission feature coming soon!'),
                    ),
                  );
                },
                icon: Icon(
                  assignment.status == AssignmentStatus.pending
                      ? Icons.upload_file_rounded
                      : Icons.visibility_rounded,
                ),
                label: Text(
                  assignment.status == AssignmentStatus.pending
                      ? 'Submit Assignment'
                      : 'View Submission',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomAppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  iconColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
