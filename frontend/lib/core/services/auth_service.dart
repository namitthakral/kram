import 'dart:convert';

import 'package:dio/dio.dart';

import '../../models/auth_models.dart';
import '../../utils/secure_storge.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';
import 'data_source_service.dart';

class AuthService {
  factory AuthService() => _instance;
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();

  final ApiService _apiService = ApiService();
  final SecureStorageService _storage = SecureStorageService();
  final DataSourceService _dataSource = DataSourceService();

  /// Login user with email and password
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/login',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final loginResponse = LoginResponse.fromJson(response.data);

        // Set data source based on user role
        if (loginResponse.user.role != null) {
          _dataSource.setDataSourceByRole(loginResponse.user.role!.id);
        }

        // Store tokens and user data securely
        await _storage.write(
          AppConstants.accessTokenKey,
          loginResponse.accessToken,
        );
        if (loginResponse.refreshToken != null) {
          await _storage.write(
            AppConstants.refreshTokenKey,
            loginResponse.refreshToken!,
          );
        }

        // Calculate and store token expiry time
        final expiryTime = DateTime.now().add(
          Duration(seconds: loginResponse.tokens.expiresIn),
        );
        await _storage.write(
          AppConstants.tokenExpiryKey,
          expiryTime.toIso8601String(),
        );

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
  /// Note: This method only clears user data and tokens.
  /// The caller is responsible for navigation to login screen.
  Future<void> logout() async {
    try {
      // Reset data source to default
      _dataSource.resetToDefault();

      // Clear stored data
      await _storage.delete(AppConstants.accessTokenKey);
      await _storage.delete(AppConstants.refreshTokenKey);
      await _storage.delete(AppConstants.tokenExpiryKey);
      await _storage.delete(AppConstants.userKey);
    } on Exception {
      // Continue with logout even if clearing fails
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(AppConstants.accessTokenKey);
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
    } on Exception {
      return null;
    }
  }

  /// Get auth token
  Future<String?> getAuthToken() async =>
      _storage.read(AppConstants.accessTokenKey);

  /// Check if access token is expired or about to expire
  /// Returns true if token will expire within the next 5 minutes
  Future<bool> isTokenExpired() async {
    try {
      final expiryString = await _storage.read(AppConstants.tokenExpiryKey);
      if (expiryString == null) {
        return true; // No expiry time stored, consider expired
      }

      final expiryTime = DateTime.parse(expiryString);
      final now = DateTime.now();

      // Consider token expired if it will expire in next 5 minutes (300 seconds)
      // This gives us time to refresh before actual expiry
      const bufferTime = Duration(minutes: 5);
      return now.isAfter(expiryTime.subtract(bufferTime));
    } on Exception {
      return true; // If any error, consider expired
    }
  }

  /// Refresh auth token
  Future<String> refreshToken() async {
    try {
      final refreshToken = await _storage.read(AppConstants.refreshTokenKey);
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await _apiService.dio.post(
        '/auth/refresh',
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );

      if (response.statusCode == 200) {
        final tokens = AuthTokens.fromJson(response.data);

        // Store new access token
        await _storage.write(AppConstants.accessTokenKey, tokens.accessToken);

        // Update refresh token if provided
        if (tokens.refreshToken != null && tokens.refreshToken!.isNotEmpty) {
          await _storage.write(
            AppConstants.refreshTokenKey,
            tokens.refreshToken!,
          );
        }

        // Calculate and store new expiry time
        final expiryTime = DateTime.now().add(
          Duration(seconds: tokens.expiresIn),
        );
        await _storage.write(
          AppConstants.tokenExpiryKey,
          expiryTime.toIso8601String(),
        );

        return tokens.accessToken;
      } else {
        throw Exception('Token refresh failed');
      }
    } catch (e) {
      // Don't logout here - let the API interceptor handle it
      // This prevents premature logout during refresh attempts
      throw Exception('Token refresh failed: $e');
    }
  }

  /// Validate and refresh token if needed
  /// Returns true if token is valid or successfully refreshed
  Future<bool> validateAndRefreshToken() async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      final isExpired = await isTokenExpired();
      if (isExpired) {
        // Try to refresh the token
        await refreshToken();
        return true;
      }

      return true;
    } on Exception {
      return false;
    }
  }

  /// Get the current data source being used
  DataSourceService get dataSource => _dataSource;

  /// Check if using local database
  bool get isUsingLocalDatabase => _dataSource.isUsingLocalDatabase;

  /// Check if using API
  bool get isUsingApi => _dataSource.isUsingApi;
}
