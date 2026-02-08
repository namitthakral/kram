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
          return data['data'] as List<dynamic>? ?? [];
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
}
