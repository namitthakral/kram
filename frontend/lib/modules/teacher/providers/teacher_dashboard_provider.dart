import 'package:flutter/foundation.dart';

import '../models/dashboard_stats.dart';
import '../services/teacher_service.dart';

class TeacherDashboardProvider extends ChangeNotifier {
  final TeacherService _teacherService = TeacherService();

  DashboardStats? _dashboardStats;
  AttendanceTrendsResponse? _attendanceTrends;
  SubjectPerformanceResponse? _subjectPerformance;
  GradeDistributionResponse? _gradeDistribution;

  bool _isLoading = false;
  bool _isLoadingCharts = false;
  String? _error;
  String? _chartsError;

  DashboardStats? get dashboardStats => _dashboardStats;
  AttendanceTrendsResponse? get attendanceTrends => _attendanceTrends;
  SubjectPerformanceResponse? get subjectPerformance => _subjectPerformance;
  GradeDistributionResponse? get gradeDistribution => _gradeDistribution;

  bool get isLoading => _isLoading;
  bool get isLoadingCharts => _isLoadingCharts;
  String? get error => _error;
  String? get chartsError => _chartsError;
  bool get hasData => _dashboardStats != null;
  bool get hasChartData =>
      _attendanceTrends != null ||
      _subjectPerformance != null ||
      _gradeDistribution != null;

  Future<void> fetchDashboardStats(String userUuid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboardStats = await _teacherService.getDashboardStats(userUuid);
      _error = null;
    } on Exception catch (e) {
      _error = e.toString();
      debugPrint('Error fetching dashboard stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAttendanceTrends(String userUuid) async {
    _isLoadingCharts = true;
    _chartsError = null;
    notifyListeners();

    try {
      _attendanceTrends = await _teacherService.getAttendanceTrends(userUuid);
      _chartsError = null;
    } on Exception catch (e) {
      _chartsError = e.toString();
      debugPrint('Error fetching attendance trends: $e');
    } finally {
      _isLoadingCharts = false;
      notifyListeners();
    }
  }

  Future<void> fetchSubjectPerformance(String userUuid) async {
    _isLoadingCharts = true;
    _chartsError = null;
    notifyListeners();

    try {
      _subjectPerformance = await _teacherService.getSubjectPerformance(
        userUuid,
      );
      _chartsError = null;
    } on Exception catch (e) {
      _chartsError = e.toString();
      debugPrint('Error fetching subject performance: $e');
    } finally {
      _isLoadingCharts = false;
      notifyListeners();
    }
  }

  Future<void> fetchGradeDistribution(String userUuid) async {
    _isLoadingCharts = true;
    _chartsError = null;
    notifyListeners();

    try {
      _gradeDistribution = await _teacherService.getGradeDistribution(userUuid);
      _chartsError = null;
    } on Exception catch (e) {
      _chartsError = e.toString();
      debugPrint('Error fetching grade distribution: $e');
    } finally {
      _isLoadingCharts = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllChartData(String userUuid) async {
    _isLoadingCharts = true;
    _chartsError = null;
    notifyListeners();

    try {
      await Future.wait([
        _teacherService
            .getAttendanceTrends(userUuid)
            .then((value) => _attendanceTrends = value),
        _teacherService
            .getSubjectPerformance(userUuid)
            .then((value) => _subjectPerformance = value),
        _teacherService
            .getGradeDistribution(userUuid)
            .then((value) => _gradeDistribution = value),
      ]);
      _chartsError = null;
    } on Exception catch (e) {
      _chartsError = e.toString();
      debugPrint('Error fetching chart data: $e');
    } finally {
      _isLoadingCharts = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String userUuid) async {
    await fetchDashboardStats(userUuid);
  }

  Future<void> refreshAll(String userUuid) async {
    await Future.wait([
      fetchDashboardStats(userUuid),
      fetchAllChartData(userUuid),
    ]);
  }

  void clearData() {
    _dashboardStats = null;
    _attendanceTrends = null;
    _subjectPerformance = null;
    _gradeDistribution = null;
    _error = null;
    _chartsError = null;
    _isLoading = false;
    _isLoadingCharts = false;
    notifyListeners();
  }
}
