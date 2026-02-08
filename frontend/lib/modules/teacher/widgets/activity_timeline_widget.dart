import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/custom_colors.dart';

/// Activity item model
class ActivityItem {
  ActivityItem({
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.studentName,
  });

  final String type; // 'submission', 'grade', 'attendance', 'remark'
  final String title;
  final String description;
  final DateTime timestamp;
  final String? studentName;
}

/// Timeline widget for class activities
class ActivityTimelineWidget extends StatelessWidget {
  const ActivityTimelineWidget({required this.activities, super.key});

  final List<ActivityItem> activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No recent activities',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final isLast = index == activities.length - 1;

        return _buildTimelineItem(activity, isLast);
      },
    );
  }

  Widget _buildTimelineItem(ActivityItem activity, bool isLast) {
    final icon = _getActivityIcon(activity.type);
    final color = _getActivityColor(activity.type);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Activity content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: AppTheme.fontWeightSemibold,
                      color: AppTheme.slate800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.description,
                    style: const TextStyle(fontSize: 13, color: AppTheme.slate600),
                  ),
                  if (activity.studentName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Student: ${activity.studentName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.slate500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    _formatTimestamp(activity.timestamp),
                    style: const TextStyle(fontSize: 12, color: AppTheme.slate500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'submission':
        return Icons.assignment_turned_in_outlined;
      case 'grade':
        return Icons.grade_outlined;
      case 'attendance':
        return Icons.check_circle_outline;
      case 'remark':
        return Icons.comment_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'submission':
        return CustomAppColors.primary;
      case 'grade':
        return const Color(0xFFf59e0b);
      case 'attendance':
        return const Color(0xFF00a63e);
      case 'remark':
        return const Color(0xFF8b5cf6);
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(timestamp);
    }
  }
}
