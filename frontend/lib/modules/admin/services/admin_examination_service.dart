import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../utils/secure_storge.dart';
import '../models/examination_oversight_models.dart';

class AdminExaminationService {
  static const String _baseUrl = AppConstants.baseUrl;
  static final SecureStorageService _storage = SecureStorageService();

  // Get authentication headers
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(AppConstants.accessTokenKey);
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get examination schedule overview
  static Future<ExaminationScheduleResponse> getExaminationSchedule({
    String? startDate,
    String? endDate,
    String? status,
    String? examType,
    int? subjectId,
    int limit = 50,
    int page = 1,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, String>{
      'limit': limit.toString(),
      'page': page.toString(),
    };

    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (status != null) queryParams['status'] = status;
    if (examType != null) queryParams['examType'] = examType;
    if (subjectId != null) queryParams['subjectId'] = subjectId.toString();

    final uri = Uri.parse(
      '$_baseUrl/admin/examinations/schedule',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return ExaminationScheduleResponse.fromJson(jsonData['data']);
    } else {
      throw Exception('Failed to load examination schedule: ${response.body}');
    }
  }

  // Get examination completion statistics
  static Future<ExaminationCompletionStats>
  getExaminationCompletionStats() async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/admin/examinations/completion-stats');

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return ExaminationCompletionStats.fromJson(jsonData['data']);
    } else {
      throw Exception('Failed to load completion stats: ${response.body}');
    }
  }

  // Get examination analytics
  static Future<Map<String, dynamic>> getExaminationAnalytics({
    String period = 'month',
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '$_baseUrl/admin/examinations/analytics',
    ).replace(queryParameters: {'period': period});

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return jsonData['data'];
    } else {
      throw Exception('Failed to load examination analytics: ${response.body}');
    }
  }

  // Get examination policy
  static Future<ExaminationPolicy?> getExaminationPolicy(
    int institutionId,
  ) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '$_baseUrl/admin/institutions/$institutionId/examination-policy',
    );

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      if (jsonData['data'] != null) {
        return ExaminationPolicy.fromJson(jsonData['data']);
      }
      return null; // No custom policy found
    } else {
      throw Exception('Failed to load examination policy: ${response.body}');
    }
  }

  // Update examination policy
  static Future<ExaminationPolicy> updateExaminationPolicy(
    int institutionId,
    Map<String, dynamic> policyData,
  ) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '$_baseUrl/admin/institutions/$institutionId/examination-policy',
    );

    final response = await http.put(
      uri,
      headers: headers,
      body: json.encode(policyData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return ExaminationPolicy.fromJson(jsonData['data']);
    } else {
      throw Exception('Failed to update examination policy: ${response.body}');
    }
  }

  // Reset examination policy to defaults
  static Future<void> resetExaminationPolicy(int institutionId) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '$_baseUrl/admin/institutions/$institutionId/examination-policy/reset',
    );

    final response = await http.post(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to reset examination policy: ${response.body}');
    }
  }

  // Get examination compliance report
  static Future<ExaminationComplianceReport> getExaminationComplianceReport({
    String? startDate,
    String? endDate,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final uri = Uri.parse(
      '$_baseUrl/admin/examinations/compliance-report',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return ExaminationComplianceReport.fromJson(jsonData['data']);
    } else {
      throw Exception('Failed to load compliance report: ${response.body}');
    }
  }
}
