import 'package:dio/dio.dart';

import '../../../core/services/api_service.dart';
import '../models/assignment_models.dart';
import '../models/dashboard_stats.dart';
import '../models/examination_models.dart';

/// Service class for handling teacher-related API calls
///
/// Available endpoints (based on backend/src/teachers/teachers.controller.ts):
/// - GET /teachers - Get all teachers (admin only)
/// - GET /teachers/:user_uuid - Get teacher by UUID
/// - GET /teachers/:user_uuid/subjects - Get teacher's subjects
/// - GET /teachers/:user_uuid/classes - Get teacher's classes
/// - GET /teachers/:user_uuid/dashboard-stats - Get enhanced dashboard stats (includes workload metrics)
/// - GET /teachers/:user_uuid/attendance-trends - Get attendance trends
/// - GET /teachers/:user_uuid/subject-performance - Get subject performance
/// - GET /teachers/:user_uuid/grade-distribution - Get grade distribution
/// - GET /teachers/:user_uuid/recent-activity - Get recent student activity
/// - GET /teachers/:user_uuid/attendance-summary - Get attendance summary
/// - POST /teachers - Create new teacher (admin only)
/// - POST /teachers/:user_uuid/assign-subjects - Assign subjects to teacher
/// - PATCH /teachers/:user_uuid - Update teacher
/// - DELETE /teachers/:user_uuid - Delete teacher
class TeacherService {
  factory TeacherService() => _instance;
  TeacherService._internal();
  static final TeacherService _instance = TeacherService._internal();

  final ApiService _apiService = ApiService();

  Future<DashboardStats> getDashboardStats(String userUuid) async {
    try {
      final response = await _apiService.dio.get(
        '/teachers/$userUuid/dashboard-stats',
      );

      if (response.statusCode == 200) {
        return DashboardStats.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load dashboard stats',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Teacher not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to load dashboard stats: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<StudentActivity>> getRecentActivity(
    String userUuid, {
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/teachers/$userUuid/recent-activity',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => StudentActivity.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load recent activity',
        );
      }
    } catch (e) {
      throw Exception('Failed to load recent activity: $e');
    }
  }

