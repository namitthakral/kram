import 'package:flutter/material.dart';

import '../services/student_service.dart';

class StudentProvider extends ChangeNotifier {
  final StudentService _studentService = StudentService();

  bool _isLoading = false;
  String? _error;

  // Student Data
  Map<String, dynamic>? _studentProfile;
  List<Map<String, dynamic>> _enrolledSubjects = [];

  // Dropdown Selections
  Map<String, dynamic>? _selectedSubject;

  // Dashboard Stats
  Map<String, dynamic>? _dashboardStats;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get studentProfile => _studentProfile;
  List<Map<String, dynamic>> get enrolledSubjects => _enrolledSubjects;
  Map<String, dynamic>? get selectedSubject => _selectedSubject;
  Map<String, dynamic>? get dashboardStats => _dashboardStats;

  // Computed properties for dropdowns
  String get studentClassName => _studentProfile?['course']?['name'] ?? '';
  String get studentSection => _studentProfile?['section'] ?? '';

  Future<void> loadStudentData(String userUuid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Fetch Student Profile (for Class/Section info)
      final profileData = await _studentService.getStudentByUuid(userUuid);
      _studentProfile = profileData['data'];

      // 2. Fetch Enrolled Subjects
      final performanceData = await _studentService.getSubjectPerformance(
        userUuid,
      );

      if (performanceData['data'] != null &&
          performanceData['data']['subjects'] != null) {
        _enrolledSubjects = List<Map<String, dynamic>>.from(
          performanceData['data']['subjects'],
        );
      } else {
        _enrolledSubjects = [];
      }

      // 3. Fetch Dashboard Stats (Assignments, Events, GPA)
      try {
        _dashboardStats = await _studentService.getDashboardStats(userUuid);
      } on Exception catch (e) {
        debugPrint('Failed to load dashboard stats: $e');
        // Non-critical, continue without stats
      }
    } on Exception catch (e) {
      _error = e.toString();
      debugPrint('Error loading student data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectSubject(Map<String, dynamic>? subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  void clearSelection() {
    _selectedSubject = null;
    notifyListeners();
  }
}
