import 'package:flutter/material.dart';

import '../../../utils/responsive_utils.dart';
import '../models/parent_dashboard_models.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    required this.announcement,
    super.key,
  });

  final SchoolAnnouncement announcement;

  Color _getPriorityColor(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.high:
        return const Color(0xFFef4444);
      case AnnouncementPriority.medium:
        return const Color(0xFFf59e0b);
      case AnnouncementPriority.low:
        return const Color(0xFF64748b);
    }
  }

  String _getPriorityLabel(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.high:
        return 'high';
      case AnnouncementPriority.medium:
        return 'medium';
      case AnnouncementPriority.low:
        return 'low';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFe2e8f0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title,
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1e293b),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      announcement.description,
                      style: TextStyle(
                        fontSize: isDesktop ? 14 : 13,
                        color: const Color(0xFF64748b),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 12 : 10,
                  vertical: isDesktop ? 6 : 5,
                ),
                decoration: BoxDecoration(
                  color: _getPriorityColor(announcement.priority),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getPriorityLabel(announcement.priority),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 12 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: isDesktop ? 16 : 14,
                color: const Color(0xFF64748b),
              ),
              const SizedBox(width: 6),
              Text(
                announcement.date,
                style: TextStyle(
                  fontSize: isDesktop ? 13 : 12,
                  color: const Color(0xFF64748b),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

