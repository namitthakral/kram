import 'package:flutter/foundation.dart';
import '../models/assignment_models.dart';
import '../services/teacher_service.dart';

class TeacherClassesProvider extends ChangeNotifier {
  final TeacherService _teacherService = TeacherService();

  bool _isLoading = false;
  String? _error;
  List<ClassSection> _classes = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ClassSection> get classes => _classes;

  Future<void> loadTeacherClasses(String userUuid, {int? semesterId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final rawClasses = await _teacherService.getTeacherClasses(
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
    } catch (e) {
      _error = e.toString();
      _classes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
