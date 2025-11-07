import 'package:dio/dio.dart';

import '../../../core/services/api_service.dart';

/// Service class for handling parent-related API calls
///
/// Available endpoints (based on backend structure):
/// - POST /auth/map-parent-child - Map parent to child
/// - GET /students/:user_uuid/* - Access child's data through student endpoints
///
/// Note: Parents access their children's data through student endpoints.
/// The backend validates parent-child relationships through authentication.
class ParentService {
  factory ParentService() => _instance;
  ParentService._internal();
  static final ParentService _instance = ParentService._internal();

  final ApiService _apiService = ApiService();

  /// Map parent to child using EdVerse ID
  ///
  /// Endpoint: POST /auth/map-parent-child
  ///
  /// [childEdverseId] - The EdVerse ID of the child to map
  Future<Map<String, dynamic>> mapParentToChild(String childEdverseId) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/map-parent-child',
        data: {'childEdverseId': childEdverseId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to map parent to child',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Child not found with the provided EdVerse ID');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid child EdVerse ID or mapping already exists');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to map parent to child: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get child's dashboard statistics
  ///
  /// Uses student endpoint: GET /students/:user_uuid/dashboard-stats
  ///
  /// [childUserUuid] - Child's user UUID
  Future<Map<String, dynamic>> getChildDashboardStats(
    String childUserUuid,
  ) async {
    try {
      final response = await _apiService.dio.get(
        '/students/$childUserUuid/dashboard-stats',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load child dashboard stats',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Not authorized to view this child\'s data');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Child not found');
      } else {
        throw Exception('Failed to load child dashboard stats: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get child's academic records
  ///
  /// Uses student endpoint: GET /students/:user_uuid/academic-records
  Future<Map<String, dynamic>> getChildAcademicRecords(
    String childUserUuid,
  ) async {
    try {
      final response = await _apiService.dio.get(
        '/students/$childUserUuid/academic-records',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load child academic records',
        );
      }
    } catch (e) {
      throw Exception('Failed to load child academic records: $e');
    }
  }

  /// Get child's attendance data
  ///
  /// Uses student endpoint: GET /students/:user_uuid/attendance
  ///
  /// [childUserUuid] - Child's user UUID
  /// [startDate] - Optional start date filter
  /// [endDate] - Optional end date filter
  Future<Map<String, dynamic>> getChildAttendance(
    String childUserUuid, {
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
        '/students/$childUserUuid/attendance',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load child attendance',
        );
      }
    } catch (e) {
      throw Exception('Failed to load child attendance: $e');
    }
  }

  /// Get child's assignments
  ///
  /// Uses student endpoint: GET /students/:user_uuid/assignments
  ///
  /// [childUserUuid] - Child's user UUID
  /// [limit] - Maximum number of assignments to return
  /// [status] - Optional filter by status
  Future<List<dynamic>> getChildAssignments(
    String childUserUuid, {
    int limit = 10,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit.toString()};
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiService.dio.get(
        '/students/$childUserUuid/assignments',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load child assignments',
        );
      }
    } catch (e) {
      throw Exception('Failed to load child assignments: $e');
    }
  }

  /// Get child's performance trends
  ///
  /// Uses student endpoint: GET /students/:user_uuid/performance-trends
  ///
  /// [childUserUuid] - Child's user UUID
  /// [startMonth] - Optional start month filter
  /// [endMonth] - Optional end month filter
  Future<Map<String, dynamic>> getChildPerformanceTrends(
    String childUserUuid, {
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
        '/students/$childUserUuid/performance-trends',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load child performance trends',
        );
      }
    } catch (e) {
      throw Exception('Failed to load child performance trends: $e');
    }
  }

  /// Get child's attendance history
  ///
  /// Uses student endpoint: GET /students/:user_uuid/attendance-history
  ///
  /// [childUserUuid] - Child's user UUID
  /// [semesterId] - Optional semester ID filter
  Future<Map<String, dynamic>> getChildAttendanceHistory(
    String childUserUuid, {
    int? semesterId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (semesterId != null) {
        queryParams['semesterId'] = semesterId.toString();
      }

      final response = await _apiService.dio.get(
        '/students/$childUserUuid/attendance-history',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load child attendance history',
        );
      }
    } catch (e) {
      throw Exception('Failed to load child attendance history: $e');
    }
  }

  /// Get child's subject performance
  ///
  /// Uses student endpoint: GET /students/:user_uuid/subject-performance
  Future<Map<String, dynamic>> getChildSubjectPerformance(
    String childUserUuid,
  ) async {
    try {
      final response = await _apiService.dio.get(
        '/students/$childUserUuid/subject-performance',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load child subject performance',
        );
      }
    } catch (e) {
      throw Exception('Failed to load child subject performance: $e');
    }
  }

  /// Get child's upcoming events
  ///
  /// Uses student endpoint: GET /students/:user_uuid/upcoming-events
  ///
  /// [childUserUuid] - Child's user UUID
  /// [limit] - Maximum number of events to return
  Future<List<dynamic>> getChildUpcomingEvents(
    String childUserUuid, {
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/students/$childUserUuid/upcoming-events',
        queryParameters: {'limit': limit.toString()},
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load child upcoming events',
        );
      }
    } catch (e) {
      throw Exception('Failed to load child upcoming events: $e');
    }
  }

  /// Get child's basic information
  ///
  /// Uses student endpoint: GET /students/:user_uuid
  Future<Map<String, dynamic>> getChildInfo(String childUserUuid) async {
    try {
      final response =
          await _apiService.dio.get('/students/$childUserUuid');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load child information',
        );
      }
    } catch (e) {
      throw Exception('Failed to load child information: $e');
    }
  }
}
