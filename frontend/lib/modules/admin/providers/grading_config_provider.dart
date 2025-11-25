import 'package:flutter/material.dart';

import '../../../models/grading_config.dart';
import '../services/admin_service.dart';

class GradingConfigProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  GradingConfig? _config;
  bool _isLoading = false;
  String? _error;
  bool _hasUnsavedChanges = false;

  GradingConfig? get config => _config;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  // Temporary values for editing
  double? _tempAttendanceWeight;
  double? _tempAssignmentWeight;
  double? _tempExamWeight;
  double? _tempParticipationWeight;
  double? _tempGradeAPlusThreshold;
  double? _tempGradeAThreshold;
  double? _tempGradeBPlusThreshold;
  double? _tempGradeBThreshold;
  double? _tempGradeCThreshold;
  double? _tempGradeAPlusPoints;
  double? _tempGradeAPoints;
  double? _tempGradeBPlusPoints;
  double? _tempGradeBPoints;
  double? _tempGradeCPoints;
  double? _tempGradeDPoints;
  double? _tempAtRiskAttendance;
  double? _tempAtRiskAssignment;
  double? _tempAtRiskExam;
  double? _tempAtRiskGradePoints;
  double? _tempNeedsImprovementAttendance;
  double? _tempNeedsImprovementAssignment;
  double? _tempNeedsImprovementExam;
  double? _tempNeedsImprovementGradePoints;
  double? _tempExcellentAttendance;
  double? _tempExcellentAssignment;
  double? _tempExcellentExam;
  double? _tempExcellentGradePoints;
  double? _tempGoodAttendance;
  double? _tempGoodAssignment;
  double? _tempGoodExam;
  double? _tempGoodGradePoints;

  // Getters for current values (either temp or from config)
  double get attendanceWeight =>
      _tempAttendanceWeight ?? _config?.attendanceWeight ?? 10;
  double get assignmentWeight =>
      _tempAssignmentWeight ?? _config?.assignmentWeight ?? 30;
  double get examWeight => _tempExamWeight ?? _config?.examWeight ?? 50;
  double get participationWeight =>
      _tempParticipationWeight ?? _config?.participationWeight ?? 10;

  double get gradeAPlusThreshold =>
      _tempGradeAPlusThreshold ?? _config?.gradeAPlusThreshold ?? 93;
  double get gradeAThreshold =>
      _tempGradeAThreshold ?? _config?.gradeAThreshold ?? 85;
  double get gradeBPlusThreshold =>
      _tempGradeBPlusThreshold ?? _config?.gradeBPlusThreshold ?? 77;
  double get gradeBThreshold =>
      _tempGradeBThreshold ?? _config?.gradeBThreshold ?? 70;
  double get gradeCThreshold =>
      _tempGradeCThreshold ?? _config?.gradeCThreshold ?? 60;

  double get gradeAPlusPoints =>
      _tempGradeAPlusPoints ?? _config?.gradeAPlusPoints ?? 4.0;
  double get gradeAPoints => _tempGradeAPoints ?? _config?.gradeAPoints ?? 3.7;
  double get gradeBPlusPoints =>
      _tempGradeBPlusPoints ?? _config?.gradeBPlusPoints ?? 3.3;
  double get gradeBPoints => _tempGradeBPoints ?? _config?.gradeBPoints ?? 3.0;
  double get gradeCPoints => _tempGradeCPoints ?? _config?.gradeCPoints ?? 2.0;
  double get gradeDPoints => _tempGradeDPoints ?? _config?.gradeDPoints ?? 1.0;

  double get atRiskAttendance =>
      _tempAtRiskAttendance ?? _config?.atRiskAttendance ?? 75;
  double get atRiskAssignment =>
      _tempAtRiskAssignment ?? _config?.atRiskAssignment ?? 60;
  double get atRiskExam => _tempAtRiskExam ?? _config?.atRiskExam ?? 60;
  double get atRiskGradePoints =>
      _tempAtRiskGradePoints ?? _config?.atRiskGradePoints ?? 2.0;

  double get needsImprovementAttendance =>
      _tempNeedsImprovementAttendance ??
      _config?.needsImprovementAttendance ??
      85;
  double get needsImprovementAssignment =>
      _tempNeedsImprovementAssignment ??
      _config?.needsImprovementAssignment ??
      70;
  double get needsImprovementExam =>
      _tempNeedsImprovementExam ?? _config?.needsImprovementExam ?? 70;
  double get needsImprovementGradePoints =>
      _tempNeedsImprovementGradePoints ??
      _config?.needsImprovementGradePoints ??
      3.0;

  double get excellentAttendance =>
      _tempExcellentAttendance ?? _config?.excellentAttendance ?? 95;
  double get excellentAssignment =>
      _tempExcellentAssignment ?? _config?.excellentAssignment ?? 90;
  double get excellentExam =>
      _tempExcellentExam ?? _config?.excellentExam ?? 90;
  double get excellentGradePoints =>
      _tempExcellentGradePoints ?? _config?.excellentGradePoints ?? 3.7;

  double get goodAttendance =>
      _tempGoodAttendance ?? _config?.goodAttendance ?? 90;
  double get goodAssignment =>
      _tempGoodAssignment ?? _config?.goodAssignment ?? 80;
  double get goodExam => _tempGoodExam ?? _config?.goodExam ?? 80;
  double get goodGradePoints =>
      _tempGoodGradePoints ?? _config?.goodGradePoints ?? 3.3;

  bool get isWeightValid {
    final total =
        attendanceWeight + assignmentWeight + examWeight + participationWeight;
    return (total - 100).abs() < 0.01;
  }

  double get totalWeight =>
      attendanceWeight + assignmentWeight + examWeight + participationWeight;

  /// Load grading configuration
  Future<void> loadConfig(int institutionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final config = await _adminService.getGradingConfig(institutionId);
      _config = config ?? GradingConfig.defaults(institutionId);
      _clearTempValues();
      _hasUnsavedChanges = false;
      _error = null;
    } on Exception catch (e) {
      _error = e.toString();
      _config = GradingConfig.defaults(institutionId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update weight values
  void updateAttendanceWeight(double value) {
    _tempAttendanceWeight = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateAssignmentWeight(double value) {
    _tempAssignmentWeight = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateExamWeight(double value) {
    _tempExamWeight = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateParticipationWeight(double value) {
    _tempParticipationWeight = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  /// Update grade thresholds
  void updateGradeAPlusThreshold(double value) {
    _tempGradeAPlusThreshold = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateGradeAThreshold(double value) {
    _tempGradeAThreshold = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateGradeBPlusThreshold(double value) {
    _tempGradeBPlusThreshold = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateGradeBThreshold(double value) {
    _tempGradeBThreshold = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateGradeCThreshold(double value) {
    _tempGradeCThreshold = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  /// Update grade points
  void updateGradeAPlusPoints(double value) {
    _tempGradeAPlusPoints = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateGradeAPoints(double value) {
    _tempGradeAPoints = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateGradeBPlusPoints(double value) {
    _tempGradeBPlusPoints = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateGradeBPoints(double value) {
    _tempGradeBPoints = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateGradeCPoints(double value) {
    _tempGradeCPoints = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateGradeDPoints(double value) {
    _tempGradeDPoints = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  /// Update risk thresholds
  void updateAtRiskAttendance(double value) {
    _tempAtRiskAttendance = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateAtRiskAssignment(double value) {
    _tempAtRiskAssignment = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateAtRiskExam(double value) {
    _tempAtRiskExam = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateAtRiskGradePoints(double value) {
    _tempAtRiskGradePoints = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateNeedsImprovementAttendance(double value) {
    _tempNeedsImprovementAttendance = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateNeedsImprovementAssignment(double value) {
    _tempNeedsImprovementAssignment = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateNeedsImprovementExam(double value) {
    _tempNeedsImprovementExam = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateNeedsImprovementGradePoints(double value) {
    _tempNeedsImprovementGradePoints = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateExcellentAttendance(double value) {
    _tempExcellentAttendance = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateExcellentAssignment(double value) {
    _tempExcellentAssignment = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateExcellentExam(double value) {
    _tempExcellentExam = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateExcellentGradePoints(double value) {
    _tempExcellentGradePoints = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateGoodAttendance(double value) {
    _tempGoodAttendance = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateGoodAssignment(double value) {
    _tempGoodAssignment = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateGoodExam(double value) {
    _tempGoodExam = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateGoodGradePoints(double value) {
    _tempGoodGradePoints = value;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  /// Save configuration
  Future<bool> saveConfig(int institutionId) async {
    if (!isWeightValid) {
      _error = 'Weights must sum to 100%';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dto = UpdateGradingConfigDto(
        attendanceWeight: _tempAttendanceWeight,
        assignmentWeight: _tempAssignmentWeight,
        examWeight: _tempExamWeight,
        participationWeight: _tempParticipationWeight,
        gradeAPlusThreshold: _tempGradeAPlusThreshold,
        gradeAThreshold: _tempGradeAThreshold,
        gradeBPlusThreshold: _tempGradeBPlusThreshold,
        gradeBThreshold: _tempGradeBThreshold,
        gradeCThreshold: _tempGradeCThreshold,
        gradeAPlusPoints: _tempGradeAPlusPoints,
        gradeAPoints: _tempGradeAPoints,
        gradeBPlusPoints: _tempGradeBPlusPoints,
        gradeBPoints: _tempGradeBPoints,
        gradeCPoints: _tempGradeCPoints,
        gradeDPoints: _tempGradeDPoints,
        atRiskAttendance: _tempAtRiskAttendance,
        atRiskAssignment: _tempAtRiskAssignment,
        atRiskExam: _tempAtRiskExam,
        atRiskGradePoints: _tempAtRiskGradePoints,
        needsImprovementAttendance: _tempNeedsImprovementAttendance,
        needsImprovementAssignment: _tempNeedsImprovementAssignment,
        needsImprovementExam: _tempNeedsImprovementExam,
        needsImprovementGradePoints: _tempNeedsImprovementGradePoints,
        excellentAttendance: _tempExcellentAttendance,
        excellentAssignment: _tempExcellentAssignment,
        excellentExam: _tempExcellentExam,
        excellentGradePoints: _tempExcellentGradePoints,
        goodAttendance: _tempGoodAttendance,
        goodAssignment: _tempGoodAssignment,
        goodExam: _tempGoodExam,
        goodGradePoints: _tempGoodGradePoints,
      );

      final success = await _adminService.updateGradingConfig(
        institutionId,
        dto,
      );

      if (success) {
        await loadConfig(institutionId); // Reload to get updated data
        return true;
      } else {
        _error = 'Failed to save configuration';
        return false;
      }
    } on Exception catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset to defaults
  Future<bool> resetToDefaults(int institutionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _adminService.resetGradingConfig(institutionId);

      if (success) {
        await loadConfig(institutionId); // Reload defaults
        return true;
      } else {
        _error = 'Failed to reset configuration';
        return false;
      }
    } on Exception catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Discard unsaved changes
  void discardChanges() {
    _clearTempValues();
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  void _clearTempValues() {
    _tempAttendanceWeight = null;
    _tempAssignmentWeight = null;
    _tempExamWeight = null;
    _tempParticipationWeight = null;
    _tempGradeAPlusThreshold = null;
    _tempGradeAThreshold = null;
    _tempGradeBPlusThreshold = null;
    _tempGradeBThreshold = null;
    _tempGradeCThreshold = null;
    _tempGradeAPlusPoints = null;
    _tempGradeAPoints = null;
    _tempGradeBPlusPoints = null;
    _tempGradeBPoints = null;
    _tempGradeCPoints = null;
    _tempGradeDPoints = null;
    _tempAtRiskAttendance = null;
    _tempAtRiskAssignment = null;
    _tempAtRiskExam = null;
    _tempAtRiskGradePoints = null;
    _tempNeedsImprovementAttendance = null;
    _tempNeedsImprovementAssignment = null;
    _tempNeedsImprovementExam = null;
    _tempNeedsImprovementGradePoints = null;
    _tempExcellentAttendance = null;
    _tempExcellentAssignment = null;
    _tempExcellentExam = null;
    _tempExcellentGradePoints = null;
    _tempGoodAttendance = null;
    _tempGoodAssignment = null;
    _tempGoodExam = null;
    _tempGoodGradePoints = null;
  }
}
