import 'package:flutter/material.dart';

import '../models/marks_models.dart';

class MarksProvider with ChangeNotifier {
  // Selected values
  ClassInfo? _selectedClass;
  SubjectInfo? _selectedSubject;
  ExamType? _selectedExamType;
  double? _totalMarks = 100;
  DateTime? _examDate;

  // List of students with marks
  List<StudentMarks> _students = [];

  // Loading state
  bool _isLoading = false;

  // Error state
  String? _error;

  // Available data (mock data - replace with API call)
  final List<ClassInfo> _availableClasses = [
    ClassInfo(id: '1', name: 'Grade 10-A', totalStudents: 28),
    ClassInfo(id: '2', name: 'Grade 10-B', totalStudents: 30),
    ClassInfo(id: '3', name: 'Grade 9-A', totalStudents: 25),
  ];

  final List<SubjectInfo> _availableSubjects = [
    SubjectInfo(id: '1', name: 'Mathematics'),
    SubjectInfo(id: '2', name: 'Physics'),
    SubjectInfo(id: '3', name: 'Chemistry'),
    SubjectInfo(id: '4', name: 'Biology'),
    SubjectInfo(id: '5', name: 'English'),
    SubjectInfo(id: '6', name: 'History'),
  ];

  final List<ExamType> _availableExamTypes = [
    ExamType(id: '1', name: 'Quiz'),
    ExamType(id: '2', name: 'Unit Test'),
    ExamType(id: '3', name: 'Mid-Term'),
    ExamType(id: '4', name: 'Final Exam'),
    ExamType(id: '5', name: 'Assignment'),
  ];

  // Getters
  ClassInfo? get selectedClass => _selectedClass;
  SubjectInfo? get selectedSubject => _selectedSubject;
  ExamType? get selectedExamType => _selectedExamType;
  double? get totalMarks => _totalMarks;
  DateTime? get examDate => _examDate;
  List<StudentMarks> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ClassInfo> get availableClasses => _availableClasses;
  List<SubjectInfo> get availableSubjects => _availableSubjects;
  List<ExamType> get availableExamTypes => _availableExamTypes;

  // Show only first 4 students
  List<StudentMarks> get displayedStudents =>
      _students.length > 4 ? _students.sublist(0, 4) : _students;

  bool get hasMoreStudents => _students.length > 4;

  MarksSummary get summary {
    final entered = _students.where((s) => s.marks != null).length;
    final pending = _students.where((s) => s.marks == null).length;
    final totalMarksSum =
        _students.where((s) => s.marks != null).fold<double>(
              0,
              (sum, s) => sum + (s.marks ?? 0),
            );
    final averageMarks =
        entered > 0 ? totalMarksSum / entered : 0.0;

    return MarksSummary(
      totalStudents: _students.length,
      entered: entered,
      pending: pending,
      averageMarks: averageMarks,
    );
  }

  bool get canSave =>
      _selectedClass != null &&
      _selectedSubject != null &&
      _selectedExamType != null &&
      _totalMarks != null &&
      _examDate != null;

  // Set selected class and load students
  Future<void> setSelectedClass(ClassInfo? classInfo) async {
    _selectedClass = classInfo;
    _error = null;
    notifyListeners();
    if (classInfo != null) {
      await _loadStudents(classInfo.id);
    } else {
      _students = [];
      notifyListeners();
    }
  }

  // Set selected subject
  void setSelectedSubject(SubjectInfo? subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  // Set selected exam type
  void setSelectedExamType(ExamType? examType) {
    _selectedExamType = examType;
    notifyListeners();
  }

  // Set total marks
  void setTotalMarks(double? marks) {
    _totalMarks = marks;
    notifyListeners();
  }

  // Set exam date
  void setExamDate(DateTime? date) {
    _examDate = date;
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

  // Update student marks
  void updateStudentMarks(String studentId, double? marks) {
    final index = _students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      _students[index] = _students[index].copyWith(marks: marks);
      notifyListeners();
    }
  }

  // Save marks (mock - replace with API call)
  Future<bool> saveMarks() async {
    if (!canSave) {
      _error = 'Please fill all required fields';
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
      _error = 'Failed to save marks: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset marks state
  void reset() {
    _selectedClass = null;
    _selectedSubject = null;
    _selectedExamType = null;
    _totalMarks = 100;
    _examDate = null;
    _students = [];
    _error = null;
    notifyListeners();
  }

  // Mock student data generator
  List<StudentMarks> _getMockStudents(String classId) {
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

        return StudentMarks(
          id: '$classId-student-$index',
          name: name,
          initials: initials,
        );
      },
    );
  }
}
