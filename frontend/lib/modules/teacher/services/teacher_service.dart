import 'package:dio/dio.dart';

import '../../../core/services/api_service.dart';
import '../models/dashboard_stats.dart';

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
}
