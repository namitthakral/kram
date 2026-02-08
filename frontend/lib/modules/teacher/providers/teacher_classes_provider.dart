import 'package:flutter/foundation.dart';
import '../models/assignment_models.dart';
import '../services/teacher_service.dart';
import '../widgets/class_view_options_widget.dart';

class TeacherClassesProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<ClassSection> _classes = [];

  // Filter and view state
  bool _isGridView = false;
  ClassSortOption _sortOption = ClassSortOption.name;
  String? _selectedSubjectFilter;
  String? _selectedSectionFilter;
  bool _showOnlyClassTeacher = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ClassSection> get classes => _getFilteredAndSortedClasses();
  List<ClassSection> get allClasses => _classes;

  // View and filter getters
  bool get isGridView => _isGridView;
  ClassSortOption get sortOption => _sortOption;
  String? get selectedSubjectFilter => _selectedSubjectFilter;
  String? get selectedSectionFilter => _selectedSectionFilter;
  bool get showOnlyClassTeacher => _showOnlyClassTeacher;

  // Get unique subjects for filter
  List<String> get availableSubjects {
    final subjects = _classes.map((c) => c.subjectName).toSet().toList();
    subjects.sort();
    return subjects;
  }

  // Get unique sections for filter
  List<String> get availableSections {
    final sections = _classes.map((c) => c.sectionName).toSet().toList();
    sections.sort();
    return sections;
  }

  // Check if teacher has any class teacher assignments
  bool get hasClassTeacherAssignments => _classes.any((c) => c.isClassTeacher);

  Future<void> loadTeacherClasses(
    String userUuid, {
    int? semesterId,
    int? teacherId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final teacherService = TeacherService();
      final rawClasses = await teacherService.getTeacherClasses(
        userUuid,
        semesterId: semesterId,
      );

      _classes =
          rawClasses
              .map(
                (json) => ClassSection.fromJson(json as Map<String, dynamic>),
              )
              .toList();
      _error = null;
    } on Exception catch (e) {
      _error = e.toString();
      _classes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // View mode management
  void setGridView(bool isGrid) {
    _isGridView = isGrid;
    notifyListeners();
  }

  // Sort management
  void setSortOption(ClassSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  // Filter management
  void setSubjectFilter(String? subject) {
    _selectedSubjectFilter = subject;
    notifyListeners();
  }

  void setSectionFilter(String? section) {
    _selectedSectionFilter = section;
    notifyListeners();
  }

  void setShowOnlyClassTeacher(bool value) {
    _showOnlyClassTeacher = value;
    notifyListeners();
  }

  void clearFilters() {
    _selectedSubjectFilter = null;
    _selectedSectionFilter = null;
    _showOnlyClassTeacher = false;
    notifyListeners();
  }

  // Get filtered and sorted classes
  List<ClassSection> _getFilteredAndSortedClasses() {
    var filtered = List<ClassSection>.from(_classes);

    // Apply filters
    if (_selectedSubjectFilter != null) {
      filtered =
          filtered
              .where((c) => c.subjectName == _selectedSubjectFilter)
              .toList();
    }

    if (_selectedSectionFilter != null) {
      filtered =
          filtered
              .where((c) => c.sectionName == _selectedSectionFilter)
              .toList();
    }

    if (_showOnlyClassTeacher) {
      filtered = filtered.where((c) => c.isClassTeacher).toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case ClassSortOption.name:
        filtered.sort((a, b) => a.displayName.compareTo(b.displayName));
        break;
      case ClassSortOption.subject:
        filtered.sort((a, b) => a.subjectName.compareTo(b.subjectName));
        break;
      case ClassSortOption.studentCount:
        filtered.sort((a, b) => b.studentCount.compareTo(a.studentCount));
        break;
      case ClassSortOption.classTeacher:
        filtered.sort((a, b) {
          if (a.isClassTeacher && !b.isClassTeacher) return -1;
          if (!a.isClassTeacher && b.isClassTeacher) return 1;
          return a.displayName.compareTo(b.displayName);
        });
        break;
    }

    return filtered;
  }
}
