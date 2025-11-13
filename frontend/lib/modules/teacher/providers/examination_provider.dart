import 'package:flutter/foundation.dart';

import '../models/examination_models.dart';
import '../services/teacher_service.dart';

/// Provider for managing examination state and operations
class ExaminationProvider with ChangeNotifier {
  final TeacherService _teacherService = TeacherService();

  List<Examination> _examinations = [];
  List<Semester> _semesters = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedCourseFilter;
  String? _selectedStatusFilter;

  List<Examination> get examinations => _examinations;
  List<Semester> get semesters => _semesters;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCourseFilter => _selectedCourseFilter;
  String? get selectedStatusFilter => _selectedStatusFilter;

  /// Load all examinations for a teacher
  Future<void> loadExaminations(String userUuid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _examinations = await _teacherService.getExaminations(
        userUuid,
        courseId:
            _selectedCourseFilter != null
                ? int.tryParse(_selectedCourseFilter!)
                : null,
        status: _selectedStatusFilter,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _examinations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load active semesters for dropdown
  Future<void> loadSemesters() async {
    try {
      _semesters = await _teacherService.getActiveSemesters();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading semesters: $e');
    }
  }

  /// Create a new examination
  Future<bool> createExamination(
    String userUuid,
    CreateExaminationDto dto,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newExamination = await _teacherService.createExamination(
        userUuid,
        dto,
      );
      _examinations.insert(0, newExamination);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update an existing examination
  Future<bool> updateExamination(
    String userUuid,
    int examId,
    UpdateExaminationDto dto,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedExamination = await _teacherService.updateExamination(
        userUuid,
        examId,
        dto,
      );
      final index = _examinations.indexWhere((e) => e.id == examId);
      if (index != -1) {
        _examinations[index] = updatedExamination;
      }
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete an examination
  Future<bool> deleteExamination(String userUuid, int examId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _teacherService.deleteExamination(userUuid, examId);
      _examinations.removeWhere((e) => e.id == examId);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Set course filter
  void setCourseFilter(String? courseId) {
    _selectedCourseFilter = courseId;
    notifyListeners();
  }

  /// Set status filter
  void setStatusFilter(String? status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  /// Clear filters
  void clearFilters() {
    _selectedCourseFilter = null;
    _selectedStatusFilter = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get filtered examinations
  List<Examination> getFilteredExaminations() => _examinations;
}
