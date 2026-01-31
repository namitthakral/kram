import 'package:dio/dio.dart';

import '../utils/api_error_handler.dart';
import 'api_service.dart';

/// Service class for handling attendance-related API calls
///
/// Available endpoints (based on backend/src/teachers/teachers.controller.ts):
/// - POST /teachers/:user_uuid/attendance - Mark single attendance
/// - POST /teachers/:user_uuid/attendance/bulk - Mark bulk attendance
/// - PATCH /teachers/:user_uuid/attendance/:attendanceId - Update attendance
/// - DELETE /teachers/:user_uuid/attendance/:attendanceId - Delete attendance
class AttendanceService {
  factory AttendanceService() => _instance;
  AttendanceService._internal();
  static final AttendanceService _instance = AttendanceService._internal();

  final ApiService _apiService = ApiService();

  /// Mark bulk attendance for multiple students
  ///
  /// Endpoint: POST /teachers/:user_uuid/attendance/bulk
  ///
  /// [teacherUuid] - Teacher's user UUID
  /// [sectionId] - ClassSection ID (Note: This is the database ID from class_sections table)
  /// [date] - Date in YYYY-MM-DD format
  /// [attendanceRecords] - List of attendance records with studentId and status
  Future<Map<String, dynamic>> markBulkAttendance({
    required String teacherUuid,
    required int sectionId,
    required String date,
    required List<Map<String, dynamic>> attendanceRecords,
  }) async {
    try {
      final requestData = {
        'sectionId': sectionId,
        'date': date,
        'attendanceRecords': attendanceRecords,
      };

      // Debug logging
      print('Marking attendance with data: $requestData');

      final response = await _apiService.dio.post(
        '/teachers/$teacherUuid/attendance/bulk',
        data: requestData,
      );

      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to mark attendance',
        );
      }
    } on DioException catch (e) {
      // Log the error response
      print('Attendance API error: ${e.response?.data}');
      print('Status code: ${e.response?.statusCode}');

      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to mark attendance',
      );
    } catch (e) {
      print('Unexpected error: $e');
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to mark attendance',
      );
    }
  }

  /// Mark single student attendance
  ///
  /// Endpoint: POST /teachers/:user_uuid/attendance
  ///
  /// [teacherUuid] - Teacher's user UUID
  /// [studentId] - Student ID
  /// [sectionId] - ClassSection ID
  /// [date] - Date in YYYY-MM-DD format
  /// [status] - Attendance status (PRESENT, ABSENT, LATE, EXCUSED)
  /// [remarks] - Optional remarks
  Future<Map<String, dynamic>> markAttendance({
    required String teacherUuid,
    required int studentId,
    required int sectionId,
    required String date,
    required String status,
    String? remarks,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/teachers/$teacherUuid/attendance',
        data: {
          'studentId': studentId,
          'sectionId': sectionId,
          'date': date,
          'status': status,
          if (remarks != null) 'remarks': remarks,
        },
      );

      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to mark attendance',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to mark attendance',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to mark attendance',
      );
    }
  }

  /// Update existing attendance record
  ///
  /// Endpoint: PATCH /teachers/:user_uuid/attendance/:attendanceId
  ///
  /// [teacherUuid] - Teacher's user UUID
  /// [attendanceId] - Attendance record ID
  /// [status] - New attendance status
  /// [remarks] - Optional remarks
  Future<Map<String, dynamic>> updateAttendance({
    required String teacherUuid,
    required int attendanceId,
    String? status,
    String? remarks,
  }) async {
    try {
      final response = await _apiService.dio.patch(
        '/teachers/$teacherUuid/attendance/$attendanceId',
        data: {
          if (status != null) 'status': status,
          if (remarks != null) 'remarks': remarks,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to update attendance',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to update attendance',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to update attendance',
      );
    }
  }

  /// Delete attendance record
  ///
  /// Endpoint: DELETE /teachers/:user_uuid/attendance/:attendanceId
  ///
  /// [teacherUuid] - Teacher's user UUID
  /// [attendanceId] - Attendance record ID
  Future<Map<String, dynamic>> deleteAttendance({
    required String teacherUuid,
    required int attendanceId,
  }) async {
    try {
      final response = await _apiService.dio.delete(
        '/teachers/$teacherUuid/attendance/$attendanceId',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to delete attendance',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to delete attendance',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to delete attendance',
      );
    }
  }

  /// Get filtered attendance records
  ///
  /// Endpoint: GET /teachers/:user_uuid/attendance/records
  Future<Map<String, dynamic>> getAttendanceRecords(
    String teacherUuid, {
    int? sectionId,
    int? studentId,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    int limit = 50,
    int offset = 0,
    String sortBy = 'date',
    String sortOrder = 'desc',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (sectionId != null) {
        queryParams['sectionId'] = sectionId;
      }
      if (studentId != null) {
        queryParams['studentId'] = studentId;
      }
      if (startDate != null) {
        queryParams['startDate'] =
            "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
      }
      if (endDate != null) {
        queryParams['endDate'] =
            "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
      }
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiService.dio.get(
        '/teachers/$teacherUuid/attendance/records',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to fetch attendance records',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to fetch attendance records',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to fetch attendance records',
      );
    }
  }
}
