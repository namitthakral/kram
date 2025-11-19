import 'package:dio/dio.dart';

import 'api_service.dart';

/// Service class for handling subject/course-related API calls
///
/// Available endpoints (based on backend structure):
/// - GET /subjects - Get all subjects with filters
/// - GET /subjects/:id - Get subject by ID
/// - GET /subjects/course/:courseId - Get subjects for a specific course
/// - POST /subjects - Create new subject (admin only)
/// - PATCH /subjects/:id - Update subject (admin only)
/// - DELETE /subjects/:id - Delete subject (admin only)
/// - GET /subjects/stats/overview - Get subjects statistics (admin only)
class SubjectService {
  factory SubjectService() => _instance;
  SubjectService._internal();
  static final SubjectService _instance = SubjectService._internal();

  final ApiService _apiService = ApiService();

  /// Get all subjects
  ///
  /// Endpoint: GET /subjects
  ///
  /// [courseId] - Optional filter by course ID
  /// [academicYearId] - Optional filter by academic year
  /// [page] - Page number for pagination
  /// [limit] - Items per page
  Future<Map<String, dynamic>> getAllSubjects({
    int? courseId,
    int? academicYearId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (courseId != null) {
        queryParams['courseId'] = courseId.toString();
      }
      if (academicYearId != null) {
        queryParams['academicYearId'] = academicYearId.toString();
      }

      final response = await _apiService.dio.get(
        '/subjects',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get subjects',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to get subjects: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get subject by ID
  ///
  /// Endpoint: GET /subjects/:id
  ///
  /// [id] - Subject ID
  Future<Map<String, dynamic>> getSubjectById(int id) async {
    try {
      final response = await _apiService.dio.get('/subjects/$id');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get subject',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Subject not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to get subject: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get subjects for a specific course
  ///
  /// Endpoint: GET /subjects/course/:courseId
  ///
  /// [courseId] - Course ID
  Future<List<dynamic>> getSubjectsByCourse(int courseId) async {
    try {
      final response = await _apiService.dio.get(
        '/subjects/course/$courseId',
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
          error: 'Failed to get subjects for course',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Course not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to get subjects for course: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Create new subject (admin only)
  ///
  /// Endpoint: POST /subjects
  ///
  /// [data] - Subject data
  Future<Map<String, dynamic>> createSubject(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.dio.post('/subjects', data: data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to create subject',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Subject already exists');
      } else if (e.response?.statusCode == 400) {
        final errorMessage =
            e.response?.data['message'] ?? 'Invalid data provided';
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 403) {
        throw Exception('Forbidden - Admin access required');
      } else {
        throw Exception('Failed to create subject: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Update subject (admin only)
  ///
  /// Endpoint: PATCH /subjects/:id
  ///
  /// [id] - Subject ID
  /// [data] - Updated subject data
  Future<Map<String, dynamic>> updateSubject(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.dio.patch(
        '/subjects/$id',
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to update subject',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Subject not found');
      } else if (e.response?.statusCode == 400) {
        final errorMessage =
            e.response?.data['message'] ?? 'Invalid data provided';
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 403) {
        throw Exception('Forbidden - Admin access required');
      } else {
        throw Exception('Failed to update subject: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Delete subject (admin only)
  ///
  /// Endpoint: DELETE /subjects/:id
  ///
  /// [id] - Subject ID
  Future<void> deleteSubject(int id) async {
    try {
      final response = await _apiService.dio.delete('/subjects/$id');

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to delete subject',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Subject not found');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Forbidden - Admin access required');
      } else if (e.response?.statusCode == 409) {
        throw Exception(
          'Cannot delete subject - it is being used by other records',
        );
      } else {
        throw Exception('Failed to delete subject: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get subjects statistics (admin only)
  ///
  /// Endpoint: GET /subjects/stats/overview
  Future<Map<String, dynamic>> getSubjectsStats() async {
    try {
      final response = await _apiService.dio.get('/subjects/stats/overview');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get subjects statistics',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Forbidden - Admin access required');
      } else {
        throw Exception('Failed to get subjects statistics: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
