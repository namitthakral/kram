import 'package:flutter/material.dart';

import '../../../utils/responsive_utils.dart';
import '../models/parent_dashboard_models.dart';

class AcademicActivityCard extends StatelessWidget {
  const AcademicActivityCard({required this.activity, super.key});

  final AcademicActivity activity;

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.test:
        return Icons.assignment;
      case ActivityType.project:
        return Icons.star;
      case ActivityType.assignment:
        return Icons.description;
      case ActivityType.quiz:
        return Icons.quiz;
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.test:
        return const Color(0xFF4F7CFF);
      case ActivityType.project:
        return const Color(0xFF8B5CF6);
      case ActivityType.assignment:
        return const Color(0xFF10b981);
      case ActivityType.quiz:
        return const Color(0xFFf59e0b);
    }
  }

  Color _getGradeColor(String? grade) {
    if (grade == null) {
      return const Color(0xFF64748b);
    }
    if (grade.startsWith('A') || grade.toLowerCase() == 'excellent') {
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
    final isDesktop = context.isDesktop;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isDesktop ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(isDesktop ? 12 : 10),
            decoration: BoxDecoration(
              color: _getActivityColor(activity.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getActivityIcon(activity.type),
              color: _getActivityColor(activity.type),
              size: isDesktop ? 24 : 20,
            ),
          ),
          const SizedBox(width: 12),

          // Activity Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontSize: isDesktop ? 15 : 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1e293b),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.date,
                  style: TextStyle(
                    fontSize: isDesktop ? 13 : 12,
                    color: const Color(0xFF64748b),
                  ),
                ),
              ],
            ),
          ),

          // Grade/Score
          if (activity.grade != null)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 12 : 10,
                vertical: isDesktop ? 6 : 5,
              ),
              decoration: BoxDecoration(
                color: _getGradeColor(activity.grade),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                activity.score ?? activity.grade!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDesktop ? 13 : 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
