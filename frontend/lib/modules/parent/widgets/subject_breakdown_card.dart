import 'package:flutter/material.dart';

import '../../../utils/responsive_utils.dart';
import '../models/parent_dashboard_models.dart';

class SubjectBreakdownCard extends StatelessWidget {
  const SubjectBreakdownCard({required this.subject, super.key});

  final SubjectBreakdown subject;

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
      ),
      child: Row(
        children: [
          // Color indicator
          Container(
            width: 4,
            height: isDesktop ? 50 : 45,
            decoration: BoxDecoration(
              color: subject.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),

          // Subject info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.subject,
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1e293b),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last test: ${subject.percentage.toInt()}%',
                  style: TextStyle(
                    fontSize: isDesktop ? 13 : 12,
                    color: const Color(0xFF64748b),
                  ),
                ),
              ],
            ),
          ),

          // Grade
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 12 : 10,
              vertical: isDesktop ? 6 : 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFf1f5f9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              subject.grade,
              style: TextStyle(
                fontSize: isDesktop ? 15 : 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1e293b),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Change indicator
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 10 : 8,
              vertical: isDesktop ? 6 : 5,
            ),
            decoration: BoxDecoration(
              color:
                  subject.change >= 0
                      ? const Color(0xFF10b981).withValues(alpha: 0.1)
                      : const Color(0xFFef4444).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  subject.change >= 0
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: isDesktop ? 16 : 14,
                  color:
                      subject.change >= 0
                          ? const Color(0xFF10b981)
                          : const Color(0xFFef4444),
                ),
                const SizedBox(width: 4),
                Text(
                  '${subject.change.abs()}',
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : 13,
                    fontWeight: FontWeight.w600,
                    color:
                        subject.change >= 0
                            ? const Color(0xFF10b981)
                            : const Color(0xFFef4444),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
