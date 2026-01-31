import 'package:flutter/material.dart';
import '../models/dashboard_stats.dart';
import '../services/teacher_service.dart';

class TeacherDashboardProvider with ChangeNotifier {
  final TeacherService _teacherService = TeacherService();

  bool _isLoading = false;
  String? _error;

  // Stats
  DashboardStats? _dashboardStats;

  // Charts Data
  AttendanceTrendsResponse? _attendanceTrends;
  SubjectPerformanceResponse? _subjectPerformance;
  GradeDistributionResponse? _gradeDistribution;

  // Recent Activity
  List<StudentActivity> _activities = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Support both naming conventions (new and old)
  DashboardStats? get stats => _dashboardStats;
  DashboardStats? get dashboardStats => _dashboardStats;

  List<StudentActivity> get activities => _activities;

  AttendanceTrendsResponse? get attendanceTrends => _attendanceTrends;
  SubjectPerformanceResponse? get subjectPerformance => _subjectPerformance;
  GradeDistributionResponse? get gradeDistribution => _gradeDistribution;

  // Method used by AcademicManagementScreen (New)
  Future<void> loadDashboardData(String userUuid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load stats and activities
      final results = await Future.wait([
        _teacherService.getDashboardStats(userUuid),
        _teacherService.getRecentActivity(userUuid),
      ]);

      _dashboardStats = results[0] as DashboardStats;
      _activities = results[1] as List<StudentActivity>;
      _error = null;
    } catch (e) {
      _error = 'Failed to load dashboard data: $e';
      debugPrint('Dashboard API Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Methods used by TeacherDashboardScreen (Old/Main)
  Future<void> fetchDashboardStats(String userUuid) async {
    // Re-use logic or independent? Independent allows separate calls.
    // But we need to handle loading state carefully if multiple calls happen.

    // If already loading, we might not want to reset flag, but complex.
    // For now, simple implementation.
    _isLoading = true;
    notifyListeners();

    try {
      _dashboardStats = await _teacherService.getDashboardStats(userUuid);
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch stats: $e';
      debugPrint('Stats Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllChartData(String userUuid) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _teacherService.getAttendanceTrends(userUuid),
        _teacherService.getSubjectPerformance(userUuid),
        _teacherService.getGradeDistribution(userUuid),
      ]);

      _attendanceTrends = results[0] as AttendanceTrendsResponse;
      _subjectPerformance = results[1] as SubjectPerformanceResponse;
      _gradeDistribution = results[2] as GradeDistributionResponse;
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch chart data: $e';
      debugPrint('Charts Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
