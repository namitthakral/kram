import 'package:flutter/foundation.dart';

import '../models/fee_stats.dart';
import '../models/fee_structure.dart';
import '../models/payment.dart';
import '../models/student_fee.dart';
import '../services/fees_service.dart';

class FeesProvider extends ChangeNotifier {
  final FeesService _feesService = FeesService();

  // ==================== STATE ====================

  bool _isLoading = false;
  String? _error;

  List<FeeStructure> _feeStructures = [];
  List<StudentFee> _studentFees = [];
  List<Payment> _payments = [];
  Map<String, int>? _paymentsMeta; // total, page, limit, totalPages
  StudentFeeSummary? _studentFeeSummary;
  FeeCollectionSummary? _collectionSummary;
  OverdueSummary? _overdueSummary;
  PaymentSummary? _paymentSummary;

  // ==================== GETTERS ====================

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<FeeStructure> get feeStructures => _feeStructures;
  List<StudentFee> get studentFees => _studentFees;
  List<Payment> get payments => _payments;
  Map<String, int>? get paymentsMeta => _paymentsMeta;
  StudentFeeSummary? get studentFeeSummary => _studentFeeSummary;
  FeeCollectionSummary? get collectionSummary => _collectionSummary;
  OverdueSummary? get overdueSummary => _overdueSummary;
  PaymentSummary? get paymentSummary => _paymentSummary;

  /// Count of unique students with at least one fee in PAID status
  int get paidStudentsCount {
    final paidIds = <int>{};
    for (final sf in _studentFees) {
      if (sf.status.toUpperCase() == 'PAID') paidIds.add(sf.studentId);
    }
    return paidIds.length;
  }

  // ==================== ACTIONS ====================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(dynamic e) {
    _error = e.toString().replaceAll('Exception: ', '');
    debugPrint('❌ FeesProvider Error: $_error');
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // --- Fee Structures ---

  Future<void> loadFeeStructures({
    int? institutionId,
    int? academicYearId,
  }) async {
    _setLoading(true);
    try {
      _feeStructures = await _feesService.getFeeStructures(
        institutionId: institutionId,
        academicYearId: academicYearId,
      );
      _error = null;
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createFeeStructure(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final newStructure = await _feesService.createFeeStructure(data);
      _feeStructures.insert(0, newStructure);
      _error = null;
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteFeeStructure(int id) async {
    _setLoading(true);
    try {
      await _feesService.deleteFeeStructure(id);
      _feeStructures.removeWhere((item) => item.id == id);
      _error = null;
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // --- Student Fees ---

  Future<void> loadStudentFees({
    int? studentId,
    int? feeStructureId,
    int? institutionId,
  }) async {
    _setLoading(true);
    try {
      _studentFees = await _feesService.getStudentFees(
        studentId: studentId,
        feeStructureId: feeStructureId,
        institutionId: institutionId,
      );
      _error = null;
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> assignFeeToStudent(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _feesService.assignFeeToStudent(data);
      // Reload lists if needed, or just return success
      _error = null;
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadStudentFeeSummary(int studentId) async {
    // Don't set global loading to avoid blocking UI if called in background
    try {
      _studentFeeSummary = await _feesService.getStudentFeeSummary(studentId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading student fee summary: $e');
    }
  }

  // --- Payments ---

  Future<void> loadPayments({int? studentId}) async {
    _setLoading(true);
    try {
      final result = await _feesService.getPayments(studentId: studentId, limit: 500);
      final data = result['data'];
      _payments = data is List ? data.cast<Payment>() : [];
      _paymentsMeta = result['meta'] is Map ? _mapToIntMeta(result['meta'] as Map) : null;
      _error = null;
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Load recent payments for institution (dashboard Recent Payments tab)
  Future<void> loadRecentPayments({required int institutionId, int page = 1, int limit = 20}) async {
    _setLoading(true);
    try {
      final result = await _feesService.getPayments(
        institutionId: institutionId,
        page: page,
        limit: limit,
      );
      final data = result['data'];
      _payments = data is List ? data.cast<Payment>() : [];
      _paymentsMeta = result['meta'] is Map ? _mapToIntMeta(result['meta'] as Map) : null;
      _error = null;
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  static Map<String, int>? _mapToIntMeta(Map meta) {
    return {
      'total': int.tryParse((meta['total'] ?? 0).toString()) ?? 0,
      'page': int.tryParse((meta['page'] ?? 1).toString()) ?? 1,
      'limit': int.tryParse((meta['limit'] ?? 10).toString()) ?? 10,
      'totalPages': int.tryParse((meta['totalPages'] ?? 0).toString()) ?? 0,
    };
  }

  Future<bool> recordPayment(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final newPayment = await _feesService.recordPayment(data);
      _payments.insert(0, newPayment);
      // Refresh student fees to show updated status
      if (data['studentId'] != null) {
        await loadStudentFees(studentId: data['studentId']);
      }
      _error = null;
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // --- Analytics ---

  Future<void> loadCollectionSummary(int institutionId) async {
    try {
      _collectionSummary = await _feesService.getCollectionSummary(
        institutionId: institutionId,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading collection summary: $e');
    }
  }

  Future<void> loadOverdueFees({int? institutionId}) async {
    try {
      _overdueSummary = await _feesService.getOverdueFees(institutionId: institutionId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading overdue fees: $e');
    }
  }

  Future<void> loadPaymentSummary({
    required int institutionId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      _paymentSummary = await _feesService.getPaymentSummary(
        institutionId: institutionId,
        startDate: startDate,
        endDate: endDate,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading payment summary: $e');
    }
  }

  /// Load all dashboard data for fees screen (summary, overdue, recent payments, student fees for paid count, payment summary)
  Future<void> loadFeeDashboardData(int institutionId) async {
    _setLoading(true);
    _error = null;
    notifyListeners();
    try {
      await Future.wait([
        _feesService.getCollectionSummary(institutionId: institutionId).then((v) {
          _collectionSummary = v;
        }),
        _feesService.getOverdueFees(institutionId: institutionId).then((v) {
          _overdueSummary = v;
        }),
        _feesService.getPayments(institutionId: institutionId, page: 1, limit: 20).then((result) {
          final data = result['data'];
          _payments = data is List ? data.cast<Payment>() : [];
          _paymentsMeta = result['meta'] is Map ? _mapToIntMeta(result['meta'] as Map) : null;
        }),
        _feesService.getStudentFees(institutionId: institutionId).then((list) {
          _studentFees = list;
        }),
        _feesService.getPaymentSummary(institutionId: institutionId).then((v) {
          _paymentSummary = v;
        }),
      ]);
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<List<dynamic>> getAcademicYears() async {
    try {
      return await _feesService.getAcademicYears();
    } catch (e) {
      _setError(e);
      return [];
    }
  }
}
