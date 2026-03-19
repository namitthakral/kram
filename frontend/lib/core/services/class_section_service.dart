import 'package:dio/dio.dart';

import '../utils/api_error_handler.dart';
import 'api_service.dart';

/// Service class for handling class section API calls
///
/// Available endpoints (based on backend/src/courses/class-sections.controller.ts):
/// - GET /class-sections - Get all class sections with optional filters
class ClassSectionService {
  factory ClassSectionService() => _instance;
  ClassSectionService._internal();
  static final ClassSectionService _instance = ClassSectionService._internal();

  final ApiService _apiService = ApiService();

  /// Get all class sections with optional filters - OPTIMIZED VERSION
  ///
  /// Endpoint: GET /class-sections
  ///
  /// This method uses the optimized backend endpoint that returns all
  /// class section data in a single API call, eliminating the need for
  /// multiple separate API calls.
  ///
  /// [institutionId] - Optional institution ID filter
  /// [semesterId] - Optional semester ID filter
  /// [courseId] - Optional course ID filter
  /// [teacherId] - Optional teacher ID filter
  /// [status] - Optional status filter (ACTIVE, INACTIVE)
  ///
  /// Returns comprehensive class section data including:
  /// - Section details (name, capacity, enrollment)
  /// - Subject information (name, code, credits)
  /// - Course/Program details
  /// - Semester and Academic Year info
  /// - Teacher details
  /// - Institution information
  /// - Performance metrics (execution time)
  Future<Map<String, dynamic>> getClassSectionsOptimized({
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
      if (status != null) {
        queryParams['status'] = status;
      }

      print('Fetching class sections with params: $queryParams');

      final response = await _apiService.dio.get(
        '/class-sections',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Log performance metrics
        final executionTime = responseData['executionTime'] ?? 0;
        print('Class sections loaded in ${executionTime}ms');

        return responseData;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load class sections',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to load class sections',
      );
    } on Exception catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to load class sections',
      );
    }
  }

  /// Get all class sections with optional filters
  ///
  /// This method uses the optimized backend endpoint for better performance.
  /// Returns only the data array for backward compatibility.
  ///
  /// [institutionId] - Optional institution ID filter
  /// [semesterId] - Optional semester ID filter
  /// [courseId] - Optional course ID filter
  /// [teacherId] - Optional teacher ID filter
  /// [status] - Optional status filter (ACTIVE, INACTIVE)
  Future<List<dynamic>> getClassSections({
    int? institutionId,
    int? semesterId,
    int? courseId,
    int? teacherId,
    String? status,
  }) async {
    final response = await getClassSectionsOptimized(
      institutionId: institutionId,
      semesterId: semesterId,
      courseId: courseId,
      teacherId: teacherId,
      status: status,
    );
    
    return response['data'] as List<dynamic>? ?? [];
  }

  /// Get all courses with their sections
  ///
  /// Endpoint: GET /courses/with-sections
  ///
  /// [institutionId] - Optional filter by institution (defaults to 1 if not provided in some contexts, but let's allow caller to decide or default here)
  Future<List<dynamic>> getCoursesWithSections({int institutionId = 1}) async {
    try {
      final queryParams = <String, dynamic>{
        'institutionId': institutionId.toString(),
      };

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

  /// Get all courses (simple list)
  ///
  /// Endpoint: GET /courses
  Future<List<dynamic>> getAllCourses({int institutionId = 1}) async {
    try {
      final queryParams = <String, dynamic>{
        'institutionId': institutionId.toString(),
      };

      final response = await _apiService.dio.get(
        '/courses',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data;
        } else if (data is Map<String, dynamic>) {
          // Handle potential 'data' wrapper
          if (data['data'] is List) {
            return data['data'] as List<dynamic>;
          }
          // Handle if it returns a paginated structure directly
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

  /// Get course by ID
  ///
  /// Endpoint: GET /courses/:id
  Future<Map<String, dynamic>> getCourseById(int id) async {
    try {
      final response = await _apiService.dio.get('/courses/$id');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data['data'] is Map<String, dynamic>
              ? data['data'] as Map<String, dynamic>
              : data;
        }
        return {};
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
  /// [courseId] - Course ID
  Future<List<dynamic>> getCourseSections(int courseId) async {
    try {
      final response = await _apiService.dio.get('/courses/$courseId/sections');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data;
        } else if (data is Map<String, dynamic>) {
          if (data['data'] is List) {
            return data['data'] as List<dynamic>;
          } else if (data['data'] is Map<String, dynamic>) {
            final innerData = data['data'] as Map<String, dynamic>;
            if (innerData.containsKey('sections') &&
                innerData['sections'] is List) {
              return innerData['sections'] as List<dynamic>;
            }
          }
          // Fallback if structure doesn't match expected patterns
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

  /// Get subjects for a specific course
  ///
  /// Endpoint: GET /subjects/course/:courseId
  ///
  /// [courseId] - Course ID
  Future<List<dynamic>> getSubjectsForCourse(int courseId) async {
    try {
      final response = await _apiService.dio.get('/subjects/course/$courseId');

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
          error: 'Failed to get subjects for course',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to get subjects for course',
      );
    } on Exception catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to get subjects for course',
      );
    }
  }

  /// Get ALL students in a course (across all sections) - OPTIMIZED
  ///
  /// Endpoint: GET /courses/:courseId/students
  ///
  /// [courseId] - The Course ID
  ///
  /// Returns all students in the course grouped by sections.
  /// This replaces multiple API calls to individual sections.
  Future<Map<String, dynamic>> getAllCourseStudents(int courseId) async {
    try {
      print('Fetching ALL students for courseId: $courseId');

      final response = await _apiService.dio.get('/courses/$courseId/students');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load all course students',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to load all course students',
      );
    } on Exception catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to load all course students',
      );
    }
  }

  /// Get students enrolled in a specific course section
  ///
  /// Endpoint: GET /courses/:courseId/sections/:sectionName/students
  ///
  /// [courseId] - The Course ID
  /// [sectionName] - The section name (e.g., 'A', 'B')
  ///
  /// Returns students enrolled in the specified course section.
  /// This is useful for marking attendance for course-based sections.
  Future<Map<String, dynamic>> getCourseStudents({
    required int courseId,
    required String sectionName,
  }) async {
    try {
      print('Fetching students for courseId: $courseId, section: $sectionName');

      final response = await _apiService.dio.get(
        '/courses/$courseId/sections/$sectionName/students',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load course students',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to load course students',
      );
    } on Exception catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to load course students',
      );
    }
  }

  /// Get class-level attendance for a specific date
  ///
  /// Endpoint: GET /students/attendance/class/date/:date
  ///
  /// [date] - Date in YYYY-MM-DD format
  /// [classLevel] - Class level (optional)
  /// [academicYearId] - Academic year ID (optional)
  /// [sectionId] - Section ID for filtering (optional)
  ///
  /// Returns attendance records for all students in the class/section
  Future<Map<String, dynamic>> getClassAttendance({
    required String date,
    int? classLevel,
    int? academicYearId,
    int? sectionId,
  }) async {
    try {
      print('Fetching class attendance for date: $date, classLevel: $classLevel, sectionId: $sectionId');

      // Build query parameters
      final queryParams = <String, dynamic>{};
      if (classLevel != null) queryParams['classLevel'] = classLevel.toString();
      if (academicYearId != null) queryParams['academicYearId'] = academicYearId.toString();
      if (sectionId != null) queryParams['sectionId'] = sectionId.toString();

      final response = await _apiService.dio.get(
        '/students/attendance/class/date/$date',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load class attendance',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to load class attendance',
      );
    } on Exception catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to load class attendance',
      );
    }
  }

  /// Get students enrolled in a specific class section
  ///
  /// Endpoint: GET /class-sections/:sectionId/students
  ///
  /// [sectionId] - The ClassSection ID
  ///
  /// Returns only students who are enrolled in the subject taught by this section.
  /// This is useful for marking attendance, as only enrolled students can be marked.
  Future<Map<String, dynamic>> getEnrolledStudents({
    required int sectionId,
  }) async {
    try {
      print('Fetching enrolled students for sectionId: $sectionId');

      final response = await _apiService.dio.get(
        '/class-sections/$sectionId/students',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load enrolled students',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to load enrolled students',
      );
    } on Exception catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to load enrolled students',
      );
    }
  }

  /// Create a new class section
  ///
  /// Endpoint: POST /class-sections
  Future<Map<String, dynamic>> createClassSection(
    Map<String, dynamic> sectionData,
  ) async {
    try {
      print('Creating class section with data: $sectionData');

      final response = await _apiService.dio.post(
        '/class-sections',
        data: sectionData,
      );

      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to create class section',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to create class section',
      );
    } on Exception catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to create class section',
      );
    }
  }

  /// Update an existing class section
  ///
  /// Endpoint: PUT /class-sections/:id
  Future<Map<String, dynamic>> updateClassSection(
    int id,
    Map<String, dynamic> sectionData,
  ) async {
    try {
      print('Updating class section $id with data: $sectionData');

      final response = await _apiService.dio.put(
        '/class-sections/$id',
        data: sectionData,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to update class section',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to update class section',
      );
    } on Exception catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to update class section',
      );
    }
  }

  /// Delete a class section
  ///
  /// Endpoint: DELETE /class-sections/:id
  Future<Map<String, dynamic>> deleteClassSection(int id) async {
    try {
      print('Deleting class section: $id');

      final response = await _apiService.dio.delete('/class-sections/$id');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to delete class section',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to delete class section',
      );
    } on Exception catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to delete class section',
      );
    }
  }
}
