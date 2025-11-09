import 'package:flutter/material.dart';

/// Library Tab Enum
enum LibraryTab { issuedBooks, bookInventory, analytics, overdue }

extension LibraryTabExtension on LibraryTab {
  String get displayName {
    switch (this) {
      case LibraryTab.issuedBooks:
        return 'Issued Books';
      case LibraryTab.bookInventory:
        return 'Book Inventory';
      case LibraryTab.analytics:
        return 'Analytics';
      case LibraryTab.overdue:
        return 'Overdue';
    }
  }
}

/// Book Model
class Book {
  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.publicationYear,
    required this.rating,
    required this.totalCopies,
    required this.availableCopies,
    required this.issuedCount,
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'] as int,
    title: json['title'] as String,
    author: json['author'] as String,
    category: json['category'] as String,
    publicationYear: json['publicationYear'] as int,
    rating: (json['rating'] as num).toDouble(),
    totalCopies: json['totalCopies'] as int,
    availableCopies: json['availableCopies'] as int,
    issuedCount: json['issuedCount'] as int,
  );
  final int id;
  final String title;
  final String author;
  final String category;
  final int publicationYear;
  final double rating;
  final int totalCopies;
  final int availableCopies;
  final int issuedCount;
}

/// Book Issue Model
class BookIssue {
  BookIssue({
    required this.id,
    required this.bookTitle,
    required this.studentName,
    required this.studentId,
    required this.grade,
    required this.category,
    required this.dueDate,
    required this.status,
    required this.userInitials,
  });

  factory BookIssue.fromJson(Map<String, dynamic> json) => BookIssue(
    id: json['id'] as int,
    bookTitle: json['bookTitle'] as String,
    studentName: json['studentName'] as String,
    studentId: json['studentId'] as String,
    grade: json['grade'] as String,
    category: json['category'] as String,
    dueDate: json['dueDate'] as String,
    status: json['status'] as String,
    userInitials: json['userInitials'] as String,
  );
  final int id;
  final String bookTitle;
  final String studentName;
  final String studentId;
  final String grade;
  final String category;
  final String dueDate;
  final String status;
  final String userInitials;
}

/// Overdue Book Model
class OverdueBook {
  OverdueBook({
    required this.id,
    required this.bookTitle,
    required this.studentName,
    required this.studentId,
    required this.grade,
    required this.dueDate,
    required this.daysOverdue,
    required this.fine,
    required this.userInitials,
  });

  factory OverdueBook.fromJson(Map<String, dynamic> json) => OverdueBook(
    id: json['id'] as int,
    bookTitle: json['bookTitle'] as String,
    studentName: json['studentName'] as String,
    studentId: json['studentId'] as String,
    grade: json['grade'] as String,
    dueDate: json['dueDate'] as String,
    daysOverdue: json['daysOverdue'] as int,
    fine: (json['fine'] as num).toDouble(),
    userInitials: json['userInitials'] as String,
  );
  final int id;
  final String bookTitle;
  final String studentName;
  final String studentId;
  final String grade;
  final String dueDate;
  final int daysOverdue;
  final double fine;
  final String userInitials;
}

/// Library Stats Model
class LibraryStats {
  LibraryStats({
    required this.totalBooks,
    required this.addedThisMonth,
    required this.availableBooks,
    required this.availablePercentage,
    required this.booksIssued,
    required this.membersCount,
    required this.overdueBooks,
  });

  factory LibraryStats.fromJson(Map<String, dynamic> json) => LibraryStats(
    totalBooks: json['totalBooks'] as int,
    addedThisMonth: json['addedThisMonth'] as int,
    availableBooks: json['availableBooks'] as int,
    availablePercentage: (json['availablePercentage'] as num).toDouble(),
    booksIssued: json['booksIssued'] as int,
    membersCount: json['membersCount'] as int,
    overdueBooks: json['overdueBooks'] as int,
  );
  final int totalBooks;
  final int addedThisMonth;
  final int availableBooks;
  final double availablePercentage;
  final int booksIssued;
  final int membersCount;
  final int overdueBooks;
}

/// Monthly Activity Data
class MonthlyActivity {
  MonthlyActivity({
    required this.month,
    required this.issued,
    required this.returned,
    required this.overdue,
  });

  factory MonthlyActivity.fromJson(Map<String, dynamic> json) =>
      MonthlyActivity(
        month: json['month'] as String,
        issued: json['issued'] as int,
        returned: json['returned'] as int,
        overdue: json['overdue'] as int,
      );
  final String month;
  final int issued;
  final int returned;
  final int overdue;
}

/// Category Distribution Data
class CategoryDistribution {
  CategoryDistribution({
    required this.category,
    required this.percentage,
    required this.color,
  });

  factory CategoryDistribution.fromJson(Map<String, dynamic> json) =>
      CategoryDistribution(
        category: json['category'] as String,
        percentage: (json['percentage'] as num).toDouble(),
        color: Color(json['color'] as int),
      );
  final String category;
  final double percentage;
  final Color color;
}
