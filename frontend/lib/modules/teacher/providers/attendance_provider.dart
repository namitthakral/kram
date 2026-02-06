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

  // Available classes
  List<ClassInfo> _availableClasses = [];

  // Available grading systems
  List<GradingSystem> _availableGradingSystems = [];

  // Attendance Summary Data
  List<dynamic> _summaryData = [];
  List<dynamic> get summaryData => _summaryData;

  String? _teacherUuid;
  int? _teacherId;

  void setTeacherUuid(String uuid) {
    _teacherUuid = uuid;
  }

  Future<void> loadInitialData(String userUuid, {int? teacherId}) async {
    _teacherUuid = userUuid;
    _teacherId = teacherId;
    _isLoading = true;
    notifyListeners();
    try {
      final classSectionService = ClassSectionService();
      // Use the new API: getClassSections with institutionId=1
      // We also filter by teacherId if provided to show only this teacher's classes
      final classesData = await classSectionService.getClassSections(
        institutionId: 1,
        teacherId: teacherId,
        status: 'ACTIVE',
      );

      _availableClasses =
          classesData.map((data) {
            final subject = data['subject'] as Map<String, dynamic>?;
            final course = data['course'] as Map<String, dynamic>?;

            return ClassInfo(
              id: data['id']?.toString() ?? '',
              name:
                  '${subject?['name'] ?? ''} ${data['sectionName'] ?? ''}'
                      .trim(),
              totalStudents: data['currentEnrollment'] as int? ?? 0,
              // Try to find courseId at top level or inside course object
              courseId: data['courseId'] as int? ?? course?['id'] as int? ?? 0,
              sectionId: data['id'] as int?,
              sectionName: data['sectionName'] as String? ?? 'A',
              subjectName: subject?['name'] as String?,
              // Use course name as the "Class Name" grouping
              className: course?['name']?.toString() ?? 'Class',
            );
          }).toList();

      _availableGradingSystems = [
        GradingSystem(
          id: '1',
          name: 'Standard System',
          description: 'Default grading configuration',
        ),
      ];

      _error = null;
    } on Exception catch (e) {
      _error = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load Attendance Summary
  Future<void> loadAttendanceSummary(String userUuid, {DateTime? date}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final classSectionService = ClassSectionService();
      final attendanceService = AttendanceService();

      // 1. Get Class Sections (instead of Teacher's Classes)
      final classes = await classSectionService.getClassSections(
        institutionId: 1,
        teacherId: _teacherId, // Use stored teacherId
        status: 'ACTIVE',
      );

      // 2. Get Attendance Records for selected date (or today)
      final targetDate = date ?? DateTime.now();
      // Fetch more records to ensure we cover all classes comfortably
      final attendanceResponse = await attendanceService.getAttendanceRecords(
        userUuid,
        startDate: targetDate,
        endDate: targetDate,
        limit: 100,
      );

      final records = attendanceResponse['records'] as List<dynamic>? ?? [];

      // 3. Synthesize Summary Data
      _summaryData =
          classes.map((classData) {
            final sectionId = classData['id'] as int;
            final subject = classData['subject'] as Map<String, dynamic>?;
            final subjectName = subject?['name'] ?? 'Unknown Subject';
            final sectionName = classData['sectionName'] ?? '';
            final studentCount = classData['currentEnrollment'] as int? ?? 0;

            // Filter records for this section and calculate present count
            final sectionRecords =
                records.where((r) => r['sectionId'] == sectionId).toList();
            final presentCount =
                sectionRecords.where((r) => r['status'] == 'PRESENT').length;

            // Determine if marked (if any record exists for this section today)
            final isMarked = sectionRecords.isNotEmpty;

            return {
              'className': '$subjectName $sectionName'.trim(),
              'sectionId': sectionId,
              'totalStudents': studentCount,
              'presentCount': presentCount,
              'isMarked': isMarked,
            };
          }).toList();

      _error = null;
    } on Exception catch (e) {
      _error = 'Failed to load attendance summary: $e';
      _summaryData = [];
      print('Error loading attendance summary: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
    // Normalize to midnight to avoid time discrepancies
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
    // Reload students with attendance for the new date
    if (_selectedClass != null) {
      await _loadStudents();
    }
  }

  // Set selected class and load students
  Future<void> setSelectedClass(ClassInfo? classInfo) async {
    _selectedClass = classInfo;
    _error = null;

    if (classInfo == null) {
      _students = [];
      // Assuming _summary is a getter, we don't set it directly.
      // The getter will return 0,0,0 if _students is empty.
      notifyListeners();
      return;
    }

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
      print('=== _loadStudents called ===');
      print('Selected Class: ${_selectedClass?.name}');
      print('Selected Date: $_selectedDate');
      print('Current Teacher UUID: $_teacherUuid');

      if (_selectedClass == null) {
        print('Aborting: No class selected');
        _students = [];
        return;
      }

      // If the ClassInfo doesn't have a sectionId, we need to fetch it first
      final sectionId = _selectedClass!.sectionId;

      if (sectionId == null) {
        // Fallback: Get section ID by fetching class sections
        // This happens when ClassInfo is created without sectionId
        _error =
            'Unable to load students: Class section ID is missing. '
            'Please ensure you have subjects assigned to this section.';
        _students = [];
        print('Aborting: Missing section ID');
        return;
      }

      final classSectionService = ClassSectionService();
      final attendanceService = AttendanceService();

      // Fetch enrolled students for this class section
      print('Fetching students for sectionId: $sectionId');
      final response = await classSectionService.getEnrolledStudents(
        sectionId: sectionId,
      );

      print('Enrolled students fetched successfully');

      // Parse the response
      final responseData = response['data'] as Map<String, dynamic>?;
      if (responseData == null) {
        print('Aborting: No data in response');
        _students = [];
        return;
      }

      final studentsData = responseData['students'] as List<dynamic>? ?? [];
      print('Found ${studentsData.length} students enrolled');

      // Fetch existing attendance records for the selected date
      final attendanceMap = <int, String>{};

      if (_teacherUuid != null) {
        print('Fetching existing attendance from DB...');
        final attendanceResponse = await attendanceService.getAttendanceRecords(
          _teacherUuid!,
          sectionId: sectionId,
          startDate: _selectedDate,
          endDate: _selectedDate,
          limit: 100,
        );

        final records = attendanceResponse['records'] as List<dynamic>? ?? [];
        print('DB returned ${records.length} records');

        for (final record in records) {
          final recordData = record as Map<String, dynamic>;
          // Try to get studentId from top level, or nested student object
          var id = recordData['studentId'];
          if (id == null && recordData['student'] != null) {
            id = recordData['student']['id'];
          }

          final studentId = int.tryParse(id?.toString() ?? '');
          final status = recordData['status'] as String?;

          if (studentId != null && status != null) {
            attendanceMap[studentId] = status;
          }
        }
        print('Parsed attendance map: $attendanceMap');
      } else {
        print('WARNING: _teacherUuid is null! Skipping DB fetch.');
      }

      _students =
          studentsData.map((studentData) {
            final student = studentData as Map<String, dynamic>;
            final userName = student['name'] as String? ?? 'Unknown Student';
            final studentId = student['id']?.toString() ?? '';
            final studentIdInt = int.tryParse(student['id']?.toString() ?? '');

            // Get initials from name
            final initials = UserUtils.getInitials(userName);

            // Check if attendance already exists for this student
            // Default to PRESENT for new records if no data exists
            var status = AttendanceStatus.present;

            if (studentIdInt != null &&
                attendanceMap.containsKey(studentIdInt)) {
              final dbStatus = attendanceMap[studentIdInt]!;
              switch (dbStatus) {
                case 'PRESENT':
                  status = AttendanceStatus.present;
                  break;
                case 'ABSENT':
                  status = AttendanceStatus.absent;
                  break;
                case 'LATE':
                  status = AttendanceStatus.late;
                  break;
                case 'EXCUSED':
                  status = AttendanceStatus.excused;
                  break;
                default:
                  status = AttendanceStatus.present;
              }
            } else {
              // If no record exists, verify if we should mark default as present.
              // For now, defaulting to present is standard behavior for new sheets.
              status = AttendanceStatus.present;
            }

            return StudentAttendance(
              id: studentId,
              name: userName,
              initials: initials,
              status: status,
            );
          }).toList();

      print('=== _loadStudents complete. Total: ${_students.length} ===');
    } on Exception catch (e) {
      print('ERROR in _loadStudents: $e');
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
        status:
            student.status == AttendanceStatus.present
                ? AttendanceStatus.absent
                : AttendanceStatus.present,
      );
      notifyListeners();
    }
  }

  // Mark all students as present
  void markAllPresent() {
    _students =
        _students
            .map(
              (student) => student.copyWith(status: AttendanceStatus.present),
            )
            .toList();
    notifyListeners();
  }

  // Mark all students as absent
  void markAllAbsent() {
    _students =
        _students
            .map((student) => student.copyWith(status: AttendanceStatus.absent))
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

      // Use the sectionId from the selected class directly
      // This ensures we write to the same section we read from
      if (_selectedClass!.sectionId == null) {
        _error = 'Invalid class selection (missing section ID)';
        return false;
      }

      final sectionId = _selectedClass!.sectionId!;
      print('Saving attendance for sectionId: $sectionId');
      print('Using sectionId: $sectionId');

      // Format date as YYYY-MM-DD
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      // Convert students to attendance records
      final attendanceRecords =
          _students
              .map(
                (student) => {
                  'studentId': int.parse(student.id),
                  'status':
                      student.status == AttendanceStatus.present
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
        _students =
            _students.map((student) {
              final studentId = int.tryParse(student.id);
              if (studentId != null && statusMap.containsKey(studentId)) {
                final dbStatus = statusMap[studentId]!;
                // Convert DB status to our enum
                final newStatus =
                    dbStatus == 'PRESENT'
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
        _error =
            'Invalid data. Please ensure:\n'
            '• Students are enrolled in this class section\n'
            '• The section has active enrollments\n'
            '• All data is valid';
      } else if (errorMessage.contains('status code of 403')) {
        _error =
            'You do not have permission to mark attendance for this section';
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

  // History State
  List<Map<String, dynamic>> _historyRecords = [];
  bool _historyLoading = false;
  int _historyTotal = 0;

  // History Filters
  DateTime? _historyStartDate;
  DateTime? _historyEndDate;
  ClassInfo? _historySelectedClass;
  String? _historyStatus; // 'PRESENT', 'ABSENT', etc.

  // Getters for History
  List<Map<String, dynamic>> get historyRecords => _historyRecords;
  bool get historyLoading => _historyLoading;
  int get historyTotal => _historyTotal;
  DateTime? get historyStartDate => _historyStartDate;
  DateTime? get historyEndDate => _historyEndDate;
  ClassInfo? get historySelectedClass => _historySelectedClass;
  String? get historyStatus => _historyStatus;

  // Setters for History Filters
  void setHistoryDateRange(DateTime? start, DateTime? end) {
    _historyStartDate = start;
    _historyEndDate = end;
    notifyListeners();
  }

  void setHistoryClass(ClassInfo? classInfo) {
    _historySelectedClass = classInfo;
    notifyListeners();
  }

  void setHistoryStatus(String? status) {
    _historyStatus = status;
    notifyListeners();
  }

  // Fetch Attendance History
  Future<void> fetchAttendanceHistory(
    String teacherUuid, {
    int limit = 20,
    int offset = 0,
  }) async {
    _historyLoading = true;
    _error = null;
    notifyListeners();

    try {
      final attendanceService = AttendanceService();
      final response = await attendanceService.getAttendanceRecords(
        teacherUuid,
        sectionId: _historySelectedClass?.sectionId,
        startDate: _historyStartDate,
        endDate: _historyEndDate,
        status: _historyStatus,
        limit: limit,
        offset: offset,
      );

      final records = response['records'] as List<dynamic>? ?? [];
      _historyRecords = records.cast<Map<String, dynamic>>();
      _historyTotal = response['total'] as int? ?? 0;
    } on Exception catch (e) {
      _error = 'Failed to fetch history: $e';
      _historyRecords = [];
    } finally {
      _historyLoading = false;
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

    // Reset history filters too
    _historyStartDate = null;
    _historyEndDate = null;
    _historySelectedClass = null;
    _historyStatus = null;
    _historyRecords = [];

    notifyListeners();
  }
}
