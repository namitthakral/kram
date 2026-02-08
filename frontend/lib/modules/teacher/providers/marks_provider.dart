import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/class_section_service.dart';
import '../../teacher/services/teacher_service.dart';
import '../models/examination_models.dart';
import '../models/marks_models.dart';

class MarksProvider with ChangeNotifier {
  final TeacherService _teacherService = TeacherService();
  final ClassSectionService _classSectionService = ClassSectionService();
  final AuthService _authService = AuthService();

  // Selected values
  ClassInfo? _selectedClass;
  // SubjectInfo is implict in ClassInfo

  // Selected Exam (Mandatory)
  Examination? _selectedExam;

  // List of students with marks
  List<StudentMarks> _students = [];

  // Loading state
  bool _isLoading = false;

  // Error state
  String? _error;

  // Available data
  List<ClassInfo> _availableClasses = [];

  // Available Exams for the selected class
  List<Examination> _availableExams = [];
  List<Examination> get availableExams => _availableExams;
  Examination? get selectedExam => _selectedExam;

  // Getters
  ClassInfo? get selectedClass => _selectedClass;
  // Use selectedExam details
  double? get totalMarks => _selectedExam?.totalMarks.toDouble();
  DateTime? get examDate => _selectedExam?.examDate;
  String? get examType => _selectedExam?.examType;

  List<StudentMarks> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ClassInfo> get availableClasses => _availableClasses;

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
      _selectedClass != null && _selectedExam != null && _students.isNotEmpty;

