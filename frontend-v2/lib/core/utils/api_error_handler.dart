import 'package:dio/dio.dart';

/// Centralized API error handler utility
///
/// This utility provides consistent error handling across all API services,
/// particularly for authentication errors where the API interceptor
/// enriches the error message.
class ApiErrorHandler {
  /// Handle DioException and convert to appropriate Exception
  ///
  /// Special handling for 401 errors - uses the custom error message
  /// from the API service interceptor which indicates session expiry
  static Exception handleDioException(
    DioException error, {
    String? defaultMessage,
  }) {
    // Check for 401 (Unauthorized) errors
    if (error.response?.statusCode == 401) {
      // Use the custom error message from the API service interceptor
      // This will be "Session expired. Please login again." after token refresh fails
      final errorMsg = error.error?.toString() ?? 'Unauthorized access';
      return Exception(errorMsg);
    }

    // Check for 403 (Forbidden) errors
    if (error.response?.statusCode == 403) {
      final errorMsg = error.response?.data['message'] ?? 'Access forbidden';
      return Exception(errorMsg);
    }

    // Check for 404 (Not Found) errors
    if (error.response?.statusCode == 404) {
      final errorMsg = error.response?.data['message'] ?? 'Resource not found';
      return Exception(errorMsg);
    }

    // Check for 409 (Conflict) errors
    if (error.response?.statusCode == 409) {
      final errorMsg =
          error.response?.data['message'] ?? 'Resource already exists';
      return Exception(errorMsg);
    }

    // Check for 400 (Bad Request) errors
    if (error.response?.statusCode == 400) {
      final errorMsg =
          error.response?.data['message'] ?? 'Invalid data provided';
      return Exception(errorMsg);
    }

    // Check for 500 (Internal Server Error) errors
    if (error.response?.statusCode == 500) {
      return Exception('Internal server error. Please try again later.');
    }

    // Default error message
    final message = defaultMessage ?? 'An error occurred';
    return Exception('$message: ${error.message}');
  }

  /// Handle any exception and convert to appropriate Exception
  static Exception handleException(Object error, {String? defaultMessage}) {
    if (error is DioException) {
      return handleDioException(error, defaultMessage: defaultMessage);
    }

    final message = defaultMessage ?? 'Unexpected error';
    return Exception('$message: $error');
  }
}