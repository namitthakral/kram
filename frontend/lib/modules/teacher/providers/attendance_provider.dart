import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/services/attendance_service.dart';
import '../../../core/services/class_section_service.dart';
import '../../../utils/user_utils.dart';
import '../models/attendance_models.dart';

class AttendanceProvider with ChangeNotifier {
  // Selected Date
  DateTime _selectedDate = DateTime.now();

  // Selected Class
  ClassInfo? _selectedClass;

  // Selected Grading System
  GradingSystem? _selectedGradingSystem;

  // List of students with attendance
  List<StudentAttendance> _students = [];

  // Loading state
  bool _isLoading = false;

  // Error state
  String? _error;

  // Available classes (mock data - replace with API call)
  final List<ClassInfo> _availableClasses = [
    ClassInfo(
      id: '1_A',
      name: 'Grade 10-A',
      totalStudents: 28,
      courseId: 1,
      sectionName: 'A',
    ),
    ClassInfo(
      id: '2_B',
      name: 'Grade 10-B',
      totalStudents: 30,
      courseId: 2,
      sectionName: 'B',
    ),
    ClassInfo(
      id: '3_A',
      name: 'Grade 9-A',
      totalStudents: 25,
      courseId: 3,
      sectionName: 'A',
    ),
  ];

  // Available grading systems (mock data - replace with API call)
  final List<GradingSystem> _availableGradingSystems = [
    GradingSystem(
      id: '1',
      name: 'Standard System',
      description: 'Default grading configuration',
    ),
    GradingSystem(
      id: '2',
      name: 'Honor System',
      description: 'Advanced grading for honors classes',
    ),
    GradingSystem(
      id: '3',
      name: 'Pass/Fail System',
      description: 'Simple pass or fail grading',
    ),
  ];

  // Getters
  DateTime get selectedDate => _selectedDate;
  ClassInfo? get selectedClass => _selectedClass;
  GradingSystem? get selectedGradingSystem => _selectedGradingSystem;
  List<StudentAttendance> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ClassInfo> get availableClasses => _availableClasses;
  List<GradingSystem> get availableGradingSystems => _availableGradingSystems;

  AttendanceSummary get summary {
    final present =
        _students.where((s) => s.status == AttendanceStatus.present).length;
    final absent =
        _students.where((s) => s.status == AttendanceStatus.absent).length;
    return AttendanceSummary(
      totalStudents: _students.length,
      present: present,
      absent: absent,
    );
  }

  // Set selected date
  Future<void> setSelectedDate(DateTime date) async {
    _selectedDate = date;
    notifyListeners();
    // Reload students with attendance for the new date
    if (_selectedClass != null) {
      await _loadStudents();
    }
  }

  // Set selected class and load students
  Future<void> setSelectedClass(ClassInfo classInfo) async {
    _selectedClass = classInfo;
    _error = null;
    notifyListeners();
    await _loadStudents();
  }

  // Set selected grading system
  void setSelectedGradingSystem(GradingSystem? system) {
    _selectedGradingSystem = system;
    notifyListeners();
  }

