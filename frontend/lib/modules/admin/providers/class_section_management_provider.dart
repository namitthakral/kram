import 'package:flutter/material.dart';

import '../../../core/services/class_section_service.dart';
import '../../../core/services/courses_service.dart';

class ClassSectionManagementProvider extends ChangeNotifier {
  final ClassSectionService _classSectionService = ClassSectionService();
  final CoursesService _coursesService = CoursesService();

  // State
  bool _isLoading = false;
  String? _error;
  List<dynamic> _classSections = [];
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  
  // Context for refreshing
  int? _lastInstitutionId;
  int? _lastCourseId;
  int? _lastSemesterId;
  int? _lastTeacherId;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get classSections => _classSections;
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

  /// Fetch all class sections (combines both simple divisions and complex sections)
  Future<void> fetchClassSections({
    int? institutionId,
    int? courseId,
    int? semesterId,
    int? teacherId,
  }) async {
    try {
      setLoading(value: true);
      setError(null);
      
      // Store parameters for future refreshes
      _lastInstitutionId = institutionId;
      _lastCourseId = courseId;
      _lastSemesterId = semesterId;
      _lastTeacherId = teacherId;

      // Get both simple class divisions and complex class sections
      final List<dynamic> allSections = [];

      // 1. Fetch complex class sections (subject-based)
      try {
        final complexSections = await _classSectionService.getClassSections(
          institutionId: institutionId,
          courseId: courseId,
          semesterId: semesterId,
          teacherId: teacherId,
          status: 'ACTIVE',
        );
        allSections.addAll(complexSections);
      } catch (e) {
        print('Error fetching complex sections: $e');
      }

      // 2. Fetch simple class divisions and convert to section format
      if (courseId != null) {
        try {
          final divisions = await _coursesService.getClassDivisions(courseId);
          final convertedDivisions = await _convertDivisionsToSections(divisions, courseId);
          allSections.addAll(convertedDivisions);
        } catch (e) {
          print('Error fetching class divisions: $e');
        }
      } else {
        // If no specific course, we need to fetch divisions for all courses
        try {
          final courses = await _coursesService.getAllCourses();
          for (final course in courses) {
            final courseData = course as Map<String, dynamic>;
            final courseIdInt = courseData['id'] as int;
            try {
              final divisions = await _coursesService.getClassDivisions(courseIdInt);
              final convertedDivisions = await _convertDivisionsToSections(divisions, courseIdInt);
              allSections.addAll(convertedDivisions);
            } catch (e) {
              print('Error fetching divisions for course $courseIdInt: $e');
            }
          }
        } catch (e) {
          print('Error fetching courses for divisions: $e');
        }
      }

      _classSections = allSections;
    } on Exception catch (e) {
      setError(e.toString());
    } finally {
      setLoading(value: false);
    }
  }

  /// Convert class divisions to section format for consistent UI display
  Future<List<Map<String, dynamic>>> _convertDivisionsToSections(
    List<dynamic> divisions, 
    int courseId,
  ) async {
    final List<Map<String, dynamic>> convertedSections = [];
    
    try {
      // Get course details for proper display
      final courses = await _coursesService.getAllCourses();
      final course = courses.firstWhere(
        (c) => (c as Map<String, dynamic>)['id'] == courseId,
        orElse: () => null,
      ) as Map<String, dynamic>?;

      for (final division in divisions) {
        final divisionData = division as Map<String, dynamic>;
        
        // Convert division to section format
        final convertedSection = {
          'id': divisionData['id'],
          'sectionName': divisionData['sectionName'],
          'maxCapacity': divisionData['maxCapacity'],
          'room': divisionData['roomNumber'] ?? '',
          'schedule': divisionData['schedule'] ?? '',
          'status': divisionData['status'] ?? 'ACTIVE',
          'teacher': divisionData['teacher'] != null 
            ? {
                'id': divisionData['teacher']['id'],
                'user': {
                  'name': divisionData['teacher']['name'],  // Fixed: direct access to name
                }
              }
            : null,
          // Create a pseudo-subject structure for consistent display
          'subject': {
            'id': courseId,
            'subjectName': course?['name'] ?? 'Unknown Course',
            'subjectCode': course?['code'] ?? '',
            'course': course,
          },
          'semester': null, // Simple divisions don't have semesters
          '_isSimpleDivision': true, // Flag to identify source
        };
        
        convertedSections.add(convertedSection);
      }
    } catch (e) {
      print('Error converting divisions to sections: $e');
    }
    
    return convertedSections;
  }

  /// Create a new class section (uses smart API selection)
  Future<bool> createClassSection(Map<String, dynamic> sectionData) async {
    try {
      _isCreating = true;
      setError(null);
      notifyListeners();

      // Use smart API selection from courses service
      await _coursesService.createCourseSection(sectionData);

      // Refresh the class sections list with stored parameters
      await fetchClassSections(
        institutionId: _lastInstitutionId,
        courseId: _lastCourseId,
        semesterId: _lastSemesterId,
        teacherId: _lastTeacherId,
      );
      return true;
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  /// Update an existing class section (handles both simple divisions and complex sections)
  Future<bool> updateClassSection(int sectionId, Map<String, dynamic> sectionData) async {
    try {
      _isUpdating = true;
      setError(null);
      notifyListeners();

      // Find the section to determine if it's a simple division or complex section
      final section = getClassSectionById(sectionId);
      final isSimpleDivision = section?['_isSimpleDivision'] == true;

      if (isSimpleDivision) {
        // Update using class divisions API
        await _coursesService.updateClassDivision(sectionId, sectionData);
      } else {
        // Update using complex class sections API
        await _classSectionService.updateClassSection(sectionId, sectionData);
      }

      // Refresh the class sections list with stored parameters
      await fetchClassSections(
        institutionId: _lastInstitutionId,
        courseId: _lastCourseId,
        semesterId: _lastSemesterId,
        teacherId: _lastTeacherId,
      );
      return true;
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// Delete a class section (handles both simple divisions and complex sections)
  Future<bool> deleteClassSection(int sectionId) async {
    try {
      _isDeleting = true;
      setError(null);
      notifyListeners();

      // Find the section to determine if it's a simple division or complex section
      final section = getClassSectionById(sectionId);
      final isSimpleDivision = section?['_isSimpleDivision'] == true;

      if (isSimpleDivision) {
        // Delete using class divisions API
        await _coursesService.deleteClassDivision(sectionId);
      } else {
        // Delete using complex class sections API
        final response = await _classSectionService.deleteClassSection(sectionId);
        if (response['success'] != true) {
          setError(response['message'] as String? ?? 'Failed to delete class section');
          return false;
        }
      }

      // Refresh the class sections list with stored parameters
      await fetchClassSections(
        institutionId: _lastInstitutionId,
        courseId: _lastCourseId,
        semesterId: _lastSemesterId,
        teacherId: _lastTeacherId,
      );
      return true;
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  /// Get class section by ID
  Map<String, dynamic>? getClassSectionById(int sectionId) {
    try {
      return _classSections.firstWhere(
        (section) => section['id'] == sectionId,
        orElse: () => null,
      ) as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }
}