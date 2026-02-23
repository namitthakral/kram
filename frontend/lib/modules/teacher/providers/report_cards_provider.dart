import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/class_section_service.dart';
import '../models/marks_models.dart';
import '../models/report_card_models.dart';
import '../services/teacher_service.dart';

/// Simple student item for the section list (id, name, initials).
class ReportCardStudentItem {
  const ReportCardStudentItem({
    required this.id,
    required this.name,
    required this.initials,
  });
  final int id;
  final String name;
  final String initials;
}

class ReportCardsProvider with ChangeNotifier {
  final TeacherService _teacherService = TeacherService();
  final ClassSectionService _classSectionService = ClassSectionService();
  final AuthService _authService = AuthService();

  List<ClassInfo> _availableClasses = [];
  ClassInfo? _selectedClass;
  String? _selectedClassName;
  String? _selectedSectionName;

  bool _isLoading = false;
  bool _isLoadingStudents = false;
  String? _error;

  /// Students in the selected section (loaded when section is selected).
  List<ReportCardStudentItem> _sectionStudents = [];
  /// Report card generated per student (studentId -> ReportCardData).
  final Map<int, ReportCardData> _reportCardByStudentId = {};
  /// Student IDs for which generate is in progress.
  final Set<int> _generatingStudentIds = {};

  bool _includeExamDetails = true;

  List<ClassInfo> get availableClasses => _availableClasses;
  ClassInfo? get selectedClass => _selectedClass;
  String? get selectedClassName => _selectedClassName;
  String? get selectedSectionName => _selectedSectionName;
  bool get isLoading => _isLoading;
  bool get isLoadingStudents => _isLoadingStudents;
  String? get error => _error;
  bool get includeExamDetails => _includeExamDetails;

  List<ReportCardStudentItem> get sectionStudents => _sectionStudents;

  ReportCardData? reportCardForStudent(int studentId) =>
      _reportCardByStudentId[studentId];
  bool isGeneratingForStudent(int studentId) =>
      _generatingStudentIds.contains(studentId);

  Future<void> loadInitialData({int? teacherId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final classesData = await _classSectionService.getClassSections(
        institutionId: 1,
        teacherId: teacherId,
        status: 'ACTIVE',
      );

      _availableClasses = classesData.map((data) {
        final subject = data['subject'] as Map<String, dynamic>?;
        final course = data['course'] as Map<String, dynamic>?;
        return ClassInfo(
          id: data['id']?.toString() ?? '',
          name:
              '${subject?['name'] ?? ''} ${data['sectionName'] ?? ''}'.trim(),
          totalStudents: data['currentEnrollment'] as int? ?? 0,
          courseId: data['courseId'] as int? ?? course?['id'] as int? ?? 0,
          sectionId: data['id'] as int?,
          sectionName: data['sectionName'] as String? ?? 'A',
          subjectName: subject?['name'] as String?,
          className: course?['name']?.toString() ?? 'Class',
          semesterId: data['semesterId'] as int?,
        );
      }).toList();
      _error = null;
    } on Exception catch (e) {
      _error = 'Failed to load classes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedClassAndSection(String? className, String? sectionName) {
    _selectedClassName = className;
    _selectedSectionName = sectionName;
    _selectedClass = null;
    _sectionStudents = [];
    _reportCardByStudentId.clear();
    if (className != null && sectionName != null) {
      try {
        _selectedClass = _availableClasses.firstWhere(
          (c) =>
              (c.className == className) && (c.sectionName == sectionName),
        );
      } catch (_) {
        _selectedClass = null;
      }
    }
    notifyListeners();
  }

  void setIncludeExamDetails(bool value) {
    _includeExamDetails = value;
    notifyListeners();
  }

  /// Load students for the currently selected section.
  Future<void> loadStudentsForSection() async {
    final sectionId = _selectedClass?.sectionId;
    if (sectionId == null) {
      _sectionStudents = [];
      notifyListeners();
      return;
    }
    _isLoadingStudents = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _classSectionService.getEnrolledStudents(
        sectionId: sectionId,
      );
      final data = response.containsKey('data')
          ? response['data'] as Map<String, dynamic>
          : response;
      final list = data['students'] as List<dynamic>? ?? [];
      _sectionStudents = list.map((s) {
        final name = s['name'] as String? ?? 'Unknown';
        final id = s['id'] is int
            ? s['id'] as int
            : int.tryParse(s['id']?.toString() ?? '0') ?? 0;
        final initials = s['initials'] as String? ?? _initials(name);
        return ReportCardStudentItem(id: id, name: name, initials: initials);
      }).toList();
      _error = null;
    } on Exception catch (e) {
      _error = 'Failed to load students: $e';
      _sectionStudents = [];
    } finally {
      _isLoadingStudents = false;
      notifyListeners();
    }
  }

  static String _initials(String name) {
    final parts = name.split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Generate report card for a single student. Stores result for Download.
  Future<bool> generateForStudent(int studentId) async {
    final user = await _authService.getCurrentUser();
    final uuid = user?.uuid;
    if (uuid == null) {
      _error = 'User not found';
      notifyListeners();
      return false;
    }
    final sectionId = _selectedClass?.sectionId;
    if (sectionId == null) {
      _error = 'Please select Class and Section';
      notifyListeners();
      return false;
    }

    _generatingStudentIds.add(studentId);
    _error = null;
    notifyListeners();
    try {
      final response = await _teacherService.generateBatchReportCards(
        uuid,
        sectionId: sectionId,
        semesterId: _selectedClass?.semesterId,
        studentIds: [studentId],
        includeExamDetails: _includeExamDetails,
      );
      if (response.success && response.reportCards.isNotEmpty) {
        _reportCardByStudentId[studentId] = response.reportCards.first;
        return true;
      }
      return false;
    } on Exception catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _generatingStudentIds.remove(studentId);
      notifyListeners();
    }
  }

  void clearReportCardForStudent(int studentId) {
    _reportCardByStudentId.remove(studentId);
    notifyListeners();
  }
}
