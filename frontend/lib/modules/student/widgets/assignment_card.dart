import 'package:flutter/material.dart';
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFe2e8f0)),
        ),
      ),
      child: _buildRow(),
    );
  }

  /// Single row layout aligned with dashboard table header (flex 3, 2, 2, Status, Grade, Score).
  /// Text uses ellipsis to avoid wrapping (e.g. "Pending Review" stays on one line).
  Widget _buildRow() => Row(
        children: [
          // Assignment
          Expanded(
            flex: 3,
            child: Text(
              assignment.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748b),
              ),
            ),
          ),
          // Due Date (center-aligned)
          Expanded(
            flex: 2,
            child: Text(
              assignment.dueDate,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748b),
              ),
            ),
          ),
          // Status
          SizedBox(
            width: 80,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(assignment.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _getStatusLabel(assignment.status),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _getStatusColor(assignment.status),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Grade (center-aligned)
          SizedBox(
            width: 50,
            child: Center(
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
          ),
          const SizedBox(width: 12),
          // Score (center-aligned, single line)
          SizedBox(
            width: 100,
            child: Text(
              assignment.score ?? 'Pending Review',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1e293b),
              ),
            ),
          ),
        ],
      );
}
