import 'package:flutter/material.dart';
import '../models/dashboard_stats.dart';

/// Student Activity Card Widget
class StudentActivityCard extends StatelessWidget {
  final StudentActivity student;
  final VoidCallback onTap;

  const StudentActivityCard({
    super.key,
    required this.student,
    required this.onTap,
  });

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  Color _getGradeColor(String grade) {
    if (grade.startsWith('A')) return const Color(0xFF10b981);
    if (grade.startsWith('B')) return const Color(0xFF3b82f6);
    if (grade.startsWith('C')) return const Color(0xFF64748b);
    return const Color(0xFF64748b);
  }

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFe2e8f0)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _parseColor(student.avatarColor),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  student.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Student Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1e293b),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last active: ${student.lastActive}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748b),
                    ),
                  ),
                ],
              ),
            ),

            // Grade Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getGradeColor(student.grade),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                student.grade,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Percentage
            Text(
              '${student.percentage.toInt()}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1e293b),
              ),
            ),

            const SizedBox(width: 12),

            // View Button
            OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                side: const BorderSide(color: Color(0xFFe2e8f0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
}
