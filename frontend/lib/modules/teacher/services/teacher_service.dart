import 'package:dio/dio.dart';

import '../../../core/services/api_service.dart';
import '../models/dashboard_stats.dart';

/// Service for teacher-related API calls
class TeacherService {
  factory TeacherService() => _instance;
  TeacherService._internal();
  static final TeacherService _instance = TeacherService._internal();

  final ApiService _apiService = ApiService();

  /// Get teacher dashboard statistics
  ///
  /// Fetches comprehensive dashboard stats including:
  /// - Total students
  /// - Present/absent counts for today
  /// - Late arrivals
  /// - Today's attendance percentage
  /// - Monthly average attendance
  Future<DashboardStats> getDashboardStats(String teacherId) async {
    try {
      final response = await _apiService.dio.get(
        '/teachers/$teacherId/dashboard-stats',
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

  /// Get recent student activity
  /// Returns list of students with their recent activities
  Future<List<StudentActivity>> getRecentActivity(
    String teacherId, {
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/teachers/$teacherId/recent-activity',
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
}
