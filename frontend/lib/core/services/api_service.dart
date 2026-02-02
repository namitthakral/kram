import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../utils/router_service.dart';
import '../../utils/secure_storge.dart';
import '../constants/app_constants.dart';
import 'auth_service.dart';

class ApiService {
  factory ApiService() => _instance;
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();

  late Dio _dio;
  final SecureStorageService _storage = SecureStorageService();
  bool _isRefreshing = false;

  /// List of endpoints that don't require authentication token
  ///
  /// To add a new public endpoint (that doesn't need token), simply add it to this list:
  /// Example: '/auth/forgot-password', '/public/health', etc.
  static const List<String> _publicEndpoints = [
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
    '/auth/activate-account',
    '/institutions/public',
  ];

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: '${AppConstants.baseUrl}${AppConstants.apiVersion}',
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: kDebugMode,
        responseBody: kDebugMode,
        logPrint: (obj) => log(obj.toString()),
      ),
    );

    // Add auth interceptor with automatic token refresh
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Check if this endpoint requires authentication
          final requiresAuth = !_isPublicEndpoint(options.path);

          if (requiresAuth) {
            // Check if token is expired and refresh if needed
            try {
              final authService = AuthService();
              final isExpired = await authService.isTokenExpired();

              if (isExpired && !_isRefreshing) {
                // Token is expired, try to refresh
                log('⏰ Token is expired, attempting proactive refresh...');
                _isRefreshing = true;
                try {
                  await authService.refreshToken();
                  log('✅ Proactive token refresh successful');
                  _isRefreshing = false;
                } on Exception catch (e) {
                  _isRefreshing = false;
                  log('❌ Proactive token refresh failed: $e');
                  // Refresh failed, let the request continue with old token
                  // and let error handler deal with 401
                }
              }

              // Add auth token if available
              final token = await _getAuthToken();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            } on Exception catch (e) {
              log('⚠️ Token check failed: $e');
              // If token check fails, continue without token
            }
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          // Log error for debugging (especially important for web)
          if (kIsWeb) {
            log('API Error on Web: ${error.message}');
            log('Request URL: ${error.requestOptions.uri}');
            if (error.type == DioExceptionType.connectionError) {
              log('Connection error - check CORS and network connectivity');
            }
          }

          // Handle common errors
          if (error.response?.statusCode == 401) {
            final originalRequest = error.requestOptions;
            final path = originalRequest.path;
            log('🔒 Received 401 Unauthorized for: $path');

            // 1. Handle Refresh Token Failure (Fatal)
            if (path.contains('/auth/refresh')) {
              log('❌ Refresh token expired or invalid. Logging out.');
              await _clearAuthToken();
              RouterService().goToLogin();

              final sessionExpiredError = DioException(
                requestOptions: originalRequest,
                response: error.response,
                type: DioExceptionType.badResponse,
                error: 'Session expired. Please login again.',
              );
              return handler.reject(sessionExpiredError);
            }

            // 2. Handle Public Endpoints (Pass through)
            // This catches Login, Register, etc.
            if (_isPublicEndpoint(path)) {
              log('ℹ️ Public endpoint 401 for $path. Passing error to caller.');
              return handler.next(error);
            }

            // 3. Handle Protected Endpoints - Attempt Refresh
            if (!_isRefreshing) {
              // NEW: Check if we even have a refresh token before trying
              // This prevents exception spam and cleaner handling of "logged out" state
              final authService = AuthService();
              final hasRefToken = await authService.hasRefreshToken();

              if (!hasRefToken) {
                log('❌ No refresh token available. Skipping reactive refresh.');
                await _clearAuthToken();
                RouterService().goToLogin();

                final sessionExpiredError = DioException(
                  requestOptions: originalRequest,
                  response: error.response,
                  type: DioExceptionType.badResponse,
                  error:
                      'Session expired (No refresh token). Please login again.',
                );
                return handler.reject(sessionExpiredError);
              }

              _isRefreshing = true;
              log('🔄 Attempting reactive token refresh...');

              try {
                // Try to refresh the token
                final newToken = await authService.refreshToken();
                _isRefreshing = false;
                log('✅ Reactive token refresh successful, retrying request...');

                // Retry the original request with new token
                originalRequest.headers['Authorization'] = 'Bearer $newToken';

                // Create a new Dio instance to retry the request
                final retryDio = Dio(_dio.options);
                final response = await retryDio.fetch(originalRequest);

                log('✅ Retry successful for: $path');
                // Return the successful response
                return handler.resolve(response);
              } on Exception catch (e) {
                _isRefreshing = false;
                log('❌ Reactive token refresh failed: $e');
                log('🚪 Clearing auth tokens and logging out user...');

                // Token refresh failed, clear tokens and let user login again
                await _clearAuthToken();

                // Redirect to login page
                RouterService().goToLogin();

                // Create a more informative error for session expiry
                final sessionExpiredError = DioException(
                  requestOptions: originalRequest,
                  response: error.response,
                  type: DioExceptionType.badResponse,
                  error: 'Session expired. Please login again.',
                );
                return handler.reject(sessionExpiredError);
              }
            } else {
              // Already refreshing
              log(
                '⚠️ Token refresh already in progress. Request for $path failed.',
              );
              // Do NOT logout here, just fail this request
              return handler.next(error);
            }
          } else {
            // Try to extract a more meaningful error message from the backend response
            String? customErrorMessage;
            try {
              if (error.response?.data is Map<String, dynamic>) {
                final data = error.response!.data as Map<String, dynamic>;
                if (data.containsKey('message')) {
                  final message = data['message'];
                  if (message is String) {
                    customErrorMessage = message;
                  } else if (message is List) {
                    customErrorMessage = message.join(', ');
                  }
                } else if (data.containsKey('error') &&
                    data['error'] is String) {
                  customErrorMessage = data['error'];
                }
              }
            } catch (e) {
              log('Error parsing backend error message: $e');
            }

            if (customErrorMessage != null) {
              final newError = DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                type: DioExceptionType.badResponse,
                error: customErrorMessage,
                message: customErrorMessage,
              );
              handler.next(newError);
            } else {
              handler.next(error);
            }
          }
        },
      ),
    );
  }

  /// Check if the endpoint is public (doesn't require authentication)
  bool _isPublicEndpoint(String path) =>
      _publicEndpoints.any((endpoint) => path.contains(endpoint));

  Future<String?> _getAuthToken() async =>
      _storage.read(AppConstants.accessTokenKey);

  Future<void> _clearAuthToken() async {
    await _storage.delete(AppConstants.accessTokenKey);
    await _storage.delete(AppConstants.refreshTokenKey);
    await _storage.delete(AppConstants.tokenExpiryKey);
    await _storage.delete(AppConstants.userKey);
  }

  Dio get dio => _dio;
}
