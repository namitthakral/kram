import '../../../../core/services/api_service.dart';
import '../models/fee_structure.dart';
import '../models/student_fee.dart';
import '../models/payment.dart';
import '../models/fee_stats.dart';

class FeesService {
  factory FeesService() => _instance;
  FeesService._internal();
  static final FeesService _instance = FeesService._internal();

  final ApiService _apiService = ApiService();

  // ==================== FEE STRUCTURES ====================

  Future<List<FeeStructure>> getFeeStructures({
    int? institutionId,
    int? academicYearId,
    int? courseId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (institutionId != null) queryParams['institutionId'] = institutionId;
      if (academicYearId != null)
        queryParams['academicYearId'] = academicYearId;
      if (courseId != null) queryParams['courseId'] = courseId;

      final response = await _apiService.dio.get(
        '/fees/structures',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => FeeStructure.fromJson(json)).toList();
      }
      throw Exception('Failed to load fee structures');
    } catch (e) {
      throw Exception('Error loading fee structures: $e');
    }
  }

  Future<FeeStructure> createFeeStructure(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.post(
        '/fees/structures',
        data: data,
      );
      if (response.statusCode == 201) {
        return FeeStructure.fromJson(response.data['data']);
      }
      throw Exception('Failed to create fee structure');
    } catch (e) {
      throw Exception('Error creating fee structure: $e');
    }
  }

  Future<FeeStructure> updateFeeStructure(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.dio.put(
        '/fees/structures/$id',
        data: data,
      );
      if (response.statusCode == 200) {
        return FeeStructure.fromJson(response.data['data']);
      }
      throw Exception('Failed to update fee structure');
    } catch (e) {
      throw Exception('Error updating fee structure: $e');
    }
  }

  Future<void> deleteFeeStructure(int id) async {
    try {
      await _apiService.dio.delete('/fees/structures/$id');
    } catch (e) {
      throw Exception('Error deleting fee structure: $e');
    }
  }

  // ==================== STUDENT FEES ====================

  Future<List<StudentFee>> getStudentFees({
    int? studentId,
    int? feeStructureId,
    int? institutionId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (studentId != null) queryParams['studentId'] = studentId;
      if (feeStructureId != null)
        queryParams['feeStructureId'] = feeStructureId;
      if (institutionId != null) queryParams['institutionId'] = institutionId;

      final response = await _apiService.dio.get(
        '/fees/student-fees',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final raw = response.data['data'];
        final List<dynamic> data = raw is List ? raw : (raw != null ? [raw] : []);
        return data.map((json) {
          final map = json is Map<String, dynamic>
              ? json
              : Map<String, dynamic>.from(json as Map);
          return StudentFee.fromJson(map);
        }).toList();
      }
      throw Exception('Failed to load student fees');
    } catch (e) {
      throw Exception('Error loading student fees: $e');
    }
  }

  Future<void> assignFeeToStudent(Map<String, dynamic> data) async {
    try {
      await _apiService.dio.post('/fees/student-fees', data: data);
    } catch (e) {
      throw Exception('Error assigning fee: $e');
    }
  }

  Future<void> bulkAssignFees(Map<String, dynamic> data) async {
    try {
      await _apiService.dio.post('/fees/student-fees/bulk', data: data);
    } catch (e) {
      throw Exception('Error bulk assigning fees: $e');
    }
  }

  Future<StudentFeeSummary> getStudentFeeSummary(int studentId) async {
    try {
      final response = await _apiService.dio.get(
        '/fees/student-fees/summary/$studentId',
      );
      if (response.statusCode == 200) {
        return StudentFeeSummary.fromJson(response.data['data']);
      }
      throw Exception('Failed to load fee summary');
    } catch (e) {
      throw Exception('Error loading fee summary: $e');
    }
  }

  // ==================== PAYMENTS ====================

  /// Get payments with optional filters. Returns paginated result when [institutionId] is set.
  Future<Map<String, dynamic>> getPayments({
    int? studentId,
    int? studentFeeId,
    int? institutionId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (studentId != null) queryParams['studentId'] = studentId;
      if (studentFeeId != null) queryParams['studentFeeId'] = studentFeeId;
      if (institutionId != null) queryParams['institutionId'] = institutionId;

      final response = await _apiService.dio.get(
        '/fees/payments',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final meta = response.data['meta'] as Map<String, dynamic>?;
        return {
          'data': data.map((json) => Payment.fromJson(json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json as Map))).toList(),
          'meta': meta ?? {},
        };
      }
      throw Exception('Failed to load payments');
    } catch (e) {
      throw Exception('Error loading payments: $e');
    }
  }

  Future<Payment> recordPayment(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.post('/fees/payments', data: data);
      if (response.statusCode == 201) {
        return Payment.fromJson(response.data['data']);
      }
      throw Exception('Failed to record payment');
    } catch (e) {
      throw Exception('Error recording payment: $e');
    }
  }

  // ==================== ANALYTICS ====================

  Future<FeeCollectionSummary> getCollectionSummary({
    required int institutionId,
    int? academicYearId,
  }) async {
    try {
      final queryParams = <String, dynamic>{'institutionId': institutionId};
      if (academicYearId != null)
        queryParams['academicYearId'] = academicYearId;

      final response = await _apiService.dio.get(
        '/fees/collection-summary',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        // Since backend might return list or object based on implementation, handle basic object
        // Assuming backend returns a summary object or list of summaries.
        // Based on backend service code: it returns result of `fee_collection_summary` view query.
        // Adapting to likely return a single aggregated object or list.
        // For now, mapping first element if list.
        final data = response.data['data'];
        if (data is List && data.isNotEmpty) {
          return FeeCollectionSummary.fromJson(data[0]);
        } else if (data is Map<String, dynamic>) {
          return FeeCollectionSummary.fromJson(data);
        }
        // Return zero/empty summary if no data
        return FeeCollectionSummary(
          totalExpected: 0,
          totalCollected: 0,
          totalPending: 0,
          collectionRate: 0,
        );
      }
      throw Exception('Failed to load collection summary');
    } catch (e) {
      throw Exception('Error loading collection summary: $e');
    }
  }

  Future<OverdueSummary> getOverdueFees({int? institutionId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (institutionId != null) queryParams['institutionId'] = institutionId;

      final response = await _apiService.dio.get(
        '/fees/overdue',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        return OverdueSummary.fromJson(
          response.data is Map<String, dynamic> ? response.data as Map<String, dynamic> : Map<String, dynamic>.from(response.data as Map),
        );
      }
      throw Exception('Failed to load overdue fees');
    } catch (e) {
      throw Exception('Error loading overdue fees: $e');
    }
  }

  Future<PaymentSummary> getPaymentSummary({
    required int institutionId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{'institutionId': institutionId};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await _apiService.dio.get(
        '/fees/payments/summary/institution',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data is Map<String, dynamic> ? response.data as Map<String, dynamic> : Map<String, dynamic>.from(response.data as Map);
        return PaymentSummary.fromJson(data);
      }
      throw Exception('Failed to load payment summary');
    } catch (e) {
      throw Exception('Error loading payment summary: $e');
    }
  }
}
