import 'package:dio/dio.dart';

import 'api_service.dart';

/// Service class for handling institution-related API calls
///
/// Available endpoints (based on backend structure):
/// - GET /institutions/public - Get all public institutions (no auth required)
/// - POST /institutions - Create a new institution (super_admin only)
class InstitutionService {
  factory InstitutionService() => _instance;
  InstitutionService._internal();
  static final InstitutionService _instance = InstitutionService._internal();

  final ApiService _apiService = ApiService();

  /// Create a new institution (super_admin only)
  ///
  /// Endpoint: POST /institutions
  Future<Map<String, dynamic>> createInstitution(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.dio.post('/institutions', data: data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = response.data;
        if (body is Map<String, dynamic>) {
          return body;
        }
        return {'success': true, 'data': body};
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to create institution',
        );
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data is Map
              ? (e.response!.data as Map)['message'] ?? e.message
              : e.message;
      throw Exception('Failed to create institution: $msg');
    } on Exception catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get all public institutions
  ///
  /// Endpoint: GET /institutions/public
  ///
  /// This endpoint doesn't require authentication and returns all institutions
  /// that are publicly visible. Useful for registration screens where users
  /// need to select their institution.
  ///
  /// [search] - Optional search term to filter institutions by name
  /// [page] - Page number for pagination
  /// [limit] - Items per page
  Future<List<dynamic>> getPublicInstitutions({
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiService.dio.get(
        '/institutions/public',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data;
        } else if (data is Map<String, dynamic>) {
          return data['data'] as List<dynamic>? ?? [];
        }
        return [];
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get public institutions',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to get public institutions: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get institution by code (for registration)
  ///
  /// This method extracts the institution code from a URL or string
  /// and finds the matching institution from the public list.
  ///
  /// [institutionCode] - The institution code/slug
  Future<Map<String, dynamic>?> getInstitutionByCode(
    String institutionCode,
  ) async {
    try {
      final institutions = await getPublicInstitutions(limit: 100);

      for (final inst in institutions) {
        if (inst is Map<String, dynamic>) {
          final code = inst['code'] as String?;
          final slug = inst['slug'] as String?;
          if (code == institutionCode || slug == institutionCode) {
            return inst;
          }
        }
      }

      return null;
    } on Exception catch (e) {
      throw Exception('Failed to get institution by code: $e');
    }
  }
}
