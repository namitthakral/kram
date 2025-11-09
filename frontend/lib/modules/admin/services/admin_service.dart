import 'package:dio/dio.dart';

import '../../../core/services/api_service.dart';
import '../models/admin_dashboard_models.dart';

/// Service class for handling admin-related API calls
class AdminService {
  factory AdminService() => _instance;
  AdminService._internal();
  static final AdminService _instance = AdminService._internal();

  final ApiService _apiService = ApiService();

  /// Get admin dashboard statistics
  ///
  /// Endpoint: GET /admin/dashboard-stats
  Future<AdminDashboardResponse> getDashboardStats() async {
    try {
      final response = await _apiService.dio.get(
        '/admin/dashboard-stats',
      );

      if (response.statusCode == 200) {
        return AdminDashboardResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load dashboard stats',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Forbidden - Admin access required');
      } else {
        throw Exception('Failed to load dashboard stats: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get teacher performance data
  ///
  /// Endpoint: GET /admin/teacher-performance
  Future<List<TeacherPerformance>> getTeacherPerformance({
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/admin/teacher-performance',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => TeacherPerformance.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load teacher performance',
        );
      }
    } catch (e) {
      throw Exception('Failed to load teacher performance: $e');
    }
  }

  /// Get attendance trends
  ///
  /// Endpoint: GET /admin/attendance-trends
  Future<List<AttendanceTrend>> getAttendanceTrends({
    String? period,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (period != null) {
        queryParams['period'] = period;
      }

      final response = await _apiService.dio.get(
        '/admin/attendance-trends',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => AttendanceTrend.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load attendance trends',
        );
      }
    } catch (e) {
      throw Exception('Failed to load attendance trends: $e');
    }
  }

  /// Get grade distribution
  ///
  /// Endpoint: GET /admin/grade-distribution
  Future<List<GradeDistribution>> getGradeDistribution() async {
    try {
      final response = await _apiService.dio.get('/admin/grade-distribution');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => GradeDistribution.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load grade distribution',
        );
      }
    } catch (e) {
      throw Exception('Failed to load grade distribution: $e');
    }
  }

  /// Get class performance data
  ///
  /// Endpoint: GET /admin/class-performance
  Future<List<ClassPerformance>> getClassPerformance() async {
    try {
      final response = await _apiService.dio.get('/admin/class-performance');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ClassPerformance.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load class performance',
        );
      }
    } catch (e) {
      throw Exception('Failed to load class performance: $e');
    }
  }

  /// Get financial overview
  ///
  /// Endpoint: GET /admin/financial-overview
  Future<List<FinancialOverview>> getFinancialOverview({
    String? period,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (period != null) {
        queryParams['period'] = period;
      }

      final response = await _apiService.dio.get(
        '/admin/financial-overview',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => FinancialOverview.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load financial overview',
        );
      }
    } catch (e) {
      throw Exception('Failed to load financial overview: $e');
    }
  }

  /// Get system alerts
  ///
  /// Endpoint: GET /admin/system-alerts
  Future<List<SystemAlert>> getSystemAlerts({
    String? severity,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      if (severity != null) {
        queryParams['severity'] = severity;
      }

      final response = await _apiService.dio.get(
        '/admin/system-alerts',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => SystemAlert.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load system alerts',
        );
      }
    } catch (e) {
      throw Exception('Failed to load system alerts: $e');
    }
  }
}
