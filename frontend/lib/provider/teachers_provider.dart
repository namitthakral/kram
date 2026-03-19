import 'package:flutter/foundation.dart';

import '../modules/teacher/services/teacher_service.dart';

/// Provider for managing teachers data
///
/// This provider handles loading and caching of teachers list
/// Can be used across the app for teacher dropdowns and selections
class TeachersProvider extends ChangeNotifier {
  final TeacherService _teacherService = TeacherService();

  // Loading states
  bool _isLoadingTeachers = false;

  // Error states
  String? _teachersError;

  // Data
  List<Map<String, dynamic>>? _teachers;

  // Getters for loading states
  bool get isLoadingTeachers => _isLoadingTeachers;

  // Getters for errors
  String? get teachersError => _teachersError;

  // Getters for data
  List<Map<String, dynamic>>? get teachers => _teachers;

  // Check if there's any loading in progress
  bool get isLoading => _isLoadingTeachers;

  /// Load all teachers
  ///
  /// [page] - Page number for pagination
  /// [limit] - Items per page
  Future<void> loadTeachers({int page = 1, int limit = 100}) async {
    // Prevent duplicate loading
    if (_isLoadingTeachers) {
      debugPrint('⏳ Teachers already loading, skipping duplicate request');
      return;
    }

    _isLoadingTeachers = true;
    _teachersError = null;
    notifyListeners();

    try {
      final response = await _teacherService.getAllTeachers(
        page: page,
        limit: limit,
      );

      debugPrint('📥 Teachers API Response: $response');

      if (response['data'] != null) {
        final List<dynamic> teachersData = response['data'];
        debugPrint('📊 Raw teachers data: $teachersData');

        _teachers =
            teachersData.map((t) {
              final teacher = t as Map<String, dynamic>;
              final user = teacher['user'] as Map<String, dynamic>?;

              return {
                'uuid': user?['uuid'] ?? '',
                'name':
                    '${user?['firstName'] ?? ''} ${user?['lastName'] ?? ''}'
                            .trim()
                            .isEmpty
                        ? 'Unknown Teacher'
                        : '${user?['firstName'] ?? ''} ${user?['lastName'] ?? ''}'
                            .trim(),
                'employeeId': teacher['employeeId'],
                'designation': teacher['designation'],
                'email': user?['email'],
                'phone': user?['phone'],
                'teacherId': teacher['id'],
              };
            }).toList();
        _teachersError = null;
        debugPrint(
          '✅ Teachers loaded successfully: ${_teachers?.length} teachers',
        );
        debugPrint('📋 Processed teachers: $_teachers');
      } else {
        _teachers = [];
        debugPrint('⚠️ No teachers data in response');
      }
    } on Exception catch (e) {
      _teachersError = e.toString().replaceAll('Exception: ', '');
      _teachers = null;
      debugPrint('❌ Error loading teachers: $e');
    } finally {
      _isLoadingTeachers = false;
      notifyListeners();
    }
  }

  /// Clear all teachers data
  void clearTeachers() {
    _teachers = null;
    _teachersError = null;
    _isLoadingTeachers = false;
    notifyListeners();
  }

  /// Get teacher by UUID
  Map<String, dynamic>? getTeacherByUuid(String uuid) {
    if (_teachers == null) {
      return null;
    }

    final matches = _teachers!.where((teacher) => teacher['uuid'] == uuid);
    return matches.isNotEmpty ? matches.first : null;
  }

  /// Get teacher name by UUID
  String? getTeacherNameByUuid(String uuid) {
    final teacher = getTeacherByUuid(uuid);
    if (teacher == null) return null;
    
    final user = teacher['user'] as Map<String, dynamic>?;
    final firstName = user?['firstName'] as String? ?? '';
    final lastName = user?['lastName'] as String? ?? '';
    final fullName = '$firstName $lastName'.trim();
    return fullName.isEmpty ? null : fullName;
  }
}
