import 'package:flutter/foundation.dart';

import '../../../core/services/class_section_service.dart';
import '../../../core/services/courses_service.dart';
import '../models/assignment_models.dart';
import '../services/teacher_service.dart';

/// Provider for managing assignment state and operations
class AssignmentProvider with ChangeNotifier {
  final TeacherService _teacherService = TeacherService();
  final CoursesService _coursesService = CoursesService();
  final ClassSectionService _classSectionService = ClassSectionService();

  List<Assignment> _assignments = [];
  List<Subject> _subjects = [];
  List<ClassSection> _classSections = [];
  List<ClassSection> _allClassSections = []; // Store all to filter later
  bool _isLoading = false;
  String? _error;
  String? _selectedCourseFilter;
  String? _selectedStatusFilter;

  List<Assignment> get assignments => _assignments;
  List<Subject> get subjects => _subjects;
  List<ClassSection> get classSections => _classSections;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCourseFilter => _selectedCourseFilter;
  String? get selectedStatusFilter => _selectedStatusFilter;

  // Legacy getters for backward compatibility
  List<Course> get courses => _subjects
      .map((s) => Course(id: s.id, courseName: s.name, courseCode: s.code))
      .toList();
  List<Section> get sections => _classSections
      .map((cs) => Section(
            id: cs.id,
            sectionName: cs.sectionName,
            courseId: cs.subjectId,
          ))
      .toList();

  /// Load all assignments for a teacher
  Future<void> loadAssignments(String userUuid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _assignments = await _teacherService.getAssignments(
        userUuid,
        courseId:
            _selectedCourseFilter != null
                ? int.tryParse(_selectedCourseFilter!)
                : null,
        status: _selectedStatusFilter,
      );
      _error = null;
    } on Exception catch (e) {
      _error = e.toString();
      _assignments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load teacher's class sections and extract subjects (legacy method)
  /// This is kept for backward compatibility but does nothing
  /// Use loadClassSectionsForTeacher(teacherId) instead
  Future<void> loadCourses(String userUuid) async {
    // This method is deprecated - call loadClassSectionsForTeacher instead
    debugPrint('loadCourses called but is deprecated. Use loadClassSectionsForTeacher instead.');
  }

  /// Load class sections and subjects for a teacher
  /// Call this method with the teacher ID to populate dropdowns
  Future<void> loadClassSectionsForTeacher(int teacherId) async {
    try {
      // Get all class sections for this teacher
      final sectionsData = await _classSectionService.getClassSections(
        teacherId: teacherId,
        status: 'ACTIVE',
      );

      // Convert to ClassSection objects
      _allClassSections = sectionsData
          .map((sectionJson) =>
              ClassSection.fromJson(sectionJson as Map<String, dynamic>))
          .toList();

      // Extract unique subjects from class sections
      final subjectMap = <int, Subject>{};
      for (final section in _allClassSections) {
        if (!subjectMap.containsKey(section.subjectId)) {
          subjectMap[section.subjectId] = Subject(
            id: section.subjectId,
            name: section.subjectName,
            code: '',
          );
        }
      }
      _subjects = subjectMap.values.toList();

      // Initially, no class sections are shown (until subject is selected)
      _classSections = [];

      notifyListeners();
    } on Exception catch (e) {
      debugPrint('Error loading class sections: $e');
      _subjects = [];
      _classSections = [];
      _allClassSections = [];
      notifyListeners();
    }
  }

  /// Filter class sections by subject
  /// Call this when a subject is selected to show relevant class sections
  void filterClassSectionsBySubject(int subjectId) {
    _classSections = _allClassSections
        .where((section) => section.subjectId == subjectId)
        .toList();
    notifyListeners();
  }

  /// Load sections for a specific course (legacy method for compatibility)
  Future<void> loadSectionsForCourse(String userUuid, int courseId) async {
    // This now filters the already-loaded class sections
    filterClassSectionsBySubject(courseId);
  }

  /// Create a new assignment
  Future<bool> createAssignment(
    String userUuid,
    CreateAssignmentDto dto,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newAssignment = await _teacherService.createAssignment(
        userUuid,
        dto,
      );
      _assignments.insert(0, newAssignment);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update an existing assignment
  Future<bool> updateAssignment(
    String userUuid,
    int assignmentId,
    UpdateAssignmentDto dto,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedAssignment = await _teacherService.updateAssignment(
        userUuid,
        assignmentId,
        dto,
      );
      final index = _assignments.indexWhere((a) => a.id == assignmentId);
      if (index != -1) {
        _assignments[index] = updatedAssignment;
      }
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete an assignment
  Future<bool> deleteAssignment(String userUuid, int assignmentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _teacherService.deleteAssignment(userUuid, assignmentId);
      _assignments.removeWhere((a) => a.id == assignmentId);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Set course filter
  void setCourseFilter(String? courseId) {
    _selectedCourseFilter = courseId;
    notifyListeners();
  }

  /// Set status filter
  void setStatusFilter(String? status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  /// Clear filters
  void clearFilters() {
    _selectedCourseFilter = null;
    _selectedStatusFilter = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get filtered assignments
  List<Assignment> getFilteredAssignments() => _assignments;
}
