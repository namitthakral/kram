import 'dart:convert';

import 'package:dio/dio.dart';

import '../../models/auth_models.dart';
import '../../utils/secure_storge.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';

class AuthService {
  factory AuthService() => _instance;
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();

  final ApiService _apiService = ApiService();
  final SecureStorageService _storage = SecureStorageService();

  /// Login user with email and password
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/login',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final loginResponse = LoginResponse.fromJson(response.data);

        // Store tokens and user data securely
        await _storage.write(AppConstants.tokenKey, loginResponse.accessToken);
        await _storage.write('refresh_token', loginResponse.refreshToken);
        await _storage.write(
          AppConstants.userKey,
          jsonEncode(loginResponse.user.toJson()),
        );

        return loginResponse;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Login failed',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid credentials');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Account is not active');
      } else {
        throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Register new user
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/register',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final registerResponse = RegisterResponse.fromJson(response.data);
        return registerResponse;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Registration failed',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('User with this email already exists');
      } else if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data['message'] ?? 'Invalid data';
        throw Exception(errorMessage);
      } else {
        throw Exception('Registration failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // Call logout endpoint if needed
      await _apiService.dio.post('/auth/logout');
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      // Clear stored data
      await _storage.delete(AppConstants.tokenKey);
      await _storage.delete('refresh_token');
      await _storage.delete(AppConstants.userKey);
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Get current user data
  Future<User?> getCurrentUser() async {
    try {
      final userJson = await _storage.read(AppConstants.userKey);
      if (userJson != null && userJson.isNotEmpty) {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get auth token
  Future<String?> getAuthToken() async {
    return await _storage.read(AppConstants.tokenKey);
  }

  /// Refresh auth token
  Future<String> refreshToken() async {
    try {
      final refreshToken = await _storage.read('refresh_token');
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await _apiService.dio.post(
        '/auth/refresh',
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );

      if (response.statusCode == 200) {
        final newToken = response.data['accessToken'];
        await _storage.write(AppConstants.tokenKey, newToken);
        return newToken;
      } else {
        throw Exception('Token refresh failed');
      }
    } catch (e) {
      // If refresh fails, logout user
      await logout();
      throw Exception('Token refresh failed: $e');
    }
  }
}
