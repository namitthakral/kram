import 'package:flutter/material.dart';

import '../../../../models/auth_models.dart';
import '../services/student_service.dart';

class StudentTimetableProvider with ChangeNotifier {
  final StudentService _studentService = StudentService();

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _timetable = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get timetable => _timetable;

  Future<void> loadTimetable(User user) async {
    final student = user.student;
    if (student == null) {
      _error = 'Student profile not found';
      notifyListeners();
      return;
    }

    // Capture values to potentially update if missing
    var programId = student.programId;
    var section = student.section;
    var currentSemester = student.currentSemester ?? 1;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // If program details are missing, try fetching full profile
      if (programId == null || section == null) {
        try {
          final profileData = await _studentService.getStudentByUuid(
            user.uuid!,
          );
          final data = profileData['data'];
          if (data != null) {
            if (data['course'] != null) {
              programId = data['course']['id'];
            }
            section = data['section'];
            currentSemester = data['currentSemester'] ?? 1;
          }
        } on Exception catch (e) {
          debugPrint('Failed to fetch full student profile: $e');
        }
      }

      if (programId == null || section == null) {
        _error = 'Student course details incomplete';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _studentService.getTimetable(
        programId,
        section,
        currentSemester,
      );

      if (response.containsKey('data') && response['data'] is Map) {
        final data = response['data'] as Map<String, dynamic>;
        if (data.containsKey('schedule') && data['schedule'] is Map) {
          _timetable = data['schedule'] as Map<String, dynamic>;
        } else {
          _timetable = data;
        }
      } else {
        _timetable = response;
      }
    } on Exception catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
