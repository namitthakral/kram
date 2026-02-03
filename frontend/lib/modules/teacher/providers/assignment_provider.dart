import 'package:flutter/foundation.dart';

import '../../../core/services/class_section_service.dart';
import '../models/assignment_models.dart';
import '../services/teacher_service.dart';

/// Provider for managing assignment state and operations
class AssignmentProvider with ChangeNotifier {
  final TeacherService _teacherService = TeacherService();
  final ClassSectionService _classSectionService = ClassSectionService();

  List<Assignment> _assignments = [];

  // Data for creation flow
  List<Course> _courses = [];
  List<Section> _sections = [];
  List<Subject> _subjects = [];

  bool _isLoading = false;
  String? _error;
  String? _selectedCourseFilter;
  String? _selectedStatusFilter;

  List<Assignment> get assignments => _assignments;
  List<Course> get courses => _courses;
  List<Section> get sections => _sections;
  List<Subject> get subjects => _subjects;

  // Backwards compatibility for ClassSection usage if needed,
  // though we are moving to discrete Course/Section/Subject selection
  List<ClassSection> get classSections => [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCourseFilter => _selectedCourseFilter;
  String? get selectedStatusFilter => _selectedStatusFilter;

  /// Load all assignments for a teacher (without filters)
  Future<void> loadAssignments(String userUuid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load ALL assignments without filters
      _assignments = await _teacherService.getAssignments(userUuid);
      _error = null;
    } on Exception catch (e) {
      _error = e.toString();
      _assignments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load courses with sections (Initialization step)
  Future<void> loadCourses() async {
    try {
      _isLoading = true;
      notifyListeners();

      final coursesData = await _classSectionService.getCoursesWithSections(
        institutionId: 1,
      );

      _courses =
          coursesData
              .map((data) => Course.fromJson(data as Map<String, dynamic>))
              .toList();

      // Reset dependent lists
      _sections = [];
      _subjects = [];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading courses: $e');
      _courses = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load details (Sections and Subjects) for a selected course
  Future<void> loadDetailsForCourse(int courseId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Parallel fetching of sections and subjects for the course
      final sectionsData = await _classSectionService.getCourseSections(
        courseId,
      );
      final courseData = await _classSectionService.getCourseById(courseId);

      // Map sections and deduplicate by ID
      final sectionsList =
          sectionsData.map((data) {
            if (data is Map<String, dynamic> && data['courseId'] == null) {
              data['courseId'] = courseId;
            }
            return Section.fromJson(data as Map<String, dynamic>);
          }).toList();

      // Deduplicate sections by ID to prevent dropdown errors
      final seenIds = <int>{};
      _sections =
          sectionsList.where((section) {
            if (seenIds.contains(section.id)) {
              return false;
            }
            seenIds.add(section.id);
            return true;
          }).toList();

      if (courseData.containsKey('subjects') &&
          courseData['subjects'] is List) {
        _subjects =
            (courseData['subjects'] as List)
                .map((data) => Subject.fromJson(data as Map<String, dynamic>))
                .toList();
      } else {
        _subjects = [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading course details: $e');
      _sections = [];
      _subjects = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  // Deprecated/Legacy methods compatibility placeholders
  Future<void> loadClassSectionsForTeacher(int teacherId) async =>
      loadCourses();
  Future<void> filterClassSectionsBySubject(
    int subjectId,
  ) async {} // No-op as flow changed

  /// Get a single assignment by ID
  Future<Assignment> getAssignment(String userUuid, int assignmentId) async {
    try {
      return await _teacherService.getAssignment(userUuid, assignmentId);
    } catch (e) {
      throw Exception('Failed to load assignment: $e');
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

  /// Get filtered assignments based on current filter criteria
  List<Assignment> getFilteredAssignments() {
    var filtered = _assignments;

    // Filter by course
    if (_selectedCourseFilter != null) {
      final courseId = int.tryParse(_selectedCourseFilter!);
      if (courseId != null) {
        filtered = filtered.where((a) => a.courseId == courseId).toList();
      }
    }

    // Filter by status
    if (_selectedStatusFilter != null) {
      filtered = filtered
          .where((a) => a.status.toUpperCase() == _selectedStatusFilter!.toUpperCase())
          .toList();
    }

    return filtered;
  }
}
