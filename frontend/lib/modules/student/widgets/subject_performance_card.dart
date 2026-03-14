import 'package:flutter/material.dart';
import '../../../utils/responsive_utils.dart';
import '../models/student_dashboard_models.dart';

/// Subject Performance Card Widget
class SubjectPerformanceCard extends StatelessWidget {
  const SubjectPerformanceCard({required this.subject, super.key});

  final SubjectPerformance subject;

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  Color _getGradeColor(String grade) {
    if (grade.startsWith('A')) {
      return const Color(0xFF10b981);
    }
    if (grade.startsWith('B')) {
      return const Color(0xFF3b82f6);
    }
    if (grade.startsWith('C')) {
      return const Color(0xFF64748b);
    }
    return const Color(0xFF64748b);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      child: Row(
        children: [
          // Subject Color Indicator
          Container(
            width: isMobile ? 4 : 6,
            height: isMobile ? 48 : 56,
            decoration: BoxDecoration(
              color: _parseColor(subject.color),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),

          // Subject Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.subject,
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1e293b),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Teacher: ${subject.teacher}',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: const Color(0xFF64748b),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Next Test: ${subject.nextTest}',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: const Color(0xFF64748b),
                  ),
                ),
              ],
            ),
          ),

          // Grade Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 12,
              vertical: isMobile ? 5 : 6,
            ),
            decoration: BoxDecoration(
              color: _getGradeColor(subject.grade),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              subject.grade,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 12 : 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(width: isMobile ? 8 : 12),

          // Percentage with Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${subject.percentage.toInt()}%',
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1e293b),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: isMobile ? 50 : 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: subject.percentage / 100,
                    minHeight: isMobile ? 4 : 5,
                    backgroundColor: const Color(0xFFe2e8f0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _parseColor(subject.color),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
