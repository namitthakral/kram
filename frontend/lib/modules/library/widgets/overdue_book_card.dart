import 'package:flutter/material.dart';

import '../../../utils/responsive_utils.dart';
import '../models/library_models.dart';

class OverdueBookCard extends StatelessWidget {
  const OverdueBookCard({required this.overdueBook, super.key});

  final OverdueBook overdueBook;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFef2f2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFef4444).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: isDesktop ? 56 : 48,
            height: isDesktop ? 56 : 48,
            decoration: BoxDecoration(
              color: const Color(0xFFef4444),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                overdueBook.userInitials,
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
                  overdueBook.bookTitle,
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
                  '${overdueBook.studentName} • ${overdueBook.studentId}',
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : 13,
                    color: const Color(0xFF64748b),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  overdueBook.grade,
                  style: TextStyle(
                    fontSize: isDesktop ? 13 : 12,
                    color: const Color(0xFF64748b),
                  ),
                ),
              ],
            ),
          ),

          // Overdue Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 12 : 10,
                  vertical: isDesktop ? 6 : 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFef4444),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${overdueBook.daysOverdue} days overdue',
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Due: ${overdueBook.dueDate}',
                style: TextStyle(
                  fontSize: isDesktop ? 13 : 12,
                  color: const Color(0xFFef4444),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fine: ₹${overdueBook.fine.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 13,
                  color: const Color(0xFFef4444),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  // Handle send reminder action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFef4444),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 16 : 12,
                    vertical: isDesktop ? 8 : 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Send Reminder',
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 11,
                    fontWeight: FontWeight.w600,
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
