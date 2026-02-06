import 'package:flutter/material.dart';
import '../../../../models/auth_models.dart';
import '../models/student_dashboard_models.dart';
import '../services/student_service.dart';

class StudentExamsProvider with ChangeNotifier {
  final StudentService _studentService = StudentService();

  bool _isLoading = false;
  String? _error;
  List<StudentExamination> _examinations = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<StudentExamination> get examinations => _examinations;

  Future<void> loadExaminations(User user) async {
    if (user.uuid == null) {
      _error = 'User UUID not found';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _studentService.getExaminations(user.uuid!);
      _examinations =
          data
              .map(
                (e) => StudentExamination.fromJson(e as Map<String, dynamic>),
              )
              .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
