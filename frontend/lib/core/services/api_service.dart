import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
            log('🔒 Received 401 Unauthorized for: ${originalRequest.path}');

            // Check if this is not a refresh token request to avoid infinite loop
            if (!originalRequest.path.contains('/auth/refresh') &&
                !_isRefreshing) {
              _isRefreshing = true;
              log('🔄 Attempting reactive token refresh...');

              try {
                // Try to refresh the token
                final authService = AuthService();
                final newToken = await authService.refreshToken();
                _isRefreshing = false;
                log('✅ Reactive token refresh successful, retrying request...');

                // Retry the original request with new token
                originalRequest.headers['Authorization'] = 'Bearer $newToken';

                // Create a new Dio instance to retry the request
                final retryDio = Dio(_dio.options);
                final response = await retryDio.fetch(originalRequest);

                log('✅ Retry successful for: ${originalRequest.path}');
                // Return the successful response
                return handler.resolve(response);
              } on Exception catch (e) {
                _isRefreshing = false;
                log('❌ Reactive token refresh failed: $e');
                log('🚪 Clearing auth tokens and logging out user...');
                // Token refresh failed, clear tokens and let user login again
                await _clearAuthToken();

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
              log('⚠️ Cannot refresh token (${originalRequest.path.contains('/auth/refresh') ? "refresh endpoint" : "already refreshing"})');
              log('🚪 Clearing auth tokens and logging out user...');
              // If refresh token request failed or already refreshing, clear tokens
              await _clearAuthToken();

              // Create a more informative error
              final sessionExpiredError = DioException(
                requestOptions: originalRequest,
                response: error.response,
                type: DioExceptionType.badResponse,
                error: 'Session expired. Please login again.',
              );
              return handler.reject(sessionExpiredError);
            }
          } else {
            handler.next(error);
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
