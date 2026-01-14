import 'package:flutter/material.dart';

import '../models/library_models.dart';

/// Service for library-related operations
/// This service provides mock data for now
class LibraryService {
  // Get library statistics
  Future<LibraryStats> getLibraryStats() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    return LibraryStats(
      totalBooks: 5420,
      addedThisMonth: 45,
      availableBooks: 4180,
      availablePercentage: 77.1,
      booksIssued: 1240,
      membersCount: 380,
      overdueBooks: 85,
    );
  }

  // Get issued books
  Future<List<BookIssue>> getIssuedBooks() async {
    await Future.delayed(const Duration(milliseconds: 600));

    return [
      BookIssue(
        id: 1,
        bookTitle: 'Physics Fundamentals',
        studentName: 'Alex Johnson',
        studentId: 'ST001',
        grade: 'Grade 11',
        category: 'Science',
        dueDate: '2024-01-29',
        status: 'Active',
        userInitials: 'AJ',
      ),
      BookIssue(
        id: 2,
        bookTitle: 'World History Chronicles',
        studentName: 'Sarah Chen',
        studentId: 'ST002',
        grade: 'Grade 10',
        category: 'History',
        dueDate: '2024-01-28',
        status: 'Active',
        userInitials: 'SC',
      ),
      BookIssue(
        id: 3,
        bookTitle: 'Advanced Mathematics',
        studentName: 'Michael Brown',
        studentId: 'ST003',
        grade: 'Grade 12',
        category: 'Mathematics',
        dueDate: '2024-01-24',
        status: 'Overdue',
        userInitials: 'MB',
      ),
      BookIssue(
        id: 4,
        bookTitle: 'English Literature Classics',
        studentName: 'Emily Davis',
        studentId: 'ST004',
        grade: 'Grade 9',
        category: 'Literature',
        dueDate: '2024-01-26',
        status: 'Active',
        userInitials: 'ED',
      ),
    ];
  }

  // Get book inventory
  Future<List<Book>> getBookInventory() async {
    await Future.delayed(const Duration(milliseconds: 700));

    return [
      Book(
        id: 1,
        title: 'Physics Fundamentals',
        author: 'By Dr. James Smith',
        category: 'Science',
        publicationYear: 2022,
        rating: 4.5,
        totalCopies: 25,
        availableCopies: 18,
        issuedCount: 7,
      ),
      Book(
        id: 2,
        title: 'World History Chronicles',
        author: 'By Prof. Maria Garcia',
        category: 'History',
        publicationYear: 2023,
        rating: 4.2,
        totalCopies: 20,
        availableCopies: 15,
        issuedCount: 5,
      ),
      Book(
        id: 3,
        title: 'Advanced Mathematics',
        author: 'By Dr. Robert Wilson',
        category: 'Mathematics',
        publicationYear: 2023,
        rating: 4.7,
        totalCopies: 30,
        availableCopies: 22,
        issuedCount: 8,
      ),
      Book(
        id: 4,
        title: 'English Literature Classics',
        author: 'By Jane Thompson',
        category: 'Literature',
        publicationYear: 2021,
        rating: 4.3,
        totalCopies: 15,
        availableCopies: 12,
        issuedCount: 3,
      ),
    ];
  }

  // Get overdue books
  Future<List<OverdueBook>> getOverdueBooks() async {
    await Future.delayed(const Duration(milliseconds: 550));

    return [
      OverdueBook(
        id: 1,
        bookTitle: 'Advanced Calculus',
        studentName: 'John Smith',
        studentId: 'ST015',
        grade: 'Grade 12',
        dueDate: '2024-01-08',
        daysOverdue: 7,
        fine: 35,
        userInitials: 'JS',
      ),
      OverdueBook(
        id: 2,
        bookTitle: 'Chemistry Basics',
        studentName: 'Lisa Wang',
        studentId: 'ST022',
        grade: 'Grade 10',
        dueDate: '2024-01-05',
        daysOverdue: 10,
        fine: 50,
        userInitials: 'LW',
      ),
      OverdueBook(
        id: 3,
        bookTitle: 'World Geography',
        studentName: 'David Miller',
        studentId: 'ST031',
        grade: 'Grade 9',
        dueDate: '2024-01-10',
        daysOverdue: 5,
        fine: 25,
        userInitials: 'DM',
      ),
    ];
  }

  // Get analytics data
  Future<Map<String, dynamic>> getAnalyticsData() async {
    await Future.delayed(const Duration(milliseconds: 650));

    final monthlyActivity = [
      MonthlyActivity(month: 'Aug', issued: 145, returned: 120, overdue: 8),
      MonthlyActivity(month: 'Sep', issued: 170, returned: 140, overdue: 12),
      MonthlyActivity(month: 'Oct', issued: 190, returned: 165, overdue: 15),
      MonthlyActivity(month: 'Nov', issued: 155, returned: 140, overdue: 18),
      MonthlyActivity(month: 'Dec', issued: 135, returned: 115, overdue: 22),
      MonthlyActivity(month: 'Jan', issued: 180, returned: 150, overdue: 15),
    ];

    final categoryDistribution = [
      CategoryDistribution(
        category: 'Science',
        percentage: 27,
        color: const Color(0xFF3B82F6),
      ),
      CategoryDistribution(
        category: 'Mathematics',
        percentage: 22,
        color: const Color(0xFF10B981),
      ),
      CategoryDistribution(
        category: 'Literature',
        percentage: 18,
        color: const Color(0xFF8B5CF6),
      ),
      CategoryDistribution(
        category: 'History',
        percentage: 15,
        color: const Color(0xFFF59E0B),
      ),
      CategoryDistribution(
        category: 'Arts',
        percentage: 10,
        color: const Color(0xFFEF4444),
      ),
      CategoryDistribution(
        category: 'Others',
        percentage: 9,
        color: const Color(0xFF06B6D4),
      ),
    ];

    return {
      'monthlyActivity': monthlyActivity,
      'categoryDistribution': categoryDistribution,
    };
  }
}



