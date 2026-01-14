import 'package:dio/dio.dart';

import '../utils/api_error_handler.dart';
import 'api_service.dart';

/// Service class for handling class section API calls
///
/// Available endpoints (based on backend/src/courses/class-sections.controller.ts):
/// - GET /class-sections - Get all class sections with optional filters
class ClassSectionService {
  factory ClassSectionService() => _instance;
  ClassSectionService._internal();
  static final ClassSectionService _instance = ClassSectionService._internal();

  final ApiService _apiService = ApiService();

  /// Get all class sections with optional filters
  ///
  /// Endpoint: GET /class-sections
  ///
  /// [institutionId] - Optional institution ID filter
  /// [semesterId] - Optional semester ID filter
  /// [courseId] - Optional course ID filter
  /// [teacherId] - Optional teacher ID filter
  /// [status] - Optional status filter (ACTIVE, INACTIVE)
  Future<List<dynamic>> getClassSections({
    int? institutionId,
    int? semesterId,
    int? courseId,
    int? teacherId,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (institutionId != null) {
        queryParams['institutionId'] = institutionId.toString();
      }
      if (semesterId != null) {
        queryParams['semesterId'] = semesterId.toString();
      }
      if (courseId != null) {
        queryParams['courseId'] = courseId.toString();
      }
      if (teacherId != null) {
        queryParams['teacherId'] = teacherId.toString();
      }
      if (status != null) {
        queryParams['status'] = status;
      }

      print('Fetching class sections with params: $queryParams');

      final response = await _apiService.dio.get(
        '/class-sections',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>? ?? [];
        return data;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load class sections',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to load class sections',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to load class sections',
      );
    }
  }

  /// Get students enrolled in a specific class section
  ///
  /// Endpoint: GET /class-sections/:sectionId/students
  ///
  /// [sectionId] - The ClassSection ID
  ///
  /// Returns only students who are enrolled in the subject taught by this section.
  /// This is useful for marking attendance, as only enrolled students can be marked.
  Future<Map<String, dynamic>> getEnrolledStudents({
    required int sectionId,
  }) async {
    try {
      print('Fetching enrolled students for sectionId: $sectionId');

      final response = await _apiService.dio.get(
        '/class-sections/$sectionId/students',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load enrolled students',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to load enrolled students',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to load enrolled students',
      );
    }
  }
}
