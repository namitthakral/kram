import 'package:dio/dio.dart';

import '../../../core/services/api_service.dart';

/// Service class for handling student-related API calls
///
/// Available endpoints (based on backend/src/students/students.controller.ts):
/// - GET /students - Get all students (admin/teacher only)
/// - GET /students/:user_uuid - Get student by UUID
/// - POST /students - Create new student (admin only)
/// - PATCH /students/:user_uuid - Update student (admin only)
/// - DELETE /students/:user_uuid - Delete student (admin only)
/// - GET /students/:user_uuid/academic-records - Get academic records
/// - GET /students/:user_uuid/attendance - Get attendance data
/// - GET /students/:user_uuid/dashboard-stats - Get dashboard statistics
/// - GET /students/:user_uuid/assignments - Get assignments
/// - GET /students/:user_uuid/performance-trends - Get performance trends
/// - GET /students/:user_uuid/attendance-history - Get attendance history
/// - GET /students/:user_uuid/subject-performance - Get subject performance
/// - GET /students/:user_uuid/upcoming-events - Get upcoming events
class StudentService {
  factory StudentService() => _instance;
  StudentService._internal();
  static final StudentService _instance = StudentService._internal();

  final ApiService _apiService = ApiService();

  /// Get student dashboard statistics
  ///
  /// Endpoint: GET /students/:user_uuid/dashboard-stats
  Future<Map<String, dynamic>> getDashboardStats(String userUuid) async {
    try {
      final response = await _apiService.dio.get(
        '/students/$userUuid/dashboard-stats',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
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
        throw Exception('Student not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to load dashboard stats: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get student by UUID
  ///
  /// Endpoint: GET /students/:user_uuid
  Future<Map<String, dynamic>> getStudentByUuid(String userUuid) async {
    try {
      final response = await _apiService.dio.get('/students/$userUuid');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load student data',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Student not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to load student data: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get student academic records
  ///
  /// Endpoint: GET /students/:user_uuid/academic-records
  Future<Map<String, dynamic>> getAcademicRecords(String userUuid) async {
    try {
      final response = await _apiService.dio.get(
        '/students/$userUuid/academic-records',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load academic records',
        );
      }
    } catch (e) {
      throw Exception('Failed to load academic records: $e');
    }
  }

  /// Get student attendance data
  ///
  /// Endpoint: GET /students/:user_uuid/attendance
  ///
  /// [userUuid] - Student's user UUID
  /// [startDate] - Optional start date filter
  /// [endDate] - Optional end date filter
  Future<Map<String, dynamic>> getAttendance(
    String userUuid, {
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate;
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate;
      }

      final response = await _apiService.dio.get(
        '/students/$userUuid/attendance',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load attendance data',
        );
      }
    } catch (e) {
      throw Exception('Failed to load attendance data: $e');
    }
  }

  /// Get student assignments
  ///
  /// Endpoint: GET /students/:user_uuid/assignments
  ///
  /// [userUuid] - Student's user UUID
  /// [limit] - Maximum number of assignments to return (default: 10)
  /// [status] - Optional filter by status
  Future<List<dynamic>> getAssignments(
    String userUuid, {
    int limit = 10,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit.toString()};
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiService.dio.get(
        '/students/$userUuid/assignments',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load assignments',
        );
      }
    } catch (e) {
      throw Exception('Failed to load assignments: $e');
    }
  }

  /// Get student performance trends
  ///
  /// Endpoint: GET /students/:user_uuid/performance-trends
  ///
  /// [userUuid] - Student's user UUID
  /// [startMonth] - Optional start month filter
  /// [endMonth] - Optional end month filter
  Future<Map<String, dynamic>> getPerformanceTrends(
    String userUuid, {
    String? startMonth,
    String? endMonth,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startMonth != null) {
        queryParams['startMonth'] = startMonth;
      }
      if (endMonth != null) {
        queryParams['endMonth'] = endMonth;
      }

      final response = await _apiService.dio.get(
        '/students/$userUuid/performance-trends',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load performance trends',
        );
      }
    } catch (e) {
      throw Exception('Failed to load performance trends: $e');
    }
  }

  /// Get student attendance history
  ///
  /// Endpoint: GET /students/:user_uuid/attendance-history
  ///
  /// [userUuid] - Student's user UUID
  /// [semesterId] - Optional semester ID filter
  Future<Map<String, dynamic>> getAttendanceHistory(
    String userUuid, {
    int? semesterId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (semesterId != null) {
        queryParams['semesterId'] = semesterId.toString();
      }

      final response = await _apiService.dio.get(
        '/students/$userUuid/attendance-history',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load attendance history',
        );
      }
    } catch (e) {
      throw Exception('Failed to load attendance history: $e');
    }
  }

  /// Get student subject performance
  ///
  /// Endpoint: GET /students/:user_uuid/subject-performance
  Future<Map<String, dynamic>> getSubjectPerformance(String userUuid) async {
    try {
      final response = await _apiService.dio.get(
        '/students/$userUuid/subject-performance',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load subject performance',
        );
      }
    } catch (e) {
      throw Exception('Failed to load subject performance: $e');
    }
  }

  /// Get student upcoming events
  ///
  /// Endpoint: GET /students/:user_uuid/upcoming-events
  ///
  /// [userUuid] - Student's user UUID
  /// [limit] - Maximum number of events to return (default: 10)
  Future<List<dynamic>> getUpcomingEvents(
    String userUuid, {
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/students/$userUuid/upcoming-events',
        queryParameters: {'limit': limit.toString()},
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load upcoming events',
        );
      }
    } catch (e) {
      throw Exception('Failed to load upcoming events: $e');
    }
  }

  /// Get all students (admin/teacher only)
  ///
  /// Endpoint: GET /students
  ///
  /// [page] - Page number for pagination
  /// [limit] - Items per page
  Future<Map<String, dynamic>> getAllStudents({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/students',
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
          error: 'Failed to load students',
        );
      }
    } catch (e) {
      throw Exception('Failed to load students: $e');
    }
  }
}
