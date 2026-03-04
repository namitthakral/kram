import 'package:flutter/material.dart';

import '../models/admin_dashboard_models.dart';
import '../services/admin_service.dart';

class AdminStudentsProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<dynamic> _students = [];
  bool _isLoading = false;
  String? _error;
  int _page = 1;
  int _limit = 20;
  int _total = 0;
  int _totalPages = 1;
  String _searchQuery = '';
  int? _courseIdFilter;
  String? _sectionFilter;
  AdminDashboardStats? _dashboardStats;

  List<dynamic> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get page => _page;
  int get limit => _limit;
  int get total => _total;
  int get totalPages => _totalPages;
  String get searchQuery => _searchQuery;
  int? get courseIdFilter => _courseIdFilter;
  String? get sectionFilter => _sectionFilter;
  AdminDashboardStats? get dashboardStats => _dashboardStats;
  
  // Convenience getters for student counts
  int get totalStudents => _dashboardStats?.totalStudents ?? _total;
  int get activeStudents => _dashboardStats?.activeStudents ?? 0;
  int get inactiveStudents => _dashboardStats?.inactiveStudents ?? 0;

  void setSearchQuery(String value) {
    _searchQuery = value;
    _page = 1;
    fetchStudents();
  }

  void setCourseFilter(int? courseId) {
    _courseIdFilter = courseId;
    _page = 1;
    fetchStudents();
  }

  void setSectionFilter(String? section) {
    _sectionFilter = section;
    _page = 1;
    fetchStudents();
  }

  void setPage(int p) {
    _page = p;
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch both students and dashboard stats in parallel
      final results = await Future.wait([
        _adminService.getStudents(
          page: _page,
          limit: _limit,
          search: _searchQuery.isEmpty ? null : _searchQuery,
          courseId: _courseIdFilter,
          section: _sectionFilter,
        ),
        _adminService.getDashboardStats(),
      ]);

      final studentsRes = results[0] as Map<String, dynamic>;
      final dashboardRes = results[1] as AdminDashboardResponse;

      _students = (studentsRes['data'] as List<dynamic>?) ?? [];
      final meta = studentsRes['pagination'] as Map<String, dynamic>?;
      if (meta != null) {
        _total = meta['total'] as int? ?? _students.length;
        _totalPages = meta['totalPages'] as int? ?? 1;
      }

      _dashboardStats = dashboardRes.stats;
    } catch (e) {
      _error = e.toString();
      _students = [];
      _dashboardStats = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch dashboard stats separately if needed
  Future<void> fetchDashboardStats() async {
    try {
      final dashboardRes = await _adminService.getDashboardStats();
      _dashboardStats = dashboardRes.stats;
      notifyListeners();
    } catch (e) {
      _dashboardStats = null;
      notifyListeners();
    }
  }

  /// Update student information
  Future<Map<String, dynamic>?> updateStudent(String userUuid, Map<String, dynamic> studentData) async {
    try {
      final response = await _adminService.updateStudent(userUuid, studentData);
      // Refresh the student list after successful update
      await fetchStudents();
      return response;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearAllFilters() {
    _searchQuery = '';
    _courseIdFilter = null;
    _sectionFilter = null;
    _page = 1;
    _error = null;
    notifyListeners();
  }
}