  Future<AttendanceTrendsResponse> getAttendanceTrends(String userUuid) async {
    try {
      final response = await _apiService.dio.get(
        '/teachers/$userUuid/attendance-trends',
      );

      if (response.statusCode == 200) {
        return AttendanceTrendsResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load attendance trends',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Teacher not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to load attendance trends: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<SubjectPerformanceResponse> getSubjectPerformance(
    String userUuid,
  ) async {
    try {
      final response = await _apiService.dio.get(
        '/teachers/$userUuid/subject-performance',
      );

      if (response.statusCode == 200) {
        return SubjectPerformanceResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load subject performance',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Teacher not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to load subject performance: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<GradeDistributionResponse> getGradeDistribution(
    String userUuid,
  ) async {
    try {
      final response = await _apiService.dio.get(
        '/teachers/$userUuid/grade-distribution',
      );

      if (response.statusCode == 200) {
        return GradeDistributionResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load grade distribution',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Teacher not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to load grade distribution: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get attendance summary for a teacher
  ///
  /// Endpoint: GET /teachers/:user_uuid/attendance-summary
  ///
  /// [userUuid] - Teacher's user UUID
  /// [date] - Optional date filter
  /// [period] - Optional period filter (daily, weekly, monthly)
  Future<Map<String, dynamic>> getAttendanceSummary(
    String userUuid, {
    String? date,
    String? period,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null) {
        queryParams['date'] = date;
      }
      if (period != null) {
        queryParams['period'] = period;
      }

      final response = await _apiService.dio.get(
        '/teachers/$userUuid/attendance-summary',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load attendance summary',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Teacher not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to load attendance summary: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get teacher by UUID
  ///
  /// Endpoint: GET /teachers/:user_uuid
  Future<Map<String, dynamic>> getTeacherByUuid(String userUuid) async {
    try {
      final response = await _apiService.dio.get('/teachers/$userUuid');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load teacher data',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Teacher not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to load teacher data: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get teacher's subjects
  ///
  /// Endpoint: GET /teachers/:user_uuid/subjects
  ///
  /// [userUuid] - Teacher's user UUID
  /// [academicYearId] - Optional academic year ID filter
  Future<List<dynamic>> getTeacherSubjects(
    String userUuid, {
    int? academicYearId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (academicYearId != null) {
        queryParams['academicYearId'] = academicYearId.toString();
      }

      final response = await _apiService.dio.get(
        '/teachers/$userUuid/subjects',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load teacher subjects',
        );
      }
    } catch (e) {
      throw Exception('Failed to load teacher subjects: $e');
    }
  }

  /// Get teacher's classes
  ///
  /// Endpoint: GET /teachers/:user_uuid/classes
  ///
  /// [userUuid] - Teacher's user UUID
  /// [semesterId] - Optional semester ID filter
  Future<List<dynamic>> getTeacherClasses(
    String userUuid, {
    int? semesterId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (semesterId != null) {
        queryParams['semesterId'] = semesterId.toString();
      }

      final response = await _apiService.dio.get(
        '/teachers/$userUuid/classes',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load teacher classes',
        );
      }
    } catch (e) {
      throw Exception('Failed to load teacher classes: $e');
    }
  }

  /// Get all teachers (admin only)
  ///
  /// Endpoint: GET /teachers
  ///
  /// [page] - Page number for pagination
  /// [limit] - Items per page
  Future<Map<String, dynamic>> getAllTeachers({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/teachers',
        queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load teachers',
        );
      }
    } catch (e) {
      throw Exception('Failed to load teachers: $e');
    }
  }

  // ==================== ASSIGNMENT MANAGEMENT ====================

  /// Create a new assignment
  ///
  /// Endpoint: POST /teachers/:user_uuid/assignments
  Future<Assignment> createAssignment(
    String userUuid,
    CreateAssignmentDto dto,
  ) async {
    try {
      final response = await _apiService.dio.post(
        '/teachers/$userUuid/assignments',
        data: dto.toJson(),
      );

      if (response.statusCode == 201) {
        return Assignment.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to create assignment',
        );
      }
    } catch (e) {
      throw Exception('Failed to create assignment: $e');
    }
  }

  /// Get all assignments for a teacher
  ///
  /// Endpoint: GET /teachers/:user_uuid/assignments
  Future<List<Assignment>> getAssignments(
    String userUuid, {
    int? courseId,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (courseId != null) {
        queryParams['courseId'] = courseId.toString();
      }
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiService.dio.get(
        '/teachers/$userUuid/assignments',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        // Handle different response formats
        final responseData = response.data;
        List<dynamic> data;

        if (responseData is List) {
          // Direct list response
          data = responseData;
        } else if (responseData is Map<String, dynamic>) {
          // Response wrapped in 'data' key
          final dataField = responseData['data'];
          if (dataField is List) {
            // data field is directly a list
            data = dataField;
          } else if (dataField == null) {
            // Empty response
            data = [];
          } else if (dataField is Map<String, dynamic>) {
            // Nested structure - check for assignments/items array
            if (dataField['assignments'] is List) {
              data = dataField['assignments'] as List<dynamic>;
            } else if (dataField['items'] is List) {
              data = dataField['items'] as List<dynamic>;
            } else {
              // Single object, wrap it in a list
              data = [dataField];
            }
          } else {
            // Unknown format
            throw Exception(
              'Unexpected response format: data field type is ${dataField.runtimeType}',
            );
          }
        } else {
          throw Exception(
            'Unexpected response format: response type is ${responseData.runtimeType}',
          );
        }

        return data.map((json) => Assignment.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load assignments',
        );
      }
    } catch (e) {
      throw Exception('Failed to load assignments: $e');
    }
  }

  /// Get a single assignment by ID
  ///
  /// Endpoint: GET /teachers/:user_uuid/assignments/:assignmentId
  Future<Assignment> getAssignment(String userUuid, int assignmentId) async {
    try {
      final response = await _apiService.dio.get(
        '/teachers/$userUuid/assignments/$assignmentId',
      );

      if (response.statusCode == 200) {
        return Assignment.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load assignment',
        );
      }
    } catch (e) {
      throw Exception('Failed to load assignment: $e');
    }
  }

  /// Update an assignment
  ///
  /// Endpoint: PATCH /teachers/:user_uuid/assignments/:assignmentId
  Future<Assignment> updateAssignment(
    String userUuid,
    int assignmentId,
    UpdateAssignmentDto dto,
  ) async {
    try {
      final response = await _apiService.dio.patch(
        '/teachers/$userUuid/assignments/$assignmentId',
        data: dto.toJson(),
      );

      if (response.statusCode == 200) {
        return Assignment.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to update assignment',
        );
      }
    } catch (e) {
      throw Exception('Failed to update assignment: $e');
    }
  }

  /// Delete an assignment
  ///
  /// Endpoint: DELETE /teachers/:user_uuid/assignments/:assignmentId
  Future<void> deleteAssignment(String userUuid, int assignmentId) async {
    try {
      final response = await _apiService.dio.delete(
        '/teachers/$userUuid/assignments/$assignmentId',
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to delete assignment',
        );
      }
    } catch (e) {
      throw Exception('Failed to delete assignment: $e');
    }
  }

  // ==================== EXAMINATION MANAGEMENT ====================

  /// Create a new examination
  ///
  /// Endpoint: POST /teachers/:user_uuid/examinations
  Future<Examination> createExamination(
    String userUuid,
    CreateExaminationDto dto,
  ) async {
    try {
      final response = await _apiService.dio.post(
        '/teachers/$userUuid/examinations',
        data: dto.toJson(),
      );

      if (response.statusCode == 201) {
        return Examination.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to create examination',
        );
      }
    } catch (e) {
      throw Exception('Failed to create examination: $e');
    }
  }

  /// Get all examinations for a teacher
  ///
  /// Endpoint: GET /teachers/:user_uuid/examinations
  Future<List<Examination>> getExaminations(
    String userUuid, {
    int? courseId,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (courseId != null) {
        queryParams['courseId'] = courseId.toString();
      }
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiService.dio.get(
        '/teachers/$userUuid/examinations',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        // Handle different response formats
        final responseData = response.data;
        List<dynamic> data;

        if (responseData is List) {
          // Direct list response
          data = responseData;
        } else if (responseData is Map<String, dynamic>) {
          // Response wrapped in 'data' key
          final dataField = responseData['data'];
          if (dataField is List) {
            // data field is directly a list
            data = dataField;
          } else if (dataField == null) {
            // Empty response
            data = [];
          } else if (dataField is Map<String, dynamic>) {
            // Nested structure - check for examinations/items array
            if (dataField['examinations'] is List) {
              data = dataField['examinations'] as List<dynamic>;
            } else if (dataField['items'] is List) {
              data = dataField['items'] as List<dynamic>;
            } else {
              // Single object, wrap it in a list
              data = [dataField];
            }
          } else {
            // Unknown format
            throw Exception(
              'Unexpected response format: data field type is ${dataField.runtimeType}',
            );
          }
        } else {
          throw Exception(
            'Unexpected response format: response type is ${responseData.runtimeType}',
          );
        }

        return data.map((json) => Examination.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load examinations',
        );
      }
    } catch (e) {
      throw Exception('Failed to load examinations: $e');
    }
  }

  /// Get a single examination by ID
  ///
  /// Endpoint: GET /teachers/:user_uuid/examinations/:examId
  Future<Examination> getExamination(String userUuid, int examId) async {
    try {
      final response = await _apiService.dio.get(
        '/teachers/$userUuid/examinations/$examId',
      );

      if (response.statusCode == 200) {
        return Examination.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load examination',
        );
      }
    } catch (e) {
      throw Exception('Failed to load examination: $e');
    }
  }

  /// Update an examination
  ///
  /// Endpoint: PATCH /teachers/:user_uuid/examinations/:examId
  Future<Examination> updateExamination(
    String userUuid,
    int examId,
    UpdateExaminationDto dto,
  ) async {
    try {
      final response = await _apiService.dio.patch(
        '/teachers/$userUuid/examinations/$examId',
        data: dto.toJson(),
      );

      if (response.statusCode == 200) {
        return Examination.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to update examination',
        );
      }
    } catch (e) {
      throw Exception('Failed to update examination: $e');
    }
  }

