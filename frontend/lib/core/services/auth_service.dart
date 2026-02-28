import 'dart:convert';
import 'dart:developer';

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
        log('💾 AuthService: Stored access token');

        if (loginResponse.refreshToken != null) {
          await _storage.write(
            AppConstants.refreshTokenKey,
            loginResponse.refreshToken!,
          );
          log('💾 AuthService: Stored refresh token');
        } else {
          log(
            '⚠️ AuthService: No refresh token received from backend in login response',
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
        log('💾 AuthService: Stored token expiry: $expiryTime');

        await _storage.write(
          AppConstants.userKey,
          jsonEncode(loginResponse.user.toJson()),
        );
        log(
          '✅ AuthService: Login successful for user: ${loginResponse.user.email}',
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
        // Extract the actual error message from backend response
        final errorMessage = e.response?.data['message'] ?? 'Invalid credentials';
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 403) {
        throw Exception('Account is not active');
      } else {
        throw Exception('Login failed: ${e.message}');
      }
    } on Exception catch (e) {
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
    } on Exception catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Logout user
  /// Note: This method only clears user data and tokens.
  /// The caller is responsible for navigation to login screen.
  Future<void> logout() async {
    try {
      log('🚪 AuthService: Logging out user...');
      // Reset data source to default
      _dataSource.resetToDefault();

      // Clear stored data
      await _storage.delete(AppConstants.accessTokenKey);
      await _storage.delete(AppConstants.refreshTokenKey);
      await _storage.delete(AppConstants.tokenExpiryKey);
      await _storage.delete(AppConstants.userKey);
      log('✅ AuthService: Logout complete, data cleared');
    } on Exception catch (e) {
      log('⚠️ AuthService: Error during logout clearing: $e');
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

  /// Check if refresh token exists in storage
  Future<bool> hasRefreshToken() async {
    final token = await _storage.read(AppConstants.refreshTokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Refresh auth token
  Future<String> refreshToken() async {
    try {
      log(
        '🔄 AuthService: Attempting to retrieve refresh token from storage...',
      );
      final refreshToken = await _storage.read(AppConstants.refreshTokenKey);

      if (refreshToken == null || refreshToken.isEmpty) {
        log(
          '❌ AuthService: No refresh token available in storage during refresh attempt',
        );
        // Debug: list all keys to see what's actually there
        final allKeys = await _storage.readAll();
        log(
          '🔎 AuthService debugging: Available keys in storage: ${allKeys.keys.join(', ')}',
        );

        throw Exception('No refresh token available');
      }

      log('🔄 AuthService: Calling refresh token API endpoint...');
      final response = await _apiService.dio.post(
        '/auth/refresh',
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );

      if (response.statusCode == 200) {
        log('✅ AuthService: Refresh token API call successful');

        // Backend returns { tokens: { accessToken, refreshToken, expiresIn } }
        // Extract the tokens object from the response
        final tokensData = response.data['tokens'] ?? response.data;
        final tokens = AuthTokens.fromJson(tokensData);

        // Store new access token
        await _storage.write(AppConstants.accessTokenKey, tokens.accessToken);

        // Verify access token write
        final verifyAccess = await _storage.read(AppConstants.accessTokenKey);
        if (verifyAccess != tokens.accessToken) {
          log(
            '❌ AuthService: CRITICAL - Access Token write verification failed!',
          );
        } else {
          log('💾 AuthService: Stored and verified new access token');
        }

        // Update refresh token if provided
        if (tokens.refreshToken != null && tokens.refreshToken!.isNotEmpty) {
          await _storage.write(
            AppConstants.refreshTokenKey,
            tokens.refreshToken!,
          );
          // Verify refresh token write
          final verifyRefresh = await _storage.read(
            AppConstants.refreshTokenKey,
          );
          if (verifyRefresh != tokens.refreshToken) {
            log(
              '❌ AuthService: CRITICAL - Refresh Token write verification failed!',
            );
          } else {
            log('💾 AuthService: Stored and verified new refresh token');
          }
        } else {
          log(
            'ℹ️ AuthService: backend did not rotate refresh token (not returned in response)',
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
        log('💾 AuthService: Stored new token expiry: $expiryTime');

        return tokens.accessToken;
      } else {
        log(
          '❌ AuthService: Token refresh failed with status: ${response.statusCode}',
        );
        log('❌ Response body: ${response.data}');
        throw Exception(
          'Token refresh failed: ${response.statusCode} - ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      log('❌ AuthService: Token refresh DioError: ${e.message}');
      if (e.response != null) {
        log(
          '❌ Response status: ${e.response?.statusCode}, data: ${e.response?.data}',
        );
      }
      throw Exception('Token refresh failed: ${e.message}');
    } on Exception catch (e) {
      log('❌ AuthService: Token refresh error: $e');
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

  /// Change user password
  ///
  /// Endpoint: POST /auth/change-password
  ///
  /// [oldPassword] - Current password
  /// [newPassword] - New password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/change-password',
        data: {'currentPassword': oldPassword, 'newPassword': newPassword},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Password changed successfully
        return;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to change password',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Current password is incorrect');
      } else if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data['message'] ?? 'Invalid password';
        throw Exception(errorMessage);
      } else {
        throw Exception('Failed to change password: ${e.message}');
      }
    } on Exception catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  /// Get current user profile
  ///
  /// Endpoint: GET /auth/profile
  ///
  /// Returns the complete profile of the currently authenticated user
  Future<User> getProfile() async {
    try {
      final response = await _apiService.dio.get('/auth/profile');

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        final userData = (body['data'] ?? body) as Map<String, dynamic>;
        final user = User.fromJson(userData);

        // Update stored user data
        await _storage.write(AppConstants.userKey, jsonEncode(user.toJson()));

        return user;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to get profile',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to get profile: ${e.message}');
      }
    } on Exception catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  /// Activate account with temporary password
  ///
  /// Endpoint: POST /auth/activate-account
  ///
  /// [kramid] - Kram ID of the user
  /// [tempPassword] - Temporary password received
  /// [newPassword] - New password to set
  Future<void> activateAccount({
    required String kramid,
    required String tempPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/activate-account',
        data: {
          'kramid': kramid,
          'tempPassword': tempPassword,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Account activated successfully
        return;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to activate account',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid temporary password');
      } else if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      } else if (e.response?.statusCode == 400) {
        final errorMessage =
            e.response?.data['message'] ?? 'Invalid data provided';
        throw Exception(errorMessage);
      } else {
        throw Exception('Failed to activate account: ${e.message}');
      }
    } on Exception catch (e) {
      throw Exception('Failed to activate account: $e');
    }
  }
}
