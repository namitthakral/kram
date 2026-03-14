import 'package:flutter/material.dart';
import '../../../utils/responsive_utils.dart';
import '../models/student_dashboard_models.dart';

/// Event Card Widget
class EventCard extends StatelessWidget {
  const EventCard({required this.event, super.key});

  final UpcomingEvent event;

  Color _getEventTypeColor(EventType type) {
    switch (type) {
      case EventType.test:
        return const Color(0xFFef4444);
      case EventType.assignment:
        return const Color(0xFF4F7CFF);
      case EventType.event:
        return const Color(0xFF64748b);
    }
  }

  String _getEventTypeLabel(EventType type) {
    switch (type) {
      case EventType.test:
        return 'test';
      case EventType.assignment:
        return 'assignment';
      case EventType.event:
        return 'event';
    }
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
          // Event Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1e293b),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.date}\n${event.time}',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: const Color(0xFF64748b),
                  ),
                ),
              ],
            ),
          ),

          // Event Type Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 12,
              vertical: isMobile ? 5 : 6,
            ),
            decoration: BoxDecoration(
              color: _getEventTypeColor(event.type),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getEventTypeLabel(event.type),
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 12 : 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