  /// Delete an examination
  ///
  /// Endpoint: DELETE /teachers/:user_uuid/examinations/:examId
  Future<void> deleteExamination(String userUuid, int examId) async {
    try {
      final response = await _apiService.dio.delete(
        '/teachers/$userUuid/examinations/$examId',
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to delete examination',
        );
      }
    } catch (e) {
      throw Exception('Failed to delete examination: $e');
    }
  }

  // ==================== HELPER METHODS ====================

  /// Get teacher's courses (for dropdowns)
  ///
  /// This wraps the getTeacherSubjects call and extracts courses
  Future<List<Course>> getTeacherCourses(String userUuid) async {
    try {
      final subjects = await getTeacherSubjects(userUuid);
      final courses = <Course>[];
      final seenCourseIds = <int>{};

      for (final subject in subjects) {
        if (subject['course'] != null) {
          final courseData = subject['course'] as Map<String, dynamic>;
          final courseId = courseData['id'] as int;
          if (!seenCourseIds.contains(courseId)) {
            courses.add(Course.fromJson(courseData));
            seenCourseIds.add(courseId);
          }
        }
      }

      return courses;
    } catch (e) {
      throw Exception('Failed to load teacher courses: $e');
    }
  }

  /// Get sections for a specific course
  Future<List<Section>> getSectionsForCourse(
    String userUuid,
    int courseId,
  ) async {
    try {
      final classes = await getTeacherClasses(userUuid);
      final sections = <Section>[];

      for (final classData in classes) {
        if (classData['courseId'] == courseId) {
          sections.add(Section.fromJson(classData as Map<String, dynamic>));
        }
      }

      return sections;
    } catch (e) {
      throw Exception('Failed to load sections: $e');
    }
  }

  /// Get active semesters
  Future<List<Semester>> getActiveSemesters() async {
    try {
      // This would need a backend endpoint, for now return empty
      // In a real app, you'd call GET /semesters?status=ACTIVE
      return [];
    } catch (e) {
      throw Exception('Failed to load semesters: $e');
    }
  }

  // ==================== ATTENDANCE MANAGEMENT ====================

  /// Mark attendance for a single student
  ///
  /// Endpoint: POST /teachers/:user_uuid/attendance
  Future<Map<String, dynamic>> markAttendance(
    String userUuid,
    Map<String, dynamic> attendanceData,
  ) async {
    try {
      final response = await _apiService.dio.post(
        '/teachers/$userUuid/attendance',
        data: attendanceData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to mark attendance',
        );
      }
    } catch (e) {
      throw Exception('Failed to mark attendance: $e');
    }
  }

  /// Mark attendance for multiple students at once
  ///
  /// Endpoint: POST /teachers/:user_uuid/attendance/bulk
  Future<Map<String, dynamic>> markBulkAttendance(
    String userUuid,
    List<Map<String, dynamic>> attendanceRecords,
  ) async {
    try {
      final response = await _apiService.dio.post(
        '/teachers/$userUuid/attendance/bulk',
        data: {'attendanceRecords': attendanceRecords},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to mark bulk attendance',
        );
      }
    } catch (e) {
      throw Exception('Failed to mark bulk attendance: $e');
    }
  }

  /// Update an attendance record
  ///
  /// Endpoint: PATCH /teachers/:user_uuid/attendance/:attendanceId
  Future<Map<String, dynamic>> updateAttendance(
    String userUuid,
    int attendanceId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _apiService.dio.patch(
        '/teachers/$userUuid/attendance/$attendanceId',
        data: updateData,
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
    } catch (e) {
      throw Exception('Failed to update attendance: $e');
    }
  }

  /// Delete an attendance record
  ///
  /// Endpoint: DELETE /teachers/:user_uuid/attendance/:attendanceId
  Future<void> deleteAttendance(String userUuid, int attendanceId) async {
    try {
      final response = await _apiService.dio.delete(
        '/teachers/$userUuid/attendance/$attendanceId',
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to delete attendance',
        );
      }
    } catch (e) {
      throw Exception('Failed to delete attendance: $e');
    }
  }

  // ==================== EXAM RESULTS MANAGEMENT ====================

  /// Create a single exam result
  ///
  /// Endpoint: POST /teachers/:user_uuid/examinations/:examId/results
  Future<Map<String, dynamic>> createExamResult(
    String userUuid,
    int examId,
    Map<String, dynamic> resultData,
  ) async {
    try {
      final response = await _apiService.dio.post(
        '/teachers/$userUuid/examinations/$examId/results',
        data: resultData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to create exam result',
        );
      }
    } catch (e) {
      throw Exception('Failed to create exam result: $e');
    }
  }

  /// Upload bulk exam results
  ///
  /// Endpoint: POST /teachers/:user_uuid/examinations/:examId/results/bulk
  Future<Map<String, dynamic>> uploadBulkExamResults(
    String userUuid,
    int examId,
    List<Map<String, dynamic>> results,
  ) async {
    try {
      final response = await _apiService.dio.post(
        '/teachers/$userUuid/examinations/$examId/results/bulk',
        data: {'results': results},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to upload bulk results',
        );
      }
    } catch (e) {
      throw Exception('Failed to upload bulk results: $e');
    }
  }

  /// Get all results for an exam
  ///
  /// Endpoint: GET /teachers/:user_uuid/examinations/:examId/results
  Future<List<dynamic>> getExamResults(String userUuid, int examId) async {
    try {
      final response = await _apiService.dio.get(
        '/teachers/$userUuid/examinations/$examId/results',
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
          error: 'Failed to get exam results',
        );
      }
    } catch (e) {
      throw Exception('Failed to get exam results: $e');
    }
  }

  /// Update an exam result
  ///
  /// Endpoint: PATCH /teachers/:user_uuid/examinations/:examId/results/:resultId
  Future<Map<String, dynamic>> updateExamResult(
    String userUuid,
    int examId,
    int resultId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _apiService.dio.patch(
        '/teachers/$userUuid/examinations/$examId/results/$resultId',
        data: updateData,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to update exam result',
        );
      }
    } catch (e) {
      throw Exception('Failed to update exam result: $e');
    }
  }

  /// Delete an exam result
  ///
  /// Endpoint: DELETE /teachers/:user_uuid/examinations/:examId/results/:resultId
  Future<void> deleteExamResult(
    String userUuid,
    int examId,
    int resultId,
  ) async {
    try {
      final response = await _apiService.dio.delete(
        '/teachers/$userUuid/examinations/$examId/results/$resultId',
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to delete exam result',
        );
      }
    } catch (e) {
      throw Exception('Failed to delete exam result: $e');
    }
  }

  // ==================== SUBMISSIONS & INSIGHTS ====================

  /// Get pending submissions to grade
  ///
  /// Endpoint: GET /teachers/:user_uuid/submissions/pending
  Future<List<dynamic>> getPendingSubmissions(
    String userUuid, {
    int? courseId,
    int? assignmentId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (courseId != null) {
        queryParams['courseId'] = courseId.toString();
      }
      if (assignmentId != null) {
        queryParams['assignmentId'] = assignmentId.toString();
      }

      final response = await _apiService.dio.get(
        '/teachers/$userUuid/submissions/pending',
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
          error: 'Failed to get pending submissions',
        );
      }
    } catch (e) {
      throw Exception('Failed to get pending submissions: $e');
    }
  }

  /// Get list of at-risk students
  ///
  /// Endpoint: GET /teachers/:user_uuid/students/at-risk
  Future<List<dynamic>> getAtRiskStudents(
    String userUuid, {
    int? courseId,
    String? criteria,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (courseId != null) {
        queryParams['courseId'] = courseId.toString();
      }
      if (criteria != null) {
        queryParams['criteria'] = criteria;
      }

      final response = await _apiService.dio.get(
        '/teachers/$userUuid/students/at-risk',
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
          error: 'Failed to get at-risk students',
        );
      }
    } catch (e) {
      throw Exception('Failed to get at-risk students: $e');
    }
  }
}
