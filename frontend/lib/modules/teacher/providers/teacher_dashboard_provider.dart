import 'package:flutter/foundation.dart';

import '../models/dashboard_stats.dart';
import '../services/teacher_service.dart';

/// Provider for managing teacher dashboard state
/// Handles loading and caching of dashboard statistics
class TeacherDashboardProvider extends ChangeNotifier {
  final TeacherService _teacherService = TeacherService();

  DashboardStats? _dashboardStats;
  bool _isLoading = false;
  String? _error;

  DashboardStats? get dashboardStats => _dashboardStats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _dashboardStats != null;

  /// Fetch dashboard statistics for a specific teacher
  Future<void> fetchDashboardStats(String teacherId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboardStats = await _teacherService.getDashboardStats(teacherId);
      _error = null;
    } on Exception catch (e) {
      _error = e.toString();
      debugPrint('Error fetching dashboard stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh dashboard statistics
  Future<void> refresh(String teacherId) async {
    await fetchDashboardStats(teacherId);
  }

  /// Clear the cached dashboard data
  void clearData() {
    _dashboardStats = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
