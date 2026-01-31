import 'package:dio/dio.dart';

import '../utils/api_error_handler.dart';
import 'api_service.dart';

/// Service class for handling timetable-related API calls
///
/// Available endpoints (based on backend structure):
/// - GET /timetable/time-slots - Get all time slots
/// - GET /timetable/time-slots/:id - Get single time slot
/// - POST /timetable/time-slots - Create time slot
/// - PATCH /timetable/time-slots/:id - Update time slot
/// - DELETE /timetable/time-slots/:id - Delete time slot
/// - GET /timetable/rooms - Get all rooms
/// - GET /timetable/rooms/:id - Get single room
/// - POST /timetable/rooms - Create room
/// - PATCH /timetable/rooms/:id - Update room
/// - DELETE /timetable/rooms/:id - Delete room
/// - GET /timetable/entries - Get all timetable entries
/// - GET /timetable/entries/:id - Get single timetable entry
/// - POST /timetable/entries - Create timetable entry
/// - POST /timetable/entries/bulk - Bulk create timetable entries
/// - PATCH /timetable/entries/:id - Update timetable entry
/// - DELETE /timetable/entries/:id - Delete timetable entry
/// - GET /timetable/class/:courseId/:section - Get timetable by class
/// - GET /timetable/teacher/:teacherId - Get timetable by teacher
/// - GET /timetable/room/:roomId - Get timetable by room
class TimetableService {
  factory TimetableService() => _instance;
  TimetableService._internal();
  static final TimetableService _instance = TimetableService._internal();

  final ApiService _apiService = ApiService();

  // ============ Time Slot Methods ============

  /// Get all time slots
  ///
  /// Endpoint: GET /timetable/time-slots
  ///
  /// [institutionId] - Optional filter by institution
  /// [slotType] - Optional filter by slot type
  /// [isActive] - Optional filter by active status
  Future<List<dynamic>> getAllTimeSlots({
    int? institutionId,
    String? slotType,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (institutionId != null) {
        queryParams['institutionId'] = institutionId.toString();
      }
      if (slotType != null && slotType.isNotEmpty) {
        queryParams['slotType'] = slotType;
      }
      if (isActive != null) {
        queryParams['isActive'] = isActive.toString();
      }

      final response = await _apiService.dio.get(
        '/timetable/time-slots',
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
          error: 'Failed to get time slots',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to get time slots',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to get time slots',
      );
    }
  }

