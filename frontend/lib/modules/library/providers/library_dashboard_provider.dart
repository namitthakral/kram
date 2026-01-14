import 'package:flutter/foundation.dart';

import '../models/library_models.dart';
import '../services/library_service.dart';

/// Provider for managing library dashboard data and state
class LibraryDashboardProvider extends ChangeNotifier {
  final LibraryService _libraryService = LibraryService();

  // Loading states
  bool _isLoadingStats = false;
  bool _isLoadingIssuedBooks = false;
  bool _isLoadingInventory = false;
  bool _isLoadingOverdueBooks = false;
  bool _isLoadingAnalytics = false;

  // Error states
  String? _statsError;
  String? _issuedBooksError;
  String? _inventoryError;
  String? _overdueError;
  String? _analyticsError;

  // Data
  LibraryStats? _stats;
  List<BookIssue>? _issuedBooks;
  List<Book>? _inventory;
  List<OverdueBook>? _overdueBooks;
  List<MonthlyActivity>? _monthlyActivity;
  List<CategoryDistribution>? _categoryDistribution;

  // Getters for loading states
  bool get isLoadingStats => _isLoadingStats;
  bool get isLoadingIssuedBooks => _isLoadingIssuedBooks;
  bool get isLoadingInventory => _isLoadingInventory;
  bool get isLoadingOverdueBooks => _isLoadingOverdueBooks;
  bool get isLoadingAnalytics => _isLoadingAnalytics;

  // Getters for errors
  String? get statsError => _statsError;
  String? get issuedBooksError => _issuedBooksError;
  String? get inventoryError => _inventoryError;
  String? get overdueError => _overdueError;
  String? get analyticsError => _analyticsError;

  // Getters for data
  LibraryStats? get stats => _stats;
  List<BookIssue>? get issuedBooks => _issuedBooks;
  List<Book>? get inventory => _inventory;
  List<OverdueBook>? get overdueBooks => _overdueBooks;
  List<MonthlyActivity>? get monthlyActivity => _monthlyActivity;
  List<CategoryDistribution>? get categoryDistribution => _categoryDistribution;

  // Initialize and load all data
  Future<void> initialize() async {
    await Future.wait([
      loadStats(),
      loadIssuedBooks(),
      loadInventory(),
      loadOverdueBooks(),
      loadAnalytics(),
    ]);
  }

  // Load library statistics
  Future<void> loadStats() async {
    _isLoadingStats = true;
    _statsError = null;
    notifyListeners();

    try {
      _stats = await _libraryService.getLibraryStats();
      _statsError = null;
    } on Exception catch (e) {
      _statsError = e.toString();
      debugPrint('Error loading library stats: $e');
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  // Load issued books
  Future<void> loadIssuedBooks() async {
    _isLoadingIssuedBooks = true;
    _issuedBooksError = null;
    notifyListeners();

    try {
      _issuedBooks = await _libraryService.getIssuedBooks();
      _issuedBooksError = null;
    } on Exception catch (e) {
      _issuedBooksError = e.toString();
      debugPrint('Error loading issued books: $e');
    } finally {
      _isLoadingIssuedBooks = false;
      notifyListeners();
    }
  }

  // Load book inventory
  Future<void> loadInventory() async {
    _isLoadingInventory = true;
    _inventoryError = null;
    notifyListeners();

    try {
      _inventory = await _libraryService.getBookInventory();
      _inventoryError = null;
    } on Exception catch (e) {
      _inventoryError = e.toString();
      debugPrint('Error loading inventory: $e');
    } finally {
      _isLoadingInventory = false;
      notifyListeners();
    }
  }

  // Load overdue books
  Future<void> loadOverdueBooks() async {
    _isLoadingOverdueBooks = true;
    _overdueError = null;
    notifyListeners();

    try {
      _overdueBooks = await _libraryService.getOverdueBooks();
      _overdueError = null;
    } on Exception catch (e) {
      _overdueError = e.toString();
      debugPrint('Error loading overdue books: $e');
    } finally {
      _isLoadingOverdueBooks = false;
      notifyListeners();
    }
  }

  // Load analytics data
  Future<void> loadAnalytics() async {
    _isLoadingAnalytics = true;
    _analyticsError = null;
    notifyListeners();

    try {
      final analyticsData = await _libraryService.getAnalyticsData();
      _monthlyActivity =
          analyticsData['monthlyActivity'] as List<MonthlyActivity>?;
      _categoryDistribution =
          analyticsData['categoryDistribution'] as List<CategoryDistribution>?;
      _analyticsError = null;
    } on Exception catch (e) {
      _analyticsError = e.toString();
      debugPrint('Error loading analytics: $e');
    } finally {
      _isLoadingAnalytics = false;
      notifyListeners();
    }
  }

  // Refresh all data
  Future<void> refresh() async {
    await initialize();
  }

  // Clear all data
  void clearData() {
    _stats = null;
    _issuedBooks = null;
    _inventory = null;
    _overdueBooks = null;
    _monthlyActivity = null;
    _categoryDistribution = null;
    notifyListeners();
  }
}

