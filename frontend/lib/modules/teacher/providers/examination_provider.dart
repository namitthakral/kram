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

  /// Load all examinations for a teacher (without filters)
  Future<void> loadExaminations(String userUuid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load ALL examinations without filters
      _examinations = await _teacherService.getExaminations(userUuid);
      _error = null;
    } on Exception catch (e) {
      _error = e.toString();
      _examinations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load active semesters for dropdown
  Future<void> loadSemesters(String userUuid) async {
    try {
      _semesters = await _teacherService.getActiveSemesters(userUuid);
      notifyListeners();
    } on Exception catch (e) {
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
    } on Exception catch (e) {
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
    } on Exception catch (e) {
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
    } on Exception catch (e) {
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

  /// Get filtered examinations based on current filter criteria
  List<Examination> getFilteredExaminations() {
    var filtered = _examinations;

    // Filter by course
    if (_selectedCourseFilter != null) {
      final courseId = int.tryParse(_selectedCourseFilter!);
      if (courseId != null) {
        filtered = filtered.where((e) => e.courseId == courseId).toList();
      }
    }

    // Filter by status
    if (_selectedStatusFilter != null) {
      filtered =
          filtered
              .where(
                (e) =>
                    e.status.toUpperCase() ==
                    _selectedStatusFilter!.toUpperCase(),
              )
              .toList();
    }

    return filtered;
  }

  /// Get a single examination by ID
  Future<Examination?> getExamination(String userUuid, int examId) async {
    // 1. Try to find in current list
    try {
      final existing = _examinations.firstWhere((e) => e.id == examId);
      return existing;
    } catch (_) {
      // 2. If not found, fetch from API
      _isLoading = true;
      _error = null;
      notifyListeners();

      try {
        final exam = await _teacherService.getExamination(userUuid, examId);
        // Add to list if not present (optional, but good for caching)
        _examinations.add(exam);
        _isLoading = false;
        notifyListeners();
        return exam;
      } on Exception catch (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
        return null;
      }
    }
  }
}
