import 'package:flutter/material.dart';

import '../../../utils/custom_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../models/library_models.dart';

class IssuedBookCard extends StatelessWidget {
  const IssuedBookCard({required this.bookIssue, super.key});

  final BookIssue bookIssue;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isOverdue = bookIssue.status == 'Overdue';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue
              ? const Color(0xFFef4444).withValues(alpha: 0.3)
              : const Color(0xFFe2e8f0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: isDesktop ? 56 : 48,
            height: isDesktop ? 56 : 48,
            decoration: BoxDecoration(
              color: CustomAppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                bookIssue.userInitials,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDesktop ? 20 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: isDesktop ? 16 : 12),

          // Book and Student Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookIssue.bookTitle,
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1e293b),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '${bookIssue.studentName} • ${bookIssue.studentId}',
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : 13,
                    color: const Color(0xFF64748b),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '${bookIssue.grade} • ${bookIssue.category}',
                  style: TextStyle(
                    fontSize: isDesktop ? 13 : 12,
                    color: const Color(0xFF64748b),
                  ),
                ),
              ],
            ),
          ),

          // Status and Due Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 12 : 10,
                  vertical: isDesktop ? 6 : 5,
                ),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? const Color(0xFFef4444).withValues(alpha: 0.1)
                      : const Color(0xFF10b981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  bookIssue.status,
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 11,
                    fontWeight: FontWeight.w600,
                    color: isOverdue
                        ? const Color(0xFFef4444)
                        : const Color(0xFF10b981),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Due: ${bookIssue.dueDate}',
                style: TextStyle(
                  fontSize: isDesktop ? 13 : 12,
                  color: isOverdue
                      ? const Color(0xFFef4444)
                      : const Color(0xFF64748b),
                  fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  // Handle return action
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.refresh,
                      size: isDesktop ? 18 : 16,
                      color: CustomAppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Return',
                      style: TextStyle(
                        fontSize: isDesktop ? 13 : 12,
                        color: CustomAppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


