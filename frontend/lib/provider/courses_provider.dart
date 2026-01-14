import 'package:flutter/foundation.dart';

import '../core/services/courses_service.dart';

/// Provider for managing courses/classes and sections data
class CoursesProvider extends ChangeNotifier {
  final CoursesService _coursesService = CoursesService();

  // Loading states
  bool _isLoadingCourses = false;
  bool _isLoadingCoursesWithSections = false;
  bool _isLoadingClassSections = false;

  // Error states
  String? _coursesError;
  String? _coursesWithSectionsError;
  String? _classSectionsError;

  // Data
  List<dynamic>? _courses;
  List<dynamic>? _coursesWithSections;
  List<dynamic>? _classSections;
  Map<String, dynamic>? _selectedCourse;

  // Getters for loading states
  bool get isLoadingCourses => _isLoadingCourses;
  bool get isLoadingCoursesWithSections => _isLoadingCoursesWithSections;
  bool get isLoadingClassSections => _isLoadingClassSections;

  // Getters for errors
  String? get coursesError => _coursesError;
  String? get coursesWithSectionsError => _coursesWithSectionsError;
  String? get classSectionsError => _classSectionsError;

  // Getters for data
  List<dynamic>? get courses => _courses;
  List<dynamic>? get coursesWithSections => _coursesWithSections;
  List<dynamic>? get classSections => _classSections;
  Map<String, dynamic>? get selectedCourse => _selectedCourse;

  // Check if there's any loading in progress
  bool get isLoading =>
      _isLoadingCourses ||
      _isLoadingCoursesWithSections ||
      _isLoadingClassSections;

  /// Load all courses/programs
  Future<void> loadCourses({
    int? institutionId,
    String? status,
    String? degreeType,
  }) async {
    _isLoadingCourses = true;
    _coursesError = null;
    notifyListeners();

    try {
      _courses = await _coursesService.getAllCourses(
        institutionId: institutionId,
        status: status,
        degreeType: degreeType,
      );
      _coursesError = null;
      debugPrint('✅ Courses loaded successfully: ${_courses?.length} courses');
    } on Exception catch (e) {
      _coursesError = e.toString().replaceAll('Exception: ', '');
      _courses = null;
      debugPrint('❌ Error loading courses: $e');
    } finally {
      _isLoadingCourses = false;
      notifyListeners();
    }
  }

  /// Load all courses with their sections
  Future<void> loadCoursesWithSections({int? institutionId}) async {
    _isLoadingCoursesWithSections = true;
    _coursesWithSectionsError = null;
    notifyListeners();

    try {
      _coursesWithSections = await _coursesService.getCoursesWithSections(
        institutionId: institutionId,
      );
      _coursesWithSectionsError = null;
      debugPrint(
        '✅ Courses with sections loaded successfully: ${_coursesWithSections?.length} courses',
      );
    } on Exception catch (e) {
      _coursesWithSectionsError = e.toString().replaceAll('Exception: ', '');
      _coursesWithSections = null;
      debugPrint('❌ Error loading courses with sections: $e');
    } finally {
      _isLoadingCoursesWithSections = false;
      notifyListeners();
    }
  }

  /// Load a single course by ID
  Future<void> loadCourseById(int id) async {
    _isLoadingCourses = true;
    _coursesError = null;
    notifyListeners();

    try {
      _selectedCourse = await _coursesService.getCourseById(id);
      _coursesError = null;
      debugPrint('✅ Course loaded successfully');
    } on Exception catch (e) {
      _coursesError = e.toString().replaceAll('Exception: ', '');
      _selectedCourse = null;
      debugPrint('❌ Error loading course: $e');
    } finally {
      _isLoadingCourses = false;
      notifyListeners();
    }
  }

  /// Load all class sections
  Future<void> loadClassSections({
    int? institutionId,
    int? semesterId,
    int? courseId,
    int? teacherId,
    String? status,
  }) async {
    _isLoadingClassSections = true;
    _classSectionsError = null;
    notifyListeners();

    try {
      _classSections = await _coursesService.getAllClassSections(
        institutionId: institutionId,
        semesterId: semesterId,
        courseId: courseId,
        teacherId: teacherId,
        status: status,
      );
      _classSectionsError = null;
      debugPrint(
        '✅ Class sections loaded successfully: ${_classSections?.length} sections',
      );
    } on Exception catch (e) {
      _classSectionsError = e.toString().replaceAll('Exception: ', '');
      _classSections = null;
      debugPrint('❌ Error loading class sections: $e');
    } finally {
      _isLoadingClassSections = false;
      notifyListeners();
    }
  }

  /// Clear all courses data
  void clearCourses() {
    _courses = null;
    _coursesError = null;
    _isLoadingCourses = false;
    notifyListeners();
  }

  /// Clear courses with sections
  void clearCoursesWithSections() {
    _coursesWithSections = null;
    _coursesWithSectionsError = null;
    _isLoadingCoursesWithSections = false;
    notifyListeners();
  }

  /// Clear class sections
  void clearClassSections() {
    _classSections = null;
    _classSectionsError = null;
    _isLoadingClassSections = false;
    notifyListeners();
  }

  /// Clear selected course
  void clearSelectedCourse() {
    _selectedCourse = null;
    notifyListeners();
  }

  /// Get unique sections from a course
  List<String> getSectionsForCourse(int courseId) {
    if (_coursesWithSections == null) {
      return [];
    }

    final course = _coursesWithSections!.firstWhere(
      (c) => c['courseId'] == courseId || c['id'] == courseId,
      orElse: () => null,
    );

    if (course == null) {
      return [];
    }

    final sections = course['sections'] as List?;
    if (sections == null) {
      return [];
    }

    return sections
        .map((s) => s['sectionName'] as String?)
        .whereType<String>()
        .toList();
  }
}