  /// Create a new time slot
  ///
  /// Endpoint: POST /timetable/time-slots
  ///
  /// [data] - Time slot data
  Future<Map<String, dynamic>> createTimeSlot(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.post(
        '/timetable/time-slots',
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to create time slot',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to create time slot',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to create time slot',
      );
    }
  }

  /// Update a time slot
  ///
  /// Endpoint: PATCH /timetable/time-slots/:id
  ///
  /// [id] - Time slot ID
  /// [data] - Updated time slot data
  Future<Map<String, dynamic>> updateTimeSlot(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.dio.patch(
        '/timetable/time-slots/$id',
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to update time slot',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to update time slot',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to update time slot',
      );
    }
  }

  /// Delete a time slot
  ///
  /// Endpoint: DELETE /timetable/time-slots/:id
  ///
  /// [id] - Time slot ID
  Future<void> deleteTimeSlot(int id) async {
    try {
      final response = await _apiService.dio.delete('/timetable/time-slots/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to delete time slot',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to delete time slot',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to delete time slot',
      );
    }
  }

  // ============ Room Methods ============

  /// Get all rooms
  ///
  /// Endpoint: GET /timetable/rooms
  ///
  /// [institutionId] - Optional filter by institution
  /// [roomType] - Optional filter by room type
  /// [isActive] - Optional filter by active status
  /// [building] - Optional filter by building
  Future<List<dynamic>> getAllRooms({
    int? institutionId,
    String? roomType,
    bool? isActive,
    String? building,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (institutionId != null) {
        queryParams['institutionId'] = institutionId.toString();
      }
      if (roomType != null && roomType.isNotEmpty) {
        queryParams['roomType'] = roomType;
      }
      if (isActive != null) {
        queryParams['isActive'] = isActive.toString();
      }
      if (building != null && building.isNotEmpty) {
        queryParams['building'] = building;
      }

      final response = await _apiService.dio.get(
        '/timetable/rooms',
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
          error: 'Failed to get rooms',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to get rooms',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to get rooms',
      );
    }
  }

  /// Create a new room
  ///
  /// Endpoint: POST /timetable/rooms
  ///
  /// [data] - Room data
  Future<Map<String, dynamic>> createRoom(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.post(
        '/timetable/rooms',
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to create room',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to create room',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to create room',
      );
    }
  }

  // ============ Timetable Entry Methods ============

  /// Get all timetable entries with filters
  ///
  /// Endpoint: GET /timetable/entries
  ///
  /// [institutionId] - Optional filter by institution
  /// [academicYearId] - Optional filter by academic year
  /// [semesterId] - Optional filter by semester
  /// [courseId] - Optional filter by course
  /// [section] - Optional filter by section
  /// [dayOfWeek] - Optional filter by day of week
  /// [teacherId] - Optional filter by teacher
  /// [subjectId] - Optional filter by subject
  /// [roomId] - Optional filter by room
  Future<List<dynamic>> getAllTimetableEntries({
    int? institutionId,
    int? academicYearId,
    int? semesterId,
    int? courseId,
    String? section,
    String? dayOfWeek,
    int? teacherId,
    int? subjectId,
    int? roomId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (institutionId != null) {
        queryParams['institutionId'] = institutionId.toString();
      }
      if (academicYearId != null) {
        queryParams['academicYearId'] = academicYearId.toString();
      }
      if (semesterId != null) {
        queryParams['semesterId'] = semesterId.toString();
      }
      if (courseId != null) {
        queryParams['courseId'] = courseId.toString();
      }
      if (section != null && section.isNotEmpty) {
        queryParams['section'] = section;
      }
      if (dayOfWeek != null && dayOfWeek.isNotEmpty) {
        queryParams['dayOfWeek'] = dayOfWeek;
      }
      if (teacherId != null) {
        queryParams['teacherId'] = teacherId.toString();
      }
      if (subjectId != null) {
        queryParams['subjectId'] = subjectId.toString();
      }
      if (roomId != null) {
        queryParams['roomId'] = roomId.toString();
      }

      final response = await _apiService.dio.get(
        '/timetable/entries',
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
          error: 'Failed to get timetable entries',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to get timetable entries',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to get timetable entries',
      );
    }
  }

  /// Get timetable for a specific class (course + section)
  ///
  /// Endpoint: GET /timetable/class/:courseId/:section
  ///
  /// [courseId] - Course ID
  /// [section] - Section name
  /// [semesterId] - Semester ID
  Future<Map<String, dynamic>> getTimetableByClass(
    int courseId,
    String section,
    int semesterId,
  ) async {
    try {
      final response = await _apiService.dio.get(
        '/timetable/class/$courseId/$section',
        queryParameters: {'semesterId': semesterId.toString()},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get class timetable',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to get class timetable',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to get class timetable',
      );
    }
  }

  /// Get timetable for a specific teacher
  ///
  /// Endpoint: GET /timetable/teacher/:teacherId
  ///
  /// [teacherId] - Teacher ID
  /// [semesterId] - Semester ID
  Future<Map<String, dynamic>> getTimetableByTeacher(
    int teacherId,
    int semesterId,
  ) async {
    try {
      final response = await _apiService.dio.get(
        '/timetable/teacher/$teacherId',
        queryParameters: {'semesterId': semesterId.toString()},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get teacher timetable',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to get teacher timetable',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to get teacher timetable',
      );
    }
  }

  /// Get timetable for a specific room
  ///
  /// Endpoint: GET /timetable/room/:roomId
  ///
  /// [roomId] - Room ID
  /// [semesterId] - Semester ID
  Future<Map<String, dynamic>> getTimetableByRoom(
    int roomId,
    int semesterId,
  ) async {
    try {
      final response = await _apiService.dio.get(
        '/timetable/room/$roomId',
        queryParameters: {'semesterId': semesterId.toString()},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get room timetable',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to get room timetable',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to get room timetable',
      );
    }
  }

  /// Create a single timetable entry
  ///
  /// Endpoint: POST /timetable/entries
  ///
  /// [data] - Timetable entry data
  Future<Map<String, dynamic>> createTimetableEntry(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.dio.post(
        '/timetable/entries',
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to create timetable entry',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to create timetable entry',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to create timetable entry',
      );
    }
  }

  /// Bulk create timetable entries
  ///
  /// Endpoint: POST /timetable/entries/bulk
  ///
  /// [data] - Bulk timetable entry data
  Future<Map<String, dynamic>> bulkCreateTimetable(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.dio.post(
        '/timetable/entries/bulk',
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to bulk create timetable',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to bulk create timetable',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to bulk create timetable',
      );
    }
  }

  /// Update a timetable entry
  ///
  /// Endpoint: PATCH /timetable/entries/:id
  ///
  /// [id] - Timetable entry ID
  /// [data] - Updated timetable entry data
  Future<Map<String, dynamic>> updateTimetableEntry(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.dio.patch(
        '/timetable/entries/$id',
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to update timetable entry',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to update timetable entry',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to update timetable entry',
      );
    }
  }

  /// Delete a timetable entry
  ///
  /// Endpoint: DELETE /timetable/entries/:id
  ///
  /// [id] - Timetable entry ID
  Future<void> deleteTimetableEntry(int id) async {
    try {
      final response = await _apiService.dio.delete('/timetable/entries/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to delete timetable entry',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to delete timetable entry',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to delete timetable entry',
      );
    }
  }
}
