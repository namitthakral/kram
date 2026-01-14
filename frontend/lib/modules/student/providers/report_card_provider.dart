import 'package:flutter/foundation.dart';

import '../services/student_service.dart';

/// Provider for managing student report card data and state
class ReportCardProvider extends ChangeNotifier {
  final StudentService _studentService = StudentService();

  // Loading state
  bool _isLoadingReportCard = false;

  // Error state
  String? _reportCardError;

  // Data
  Map<String, dynamic>? _reportCard;

  // Getters
  bool get isLoadingReportCard => _isLoadingReportCard;
  String? get reportCardError => _reportCardError;
  Map<String, dynamic>? get reportCard => _reportCard;

  /// Load student report card
  ///
  /// [userUuid] - Student's user UUID
  /// [semesterId] - Optional semester ID filter
  /// [academicYearId] - Optional academic year ID filter
  /// [includeExamDetails] - Optional flag to include exam details
  Future<void> loadReportCard(
    String userUuid, {
    int? semesterId,
    int? academicYearId,
    bool? includeExamDetails,
  }) async {
    _isLoadingReportCard = true;
    _reportCardError = null;
    notifyListeners();

    try {
      _reportCard = await _studentService.getReportCard(
        userUuid,
        semesterId: semesterId,
        academicYearId: academicYearId,
        includeExamDetails: includeExamDetails,
      );
      _reportCardError = null;
      debugPrint('✅ Report card loaded successfully');
    } on Exception catch (e) {
      _reportCardError = e.toString().replaceAll('Exception: ', '');
      _reportCard = null;
      debugPrint('❌ Error loading report card: $e');
    } finally {
      _isLoadingReportCard = false;
      notifyListeners();
    }
  }

  /// Clear report card data
  void clearReportCard() {
    _reportCard = null;
    _reportCardError = null;
    _isLoadingReportCard = false;
    notifyListeners();
  }

  /// Get student name from report card
  String? get studentName => _reportCard?['studentName'];

  /// Get overall grade from report card
  String? get overallGrade => _reportCard?['overallGrade'];

  /// Get overall percentage from report card
  double? get overallPercentage {
    final percentage = _reportCard?['overallPercentage'];
    return percentage != null ? double.tryParse(percentage.toString()) : null;
  }

  /// Get subjects from report card
  List<Map<String, dynamic>> get subjects {
    if (_reportCard == null) {
      return [];
    }
    final data = _reportCard!['data'];
    if (data is Map<String, dynamic>) {
      final subjects = data['subjects'];
      if (subjects is List) {
        return subjects.cast<Map<String, dynamic>>();
      }
    }
    return [];
  }

  /// Get attendance summary from report card
  Map<String, dynamic>? get attendanceSummary {
    if (_reportCard == null) {
      return null;
    }
    final data = _reportCard!['data'];
    if (data is Map<String, dynamic>) {
      return data['attendanceSummary'] as Map<String, dynamic>?;
    }
    return null;
  }

  /// Get remarks from report card
  String? get remarks {
    if (_reportCard == null) {
      return null;
    }
    final data = _reportCard!['data'];
    if (data is Map<String, dynamic>) {
      return data['remarks'] as String?;
    }
    return null;
  }
}
