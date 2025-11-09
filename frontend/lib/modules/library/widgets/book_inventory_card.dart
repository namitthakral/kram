import 'package:flutter/material.dart';

import '../../../utils/custom_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../models/library_models.dart';

class BookInventoryCard extends StatelessWidget {
  const BookInventoryCard({required this.book, super.key});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final availablePercentage = (book.availableCopies / book.totalCopies) * 100;

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
      child: Row(
        children: [
          // Book Icon
          Container(
            width: isDesktop ? 56 : 48,
            height: isDesktop ? 56 : 48,
            decoration: BoxDecoration(
              color: CustomAppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: CustomAppColors.primary,
              size: isDesktop ? 28 : 24,
            ),
          ),
          SizedBox(width: isDesktop ? 16 : 12),

          // Book Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
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
                  book.author,
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : 13,
                    color: const Color(0xFF64748b),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      book.category,
                      style: TextStyle(
                        fontSize: isDesktop ? 13 : 12,
                        color: const Color(0xFF64748b),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '•',
                      style: TextStyle(
                        fontSize: isDesktop ? 13 : 12,
                        color: const Color(0xFF64748b),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      book.publicationYear.toString(),
                      style: TextStyle(
                        fontSize: isDesktop ? 13 : 12,
                        color: const Color(0xFF64748b),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '•',
                      style: TextStyle(
                        fontSize: isDesktop ? 13 : 12,
                        color: const Color(0xFF64748b),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.star,
                      size: isDesktop ? 16 : 14,
                      color: const Color(0xFFf59e0b),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      book.rating.toString(),
                      style: TextStyle(
                        fontSize: isDesktop ? 13 : 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748b),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Availability
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Available: ${book.availableCopies}/${book.totalCopies}',
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1e293b),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Issued: ${book.issuedCount}',
                style: TextStyle(
                  fontSize: isDesktop ? 13 : 12,
                  color: const Color(0xFF64748b),
                ),
              ),
              const SizedBox(height: 12),
              // Progress bar
              SizedBox(
                width: isDesktop ? 100 : 80,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: availablePercentage / 100,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFe2e8f0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          availablePercentage > 50
                              ? const Color(0xFF10b981)
                              : availablePercentage > 20
                                  ? const Color(0xFFf59e0b)
                                  : const Color(0xFFef4444),
                        ),
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


