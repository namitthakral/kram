import 'package:dio/dio.dart';

import '../utils/api_error_handler.dart';
import 'api_service.dart';

/// Service class for handling question paper-related API calls
///
/// Available endpoints (based on backend structure):
/// Question Paper:
/// - POST /teachers/:user_uuid/examinations/:examId/question-paper - Create empty question paper
/// - POST /teachers/:user_uuid/question-papers/full - Create full question paper
/// - GET /teachers/:user_uuid/examinations/:examId/question-paper - Get question paper by exam ID
/// - GET /teachers/:user_uuid/question-papers/:paperId - Get question paper by ID
/// - PATCH /teachers/:user_uuid/question-papers/:paperId - Update question paper
/// - PATCH /teachers/:user_uuid/question-papers/:paperId/publish - Publish question paper
/// - DELETE /teachers/:user_uuid/question-papers/:paperId - Delete question paper
///
/// Section:
/// - POST /teachers/:user_uuid/question-papers/:paperId/sections - Add section
/// - PATCH /teachers/:user_uuid/sections/:sectionId - Update section
/// - DELETE /teachers/:user_uuid/sections/:sectionId - Delete section
///
/// Question:
/// - POST /teachers/:user_uuid/sections/:sectionId/questions - Add question
/// - POST /teachers/:user_uuid/sections/:sectionId/questions/bulk - Bulk add questions
/// - PATCH /teachers/:user_uuid/questions/:questionId - Update question
/// - DELETE /teachers/:user_uuid/questions/:questionId - Delete question
///
/// Option:
/// - POST /teachers/:user_uuid/questions/:questionId/options - Add option
/// - PATCH /teachers/:user_uuid/options/:optionId - Update option
/// - DELETE /teachers/:user_uuid/options/:optionId - Delete option
///
/// Student View:
/// - GET /students/:user_uuid/examinations/:examId/question-paper - Get published paper (student view)
class QuestionPaperService {
  factory QuestionPaperService() => _instance;
  QuestionPaperService._internal();
  static final QuestionPaperService _instance =
      QuestionPaperService._internal();

  final ApiService _apiService = ApiService();

  // ============ Question Paper Methods (Teacher) ============

