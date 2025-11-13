import 'package:flutter/foundation.dart';

import '../models/student_dashboard_models.dart';
import '../services/student_service.dart';

/// Provider for managing student dashboard data and state
class StudentDashboardProvider extends ChangeNotifier {
  final StudentService _studentService = StudentService();

  // Loading states
  bool _isLoadingStats = false;
  bool _isLoadingSubjectPerformance = false;
  bool _isLoadingUpcomingEvents = false;
  bool _isLoadingAssignments = false;
  bool _isLoadingPerformanceTrends = false;
  bool _isLoadingAttendanceHistory = false;

  // Error states
  String? _statsError;
  String? _subjectPerformanceError;
  String? _upcomingEventsError;
  String? _assignmentsError;
  String? _performanceTrendsError;
  String? _attendanceHistoryError;

  // Data
  Map<String, dynamic>? _dashboardStats;
  Map<String, dynamic>? _subjectPerformance;
  List<dynamic>? _upcomingEvents;
  List<dynamic>? _assignments;
  Map<String, dynamic>? _performanceTrends;
  Map<String, dynamic>? _attendanceHistory;

  // Getters for loading states
  bool get isLoadingStats => _isLoadingStats;
  bool get isLoadingSubjectPerformance => _isLoadingSubjectPerformance;
  bool get isLoadingUpcomingEvents => _isLoadingUpcomingEvents;
  bool get isLoadingAssignments => _isLoadingAssignments;
  bool get isLoadingPerformanceTrends => _isLoadingPerformanceTrends;
  bool get isLoadingAttendanceHistory => _isLoadingAttendanceHistory;

  // Getters for errors
  String? get statsError => _statsError;
  String? get subjectPerformanceError => _subjectPerformanceError;
  String? get upcomingEventsError => _upcomingEventsError;
  String? get assignmentsError => _assignmentsError;
  String? get performanceTrendsError => _performanceTrendsError;
  String? get attendanceHistoryError => _attendanceHistoryError;

  // Getters for data
  Map<String, dynamic>? get dashboardStats => _dashboardStats;
  Map<String, dynamic>? get subjectPerformance => _subjectPerformance;
  List<dynamic>? get upcomingEvents => _upcomingEvents;
  List<dynamic>? get assignments => _assignments;
  Map<String, dynamic>? get performanceTrends => _performanceTrends;
  Map<String, dynamic>? get attendanceHistory => _attendanceHistory;

  // Check if there's any loading in progress
  bool get isLoading =>
      _isLoadingStats ||
      _isLoadingSubjectPerformance ||
      _isLoadingUpcomingEvents ||
      _isLoadingAssignments ||
      _isLoadingPerformanceTrends ||
      _isLoadingAttendanceHistory;

  /// Load all dashboard data
  Future<void> loadAllDashboardData(String userUuid) async {
    debugPrint('🚀 Loading all dashboard data for UUID: $userUuid');

    await Future.wait([
      loadDashboardStats(userUuid),
      loadSubjectPerformance(userUuid),
      loadUpcomingEvents(userUuid),
      loadAssignments(userUuid),
      loadPerformanceTrends(userUuid),
      loadAttendanceHistory(userUuid),
    ]);

    debugPrint('🎉 All dashboard data loading completed');
  }

