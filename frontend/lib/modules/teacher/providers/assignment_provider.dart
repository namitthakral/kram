import 'package:flutter/foundation.dart';

import '../models/assignment_models.dart';
import '../services/teacher_service.dart';

/// Provider for managing assignment state and operations
class AssignmentProvider with ChangeNotifier {
  final TeacherService _teacherService = TeacherService();

  List<Assignment> _assignments = [];
  List<Course> _courses = [];
  List<Section> _sections = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedCourseFilter;
  String? _selectedStatusFilter;

  List<Assignment> get assignments => _assignments;
  List<Course> get courses => _courses;
  List<Section> get sections => _sections;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCourseFilter => _selectedCourseFilter;
  String? get selectedStatusFilter => _selectedStatusFilter;

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

  /// Load teacher's courses for dropdown
  Future<void> loadCourses(String userUuid) async {
    try {
      _courses = await _teacherService.getTeacherCourses(userUuid);
      notifyListeners();
    } on Exception catch (e) {
      debugPrint('Error loading courses: $e');
    }
  }

  /// Load sections for a specific course
  Future<void> loadSectionsForCourse(String userUuid, int courseId) async {
    try {
      _sections = await _teacherService.getSectionsForCourse(
        userUuid,
        courseId,
      );
      notifyListeners();
    } on Exception catch (e) {
      debugPrint('Error loading sections: $e');
    }
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
