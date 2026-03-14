import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/custom_colors.dart';

/// Widget to display class-level statistics
class ClassStatisticsWidget extends StatelessWidget {
  const ClassStatisticsWidget({
    required this.totalStudents,
    required this.averageAttendance,
    required this.averageGrade,
    required this.upcomingDeadlines,
    super.key,
  });

  final int totalStudents;
  final double averageAttendance;
  final double? averageGrade;
  final int upcomingDeadlines;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.grey.shade200),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Class Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: AppTheme.fontWeightSemibold,
              color: AppTheme.slate800,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people_outline,
                  label: 'Total Students',
                  value: totalStudents.toString(),
                  color: CustomAppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle_outline,
                  label: 'Avg Attendance',
                  value: '${averageAttendance.toStringAsFixed(1)}%',
                  color: const Color(0xFF00a63e),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star_outline,
                  label: 'Avg Grade',
                  value:
                      averageGrade != null
                          ? averageGrade!.toStringAsFixed(1)
                          : 'N/A',
                  color: const Color(0xFFf59e0b),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.event_outlined,
                  label: 'Upcoming',
                  value: upcomingDeadlines.toString(),
                  color: const Color(0xFFef4444),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: AppTheme.fontWeightBold,
            color: AppTheme.slate800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.slate600),
        ),
      ],
    ),
  );
}
