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
  String? _lastInstitutionType;

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

  /// Fetch class sections using smart API selection based on institution type
  Future<void> fetchClassSections({
    int? institutionId,
    int? courseId,
    int? semesterId,
    int? teacherId,
    String? institutionType,
  }) async {
    try {
      setLoading(value: true);
      setError(null);

      // Store parameters for future refreshes
      _lastInstitutionId = institutionId;
      _lastCourseId = courseId;
      _lastSemesterId = semesterId;
      _lastTeacherId = teacherId;
      _lastInstitutionType = institutionType;

      // Smart API selection based on institution type
      final isSchool = institutionType == 'SCHOOL';
      
      if (isSchool) {
        // Schools: Fetch class divisions only (simple class organization)
        await _fetchClassDivisions(courseId);
      } else {
        // Colleges/Universities: Fetch class sections only (subject-specific)
        await _fetchClassSections(
          institutionId: institutionId,
          courseId: courseId,
          semesterId: semesterId,
          teacherId: teacherId,
        );
      }
    } on Exception catch (e) {
      setError(e.toString());
    } finally {
      setLoading(value: false);
    }
  }

  /// Fetch class divisions for schools using optimized single API call
  Future<void> _fetchClassDivisions(int? courseId) async {
    if (courseId != null) {
      // Fetch divisions for specific course
      final divisions = await _coursesService.getClassDivisions(courseId);
      final convertedDivisions = await _convertDivisionsToSections(
        divisions,
        courseId,
      );
      _classSections = convertedDivisions;
    } else {
      // Fetch ALL divisions for institution in single optimized call
      final allDivisions = await _coursesService.getAllClassDivisions();
      
      // Convert to consistent format (divisions already have course info)
      _classSections = allDivisions.map((division) {
        final divisionData = division as Map<String, dynamic>;
        final course = divisionData['course'] as Map<String, dynamic>?;
        
        
        return {
          'id': divisionData['id'],
          'sectionName': divisionData['sectionName'],
          'maxCapacity': divisionData['maxCapacity'],
          'currentEnrollment': divisionData['currentEnrollment'] ?? 0,
          'room': divisionData['roomNumber'] ?? '',
          'schedule': divisionData['schedule'] ?? '',
          'status': divisionData['status'] ?? 'ACTIVE',
          'teacher': divisionData['teacher'],
          // Create a pseudo-subject structure for consistent display
          'subject': {
            'id': course?['id'],
            'subjectName': course?['name'] ?? 'Unknown Course',
            'subjectCode': course?['code'] ?? '',
            'course': course,
          },
          'course': course,
          'semester': null, // Simple divisions don't have semesters
          '_isSimpleDivision': true, // Flag to identify source
        };
      }).toList();
    }
  }

  /// Fetch class sections for colleges/universities
  Future<void> _fetchClassSections({
    int? institutionId,
    int? courseId,
    int? semesterId,
    int? teacherId,
  }) async {
    // Use the optimized API endpoint for better performance
    final response = await _classSectionService.getClassSectionsOptimized(
      institutionId: institutionId,
      courseId: courseId,
      semesterId: semesterId,
      teacherId: teacherId,
      status: 'ACTIVE',
    );

    // Extract data from optimized response
    _classSections = response['data'] as List<dynamic>? ?? [];
    
    // Log performance metrics
    final executionTime = response['executionTime'] ?? 0;
    print('Class sections loaded in ${executionTime}ms (optimized)');
  }

  /// Convert class divisions to section format for consistent UI display
  Future<List<Map<String, dynamic>>> _convertDivisionsToSections(
    List<dynamic> divisions,
    int courseId,
  ) async {
    final convertedSections = <Map<String, dynamic>>[];

    try {
      // Get course details for proper display
      final courses = await _coursesService.getAllCourses();
      final course =
          courses.firstWhere(
                (c) => (c as Map<String, dynamic>)['id'] == courseId,
                orElse: () => null,
              )
              as Map<String, dynamic>?;

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
          'teacher':
              divisionData['teacher'] != null
                  ? {
                    'id': divisionData['teacher']['id'],
                    'user': {
                      'name':
                          divisionData['teacher']['name'], // Fixed: direct access to name
                    },
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
    } on Exception catch (e) {
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
        institutionType: _lastInstitutionType,
      );
      return true;
    } on Exception catch (e) {
      setError(_formatErrorMessage(e.toString()));
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  /// Update an existing class section (handles both simple divisions and complex sections)
  Future<bool> updateClassSection(
    int sectionId,
    Map<String, dynamic> sectionData,
  ) async {
    try {
      _isUpdating = true;
      setError(null);
      notifyListeners();

      // Find the section to determine if it's a simple division or complex section
      final section = getClassSectionById(sectionId);
      if (section == null) {
        throw Exception('Class section with ID $sectionId not found');
      }
      final isSimpleDivision = section['_isSimpleDivision'] == true;
      print('Updating section $sectionId: isSimpleDivision=$isSimpleDivision');

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
        institutionType: _lastInstitutionType,
      );
      return true;
    } on Exception catch (e) {
      // Format error message for better user experience
      String errorMessage = e.toString();
      
      // Clean up common error prefixes
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      if (errorMessage.startsWith('DioException: ')) {
        errorMessage = errorMessage.substring(14);
      }
      
      setError(_formatErrorMessage(errorMessage));
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
      if (section == null) {
        throw Exception('Class section with ID $sectionId not found');
      }
      final isSimpleDivision = section['_isSimpleDivision'] == true;

      if (isSimpleDivision) {
        // Delete using class divisions API
        await _coursesService.deleteClassDivision(sectionId);
      } else {
        // Delete using complex class sections API
        final response = await _classSectionService.deleteClassSection(
          sectionId,
        );
        if (response['success'] != true) {
          setError(
            response['message'] as String? ?? 'Failed to delete class section',
          );
          return false;
        }
      }

      // Refresh the class sections list with stored parameters
      await fetchClassSections(
        institutionId: _lastInstitutionId,
        courseId: _lastCourseId,
        semesterId: _lastSemesterId,
        teacherId: _lastTeacherId,
        institutionType: _lastInstitutionType,
      );
      return true;
    } on Exception catch (e) {
      setError(_formatErrorMessage(e.toString()));
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  /// Get class section by ID
  Map<String, dynamic>? getClassSectionById(int sectionId) {
    try {
      for (final section in _classSections) {
        final sectionMap = section as Map<String, dynamic>;
        if (sectionMap['id'] == sectionId) {
          return sectionMap;
        }
      }
      return null;
    } on Exception {
      return null;
    }
  }

  /// Format error messages for better user experience
  String _formatErrorMessage(String errorMessage) {
    // Clean up common error prefixes
    if (errorMessage.startsWith('Exception: ')) {
      errorMessage = errorMessage.substring(11);
    }
    if (errorMessage.startsWith('DioException: ')) {
      errorMessage = errorMessage.substring(14);
    }
    
    // Handle specific error cases with user-friendly messages
    if (errorMessage.contains('No active academic year found')) {
      return 'Cannot assign teacher: No active academic year found. Please contact your administrator to set up the current academic year.';
    }
    
    if (errorMessage.contains('Teacher with ID') && errorMessage.contains('not found')) {
      return 'Selected teacher not found. Please try selecting a different teacher.';
    }
    
    if (errorMessage.contains('already exists')) {
      return 'A class section with this name already exists. Please choose a different name.';
    }
    
    if (errorMessage.contains('institution')) {
      return 'You can only manage class sections within your own institution.';
    }
    
    // Return cleaned error message if no specific case matches
    return errorMessage;
  }
}
