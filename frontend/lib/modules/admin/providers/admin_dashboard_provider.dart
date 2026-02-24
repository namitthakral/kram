import 'package:flutter/foundation.dart';

import '../models/admin_dashboard_models.dart';
import '../services/admin_service.dart';

class AdminDashboardProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  AdminDashboardResponse? _dashboardData;
  List<TeacherPerformance>? _teacherPerformance;
  List<AttendanceTrend>? _attendanceTrends;
  List<GradeDistribution>? _gradeDistribution;
  List<ClassPerformance>? _classPerformance;
  List<FinancialOverview>? _financialOverview;
  List<SystemAlert>? _systemAlerts;

  bool _isLoading = false;
  bool _isLoadingCharts = false;
  String? _error;
  String? _chartsError;

  AdminDashboardResponse? get dashboardData => _dashboardData;
  List<TeacherPerformance>? get teacherPerformance => _teacherPerformance;
  List<AttendanceTrend>? get attendanceTrends => _attendanceTrends;
  List<GradeDistribution>? get gradeDistribution => _gradeDistribution;
  List<ClassPerformance>? get classPerformance => _classPerformance;
  List<FinancialOverview>? get financialOverview => _financialOverview;
  List<SystemAlert>? get systemAlerts => _systemAlerts;

  bool get isLoading => _isLoading;
  bool get isLoadingCharts => _isLoadingCharts;
  String? get error => _error;
  String? get chartsError => _chartsError;
  bool get hasData => _dashboardData != null;
  bool get hasChartData =>
      _attendanceTrends != null ||
      _gradeDistribution != null ||
      _classPerformance != null ||
      _financialOverview != null;

  AdminDashboardStats? get stats => _dashboardData?.stats;

  /// Fetches all dashboard data from single API (stats, alerts, charts).
  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboardData = await _adminService.getDashboardStats();
      _teacherPerformance = _dashboardData?.teacherPerformance ?? [];
      _systemAlerts = _dashboardData?.systemAlerts ?? [];
      _attendanceTrends = _dashboardData?.attendanceTrends ?? [];
      _gradeDistribution = _dashboardData?.gradeDistribution ?? [];
      _classPerformance = _dashboardData?.classPerformance ?? [];
      _financialOverview = _dashboardData?.financialOverview ?? [];
      _error = null;
    } on Exception catch (e) {
      _error = e.toString();
      debugPrint('Error fetching dashboard stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTeacherPerformance({int limit = 10}) async {
    try {
      _teacherPerformance = await _adminService.getTeacherPerformance(
        limit: limit,
      );
      notifyListeners();
    } on Exception catch (e) {
      debugPrint('Error fetching teacher performance: $e');
    }
  }

  Future<void> fetchAttendanceTrends({String? period}) async {
    _isLoadingCharts = true;
    _chartsError = null;
    notifyListeners();

    try {
      _attendanceTrends = await _adminService.getAttendanceTrends(
        period: period,
      );
      _chartsError = null;
    } on Exception catch (e) {
      _chartsError = e.toString();
      debugPrint('Error fetching attendance trends: $e');
    } finally {
      _isLoadingCharts = false;
      notifyListeners();
    }
  }

  Future<void> fetchGradeDistribution() async {
    _isLoadingCharts = true;
    _chartsError = null;
    notifyListeners();

    try {
      _gradeDistribution = await _adminService.getGradeDistribution();
      _chartsError = null;
    } on Exception catch (e) {
      _chartsError = e.toString();
      debugPrint('Error fetching grade distribution: $e');
    } finally {
      _isLoadingCharts = false;
      notifyListeners();
    }
  }

  Future<void> fetchClassPerformance() async {
    _isLoadingCharts = true;
    _chartsError = null;
    notifyListeners();

    try {
      _classPerformance = await _adminService.getClassPerformance();
      _chartsError = null;
    } on Exception catch (e) {
      _chartsError = e.toString();
      debugPrint('Error fetching class performance: $e');
    } finally {
      _isLoadingCharts = false;
      notifyListeners();
    }
  }

  Future<void> fetchFinancialOverview({String? period}) async {
    _isLoadingCharts = true;
    _chartsError = null;
    notifyListeners();

    try {
      _financialOverview = await _adminService.getFinancialOverview(
        period: period,
      );
      _chartsError = null;
    } on Exception catch (e) {
      _chartsError = e.toString();
      debugPrint('Error fetching financial overview: $e');
    } finally {
      _isLoadingCharts = false;
      notifyListeners();
    }
  }

  Future<void> fetchSystemAlerts({String? severity, int limit = 20}) async {
    try {
      _systemAlerts = await _adminService.getSystemAlerts(
        severity: severity,
        limit: limit,
      );
      notifyListeners();
    } on Exception catch (e) {
      debugPrint('Error fetching system alerts: $e');
    }
  }

  Future<void> fetchAllChartData() async {
    _isLoadingCharts = true;
    _chartsError = null;
    notifyListeners();

    try {
      await Future.wait([
        _adminService
            .getAttendanceTrends()
            .then((value) => _attendanceTrends = value),
        _adminService
            .getGradeDistribution()
            .then((value) => _gradeDistribution = value),
        _adminService
            .getClassPerformance()
            .then((value) => _classPerformance = value),
        _adminService
            .getFinancialOverview()
            .then((value) => _financialOverview = value),
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

  Future<void> refresh() async {
    await fetchDashboardStats();
  }

  Future<void> refreshAll() async {
    await Future.wait([
      fetchDashboardStats(),
      fetchAllChartData(),
    ]);
  }

  void clearData() {
    _dashboardData = null;
    _teacherPerformance = null;
    _attendanceTrends = null;
    _gradeDistribution = null;
    _classPerformance = null;
    _financialOverview = null;
    _systemAlerts = null;
    _error = null;
    _chartsError = null;
    _isLoading = false;
    _isLoadingCharts = false;
    notifyListeners();
  }
}
