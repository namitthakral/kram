import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../models/auth_models.dart';
import '../constants/app_constants.dart';
import '../utils/secure_storage.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  factory AuthService() => _instance;
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();

  final ApiService _apiService = ApiService();
  final SecureStorageService _storage = SecureStorageService();

  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  /// Initialize auth service and API service
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Initialize API service first
      _apiService.init();
      
      // Load stored user data
      final userJson = await _storage.read(AppConstants.userKey);
      if (userJson != null && userJson.isNotEmpty) {
        final userData = jsonDecode(userJson);
        _currentUser = User.fromJson(userData);
      }
      
      log('✅ AuthService: Initialized - User: ${_currentUser?.email ?? 'None'}');
    } catch (e) {
      log('❌ AuthService: Error initializing: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Login user with email and password
  Future<LoginResponse> login(LoginRequest request) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.dio.post(
        '/auth/login',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final loginResponse = LoginResponse.fromJson(response.data);
        
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
          log('⚠️ AuthService: No refresh token received from backend');
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
        
        // Update current user
        _currentUser = loginResponse.user;
        
        // Reset logout state for API service
        _apiService.resetLogoutState();
        
        log('✅ AuthService: Login successful for user: ${loginResponse.user.email}');
        
        _isLoading = false;
        notifyListeners();
        
        return loginResponse;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Login failed',
        );
      }
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      
      if (e.response?.statusCode == 401) {
        final errorMessage = e.response?.data['message'] ?? 'Invalid credentials';
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 403) {
        throw Exception('Account is not active');
      } else {
        throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Login failed: $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      log('🚪 AuthService: Logging out user...');
      
      // Clear stored data
      await _storage.delete(AppConstants.accessTokenKey);
      await _storage.delete(AppConstants.refreshTokenKey);
      await _storage.delete(AppConstants.tokenExpiryKey);
      await _storage.delete(AppConstants.userKey);
      
      // Clear current user
      _currentUser = null;
      
      log('✅ AuthService: Logout complete, data cleared');
      notifyListeners();
    } catch (e) {
      log('⚠️ AuthService: Error during logout: $e');
      // Continue with logout even if clearing fails
      _currentUser = null;
      notifyListeners();
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

      // Consider token expired if it will expire in next 5 minutes
      const bufferTime = Duration(minutes: 5);
      return now.isAfter(expiryTime.subtract(bufferTime));
    } catch (e) {
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
      log('🔄 AuthService: Attempting to retrieve refresh token from storage...');
      final refreshToken = await _storage.read(AppConstants.refreshTokenKey);

      if (refreshToken == null || refreshToken.isEmpty) {
        log('❌ AuthService: No refresh token available in storage');
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
        final tokensData = response.data['tokens'] ?? response.data;
        final tokens = AuthTokens.fromJson(tokensData);

        // Store new access token
        await _storage.write(AppConstants.accessTokenKey, tokens.accessToken);
        log('💾 AuthService: Stored new access token');

        // Update refresh token if provided
        if (tokens.refreshToken != null && tokens.refreshToken!.isNotEmpty) {
          await _storage.write(
            AppConstants.refreshTokenKey,
            tokens.refreshToken!,
          );
          log('💾 AuthService: Stored new refresh token');
        } else {
          log('ℹ️ AuthService: Backend did not rotate refresh token');
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
        log('❌ AuthService: Token refresh failed with status: ${response.statusCode}');
        throw Exception('Token refresh failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ AuthService: Token refresh DioError: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Refresh token is invalid or expired');
      } else {
        throw Exception('Token refresh failed: ${e.message}');
      }
    } catch (e) {
      log('❌ AuthService: Token refresh error: $e');
      throw Exception('Token refresh failed: $e');
    }
  }

  /// Check if user has specific role
  bool hasRole(String roleName) {
    return _currentUser?.role?.roleName == roleName;
  }

  /// Login with email and password (convenience method matching existing pattern)
  Future<LoginResponse> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final request = LoginRequest(
      email: email,
      password: password,
    );
    return await login(request);
  }

  /// Login with phone and password (convenience method matching existing pattern) 
  Future<LoginResponse> loginWithPhone({
    required String phone,
    required String password,
  }) async {
    final request = LoginRequest(
      phone: phone,
      password: password,
    );
    return await login(request);
  }

  /// Login with KramID and password (convenience method matching existing pattern)
  Future<LoginResponse> loginWithKramId({
    required String kramId,
    required String password,
  }) async {
    final request = LoginRequest(
      kramid: kramId,
      password: password,
    );
    return await login(request);
  }
}