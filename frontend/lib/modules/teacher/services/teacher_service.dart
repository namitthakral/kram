import 'package:dio/dio.dart';

import '../../../core/services/api_service.dart';
import '../models/dashboard_stats.dart';

/// Service class for handling teacher-related API calls
///
/// Available endpoints (based on backend/src/teachers/teachers.controller.ts):
/// - GET /teachers - Get all teachers (admin only)
/// - GET /teachers/stats - Get overall teacher statistics
/// - GET /teachers/:user_uuid - Get teacher by UUID
/// - GET /teachers/:user_uuid/subjects - Get teacher's subjects
/// - GET /teachers/:user_uuid/classes - Get teacher's classes
/// - GET /teachers/:user_uuid/stats - Get teacher statistics
/// - GET /teachers/:user_uuid/dashboard-stats - Get enhanced dashboard stats
/// - GET /teachers/:user_uuid/attendance-trends - Get attendance trends
/// - GET /teachers/:user_uuid/subject-performance - Get subject performance
/// - GET /teachers/:user_uuid/grade-distribution - Get grade distribution
/// - GET /teachers/:user_uuid/recent-activity - Get recent student activity
/// - GET /teachers/:user_uuid/attendance-summary - Get attendance summary
/// - POST /teachers - Create new teacher (admin only)
/// - POST /teachers/:user_uuid/assign-subjects - Assign subjects to teacher
/// - PATCH /teachers/:user_uuid - Update teacher
/// - DELETE /teachers/:user_uuid - Delete teacher
class TeacherService {
  factory TeacherService() => _instance;
  TeacherService._internal();
  static final TeacherService _instance = TeacherService._internal();

  final ApiService _apiService = ApiService();

  Future<DashboardStats> getDashboardStats(String userUuid) async {
    try {
      final response = await _apiService.dio.get(
        '/teachers/$userUuid/dashboard-stats',
      );

      if (response.statusCode == 200) {
        return DashboardStats.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load dashboard stats',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Teacher not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to load dashboard stats: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<StudentActivity>> getRecentActivity(
    String userUuid, {
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/teachers/$userUuid/recent-activity',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => StudentActivity.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load recent activity',
        );
      }
    } catch (e) {
      throw Exception('Failed to load recent activity: $e');
    }
  }

  Future<AttendanceTrendsResponse> getAttendanceTrends(String userUuid) async {
    try {
      final response = await _apiService.dio.get(
        '/teachers/$userUuid/attendance-trends',
      );

      if (response.statusCode == 200) {
        return AttendanceTrendsResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load attendance trends',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Teacher not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to load attendance trends: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<SubjectPerformanceResponse> getSubjectPerformance(
    String userUuid,
  ) async {
    try {
      final response = await _apiService.dio.get(
        '/teachers/$userUuid/subject-performance',
      );

      if (response.statusCode == 200) {
        return SubjectPerformanceResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load subject performance',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Teacher not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to load subject performance: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<GradeDistributionResponse> getGradeDistribution(
    String userUuid,
  ) async {
    try {
      final response = await _apiService.dio.get(
        '/teachers/$userUuid/grade-distribution',
      );

      if (response.statusCode == 200) {
        return GradeDistributionResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load grade distribution',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Teacher not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to load grade distribution: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get attendance summary for a teacher
  ///
  /// Endpoint: GET /teachers/:user_uuid/attendance-summary
  ///
  /// [userUuid] - Teacher's user UUID
  /// [date] - Optional date filter
  /// [period] - Optional period filter (daily, weekly, monthly)
  Future<Map<String, dynamic>> getAttendanceSummary(
    String userUuid, {
    String? date,
    String? period,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null) {
        queryParams['date'] = date;
      }
      if (period != null) {
        queryParams['period'] = period;
      }

      final response = await _apiService.dio.get(
        '/teachers/$userUuid/attendance-summary',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load attendance summary',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Teacher not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to load attendance summary: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get teacher by UUID
  ///
  /// Endpoint: GET /teachers/:user_uuid
  Future<Map<String, dynamic>> getTeacherByUuid(String userUuid) async {
    try {
      final response = await _apiService.dio.get('/teachers/$userUuid');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load teacher data',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Teacher not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to load teacher data: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get teacher's subjects
  ///
  /// Endpoint: GET /teachers/:user_uuid/subjects
  ///
  /// [userUuid] - Teacher's user UUID
  /// [academicYearId] - Optional academic year ID filter
  Future<List<dynamic>> getTeacherSubjects(
    String userUuid, {
    int? academicYearId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (academicYearId != null) {
        queryParams['academicYearId'] = academicYearId.toString();
      }

      final response = await _apiService.dio.get(
        '/teachers/$userUuid/subjects',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load teacher subjects',
        );
      }
    } catch (e) {
      throw Exception('Failed to load teacher subjects: $e');
    }
  }

  /// Get teacher's classes
  ///
  /// Endpoint: GET /teachers/:user_uuid/classes
  ///
  /// [userUuid] - Teacher's user UUID
  /// [semesterId] - Optional semester ID filter
  Future<List<dynamic>> getTeacherClasses(
    String userUuid, {
    int? semesterId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (semesterId != null) {
        queryParams['semesterId'] = semesterId.toString();
      }

      final response = await _apiService.dio.get(
        '/teachers/$userUuid/classes',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load teacher classes',
        );
      }
    } catch (e) {
      throw Exception('Failed to load teacher classes: $e');
    }
  }

  /// Get teacher statistics
  ///
  /// Endpoint: GET /teachers/:user_uuid/stats
  Future<Map<String, dynamic>> getTeacherStats(String userUuid) async {
    try {
      final response = await _apiService.dio.get('/teachers/$userUuid/stats');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load teacher stats',
        );
      }
    } catch (e) {
      throw Exception('Failed to load teacher stats: $e');
    }
  }

  /// Get all teachers (admin only)
  ///
  /// Endpoint: GET /teachers
  ///
  /// [page] - Page number for pagination
  /// [limit] - Items per page
  Future<Map<String, dynamic>> getAllTeachers({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/teachers',
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load teachers',
        );
      }
    } catch (e) {
      throw Exception('Failed to load teachers: $e');
    }
  }
}
