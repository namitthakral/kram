
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../models/communication_model.dart';
import '../utils/api_error_handler.dart';
import 'api_service.dart';

class CommunicationsService {
  final ApiService _apiService = ApiService();

  /// Get unread communications for the current user
  Future<List<Communication>> getUnreadCommunications({int? institutionId}) async {
    try {
      final response = await _apiService.dio.get(
        '/communications/unread',
        queryParameters: institutionId != null ? {'institutionId': institutionId} : null,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Communication.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Error fetching unread communications: $e');
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      debugPrint('Error fetching unread communications: $e');
      throw ApiErrorHandler.handleException(e);
    }
  }

  /// Get all communications with filters
  Future<Map<String, dynamic>> getAllCommunications({
    int page = 1,
    int limit = 10,
    String? type,
    String? search,
    int? institutionId,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (type != null) 'type': type,
        if (search != null) 'search': search,
        if (institutionId != null) 'institutionId': institutionId,
      };

      final response = await _apiService.dio.get(
        '/communications',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return {
          'data': (response.data['data'] as List)
              .map((json) => Communication.fromJson(json))
              .toList(),
          'meta': response.data['meta'],
        };
      }
      throw Exception('Failed to load communications');
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw ApiErrorHandler.handleException(e);
    }
  }

  /// Mark a communication as read
  Future<bool> markAsRead(int id) async {
    try {
      final response = await _apiService.dio.post('/communications/$id/read');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error marking communication as read: $e');
      return false;
    }
  }

  /// Get communication statistics
  Future<Map<String, dynamic>> getCommunicationStats({int? institutionId}) async {
    try {
      final response = await _apiService.dio.get(
        '/communications/statistics',
        queryParameters: institutionId != null ? {'institutionId': institutionId} : null,
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching communication stats: $e');
      return {};
    }
  }
}