  /// Load dashboard statistics
  Future<void> loadDashboardStats(String userUuid) async {
    _isLoadingStats = true;
    _statsError = null;
    notifyListeners();

    try {
      _dashboardStats = await _studentService.getDashboardStats(userUuid);
      _statsError = null;
      debugPrint('✅ Dashboard stats loaded successfully: $_dashboardStats');
    } on Exception catch (e) {
      _statsError = e.toString();
      _dashboardStats = null;
      debugPrint('❌ Error loading dashboard stats: $e');
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  /// Load subject performance data
  Future<void> loadSubjectPerformance(String userUuid) async {
    _isLoadingSubjectPerformance = true;
    _subjectPerformanceError = null;
    notifyListeners();

    try {
      _subjectPerformance = await _studentService.getSubjectPerformance(
        userUuid,
      );
      _subjectPerformanceError = null;
    } on Exception catch (e) {
      _subjectPerformanceError = e.toString();
      _subjectPerformance = null;
      debugPrint('Error loading subject performance: $e');
    } finally {
      _isLoadingSubjectPerformance = false;
      notifyListeners();
    }
  }

  /// Load upcoming events
  Future<void> loadUpcomingEvents(String userUuid, {int limit = 10}) async {
    _isLoadingUpcomingEvents = true;
    _upcomingEventsError = null;
    notifyListeners();

    try {
      _upcomingEvents = await _studentService.getUpcomingEvents(
        userUuid,
        limit: limit,
      );
      _upcomingEventsError = null;
    } on Exception catch (e) {
      _upcomingEventsError = e.toString();
      _upcomingEvents = null;
      debugPrint('Error loading upcoming events: $e');
    } finally {
      _isLoadingUpcomingEvents = false;
      notifyListeners();
    }
  }

  /// Load assignments
  Future<void> loadAssignments(
    String userUuid, {
    int limit = 10,
    String? status,
  }) async {
    _isLoadingAssignments = true;
    _assignmentsError = null;
    notifyListeners();

    try {
      _assignments = await _studentService.getAssignments(
        userUuid,
        limit: limit,
        status: status,
      );
      _assignmentsError = null;
    } on Exception catch (e) {
      _assignmentsError = e.toString();
      _assignments = null;
      debugPrint('Error loading assignments: $e');
    } finally {
      _isLoadingAssignments = false;
      notifyListeners();
    }
  }

  /// Load performance trends
  Future<void> loadPerformanceTrends(
    String userUuid, {
    String? startMonth,
    String? endMonth,
  }) async {
    _isLoadingPerformanceTrends = true;
    _performanceTrendsError = null;
    notifyListeners();

    try {
      _performanceTrends = await _studentService.getPerformanceTrends(
        userUuid,
        startMonth: startMonth,
        endMonth: endMonth,
      );
      _performanceTrendsError = null;
      debugPrint('✅ Performance trends loaded: $_performanceTrends');
    } on Exception catch (e) {
      _performanceTrendsError = e.toString();
      _performanceTrends = null;
      debugPrint('❌ Error loading performance trends: $e');
    } finally {
      _isLoadingPerformanceTrends = false;
      notifyListeners();
    }
  }

  /// Load attendance history
  Future<void> loadAttendanceHistory(String userUuid, {int? semesterId}) async {
    _isLoadingAttendanceHistory = true;
    _attendanceHistoryError = null;
    notifyListeners();

    try {
      _attendanceHistory = await _studentService.getAttendanceHistory(
        userUuid,
        semesterId: semesterId,
      );
      _attendanceHistoryError = null;
      debugPrint('✅ Attendance history loaded: $_attendanceHistory');
    } on Exception catch (e) {
      _attendanceHistoryError = e.toString();
      _attendanceHistory = null;
      debugPrint('❌ Error loading attendance history: $e');
    } finally {
      _isLoadingAttendanceHistory = false;
      notifyListeners();
    }
  }

  /// Refresh all data
  Future<void> refresh(String userUuid) async {
    await loadAllDashboardData(userUuid);
  }

  /// Clear all data
  void clearData() {
    _dashboardStats = null;
    _subjectPerformance = null;
    _upcomingEvents = null;
    _assignments = null;
    _performanceTrends = null;
    _attendanceHistory = null;

    _statsError = null;
    _subjectPerformanceError = null;
    _upcomingEventsError = null;
    _assignmentsError = null;
    _performanceTrendsError = null;
    _attendanceHistoryError = null;

    notifyListeners();
  }

  /// Helper method to get stat value safely
  dynamic getStatValue(String key, {Object? defaultValue}) =>
      _dashboardStats?[key] ?? defaultValue;

  /// Helper method to parse subject performance to list of SubjectPerformance
  List<SubjectPerformance> getSubjectPerformanceList() {
    if (_subjectPerformance == null) {
      return [];
    }

    try {
      final data = _subjectPerformance!['data'] as Map<String, dynamic>?;
      if (data == null) {
        return [];
      }

      final subjects = data['subjects'] as List<dynamic>?;
      if (subjects == null) {
        return [];
      }

      return subjects
          .map(
            (subject) => SubjectPerformance(
              subject: subject['subject'] ?? 'Unknown',
              teacher: subject['teacher'] ?? 'TBD',
              nextTest: subject['nextTest'] ?? 'TBD',
              grade: subject['grade'] ?? 'N/A',
              percentage: (subject['percentage'] ?? 0).toDouble(),
              color: subject['color'] ?? '#4F7CFF',
            ),
          )
          .toList();
    } on Exception catch (e) {
      debugPrint('Error parsing subject performance: $e');
      return [];
    }
  }

  /// Helper method to parse upcoming events to list of UpcomingEvent
  List<UpcomingEvent> getUpcomingEventsList() {
    if (_upcomingEvents == null) {
      return [];
    }

    try {
      return _upcomingEvents!.map((event) {
        final typeStr = event['type']?.toString().toLowerCase();
        final EventType type;
        if (typeStr == 'test') {
          type = EventType.test;
        } else if (typeStr == 'assignment') {
          type = EventType.assignment;
        } else {
          type = EventType.event;
        }

        return UpcomingEvent(
          title: event['title'] ?? 'Untitled Event',
          date: event['date'] ?? '',
          time: event['time'] ?? '',
          type: type,
        );
      }).toList();
    } on Exception catch (e) {
      debugPrint('Error parsing upcoming events: $e');
      return [];
    }
  }

  /// Helper method to parse assignments to list of Assignment
  List<Assignment> getAssignmentsList() {
    if (_assignments == null) {
      return [];
    }

    try {
      return _assignments!.map((assignment) {
        final statusStr = assignment['status']?.toString().toLowerCase();
        final AssignmentStatus status;
        if (statusStr == 'submitted') {
          status = AssignmentStatus.submitted;
        } else if (statusStr == 'graded') {
          status = AssignmentStatus.graded;
        } else {
          status = AssignmentStatus.pending;
        }

        return Assignment(
          title: assignment['title'] ?? 'Untitled Assignment',
          subject: assignment['subject'] ?? 'Unknown',
          dueDate: assignment['dueDate'] ?? '',
          status: status,
          grade: assignment['grade'],
          score: assignment['score'],
        );
      }).toList();
    } on Exception catch (e) {
      debugPrint('Error parsing assignments: $e');
      return [];
    }
  }
}