  // Load students for a class
  Future<void> _loadStudents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_selectedClass == null) {
        _students = [];
        return;
      }

      // If the ClassInfo doesn't have a sectionId, we need to fetch it first
      int? sectionId = _selectedClass!.sectionId;

      if (sectionId == null) {
        // Fallback: Get section ID by fetching class sections
        // This happens when ClassInfo is created without sectionId
        _error = 'Unable to load students: Class section ID is missing. '
            'Please ensure you have subjects assigned to this section.';
        _students = [];
        return;
      }

      final classSectionService = ClassSectionService();
      final attendanceService = AttendanceService();

      // Fetch enrolled students for this class section
      final response = await classSectionService.getEnrolledStudents(
        sectionId: sectionId,
      );

      print('Enrolled students response: $response');

      // Parse the response
      final responseData = response['data'] as Map<String, dynamic>?;
      if (responseData == null) {
        _students = [];
        return;
      }

      final studentsData = responseData['students'] as List<dynamic>? ?? [];

      // Fetch existing attendance records for the selected date
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final attendanceResponse = await attendanceService.getAttendance(
        sectionId: sectionId,
        date: dateStr,
      );

      print('Existing attendance response: $attendanceResponse');

      // Create a map of studentId -> attendance status
      final attendanceMap = <int, String>{};
      final attendanceData = attendanceResponse['data'] as Map<String, dynamic>?;
      if (attendanceData != null) {
        final attendanceList = attendanceData['attendance'] as List<dynamic>? ?? [];
        for (final record in attendanceList) {
          final recordData = record as Map<String, dynamic>;
          final studentId = recordData['studentId'] as int?;
          final status = recordData['status'] as String?;

          if (studentId != null && status != null) {
            attendanceMap[studentId] = status;
          }
        }
      }

      print('Found ${attendanceMap.length} existing attendance records');

      _students = studentsData.map((studentData) {
        final student = studentData as Map<String, dynamic>;
        final userName = student['name'] as String? ?? 'Unknown Student';
        final studentId = student['id']?.toString() ?? '';
        final studentIdInt = student['id'] as int?;

        // Get initials from name
        final initials = UserUtils.getInitials(userName);

        // Check if attendance already exists for this student
        AttendanceStatus status = AttendanceStatus.present;
        if (studentIdInt != null && attendanceMap.containsKey(studentIdInt)) {
          final dbStatus = attendanceMap[studentIdInt]!;
          status = dbStatus == 'PRESENT'
              ? AttendanceStatus.present
              : dbStatus == 'ABSENT'
                  ? AttendanceStatus.absent
                  : dbStatus == 'LATE'
                      ? AttendanceStatus.late
                      : dbStatus == 'EXCUSED'
                          ? AttendanceStatus.excused
                          : AttendanceStatus.present;
        }

        return StudentAttendance(
          id: studentId,
          name: userName,
          initials: initials,
          status: status,
        );
      }).toList();

      print('Loaded ${_students.length} enrolled students with attendance status');
    } on Exception catch (e) {
      _error = 'Failed to load students: $e';
      _students = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle student attendance status
  void toggleStudentAttendance(String studentId) {
    final index = _students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      final student = _students[index];
      _students[index] = student.copyWith(
        status: student.status == AttendanceStatus.present
            ? AttendanceStatus.absent
            : AttendanceStatus.present,
      );
      notifyListeners();
    }
  }

  // Mark all students as present
  void markAllPresent() {
    _students = _students
        .map(
          (student) => student.copyWith(status: AttendanceStatus.present),
        )
        .toList();
    notifyListeners();
  }

  // Mark all students as absent
  void markAllAbsent() {
    _students = _students
        .map(
          (student) => student.copyWith(status: AttendanceStatus.absent),
        )
        .toList();
    notifyListeners();
  }

  // Save attendance
  Future<bool> saveAttendance(String teacherUuid, int teacherId) async {
    if (_selectedClass == null) {
      _error = 'Please select a class';
      notifyListeners();
      return false;
    }

    if (_students.isEmpty) {
      _error = 'No students to mark attendance for';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final attendanceService = AttendanceService();
      final classSectionService = ClassSectionService();

      // Fetch class sections for this teacher and course
      print('Fetching class sections for teacherId: $teacherId, '
          'courseId: ${_selectedClass!.courseId}');

      final classSections = await classSectionService.getClassSections(
        teacherId: teacherId,
        courseId: _selectedClass!.courseId,
        status: 'ACTIVE',
      );

      print('Found ${classSections.length} class sections');

      if (classSections.isEmpty) {
        _error =
            'No active class sections found for this course. '
            'Please ensure the class has subjects assigned with you as the teacher.';
        return false;
      }

      // Filter sections by matching sectionName
      final matchingSections = classSections.where((section) {
        final sectionName = section['sectionName'] as String?;
        print('Section: $sectionName, looking for: ${_selectedClass!.sectionName}');
        return sectionName == _selectedClass!.sectionName;
      }).toList();

      print('Found ${matchingSections.length} matching sections');

      if (matchingSections.isEmpty) {
        _error =
            'No class section found for ${_selectedClass!.sectionName}. '
            'Please ensure subjects are assigned to this section.';
        return false;
      }

      // Use the first matching section (or we could mark attendance for all subjects)
      final sectionId = matchingSections.first['id'] as int;
      print('Using sectionId: $sectionId');

      // Format date as YYYY-MM-DD
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      // Convert students to attendance records
      final attendanceRecords = _students
          .map(
            (student) => {
              'studentId': int.parse(student.id),
              'status': student.status == AttendanceStatus.present
                  ? 'PRESENT'
                  : 'ABSENT',
            },
          )
          .toList();

      // Call the bulk attendance API
      final result = await attendanceService.markBulkAttendance(
        teacherUuid: teacherUuid,
        sectionId: sectionId,
        date: dateStr,
        attendanceRecords: attendanceRecords,
      );

      print('Attendance API response: $result');

      // Parse the response to get the actual data from the backend
      final data = result['data'] as Map<String, dynamic>?;
      if (data == null) {
        _error = 'Invalid response from server';
        return false;
      }

      // Check if there were any errors
      final errors = data['errors'] as List<dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        _error = 'Some students could not be marked: ${errors.length} errors';
        return false;
      }

      // Update local state with the actual status from database
      final results = data['results'] as List<dynamic>?;
      if (results != null && results.isNotEmpty) {
        // Create a map of studentId -> status from the backend response
        final statusMap = <int, String>{};
        for (final resultItem in results) {
          final resultData = resultItem as Map<String, dynamic>;
          final studentId = resultData['studentId'] as int?;
          final status = resultData['status'] as String?;

          if (studentId != null && status != null) {
            statusMap[studentId] = status;
          }
        }

        // Update each student's status to match what's in the database
        _students = _students.map((student) {
          final studentId = int.tryParse(student.id);
          if (studentId != null && statusMap.containsKey(studentId)) {
            final dbStatus = statusMap[studentId]!;
            // Convert DB status to our enum
            final newStatus = dbStatus == 'PRESENT'
                ? AttendanceStatus.present
                : dbStatus == 'ABSENT'
                    ? AttendanceStatus.absent
                    : dbStatus == 'LATE'
                        ? AttendanceStatus.late
                        : dbStatus == 'EXCUSED'
                            ? AttendanceStatus.excused
                            : AttendanceStatus.absent;

            return student.copyWith(status: newStatus);
          }
          return student;
        }).toList();

        print('Updated ${statusMap.length} students with DB state');
        notifyListeners();
      }

      return true;
    } on Exception catch (e) {
      // Extract more detailed error information
      final errorMessage = e.toString();
      if (errorMessage.contains('status code of 400')) {
        _error = 'Invalid data. Please ensure:\n'
            '• Students are enrolled in this class section\n'
            '• The section has active enrollments\n'
            '• All data is valid';
      } else if (errorMessage.contains('status code of 403')) {
        _error = 'You do not have permission to mark attendance for this section';
      } else if (errorMessage.contains('status code of 404')) {
        _error = 'Class section not found';
      } else {
        _error = 'Failed to save attendance: $errorMessage';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset attendance state
  void reset() {
    _selectedDate = DateTime.now();
    _selectedClass = null;
    _selectedGradingSystem = null;
    _students = [];
    _error = null;
    notifyListeners();
  }
}
