import 'package:flutter/material.dart';

class LibraryFilterProvider extends ChangeNotifier {
  String _searchQuery = '';
  String _selectedCategory = 'All Categories';
  String _selectedStatus = 'All Status';
  String _selectedReportType = 'Complete Inventory';

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedStatus => _selectedStatus;
  String get selectedReportType => _selectedReportType;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setReportType(String reportType) {
    _selectedReportType = reportType;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All Categories';
    _selectedStatus = 'All Status';
    notifyListeners();
  }

  void reset() {
    _searchQuery = '';
    _selectedCategory = 'All Categories';
    _selectedStatus = 'All Status';
    _selectedReportType = 'Complete Inventory';
    notifyListeners();
  }
}
