import 'package:flutter/material.dart';

import '../models/parent_dashboard_models.dart';

class ParentDashboardProvider extends ChangeNotifier {
  ParentDashboardProvider();

  bool _isLoading = false;
  String? _error;
  ChildInfo? _childInfo;
  List<AcademicActivity> _academicActivities = [];
  List<SchoolAnnouncement> _announcements = [];
  List<PerformanceTrendPoint> _performanceTrends = [];
  List<AttendanceTrendPoint> _attendanceTrends = [];
  List<SubjectBreakdown> _subjectBreakdowns = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  ChildInfo? get childInfo => _childInfo;
  List<AcademicActivity> get academicActivities => _academicActivities;
  List<SchoolAnnouncement> get announcements => _announcements;
  List<PerformanceTrendPoint> get performanceTrends => _performanceTrends;
  List<AttendanceTrendPoint> get attendanceTrends => _attendanceTrends;
  List<SubjectBreakdown> get subjectBreakdowns => _subjectBreakdowns;

  // Statistics
  double get testAverage => 87.0;
  double get semesterImprovement => 3.2;

  Future<void> fetchDashboardData(String parentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call with mock data
      await Future.delayed(const Duration(milliseconds: 500));

      _childInfo = const ChildInfo(
        name: 'Emma Johnson',
        initials: 'EJ',
        grade: 'Grade 5A',
        rollNumber: '2024-05-15',
        overallGrade: 'A',
        attendance: 94.5,
      );

      _academicActivities = _getMockAcademicActivities();
      _announcements = _getMockAnnouncements();
      _performanceTrends = _getMockPerformanceTrends();
      _attendanceTrends = _getMockAttendanceTrends();
      _subjectBreakdowns = _getMockSubjectBreakdowns();

      _isLoading = false;
      notifyListeners();
    } on Exception catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  List<AcademicActivity> _getMockAcademicActivities() => const [
    AcademicActivity(
      title: 'Mathematics Test',
      date: '2024-09-18',
      type: ActivityType.test,
      score: '88/100',
      grade: 'A',
    ),
    AcademicActivity(
      title: 'Science Project Submission',
      date: '2024-09-17',
      type: ActivityType.project,
      grade: 'Excellent',
    ),
    AcademicActivity(
      title: 'English Essay',
      date: '2024-09-16',
      type: ActivityType.assignment,
      score: '92/100',
      grade: 'A+',
    ),
    AcademicActivity(
      title: 'History Quiz',
      date: '2024-09-15',
      type: ActivityType.quiz,
      score: '15/20',
      grade: 'B+',
    ),
  ];

  List<SchoolAnnouncement> _getMockAnnouncements() => const [
    SchoolAnnouncement(
      title: 'Parent-Teacher Meeting',
      description: 'Scheduled for Grade 5A parents. Please confirm attendance.',
      date: '2024-09-25',
      priority: AnnouncementPriority.high,
    ),
    SchoolAnnouncement(
      title: 'School Sports Day',
      description: 'Annual sports event. Volunteers needed for organizing.',
      date: '2024-10-02',
      priority: AnnouncementPriority.medium,
    ),
    SchoolAnnouncement(
      title: 'Mid-term Exam Schedule',
      description:
          'Exam schedule has been updated. Check student portal for details.',
      date: '2024-10-15',
      priority: AnnouncementPriority.high,
    ),
  ];

  List<PerformanceTrendPoint> _getMockPerformanceTrends() => const [
    PerformanceTrendPoint(
      month: 'Jan',
      english: 92,
      mathematics: 85,
      science: 88,
    ),
    PerformanceTrendPoint(
      month: 'Feb',
      english: 91,
      mathematics: 86,
      science: 87,
    ),
    PerformanceTrendPoint(
      month: 'Mar',
      english: 90,
      mathematics: 88,
      science: 89,
    ),
    PerformanceTrendPoint(
      month: 'Apr',
      english: 89,
      mathematics: 87,
      science: 86,
    ),
    PerformanceTrendPoint(
      month: 'May',
      english: 93,
      mathematics: 90,
      science: 91,
    ),
    PerformanceTrendPoint(
      month: 'Jun',
      english: 94,
      mathematics: 88,
      science: 89,
    ),
  ];

  List<AttendanceTrendPoint> _getMockAttendanceTrends() => const [
    AttendanceTrendPoint(month: 'Jan', percentage: 96),
    AttendanceTrendPoint(month: 'Feb', percentage: 94),
    AttendanceTrendPoint(month: 'Mar', percentage: 98),
    AttendanceTrendPoint(month: 'Apr', percentage: 92),
    AttendanceTrendPoint(month: 'May', percentage: 95),
    AttendanceTrendPoint(month: 'Jun', percentage: 97),
  ];

  List<SubjectBreakdown> _getMockSubjectBreakdowns() => const [
    SubjectBreakdown(
      subject: 'Mathematics',
      percentage: 88,
      grade: 'A',
      change: 5,
      color: Color(0xFF4F7CFF),
    ),
    SubjectBreakdown(
      subject: 'Science',
      percentage: 85,
      grade: 'A-',
      change: 2,
      color: Color(0xFF10b981),
    ),
    SubjectBreakdown(
      subject: 'English',
      percentage: 92,
      grade: 'A+',
      change: 3,
      color: Color(0xFFf59e0b),
    ),
    SubjectBreakdown(
      subject: 'History',
      percentage: 79,
      grade: 'B+',
      change: -1,
      color: Color(0xFFef4444),
    ),
    SubjectBreakdown(
      subject: 'Art',
      percentage: 90,
      grade: 'A',
      change: 7,
      color: Color(0xFF8B5CF6),
    ),
  ];

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
