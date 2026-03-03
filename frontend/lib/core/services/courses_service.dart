import 'package:dio/dio.dart';

import '../utils/api_error_handler.dart';
import 'api_service.dart';

/// Service class for handling courses/classes-related API calls
///
/// Available endpoints (based on backend structure):
/// - GET /courses - Get all courses/programs
/// - GET /courses/with-sections - Get courses with their sections
/// - GET /courses/:id - Get a single course by ID with its subjects
/// - GET /courses/:id/sections - Get sections for a specific course
/// - GET /class-sections - Get all class sections
class CoursesService {
  factory CoursesService() => _instance;
  CoursesService._internal();
  static final CoursesService _instance = CoursesService._internal();

  final ApiService _apiService = ApiService();

  /// Get all courses/programs
  ///
  /// Endpoint: GET /courses
  ///
  /// [institutionId] - Optional filter by institution
  /// [status] - Optional filter by status
  /// [degreeType] - Optional filter by degree type
  Future<List<dynamic>> getAllCourses({
    int? institutionId,
    String? status,
    String? degreeType,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (institutionId != null) {
        queryParams['institutionId'] = institutionId.toString();
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (degreeType != null && degreeType.isNotEmpty) {
        queryParams['degreeType'] = degreeType;
      }

      final response = await _apiService.dio.get(
        '/courses',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data;
        } else if (data is Map<String, dynamic>) {
          return data['data'] as List<dynamic>? ?? [];
        }
        return [];
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get courses',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to get courses',
      );
    } on Exception catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to get courses',
      );
    }
  }

  /// Get all courses with their sections
  ///
  /// Endpoint: GET /courses/with-sections
  ///
  /// [institutionId] - Optional filter by institution
  Future<List<dynamic>> getCoursesWithSections({int? institutionId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (institutionId != null) {
        queryParams['institutionId'] = institutionId.toString();
      }

      final response = await _apiService.dio.get(
        '/courses/with-sections',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data;
        } else if (data is Map<String, dynamic>) {
          return data['data'] as List<dynamic>? ?? [];
        }
        return [];
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get courses with sections',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to get courses with sections',
      );
    } on Exception catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to get courses with sections',
      );
    }
  }

  /// Get a single course by ID with its subjects
  ///
  /// Endpoint: GET /courses/:id
  ///
  /// [id] - Course ID
  Future<Map<String, dynamic>> getCourseById(int id) async {
    try {
      final response = await _apiService.dio.get('/courses/$id');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get course',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to get course',
      );
    } on Exception catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to get course',
      );
    }
  }

  /// Get sections for a specific course
  ///
  /// Endpoint: GET /courses/:id/sections
  ///
  /// [id] - Course ID
  Future<List<dynamic>> getCourseSections(int id) async {
    try {
      final response = await _apiService.dio.get('/courses/$id/sections');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data;
        } else if (data is Map<String, dynamic>) {
          final inner = data['data'];
          if (inner is List) return inner;
          if (inner is Map<String, dynamic>) {
            final sections = inner['sections'] as List<dynamic>?;
            return sections ?? [];
          }
          return [];
        }
        return [];
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get course sections',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to get course sections',
      );
    } on Exception catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to get course sections',
      );
    }
  }

  /// Returns section names for a course (e.g. ['A', 'B', 'C']).
  /// DEPRECATED: Use getCourseSectionNames() for smart API selection
  Future<List<String>> getCourseSectionNamesLegacy(int courseId) async {
    final list = await getCourseSections(courseId);
    final names = <String>[];
    for (final e in list) {
      if (e is Map && e['sectionName'] != null) {
        names.add(e['sectionName'] as String);
      } else if (e is String) {
        names.add(e);
      }
    }
    return names;
  }

  /// Get all class sections
  ///
  /// Endpoint: GET /class-sections
  ///
  /// [institutionId] - Optional filter by institution
  /// [semesterId] - Optional filter by semester
  /// [courseId] - Optional filter by course
  /// [teacherId] - Optional filter by teacher
  /// [status] - Optional filter by status
  Future<List<dynamic>> getAllClassSections({
    int? institutionId,
    int? semesterId,
    int? courseId,
    int? teacherId,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (institutionId != null) {
        queryParams['institutionId'] = institutionId.toString();
      }
      if (semesterId != null) {
        queryParams['semesterId'] = semesterId.toString();
      }
      if (courseId != null) {
        queryParams['courseId'] = courseId.toString();
      }
      if (teacherId != null) {
        queryParams['teacherId'] = teacherId.toString();
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _apiService.dio.get(
        '/class-sections',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data;
        } else if (data is Map<String, dynamic>) {
          return data['data'] as List<dynamic>? ?? [];
        }
        return [];
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get class sections',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to get class sections',
      );
    } on Exception catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to get class sections',
      );
    }
  }

  /// Create a new course
  ///
  /// Endpoint: POST /courses
  Future<Map<String, dynamic>> createCourse(Map<String, dynamic> courseData) async {
    try {
      final response = await _apiService.dio.post('/courses', data: courseData);

      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to create course',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to create course',
      );
    } on Exception catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to create course',
      );
    }
  }

  /// Update an existing course
  ///
  /// Endpoint: PUT /courses/:id
  Future<Map<String, dynamic>> updateCourse(int id, Map<String, dynamic> courseData) async {
    try {
      final response = await _apiService.dio.put('/courses/$id', data: courseData);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to update course',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to update course',
      );
    } on Exception catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to update course',
      );
    }
  }

  /// Delete a course
  ///
  /// Endpoint: DELETE /courses/:id
  Future<Map<String, dynamic>> deleteCourse(int id) async {
    try {
      final response = await _apiService.dio.delete('/courses/$id');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to delete course',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to delete course',
      );
    } on Exception catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to delete course',
      );
    }
  }

  // ============================================================================
  // CLASS DIVISIONS (Simple class organization)
  // ============================================================================

  /// Create a new class division (simple class organization)
  Future<Map<String, dynamic>> createClassDivision(
    Map<String, dynamic> classDivisionData,
  ) async {
    try {
      final response = await _apiService.dio.post(
        '/class-divisions',
        data: classDivisionData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to create class division',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to create class division',
      );
    } on Exception catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to create class division',
      );
    }
  }

  /// Smart section loading - automatically chooses between simple divisions and complex sections
  /// Based on course type and available data
  Future<List<String>> getCourseSectionNames(int courseId) async {
    try {
      // First, get course details to determine the appropriate API
      final courseResponse = await _apiService.dio.get('/courses/$courseId');
      final course = courseResponse.data['data'] as Map<String, dynamic>;
      
      // Determine which API to use based on course characteristics
      final shouldUseSimpleAPI = _shouldUseSimpleDivisions(course);
      
      if (shouldUseSimpleAPI) {
        // Use simple class divisions API
        return await _getSimpleClassDivisions(courseId);
      } else {
        // Use complex class sections API (subject-based)
        return await _getComplexClassSections(courseId);
      }
    } catch (e) {
      // Fallback: try simple API first, then complex
      try {
        return await _getSimpleClassDivisions(courseId);
      } catch (_) {
        try {
          return await _getComplexClassSections(courseId);
        } catch (_) {
          return []; // Return empty if both fail
        }
      }
    }
  }

  /// Determine if course should use simple divisions or complex sections
  bool _shouldUseSimpleDivisions(Map<String, dynamic> course) {
    final degreeType = course['degreeType'] as String?;
    final courseName = course['name'] as String? ?? '';
    
    // Use simple divisions for:
    // 1. School-level courses (CERTIFICATE degree type mapped from SCHOOL)
    // 2. Courses with "Class" in the name (e.g., "Class I", "Class X")
    // 3. Basic educational levels
    
    if (degreeType == 'CERTIFICATE') return true;
    if (courseName.toLowerCase().contains('class')) return true;
    if (courseName.toLowerCase().contains('grade')) return true;
    if (RegExp(r'(class|std|standard)\s*[ivx\d]', caseSensitive: false).hasMatch(courseName)) return true;
    
    // Use complex sections for:
    // - BACHELORS, MASTERS, PHD (university level)
    // - Courses with specific subject structure
    return false;
  }

  /// Get simple class divisions (basic school organization)
  Future<List<String>> _getSimpleClassDivisions(int courseId) async {
    final response = await _apiService.dio.get('/class-divisions/course/$courseId');
    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      final divisions = data['data'] as List<dynamic>;
      return divisions.map((division) => division['sectionName'] as String).toList();
    }
    throw Exception('Failed to get class divisions');
  }

  /// Get complex class sections (subject-based, semester-specific)
  Future<List<String>> _getComplexClassSections(int courseId) async {
    final response = await _apiService.dio.get('/courses/$courseId/sections');
    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      final sections = data['data'] as List<dynamic>;
      // Extract unique section names from complex structure
      final sectionNames = <String>{};
      for (final section in sections) {
        if (section['sectionName'] != null) {
          sectionNames.add(section['sectionName'] as String);
        }
      }
      return sectionNames.toList();
    }
    throw Exception('Failed to get class sections');
  }

  /// Get class divisions for a course (direct API call for advanced usage)
  Future<List<dynamic>> getClassDivisions(int courseId) async {
    try {
      final response = await _apiService.dio.get('/class-divisions/course/$courseId');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['data'] as List<dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get class divisions',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to get class divisions',
      );
    } on Exception catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to get class divisions',
      );
    }
  }

  /// Update an existing class division
  Future<Map<String, dynamic>> updateClassDivision(
    int id,
    Map<String, dynamic> classDivisionData,
  ) async {
    try {
      final response = await _apiService.dio.put(
        '/class-divisions/$id',
        data: classDivisionData,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to update class division',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to update class division',
      );
    } on Exception catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to update class division',
      );
    }
  }

  /// Delete a class division
  Future<Map<String, dynamic>> deleteClassDivision(int id) async {
    try {
      final response = await _apiService.dio.delete('/class-divisions/$id');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to delete class division',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to delete class division',
      );
    } on Exception catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to delete class division',
      );
    }
  }

  /// Smart section creation - automatically chooses between simple divisions and complex sections
  Future<Map<String, dynamic>> createCourseSection(
    Map<String, dynamic> sectionData,
  ) async {
    try {
      final courseId = sectionData['courseId'] as int;
      
      // Get course details to determine the appropriate API
      final courseResponse = await _apiService.dio.get('/courses/$courseId');
      final course = courseResponse.data['data'] as Map<String, dynamic>;
      
      // Determine which API to use based on course characteristics
      final shouldUseSimpleAPI = _shouldUseSimpleDivisions(course);
      
      if (shouldUseSimpleAPI) {
        // Use simple class divisions API
        return await createClassDivision(sectionData);
      } else {
        // Use complex class sections API (would need to be implemented)
        throw UnimplementedError('Complex class sections creation not yet implemented. Use simple divisions for now.');
      }
    } catch (e) {
      // Fallback to simple API
      return await createClassDivision(sectionData);
    }
  }
}