  // Load Initial Data
  Future<void> loadInitialData(String userUuid, {int? teacherId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final classesData = await _classSectionService.getClassSections(
        institutionId: 1,
        teacherId: teacherId,
        status: 'ACTIVE',
      );

      _availableClasses =
          classesData.map((data) {
            final subject = data['subject'] as Map<String, dynamic>?;
            final course = data['course'] as Map<String, dynamic>?;

            return ClassInfo(
              id: data['id']?.toString() ?? '',
              name:
                  '${subject?['name'] ?? ''} ${data['sectionName'] ?? ''}'
                      .trim(),
              totalStudents: data['currentEnrollment'] as int? ?? 0,
              // Fix: Check multiple possible fields for valid course/subject ID
              courseId: data['courseId'] as int? ?? course?['id'] as int? ?? 0,
              sectionId: data['id'] as int?,
              sectionName: data['sectionName'] as String? ?? 'A',
              subjectName: subject?['name'] as String?,
              className: course?['name']?.toString() ?? 'Class',
              semesterId: data['semesterId'] as int?,
            );
          }).toList();

      _error = null;
    } on Exception catch (e) {
      _error = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set selected class and load students (Early Loading)
  // DEPRECATED in favor of loadExamsForSection for the new flow
  Future<void> setSelectedClass(ClassInfo? classInfo) async {
    _selectedClass = classInfo;
    _selectedExam = null; // Reset specific exam when class changes
    _availableExams = [];
    _error = null;
    notifyListeners();

    if (classInfo != null) {
      // 1. Load students for this section
      await loadStudents(classInfo.id);

      // 2. Load exams for this course
      await _loadExamsForClass(classInfo.courseId);
    } else {
      _students = [];
      notifyListeners();
    }
  }

  // Load exams for a specific section (identifies all relevant subjects/courses)
  Future<void> loadExamsForSection(String className, String sectionName) async {
    _isLoading = true;
    _selectedExam = null;
    _error = null;
    notifyListeners();

    try {
      // 1. Find all ClassInfo objects that match this Class & Section
      final relevantClasses =
          _availableClasses
              .where(
                (c) =>
                    (c.className == className) &&
                    (c.sectionName == sectionName),
              )
              .toList();

      if (relevantClasses.isEmpty) {
        _students = [];
        _availableExams = [];
        notifyListeners();
        return;
      }

      // 2. Load Students (using the ID of the first match - section IDs should be same for same section)
      // We assume the underlying sectionId is the same for all subjects of the same section
      final representativeClass = relevantClasses.first;
      await loadStudents(representativeClass.id);

      // 3. Load Exams for ALL relevant courses
      final relevantCourseIds = relevantClasses.map((c) => c.courseId).toSet();

      final user = await _authService.getCurrentUser();
      if (user?.uuid != null) {
        // Fetch ALL exams for teacher
        final allExams = await _teacherService.getExaminations(user!.uuid!);

        _availableExams =
            allExams
                .where(
                  (e) =>
                      relevantCourseIds.contains(e.courseId) &&
                      e.status != 'CANCELLED',
                )
                .toList();
      }
    } on Exception catch (e) {
      _error = 'Failed to load exams: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadExamsForClass(int courseId) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user?.uuid != null) {
        final exams = await _teacherService.getExaminations(
          user!.uuid!,
          courseId: courseId,
        );
        // Filter out cancelled exams if needed
        _availableExams = exams.where((e) => e.status != 'CANCELLED').toList();
        notifyListeners();
      }
    } on Exception catch (e) {
      print('Failed to load exams for course $courseId: $e');
    }
  }

  // Set selected exam
  Future<void> setSelectedExam(Examination? exam) async {
    _selectedExam = exam;

    // INFERS the selected class/subject context based on the exam
    if (exam != null) {
      // Find the class info that matches this exam's course
      try {
        final matchingClass = _availableClasses.firstWhere(
          (c) => c.courseId == exam.courseId,
        );
        _selectedClass = matchingClass;
      } on Exception {
        // Should not happen if data is consistent
        print(
          'Warning: Could not find ClassInfo for exam course ${exam.courseId}',
        );
      }
    } else {
      _selectedClass = null;
    }

    notifyListeners(); // Updates UI with new total marks/date implicitly via getters

    if (exam != null) {
      // Load existing marks
      if (_students.isNotEmpty) {
        final user = await _authService.getCurrentUser();
        if (user?.uuid != null) {
          _isLoading = true;
          notifyListeners();
          await _loadMarksForExam(user!.uuid!, exam.id);
          _isLoading = false;
          notifyListeners();
        }
      }
    } else {
      // Reset marks if no exam selected
      for (var i = 0; i < _students.length; i++) {
        _students[i] = _students[i].copyWith();
      }
      notifyListeners();
    }
  }

  Future<void> _loadMarksForExam(String userUuid, int examId) async {
    try {
      final results = await _teacherService.getExamResults(userUuid, examId);
      final resultMap = {
        for (final r in results)
          r['studentId'].toString(): (r['marksObtained'] as num?)?.toDouble(),
      };

      for (var i = 0; i < _students.length; i++) {
        final sid = _students[i].id;
        if (resultMap.containsKey(sid)) {
          _students[i] = _students[i].copyWith(marks: resultMap[sid]);
        } else {
          _students[i] = _students[i].copyWith();
        }
      }
    } on Exception catch (e) {
      _error = 'Failed to load marks: $e';
    }
  }

  // Load students for a class
  Future<void> loadStudents(String classId) async {
    // Only set loading if not already loading (to avoid flicker if called internally)
    if (!_isLoading) _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final sectionId = int.tryParse(classId) ?? 0;
      if (sectionId == 0) throw Exception('Invalid Class ID');

      final response = await _classSectionService.getEnrolledStudents(
        sectionId: sectionId,
      );

      final data =
          response.containsKey('data')
              ? response['data'] as Map<String, dynamic>
              : response;
      final studentsList = data['students'] as List<dynamic>? ?? [];

      _students =
          studentsList.map((s) {
            final name = s['name'] ?? 'Unknown';
            final initials = s['initials'] ?? _getInitials(name);
            return StudentMarks(
              id: s['id']?.toString() ?? '',
              name: name,
              initials: initials,
            );
          }).toList();
    } on Exception catch (e) {
      _error = 'Failed to load students: $e';
      _students = [];
    } finally {
      // Don't turn off loading here if it was part of a larger operation?
      // For safety, let the caller handle main loading state or use check
      if (isLoading) {
        // _isLoading = false; // logic moved to loadExamsForSection
      }
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
      _error = 'Please select an exam and class';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.getCurrentUser();
      if (user == null || user.uuid == null) {
        throw Exception('User not authenticated');
      }
      final userUuid = user.uuid!;

      final examId = _selectedExam!.id;

      final results =
          _students
              .where((s) => s.marks != null)
              .map(
                (s) => {'studentId': int.parse(s.id), 'marksObtained': s.marks},
              )
              .toList();

      if (results.isEmpty) {
        return true;
      }

      await _teacherService.uploadBulkExamResults(userUuid, examId, results);

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
    _selectedExam = null;
    _students = [];
    _availableExams = [];
    _error = null;
    notifyListeners();
  }
}
