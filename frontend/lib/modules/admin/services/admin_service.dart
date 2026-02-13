import 'package:dio/dio.dart';

import '../../../core/services/api_service.dart';
import '../../../models/grading_config.dart';
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
      final response = await _apiService.dio.get('/admin/dashboard-stats');

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
    } on Exception catch (e) {
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
    } on Exception catch (e) {
      throw Exception('Failed to load teacher performance: $e');
    }
  }

  /// Get attendance trends
  ///
  /// Endpoint: GET /admin/attendance-trends
  Future<List<AttendanceTrend>> getAttendanceTrends({String? period}) async {
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
    } on Exception catch (e) {
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
    } on Exception catch (e) {
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
    } on Exception catch (e) {
      throw Exception('Failed to load class performance: $e');
    }
  }

  /// Get financial overview
  ///
  /// Endpoint: GET /admin/financial-overview
  Future<List<FinancialOverview>> getFinancialOverview({String? period}) async {
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
    } on Exception catch (e) {
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
      final queryParams = <String, dynamic>{'limit': limit};
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
    } on Exception catch (e) {
      throw Exception('Failed to load system alerts: $e');
    }
  }

  /// Get grading configuration for an institution
  ///
  /// Endpoint: GET /admin/institutions/:institutionId/grading-config
  Future<GradingConfig?> getGradingConfig(int institutionId) async {
    try {
      final response = await _apiService.dio.get(
        '/admin/institutions/$institutionId/grading-config',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return GradingConfig.fromJson(data['data']);
        }
        return null;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load grading configuration',
        );
      }
    } on Exception catch (e) {
      throw Exception('Failed to load grading configuration: $e');
    }
  }

  /// Update grading configuration for an institution
  ///
  /// Endpoint: PUT /admin/institutions/:institutionId/grading-config
  Future<bool> updateGradingConfig(
    int institutionId,
    UpdateGradingConfigDto dto,
  ) async {
    try {
      final response = await _apiService.dio.put(
        '/admin/institutions/$institutionId/grading-config',
        data: dto.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] == true;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to update grading configuration',
        );
      }
    } on Exception catch (e) {
      throw Exception('Failed to update grading configuration: $e');
    }
  }

  /// Reset grading configuration to defaults
  ///
  /// Endpoint: POST /admin/institutions/:institutionId/grading-config/reset
  Future<bool> resetGradingConfig(int institutionId) async {
    try {
      final response = await _apiService.dio.post(
        '/admin/institutions/$institutionId/grading-config/reset',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] == true;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to reset grading configuration',
        );
      }
    } on Exception catch (e) {
      throw Exception('Failed to reset grading configuration: $e');
    }
  }

  // ==================== INSTITUTION SETTINGS ====================

  /// Get ID configuration for an institution
  ///
  /// Endpoint: GET /institutions/:institutionId/id-config
  Future<Map<String, dynamic>> getIdConfig(int institutionId) async {
    try {
      final response = await _apiService.dio.get(
        '/institutions/$institutionId/id-config',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load ID configuration',
        );
      }
    } on Exception catch (e) {
      throw Exception('Failed to load ID configuration: $e');
    }
  }

  /// Update ID configuration for an institution
  ///
  /// Endpoint: PATCH /institutions/:institutionId/id-config
  Future<Map<String, dynamic>> updateIdConfig(
    int institutionId,
    Map<String, dynamic> config,
  ) async {
    try {
      final response = await _apiService.dio.patch(
        '/institutions/$institutionId/id-config',
        data: config,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to update ID configuration',
        );
      }
    } on Exception catch (e) {
      throw Exception('Failed to update ID configuration: $e');
    }
  }

  /// Preview ID format
  ///
  /// Endpoint: POST /institutions/:institutionId/id-config/preview
  Future<Map<String, dynamic>> previewIdFormat(
    int institutionId,
    Map<String, dynamic> previewData,
  ) async {
    try {
      final response = await _apiService.dio.post(
        '/institutions/$institutionId/id-config/preview',
        data: previewData,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to preview ID format',
        );
      }
    } on Exception catch (e) {
      throw Exception('Failed to preview ID format: $e');
    }
  }

  // ==================== USER MANAGEMENT ====================

  /// Create institutional user
  ///
  /// Endpoint: POST /admin/users
  Future<Map<String, dynamic>> createInstitutionalUser(
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await _apiService.dio.post(
        '/admin/users',
        data: userData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to create user',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('User already exists');
      } else if (e.response?.statusCode == 400) {
        final errorMessage =
            e.response?.data['message'] ?? 'Invalid data provided';
        throw Exception(errorMessage);
      }
      throw Exception('Failed to create user: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  /// Get all users with filters
  ///
  /// Endpoint: GET /admin/users
  Future<Map<String, dynamic>> getAllUsers({
    int page = 1,
    int limit = 10,
    String? search,
    int? roleId,
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (roleId != null) {
        queryParams['roleId'] = roleId.toString();
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }
      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams['sortOrder'] = sortOrder;
      }

      final response = await _apiService.dio.get(
        '/admin/users',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load users',
        );
      }
    } on Exception catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  /// Get users statistics
  ///
  /// Endpoint: GET /admin/users/stats
  Future<Map<String, dynamic>> getUsersStats() async {
    try {
      final response = await _apiService.dio.get('/admin/users/stats');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load user statistics',
        );
      }
    } on Exception catch (e) {
      throw Exception('Failed to load user statistics: $e');
    }
  }

  /// Get users by role
  ///
  /// Endpoint: GET /admin/users/role/:roleId
  Future<Map<String, dynamic>> getUsersByRole(
    int roleId, {
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _apiService.dio.get(
        '/admin/users/role/$roleId',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load users by role',
        );
      }
    } on Exception catch (e) {
      throw Exception('Failed to load users by role: $e');
    }
  }

  /// Get user by UUID
  ///
  /// Endpoint: GET /admin/users/:user_uuid
  Future<Map<String, dynamic>> getUserByUuid(String userUuid) async {
    try {
      final response = await _apiService.dio.get('/admin/users/$userUuid');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load user',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      }
      throw Exception('Failed to load user: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }

  /// Get user by Kram ID
  ///
  /// Endpoint: GET /admin/users/kramid/:kramid
  Future<Map<String, dynamic>> getUserByKramid(String kramid) async {
    try {
      final response = await _apiService.dio.get(
        '/admin/users/kramid/$kramid',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load user',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found with Kram ID: $kramid');
      }
      throw Exception('Failed to load user: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }

  /// Update user
  ///
  /// Endpoint: PATCH /admin/users/:user_uuid
  Future<Map<String, dynamic>> updateUser(
    String userUuid,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _apiService.dio.patch(
        '/admin/users/$userUuid',
        data: updateData,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to update user',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      } else if (e.response?.statusCode == 409) {
        throw Exception('Email already exists');
      } else if (e.response?.statusCode == 400) {
        final errorMessage =
            e.response?.data['message'] ?? 'Invalid data provided';
        throw Exception(errorMessage);
      }
      throw Exception('Failed to update user: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Delete user (soft delete)
  ///
  /// Endpoint: DELETE /admin/users/:user_uuid
  Future<void> deleteUser(String userUuid) async {
    try {
      final response = await _apiService.dio.delete('/admin/users/$userUuid');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to delete user',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      }
      throw Exception('Failed to delete user: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Hard delete user (permanent deletion)
  ///
  /// Endpoint: DELETE /admin/users/:user_uuid/hard
  Future<void> hardDeleteUser(String userUuid) async {
    try {
      final response = await _apiService.dio.delete(
        '/admin/users/$userUuid/hard',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to permanently delete user',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Forbidden - Super admin access required');
      }
      throw Exception('Failed to permanently delete user: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Failed to permanently delete user: $e');
    }
  }

  /// Bulk import users
  ///
  /// Endpoint: POST /admin/users/bulk-import
  Future<Map<String, dynamic>> bulkImportUsers(
    List<Map<String, dynamic>> users,
  ) async {
    try {
      final response = await _apiService.dio.post(
        '/admin/users/bulk-import',
        data: users,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to bulk import users',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorMessage =
            e.response?.data['message'] ?? 'Invalid data provided';
        throw Exception(errorMessage);
      }
      throw Exception('Failed to bulk import users: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Failed to bulk import users: $e');
    }
  }

  /// Unlock user account
  ///
  /// Endpoint: POST /admin/users/:user_uuid/unlock
  Future<Map<String, dynamic>> unlockUserAccount(String userUuid) async {
    try {
      final response = await _apiService.dio.post(
        '/admin/users/$userUuid/unlock',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to unlock user account',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      }
      throw Exception('Failed to unlock user account: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Failed to unlock user account: $e');
    }
  }
}
