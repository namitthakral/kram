import 'package:dio/dio.dart';

import '../../models/auth_models.dart';
import 'api_service.dart';

/// Service class for handling user-related API calls
///
/// Available endpoints (based on backend structure):
/// - GET /users/profile - Get own profile
/// - GET /users/kramid/:kramid - Get user by Kram ID
/// - GET /users/:uuid - Get user by UUID (admin only)
/// - PATCH /users/:uuid - Update user profile
/// - GET /users - Get all users (admin only)
/// - GET /users/stats - Get user statistics (admin only)
/// - GET /users/role/:roleId - Get users by role (admin only)
/// - DELETE /users/:uuid - Delete user (admin only)
class UserService {
  factory UserService() => _instance;
  UserService._internal();
  static final UserService _instance = UserService._internal();

  final ApiService _apiService = ApiService();

  /// Get current user profile
  ///
  /// Endpoint: GET /users/profile
  Future<User> getProfile() async {
    try {
      final response = await _apiService.dio.get('/users/profile');

      if (response.statusCode == 200) {
        return User.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get profile',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to get profile: ${e.message}');
      }
    } on Exception catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get user by Kram ID
  ///
  /// Endpoint: GET /users/kramid/:kramid
  ///
  /// [kramid] - The Kram ID to search for
  Future<User> getUserByKramid(String kramid) async {
    try {
      final response = await _apiService.dio.get(
        '/users/kramid/$kramid',
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get user',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found with Kram ID: $kramid');
      } else if (e.response?.statusCode == 401) {
        // Use the custom error message from the API service
        final errorMsg = e.error?.toString() ?? 'Unauthorized access';
        throw Exception(errorMsg);
      } else {
        throw Exception('Failed to get user: ${e.message}');
      }
    } on Exception catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get user by UUID
  ///
  /// Endpoint: GET /users/:uuid
  ///
  /// [uuid] - User UUID
  Future<User> getUserByUuid(String uuid) async {
    try {
      final response = await _apiService.dio.get('/users/$uuid');

      if (response.statusCode == 200) {
        return User.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get user',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      } else if (e.response?.statusCode == 401) {
        // Use the custom error message from the API service
        final errorMsg = e.error?.toString() ?? 'Unauthorized access';
        throw Exception(errorMsg);
      } else if (e.response?.statusCode == 403) {
        throw Exception('Forbidden - Admin access required');
      } else {
        throw Exception('Failed to get user: ${e.message}');
      }
    } on Exception catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Update user profile
  ///
  /// Endpoint: PATCH /users/:uuid
  ///
  /// [uuid] - User UUID
  /// [data] - Map of fields to update
  Future<User> updateUser(String uuid, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.patch('/users/$uuid', data: data);

      if (response.statusCode == 200) {
        return User.fromJson(response.data as Map<String, dynamic>);
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
      } else if (e.response?.statusCode == 401) {
        // Use the custom error message from the API service
        final errorMsg = e.error?.toString() ?? 'Unauthorized access';
        throw Exception(errorMsg);
      } else if (e.response?.statusCode == 400) {
        final errorMessage =
            e.response?.data['message'] ?? 'Invalid data provided';
        throw Exception(errorMessage);
      } else {
        throw Exception('Failed to update user: ${e.message}');
      }
    } on Exception catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get all users (admin only)
  ///
  /// Endpoint: GET /users
  ///
  /// [page] - Page number for pagination
  /// [limit] - Items per page
  /// [roleId] - Optional filter by role ID
  /// [search] - Optional search term
  Future<Map<String, dynamic>> getAllUsers({
    int page = 1,
    int limit = 10,
    int? roleId,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (roleId != null) {
        queryParams['roleId'] = roleId.toString();
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiService.dio.get(
        '/users',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get users',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Forbidden - Admin access required');
      } else {
        throw Exception('Failed to get users: ${e.message}');
      }
    } on Exception catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get user statistics (admin only)
  ///
  /// Endpoint: GET /users/stats
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await _apiService.dio.get('/users/stats');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get user stats',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Forbidden - Admin access required');
      } else {
        throw Exception('Failed to get user stats: ${e.message}');
      }
    } on Exception catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get users by role (admin only)
  ///
  /// Endpoint: GET /users/role/:roleId
  ///
  /// [roleId] - Role ID to filter by
  /// [page] - Page number for pagination
  /// [limit] - Items per page
  Future<Map<String, dynamic>> getUsersByRole(
    int roleId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/users/role/$roleId',
        queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get users by role',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Forbidden - Admin access required');
      } else {
        throw Exception('Failed to get users by role: ${e.message}');
      }
    } on Exception catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Delete user (admin only)
  ///
  /// Endpoint: DELETE /users/:uuid
  ///
  /// [uuid] - User UUID to delete
  Future<void> deleteUser(String uuid) async {
    try {
      final response = await _apiService.dio.delete('/users/$uuid');

      if (response.statusCode != 200) {
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
      } else if (e.response?.statusCode == 403) {
        throw Exception('Forbidden - Admin access required');
      } else {
        throw Exception('Failed to delete user: ${e.message}');
      }
    } on Exception catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Create a new user (admin only)
  ///
  /// Endpoint: POST /users
  ///
  /// [data] - User data to create
  Future<User> createUser(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.post('/users', data: data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return User.fromJson(response.data as Map<String, dynamic>);
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
      } else if (e.response?.statusCode == 403) {
        throw Exception('Forbidden - Admin access required');
      } else {
        throw Exception('Failed to create user: ${e.message}');
      }
    } on Exception catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
