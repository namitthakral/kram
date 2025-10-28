import 'package:dio/dio.dart';

import '../../utils/secure_storge.dart';
import '../constants/app_constants.dart';

class ApiService {
  factory ApiService() => _instance;
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();

  late Dio _dio;
  final SecureStorageService _storage = SecureStorageService();

  /// List of endpoints that don't require authentication token
  ///
  /// To add a new public endpoint (that doesn't need token), simply add it to this list:
  /// Example: '/auth/forgot-password', '/public/health', etc.
  static const List<String> _publicEndpoints = [
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
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
      LogInterceptor(requestBody: true, responseBody: true),
    );

    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Check if this endpoint requires authentication
          final requiresAuth = !_isPublicEndpoint(options.path);

          if (requiresAuth) {
            // Add auth token if available
            final token = await _getAuthToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          handler.next(options);
        },
        onError: (error, handler) {
          // Handle common errors
          if (error.response?.statusCode == 401) {
            // Handle unauthorized access - clear tokens
            _clearAuthToken();
          }
          handler.next(error);
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
    await _storage.delete('refresh_token');
    await _storage.delete(AppConstants.userKey);
  }

  Dio get dio => _dio;
}