  /// Create an empty question paper for an examination
  ///
  /// Endpoint: POST /teachers/:user_uuid/examinations/:examId/question-paper
  ///
  /// [userUuid] - Teacher user UUID
  /// [examId] - Examination ID
  /// [data] - Question paper data
  Future<Map<String, dynamic>> createQuestionPaper(
    String userUuid,
    int examId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.dio.post(
        '/teachers/$userUuid/examinations/$examId/question-paper',
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to create question paper',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to create question paper',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to create question paper',
      );
    }
  }

  /// Create a complete question paper with sections and questions
  ///
  /// Endpoint: POST /teachers/:user_uuid/question-papers/full
  ///
  /// [userUuid] - Teacher user UUID
  /// [data] - Full question paper data with sections and questions
  Future<Map<String, dynamic>> createFullQuestionPaper(
    String userUuid,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.dio.post(
        '/teachers/$userUuid/question-papers/full',
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to create full question paper',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to create full question paper',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to create full question paper',
      );
    }
  }

  /// Get question paper by examination ID
  ///
  /// Endpoint: GET /teachers/:user_uuid/examinations/:examId/question-paper
  ///
  /// [userUuid] - Teacher user UUID
  /// [examId] - Examination ID
  Future<Map<String, dynamic>> getQuestionPaperByExamId(
    String userUuid,
    int examId,
  ) async {
    try {
      final response = await _apiService.dio.get(
        '/teachers/$userUuid/examinations/$examId/question-paper',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get question paper',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to get question paper',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to get question paper',
      );
    }
  }

  /// Get question paper by ID
  ///
  /// Endpoint: GET /teachers/:user_uuid/question-papers/:paperId
  ///
  /// [userUuid] - Teacher user UUID
  /// [paperId] - Question paper ID
  Future<Map<String, dynamic>> getQuestionPaperById(
    String userUuid,
    int paperId,
  ) async {
    try {
      final response = await _apiService.dio.get(
        '/teachers/$userUuid/question-papers/$paperId',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get question paper',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to get question paper',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to get question paper',
      );
    }
  }

  /// Update question paper details
  ///
  /// Endpoint: PATCH /teachers/:user_uuid/question-papers/:paperId
  ///
  /// [userUuid] - Teacher user UUID
  /// [paperId] - Question paper ID
  /// [data] - Updated question paper data
  Future<Map<String, dynamic>> updateQuestionPaper(
    String userUuid,
    int paperId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.dio.patch(
        '/teachers/$userUuid/question-papers/$paperId',
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to update question paper',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to update question paper',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to update question paper',
      );
    }
  }

  /// Publish a question paper (makes it visible to students)
  ///
  /// Endpoint: PATCH /teachers/:user_uuid/question-papers/:paperId/publish
  ///
  /// [userUuid] - Teacher user UUID
  /// [paperId] - Question paper ID
  Future<Map<String, dynamic>> publishQuestionPaper(
    String userUuid,
    int paperId,
  ) async {
    try {
      final response = await _apiService.dio.patch(
        '/teachers/$userUuid/question-papers/$paperId/publish',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to publish question paper',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to publish question paper',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to publish question paper',
      );
    }
  }

  /// Delete a question paper (only if not published)
  ///
  /// Endpoint: DELETE /teachers/:user_uuid/question-papers/:paperId
  ///
  /// [userUuid] - Teacher user UUID
  /// [paperId] - Question paper ID
  Future<void> deleteQuestionPaper(String userUuid, int paperId) async {
    try {
      final response = await _apiService.dio.delete(
        '/teachers/$userUuid/question-papers/$paperId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to delete question paper',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to delete question paper',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to delete question paper',
      );
    }
  }

  // ============ Section Methods ============

  /// Add a section to a question paper
  ///
  /// Endpoint: POST /teachers/:user_uuid/question-papers/:paperId/sections
  ///
  /// [userUuid] - Teacher user UUID
  /// [paperId] - Question paper ID
  /// [data] - Section data
  Future<Map<String, dynamic>> addSection(
    String userUuid,
    int paperId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.dio.post(
        '/teachers/$userUuid/question-papers/$paperId/sections',
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to add section',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to add section',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to add section',
      );
    }
  }

  /// Update a section
  ///
  /// Endpoint: PATCH /teachers/:user_uuid/sections/:sectionId
  ///
  /// [userUuid] - Teacher user UUID
  /// [sectionId] - Section ID
  /// [data] - Updated section data
  Future<Map<String, dynamic>> updateSection(
    String userUuid,
    int sectionId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.dio.patch(
        '/teachers/$userUuid/sections/$sectionId',
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to update section',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to update section',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to update section',
      );
    }
  }

  /// Delete a section (and all its questions)
  ///
  /// Endpoint: DELETE /teachers/:user_uuid/sections/:sectionId
  ///
  /// [userUuid] - Teacher user UUID
  /// [sectionId] - Section ID
  Future<void> deleteSection(String userUuid, int sectionId) async {
    try {
      final response = await _apiService.dio.delete(
        '/teachers/$userUuid/sections/$sectionId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to delete section',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to delete section',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to delete section',
      );
    }
  }

  // ============ Question Methods ============

  /// Add a question to a section
  ///
  /// Endpoint: POST /teachers/:user_uuid/sections/:sectionId/questions
  ///
  /// [userUuid] - Teacher user UUID
  /// [sectionId] - Section ID
  /// [data] - Question data
  Future<Map<String, dynamic>> addQuestion(
    String userUuid,
    int sectionId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.dio.post(
        '/teachers/$userUuid/sections/$sectionId/questions',
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to add question',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to add question',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to add question',
      );
    }
  }

  /// Bulk add questions to a section
  ///
  /// Endpoint: POST /teachers/:user_uuid/sections/:sectionId/questions/bulk
  ///
  /// [userUuid] - Teacher user UUID
  /// [sectionId] - Section ID
  /// [data] - Bulk questions data
  Future<Map<String, dynamic>> bulkAddQuestions(
    String userUuid,
    int sectionId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.dio.post(
        '/teachers/$userUuid/sections/$sectionId/questions/bulk',
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to bulk add questions',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to bulk add questions',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to bulk add questions',
      );
    }
  }

  /// Update a question
  ///
  /// Endpoint: PATCH /teachers/:user_uuid/questions/:questionId
  ///
  /// [userUuid] - Teacher user UUID
  /// [questionId] - Question ID
  /// [data] - Updated question data
  Future<Map<String, dynamic>> updateQuestion(
    String userUuid,
    int questionId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.dio.patch(
        '/teachers/$userUuid/questions/$questionId',
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to update question',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to update question',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to update question',
      );
    }
  }

  /// Delete a question
  ///
  /// Endpoint: DELETE /teachers/:user_uuid/questions/:questionId
  ///
  /// [userUuid] - Teacher user UUID
  /// [questionId] - Question ID
  Future<void> deleteQuestion(String userUuid, int questionId) async {
    try {
      final response = await _apiService.dio.delete(
        '/teachers/$userUuid/questions/$questionId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to delete question',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to delete question',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to delete question',
      );
    }
  }

  // ============ Student View Methods ============

  /// Get published question paper for a student
  /// (Hides correct answers and hints)
  ///
  /// Endpoint: GET /students/:user_uuid/examinations/:examId/question-paper
  ///
  /// [userUuid] - Student user UUID
  /// [examId] - Examination ID
  Future<Map<String, dynamic>> getPublishedQuestionPaper(
    String userUuid,
    int examId,
  ) async {
    try {
      final response = await _apiService.dio.get(
        '/students/$userUuid/examinations/$examId/question-paper',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get published question paper',
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(
        e,
        defaultMessage: 'Failed to get published question paper',
      );
    } catch (e) {
      throw ApiErrorHandler.handleException(
        e,
        defaultMessage: 'Failed to get published question paper',
      );
    }
  }
}
