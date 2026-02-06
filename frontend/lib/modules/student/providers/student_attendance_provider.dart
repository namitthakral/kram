import 'package:flutter/material.dart';
import '../models/student_attendance_model.dart';
import '../services/student_service.dart';

class StudentAttendanceProvider with ChangeNotifier {
  final StudentService _studentService = StudentService();

  List<StudentAttendanceRecord> _attendanceRecords = [];
  bool _isLoading = false;
  String? _error;

  // Filter state
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedSubject;

  // Getters
  List<StudentAttendanceRecord> get attendanceRecords => _attendanceRecords;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String? get selectedSubject => _selectedSubject;

  // Get unique subjects from attendance records
  List<String> get availableSubjects {
    final subjects = <String>{};
    for (final record in _attendanceRecords) {
      if (record.subjectName != null && record.subjectName!.isNotEmpty) {
        subjects.add(record.subjectName!);
      } else {
        subjects.add('Daily Attendance');
      }
    }
    return subjects.toList()..sort();
  }

  // Get filtered attendance records based on selected subject
  List<StudentAttendanceRecord> get filteredAttendanceRecords {
    if (_selectedSubject == null) {
      return _attendanceRecords;
    }

    return _attendanceRecords.where((record) {
      if (_selectedSubject == 'Daily Attendance') {
        return record.subjectName == null || record.subjectName!.isEmpty;
      }
      return record.subjectName == _selectedSubject;
    }).toList();
  }

  AttendanceStats get stats {
    var present = 0;
    var absent = 0;
    var late = 0;
    var excused = 0;

    // Calculate stats based on filtered records
    final records = filteredAttendanceRecords;
    for (final record in records) {
      switch (record.status) {
        case AttendanceStatus.PRESENT:
          present++;
          break;
        case AttendanceStatus.ABSENT:
          absent++;
          break;
        case AttendanceStatus.LATE:
          late++;
          break;
        case AttendanceStatus.EXCUSED:
          excused++;
          break;
      }
    }

    return AttendanceStats(
      totalClasses: records.length,
      present: present,
      absent: absent,
      late: late,
      excused: excused,
    );
  }

  Future<void> fetchAttendance(
    String userUuid, {
    DateTime? start,
    DateTime? end,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _startDate = start;
      _endDate = end;

      final startDateStr =
          start != null ? start.toIso8601String().split('T')[0] : null;
      final endDateStr =
          end != null ? end.toIso8601String().split('T')[0] : null;

      final response = await _studentService.getAttendance(
        userUuid,
        startDate: startDateStr,
        endDate: endDateStr,
      );

      final List<dynamic> data = response['data'] ?? [];
      _attendanceRecords =
          data.map((json) => StudentAttendanceRecord.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
      _attendanceRecords = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setDateFilter(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    // Note: You usually need to call fetchAttendance after setting filters
    notifyListeners();
  }

  void setSubjectFilter(String? subject) {
    _selectedSubject = subject;
    notifyListeners();
  }
}
