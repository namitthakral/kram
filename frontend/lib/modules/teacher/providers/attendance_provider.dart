import 'package:flutter/material.dart';

import '../models/attendance_models.dart';

class AttendanceProvider with ChangeNotifier {
  // Selected Date
  DateTime _selectedDate = DateTime.now();

  // Selected Class
  ClassInfo? _selectedClass;

  // Selected Grading System
  GradingSystem? _selectedGradingSystem;

  // List of students with attendance
  List<StudentAttendance> _students = [];

  // Loading state
  bool _isLoading = false;

  // Error state
  String? _error;

  // Available classes (mock data - replace with API call)
  final List<ClassInfo> _availableClasses = [
    ClassInfo(id: '1', name: 'Grade 10-A', totalStudents: 28),
    ClassInfo(id: '2', name: 'Grade 10-B', totalStudents: 30),
    ClassInfo(id: '3', name: 'Grade 9-A', totalStudents: 25),
  ];

  // Available grading systems (mock data - replace with API call)
  final List<GradingSystem> _availableGradingSystems = [
    GradingSystem(
      id: '1',
      name: 'Standard System',
      description: 'Default grading configuration',
    ),
    GradingSystem(
      id: '2',
      name: 'Honor System',
      description: 'Advanced grading for honors classes',
    ),
    GradingSystem(
      id: '3',
      name: 'Pass/Fail System',
      description: 'Simple pass or fail grading',
    ),
  ];

  // Getters
  DateTime get selectedDate => _selectedDate;
  ClassInfo? get selectedClass => _selectedClass;
  GradingSystem? get selectedGradingSystem => _selectedGradingSystem;
  List<StudentAttendance> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ClassInfo> get availableClasses => _availableClasses;
  List<GradingSystem> get availableGradingSystems => _availableGradingSystems;

  AttendanceSummary get summary {
    final present =
        _students.where((s) => s.status == AttendanceStatus.present).length;
    final absent =
        _students.where((s) => s.status == AttendanceStatus.absent).length;
    return AttendanceSummary(
      totalStudents: _students.length,
      present: present,
      absent: absent,
    );
  }

  // Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Set selected class and load students
  Future<void> setSelectedClass(ClassInfo classInfo) async {
    _selectedClass = classInfo;
    _error = null;
    notifyListeners();
    await _loadStudents(classInfo.id);
  }

  // Set selected grading system
  void setSelectedGradingSystem(GradingSystem? system) {
    _selectedGradingSystem = system;
    notifyListeners();
  }

  // Load students for a class (mock data - replace with API call)
  Future<void> _loadStudents(String classId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock student data
      _students = _getMockStudents(classId);
    } on Exception catch (e) {
      _error = 'Failed to load students: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle student attendance status
  void toggleStudentAttendance(String studentId) {
    final index = _students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      final student = _students[index];
      _students[index] = student.copyWith(
        status: student.status == AttendanceStatus.present
            ? AttendanceStatus.absent
            : AttendanceStatus.present,
      );
      notifyListeners();
    }
  }

  // Mark all students as present
  void markAllPresent() {
    _students = _students
        .map(
          (student) => student.copyWith(status: AttendanceStatus.present),
        )
        .toList();
    notifyListeners();
  }

  // Mark all students as absent
  void markAllAbsent() {
    _students = _students
        .map(
          (student) => student.copyWith(status: AttendanceStatus.absent),
        )
        .toList();
    notifyListeners();
  }

  // Save attendance (mock - replace with API call)
  Future<bool> saveAttendance() async {
    if (_selectedClass == null) {
      _error = 'Please select a class';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock success
      return true;
    } on Exception catch (e) {
      _error = 'Failed to save attendance: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset attendance state
  void reset() {
    _selectedDate = DateTime.now();
    _selectedClass = null;
    _selectedGradingSystem = null;
    _students = [];
    _error = null;
    notifyListeners();
  }

  // Mock student data generator
  List<StudentAttendance> _getMockStudents(String classId) {
    final mockNames = [
      'Emma Johnson',
      'Michael Chen',
      'Sarah Williams',
      'David Brown',
      'Lisa Anderson',
      'James Wilson',
      'Maria Garcia',
      'Robert Martinez',
      'Jennifer Davis',
      'William Rodriguez',
      'Emily Taylor',
      'Daniel Thomas',
      'Jessica Moore',
      'Christopher Jackson',
      'Ashley White',
      'Matthew Harris',
      'Amanda Martin',
      'Joshua Thompson',
      'Stephanie Garcia',
      'Andrew Martinez',
      'Rebecca Robinson',
      'Justin Clark',
      'Laura Lewis',
      'Ryan Lee',
      'Michelle Walker',
      'Kevin Hall',
      'Nicole Allen',
      'Brandon Young',
    ];

    return List.generate(
      mockNames.length,
      (index) {
        final name = mockNames[index];
        final nameParts = name.split(' ');
        final initials =
            '${nameParts[0][0]}${nameParts.length > 1 ? nameParts[1][0] : ''}';

        return StudentAttendance(
          id: '$classId-student-$index',
          name: name,
          initials: initials,
        );
      },
    );
  }
}
