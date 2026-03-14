import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/user_utils.dart';

/// Enhanced student card with profile and quick stats
class StudentProfileCard extends StatelessWidget {
  const StudentProfileCard({
    required this.studentName,
    required this.rollNumber,
    this.attendancePercentage,
    this.averageGrade,
    this.onTap,
    this.onContact,
    this.onAddRemark,
    super.key,
  });

  final String studentName;
  final String rollNumber;
  final double? attendancePercentage;
  final double? averageGrade;
  final VoidCallback? onTap;
  final VoidCallback? onContact;
  final VoidCallback? onAddRemark;

  @override
  Widget build(BuildContext context) {
    final initials = UserUtils.getInitials(studentName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with Status Indicator
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: CustomAppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: CustomAppColors.primary.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: CustomAppColors.primary,
                            fontSize: 20,
                            fontWeight: AppTheme.fontWeightBold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _getStatusColor(),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Student Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: AppTheme.fontWeightBold,
                          color: AppTheme.slate800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Roll No: $rollNumber',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.slate500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Tags / Stats
                      Row(
                        children: [
                          if (attendancePercentage != null) ...[
                            _buildStatBadge(
                              icon: Icons.check_circle_outline,
                              label: '${attendancePercentage!.toInt()}%',
                              color: _getAttendanceColor(attendancePercentage!),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (averageGrade != null)
                            _buildStatBadge(
                              icon: Icons.grade_outlined,
                              label: averageGrade!.toStringAsFixed(1),
                              color: _getGradeColor(averageGrade!),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions Column
                Column(
                  children: [
                    if (onContact != null)
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline_rounded),
                        onPressed: onContact,
                        color: AppTheme.slate500,
                        iconSize: 20,
                        tooltip: 'Message',
                      ),
                    if (onAddRemark != null)
                      IconButton(
                        icon: const Icon(Icons.note_add_outlined),
                        onPressed: onAddRemark,
                        color: AppTheme.slate500,
                        iconSize: 20,
                        tooltip: 'Add Learning Note',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: AppTheme.fontWeightSemibold,
            color: color,
          ),
        ),
      ],
    ),
  );

  Color _getStatusColor() {
    // Logic to determine status color (e.g. based on attendance or performance)
    // For now, simple logic
    if (attendancePercentage != null && attendancePercentage! < 75) {
      return const Color(0xFFef4444); // Red for low attendance
    }
    return const Color(0xFF00a63e); // Green otherwise
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 75) return const Color(0xFF00a63e);
    if (percentage >= 60) return const Color(0xFFf59e0b);
    return const Color(0xFFef4444);
  }

  Color _getGradeColor(double grade) {
    if (grade >= 80) return const Color(0xFF00a63e);
    if (grade >= 60) return const Color(0xFFf59e0b);
    return const Color(0xFFef4444);
  }
}
