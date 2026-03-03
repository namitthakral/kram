import 'package:flutter/material.dart';

import '../../../core/services/courses_service.dart';

class CourseManagementProvider extends ChangeNotifier {
  final CoursesService _coursesService = CoursesService();

  // State
  bool _isLoading = false;
  String? _error;
  List<dynamic> _courses = [];
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get courses => _courses;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;

  void setLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Fetch all courses
  Future<void> fetchCourses({int? institutionId}) async {
    try {
      setLoading(value: true);
      setError(null);

      final coursesList = await _coursesService.getAllCourses(
        institutionId: institutionId,
        status: 'ACTIVE',
      );

      _courses = coursesList;
    } on Exception catch (e) {
      setError(e.toString());
    } finally {
      setLoading(value: false);
    }
  }

  /// Create a new course
  Future<bool> createCourse(Map<String, dynamic> courseData) async {
    try {
      _isCreating = true;
      setError(null);
      notifyListeners();

      final response = await _coursesService.createCourse(courseData);

      if (response['success'] == true) {
        // Refresh the courses list
        await fetchCourses();
        return true;
      } else {
        setError(response['message'] as String? ?? 'Failed to create course');
        return false;
      }
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  /// Update an existing course
  Future<bool> updateCourse(int courseId, Map<String, dynamic> courseData) async {
    try {
      _isUpdating = true;
      setError(null);
      notifyListeners();

      final response = await _coursesService.updateCourse(courseId, courseData);

      if (response['success'] == true) {
        // Refresh the courses list
        await fetchCourses();
        return true;
      } else {
        setError(response['message'] as String? ?? 'Failed to update course');
        return false;
      }
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// Delete a course
  Future<bool> deleteCourse(int courseId) async {
    try {
      _isDeleting = true;
      setError(null);
      notifyListeners();

      final response = await _coursesService.deleteCourse(courseId);

      if (response['success'] == true) {
        // Refresh the courses list
        await fetchCourses();
        return true;
      } else {
        setError(response['message'] as String? ?? 'Failed to delete course');
        return false;
      }
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  /// Get course by ID
  Map<String, dynamic>? getCourseById(int courseId) {
    try {
      return _courses.firstWhere(
        (course) => course['id'] == courseId,
        orElse: () => null,
      ) as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }
}