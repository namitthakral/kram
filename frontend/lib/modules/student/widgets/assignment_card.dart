import 'package:flutter/material.dart';
import '../../../utils/responsive_utils.dart';
import '../models/student_dashboard_models.dart';

/// Assignment Card Widget
class AssignmentCard extends StatelessWidget {
  const AssignmentCard({
    required this.assignment,
    super.key,
  });

  final Assignment assignment;

  Color _getStatusColor(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.submitted:
        return const Color(0xFF4F7CFF);
      case AssignmentStatus.graded:
        return const Color(0xFF10b981);
      case AssignmentStatus.pending:
        return const Color(0xFFf59e0b);
    }
  }

  String _getStatusLabel(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.submitted:
        return 'submitted';
      case AssignmentStatus.graded:
        return 'graded';
      case AssignmentStatus.pending:
        return 'pending';
    }
  }

  Color _getGradeColor(String? grade) {
    if (grade == null) {
      return const Color(0xFF64748b);
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFe2e8f0)),
        ),
      ),
      child: isMobile
          ? _buildMobileRow()
          : _buildDesktopRow(),
    );
  }

  // Mobile row with fixed widths for horizontal scrolling
  Widget _buildMobileRow() => Row(
        children: [
          // Assignment Info
          SizedBox(
            width: 200,
            child: Text(
              assignment.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1e293b),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Subject
          SizedBox(
            width: 150,
            child: Text(
              assignment.subject,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748b),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Due Date
          SizedBox(
            width: 120,
            child: Text(
              assignment.dueDate,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748b),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Status Badge
          SizedBox(
            width: 100,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(assignment.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getStatusLabel(assignment.status),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _getStatusColor(assignment.status),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Grade Badge
          SizedBox(
            width: 60,
            child: assignment.grade != null
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getGradeColor(assignment.grade),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      assignment.grade!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : const Text(
                    '-',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF64748b),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Score
          SizedBox(
            width: 100,
            child: Text(
              assignment.score ?? 'Pending Review',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1e293b),
              ),
            ),
          ),
        ],
      );

  // Desktop row with flexible widths
  Widget _buildDesktopRow() => Row(
        children: [
          // Assignment Info
          Expanded(
            flex: 3,
            child: Text(
              assignment.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1e293b),
              ),
            ),
          ),

          // Subject
          Expanded(
            flex: 2,
            child: Text(
              assignment.subject,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748b),
              ),
            ),
          ),

          // Due Date
          Expanded(
            flex: 2,
            child: Text(
              assignment.dueDate,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748b),
              ),
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _getStatusColor(assignment.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _getStatusLabel(assignment.status),
              style: TextStyle(
                color: _getStatusColor(assignment.status),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Grade Badge
          if (assignment.grade != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _getGradeColor(assignment.grade),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                assignment.grade!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: const Text(
                '-',
                style: TextStyle(
                  color: Color(0xFF64748b),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          const SizedBox(width: 12),

          // Score
          SizedBox(
            width: 100,
            child: Text(
              assignment.score ?? 'Pending Review',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1e293b),
              ),
            ),
          ),
        ],
      );
}
