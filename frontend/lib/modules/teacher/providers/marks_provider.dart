import 'package:flutter/material.dart';

import '../../../core/services/class_section_service.dart';
import '../../teacher/services/teacher_service.dart';
import '../models/marks_models.dart';

class MarksProvider with ChangeNotifier {
  final TeacherService _teacherService = TeacherService();
  final ClassSectionService _classSectionService = ClassSectionService();

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

  // Available data
  List<ClassInfo> _availableClasses = [];
  List<SubjectInfo> _availableSubjects = [];

  // Recent exams list
  List<dynamic> _recentExams = [];
  List<dynamic> get recentExams => _recentExams;

  // Keep mock exam types for now as no service found for it yet,
  // or fetch if available. Assuming static for now.
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

  // Show only first 4 students (Logic kept for EnterMarksScreen widget structure)
  List<StudentMarks> get displayedStudents =>
      _students.length > 4 ? _students.sublist(0, 4) : _students;

  bool get hasMoreStudents => _students.length > 4;

  MarksSummary get summary {
    final entered = _students.where((s) => s.marks != null).length;
    final pending = _students.where((s) => s.marks == null).length;
    final totalMarksSum = _students
        .where((s) => s.marks != null)
        .fold<double>(0, (sum, s) => sum + (s.marks ?? 0));
    final averageMarks = entered > 0 ? totalMarksSum / entered : 0.0;

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

  // Load Initial Data
  Future<void> loadInitialData(String userUuid) async {
    _isLoading = true;
    notifyListeners();
    try {
      final classesData = await _teacherService.getTeacherClasses(userUuid);
      _availableClasses =
          classesData.map((data) {
            return ClassInfo(
              id: data['id']?.toString() ?? '',
              name: '${data['name'] ?? ''} ${data['section'] ?? ''}'.trim(),
              totalStudents: data['studentCount'] as int? ?? 0,
            );
          }).toList();

      final subjectsData = await _teacherService.getTeacherSubjects(userUuid);
      _availableSubjects =
          subjectsData.map((data) {
            return SubjectInfo(
              id: data['id']?.toString() ?? '',
              name: data['name'] ?? 'Unknown Subject',
            );
          }).toList();

      _error = null;
    } catch (e) {
      _error = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load Recent Exams for List Screen
  Future<void> loadRecentExams(String userUuid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final exams = await _teacherService.getExaminations(userUuid);
      _recentExams = exams;
      _error = null;
    } catch (e) {
      _error = 'Failed to load exams: $e';
      _recentExams = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  // Load students for a class
  Future<void> _loadStudents(String classId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final sectionId = int.tryParse(classId) ?? 0;
      if (sectionId == 0) throw Exception('Invalid Class ID');

      final response = await _classSectionService.getEnrolledStudents(
        sectionId: sectionId,
      );

      final studentsList = response['students'] as List<dynamic>? ?? [];

      _students =
          studentsList.map((s) {
            final name = s['name'] ?? 'Unknown';
            final initials = s['initials'] ?? _getInitials(name);
            return StudentMarks(
              id: s['id']?.toString() ?? '',
              name: name,
              initials: initials,
              marks: null, // Reset marks initially
            );
          }).toList();
    } catch (e) {
      _error = 'Failed to load students: $e';
      _students = []; // Clear on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // Update student marks
  void updateStudentMarks(String studentId, double? marks) {
    final index = _students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      _students[index] = _students[index].copyWith(marks: marks);
      notifyListeners();
    }
  }

  // Save marks
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
      // Logic to save marks would go here
      await Future.delayed(
        const Duration(seconds: 1),
      ); // Mock save for now

      return true;
    } catch (e) {
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
}
