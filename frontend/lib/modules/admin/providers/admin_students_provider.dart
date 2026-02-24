import 'package:flutter/material.dart';

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
  Map<String, dynamic>? _stats;

  List<dynamic> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get page => _page;
  int get limit => _limit;
  int get total => _total;
  int get totalPages => _totalPages;
  String get searchQuery => _searchQuery;
  int? get courseIdFilter => _courseIdFilter;
  Map<String, dynamic>? get stats => _stats;

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

  void setPage(int p) {
    _page = p;
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _adminService.getStudents(
        page: _page,
        limit: _limit,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        courseId: _courseIdFilter,
      );
      _students = (res['data'] as List<dynamic>?) ?? [];
      final meta = res['pagination'] as Map<String, dynamic>?;
      if (meta != null) {
        _total = meta['total'] as int? ?? _students.length;
        _totalPages = meta['totalPages'] as int? ?? 1;
      }
    } catch (e) {
      _error = e.toString();
      _students = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Optional: fetch summary stats (total, active, avg attendance, honor) if backend provides
  Future<void> fetchStats() async {
    try {
      // Could be GET /admin/students/stats or derived from dashboard
      _stats = null;
      notifyListeners();
    } catch (_) {
      _stats = null;
      notifyListeners();
    }
  }
}
