import 'package:flutter/material.dart';

import '../../../core/services/attendance_service.dart';
import '../../../core/services/class_section_service.dart';
import '../../../utils/user_utils.dart';
import '../models/attendance_models.dart';

class AttendanceProvider with ChangeNotifier {
  // Mode: 'marking' for teachers, 'viewing' for admins
  String _mode = 'marking';
  
  // Selected Date
  DateTime _selectedDate = DateTime.now();

  // Selected Course (Class)
  CourseInfo? _selectedCourse;
  
  // Selected Section within the course
  String? _selectedSection;

  // Selected Grading System
  GradingSystem? _selectedGradingSystem;

  // List of students with attendance
  List<StudentAttendance> _students = [];

  // List of attendance records (for viewing mode)
  List<AttendanceRecord> _attendanceRecords = [];

  // Loading state
  bool _isLoading = false;

  // Error state
  String? _error;

  // Available courses (classes)
  List<CourseInfo> _availableCourses = [];
  
  // Available sections for selected course
  List<String> _availableSections = [];

  // Available grading systems
  List<GradingSystem> _availableGradingSystems = [];

  // Attendance Summary Data
  List<dynamic> _summaryData = [];
  List<dynamic> get summaryData => _summaryData;

  int? _teacherId;

  Future<void> loadInitialData(String userUuid, {int? teacherId}) async {
    _teacherId = teacherId;
    if (_isLoading) {
      // Changed from `isLoading` to `_isLoading` to match private member
      return; // Changed from `const SizedBox.shrink()` to `return;` for Future<void>
    }
    _isLoading = true;
    notifyListeners();
    try {
      final classSectionService = ClassSectionService();
      // Use courses with sections API instead of class sections
      // This gives us actual class/section groupings (like "Class 10 A") rather than subject sections
      final coursesData = await classSectionService.getCoursesWithSections(
        institutionId: 1,
      );

      // Parse courses with sections data
      _availableCourses = coursesData.map<CourseInfo>((courseData) {
        final courseId = courseData['courseId'] as int?;
        final courseName = courseData['courseName'] as String? ?? 'Unknown Course';
        final courseCode = courseData['courseCode'] as String? ?? '';
        final totalStudents = courseData['totalStudents'] as int? ?? 0;
        final sectionsData = courseData['sections'] as List<dynamic>? ?? [];
        
        final sections = sectionsData.map<SectionInfo>((sectionData) {
          return SectionInfo(
            name: sectionData['sectionName'] as String? ?? 'A',
            studentCount: sectionData['studentCount'] as int? ?? 0,
            classTeacher: sectionData['classTeacher'] as String?,
          );
        }).toList();
        
        return CourseInfo(
          id: courseId ?? 0,
          name: courseName,
          code: courseCode,
          totalStudents: totalStudents,
          sections: sections,
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

      // 1. Get Class Sections (filter by teacherId only if available)
      final classes = await classSectionService.getClassSections(
        institutionId: 1,
        teacherId: _teacherId, // Will be null for admin users, showing all classes
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
  String get mode => _mode;
  DateTime get selectedDate => _selectedDate;
  CourseInfo? get selectedCourse => _selectedCourse;
  String? get selectedSection => _selectedSection;
  GradingSystem? get selectedGradingSystem => _selectedGradingSystem;
  List<StudentAttendance> get students => _students;
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CourseInfo> get availableCourses => _availableCourses;
  List<String> get availableSections => _availableSections;
  List<GradingSystem> get availableGradingSystems => _availableGradingSystems;
  
  // Backward compatibility getter - converts courses to legacy ClassInfo format
  List<ClassInfo> get availableClasses {
    final List<ClassInfo> classes = [];
    for (final course in _availableCourses) {
      for (final section in course.sections) {
        classes.add(ClassInfo(
          id: '${course.id}_${section.name}',
          name: '${course.name} - Section ${section.name}',
          totalStudents: section.studentCount,
          courseId: course.id,
          sectionName: section.name,
          className: course.name,
        ));
      }
    }
    return classes;
  }
  
  // Legacy getter for backward compatibility
  ClassInfo? get selectedClass => _selectedCourse != null && _selectedSection != null
      ? ClassInfo(
          id: '${_selectedCourse!.id}_$_selectedSection',
          name: '${_selectedCourse!.name} - Section $_selectedSection',
          totalStudents: _selectedCourse!.sections
              .firstWhere((s) => s.name == _selectedSection, 
                         orElse: () => SectionInfo(name: '', studentCount: 0))
              .studentCount,
          courseId: _selectedCourse!.id,
          sectionName: _selectedSection!,
          className: _selectedCourse!.name,
        )
      : null;

  AttendanceSummary get summary {
    final present =
        _students.where((s) => s.status == AttendanceStatus.present).length;
    final absent =
        _students.where((s) => s.status == AttendanceStatus.absent).length;
    final late =
        _students.where((s) => s.status == AttendanceStatus.late).length;
    return AttendanceSummary(
      totalStudents: _students.length,
      present: present,
      absent: absent,
      late: late,
    );
  }

  // Set selected date
  Future<void> setSelectedDate(DateTime date) async {
    // Normalize to midnight to avoid time discrepancies
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
    // Reload data for the new date based on mode
    if (_selectedCourse != null) {
      if (_mode == 'viewing') {
        await _loadClassAttendance();
      } else {
        // For marking mode, reload students with attendance for the new date
        if (_selectedSection != null) {
          await _loadSectionStudentsForMarking();
        } else {
          await _loadAllCourseStudentsForMarking();
        }
      }
    }
  }

  // Set selected course and update available sections
  Future<void> setSelectedCourse(CourseInfo? course) async {
    _selectedCourse = course;
    _selectedSection = null; // Reset section when course changes
    _error = null;

    if (course == null) {
      _availableSections = [];
      _students = [];
      notifyListeners();
      return;
    }

    // Update available sections for this course
    _availableSections = course.sections.map((s) => s.name).toList();
    
    // Load data based on mode
    _students = [];
    _attendanceRecords = [];
    notifyListeners();
    
    if (_mode == 'viewing') {
      await _loadClassAttendance();
    } else {
      // For marking mode, load students for attendance marking
      await _loadAllCourseStudentsForMarking();
    }
  }

  // Set selected section and load students for that section
  Future<void> setSelectedSection(String? sectionName) async {
    _selectedSection = sectionName;
    _error = null;

    if (_selectedCourse == null) {
      _error = 'Please select a course first';
      notifyListeners();
      return;
    }

    notifyListeners();
    
    // Load data based on mode
    if (_mode == 'viewing') {
      // Load attendance records (filtered by section if selected)
      await _loadClassAttendance();
    } else {
      // For marking mode, load students for specific section or all sections
      if (sectionName == null) {
        await _loadAllCourseStudentsForMarking();
      } else {
        await _loadSectionStudentsForMarking();
      }
    }
  }

  // Legacy method for backward compatibility
  Future<void> setSelectedClass(ClassInfo? classInfo) async {
    if (classInfo == null) {
      await setSelectedCourse(null);
      return;
    }
    
    // Find the course by ID
    final course = _availableCourses.firstWhere(
      (c) => c.id == classInfo.courseId,
      orElse: () => CourseInfo(id: 0, name: '', code: '', totalStudents: 0, sections: []),
    );
    
    if (course.id != 0) {
      await setSelectedCourse(course);
      await setSelectedSection(classInfo.sectionName);
    }
  }

  // Set selected grading system
  void setSelectedGradingSystem(GradingSystem? system) {
    _selectedGradingSystem = system;
    notifyListeners();
  }

  // Set mode (marking or viewing)
  void setMode(String mode) {
    _mode = mode;
    notifyListeners();
  }

  // Load attendance records for the selected course and date
  Future<void> _loadClassAttendance() async {
    if (_selectedCourse == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final classSectionService = ClassSectionService();
      final dateString = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      
      // Get the first section to determine classLevel (assuming all sections in a course have same level)
      final classLevel = _selectedCourse!.sections.isNotEmpty ? 1 : null; // TODO: Get actual class level from course
      
      // Load attendance records for the class
      final response = await classSectionService.getClassAttendance(
        date: dateString,
        classLevel: classLevel,
        academicYearId: 2026, // TODO: Get current academic year
      );

      final responseData = response['data'] as List<dynamic>? ?? [];
      List<AttendanceRecord> allRecords = responseData
          .map((record) => AttendanceRecord.fromJson(record as Map<String, dynamic>))
          .toList();

      // Filter by section if one is selected
      if (_selectedSection != null) {
        _attendanceRecords = allRecords
            .where((record) => record.sectionName == _selectedSection)
            .toList();
      } else {
        _attendanceRecords = allRecords;
      }

      // Clear students list as we're now showing attendance records
      _students = [];
    } on Exception catch (e) {
      _error = 'Failed to load class attendance: $e';
      _attendanceRecords = [];
      _students = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  // TODO: Remove this method - no longer needed for attendance viewing
  Future<List<StudentAttendance>> _loadCourseStudents(int courseId, String sectionName) async {
    try {
      final classSectionService = ClassSectionService();

      // Fetch students for this course section
      final response = await classSectionService.getCourseStudents(
        courseId: courseId,
        sectionName: sectionName,
      );

      // Parse the response
      final responseData = response['data'] as Map<String, dynamic>?;
      if (responseData == null) {
        return [];
      }

      final studentsData = responseData['students'] as List<dynamic>? ?? [];

      // For now, we'll skip fetching existing attendance records since we need to 
      // implement a new attendance system for course-based sections
      // TODO: Implement attendance fetching by course and section
      final attendanceMap = <int, String>{};

      return studentsData.map<StudentAttendance>((studentData) {
        final student = studentData as Map<String, dynamic>;
        final userName = student['name'] as String? ?? 'Unknown Student';
        final studentId = student['id']?.toString() ?? '';
        final studentIdInt = int.tryParse(student['id']?.toString() ?? '');

        // Get initials from name
        final initials = UserUtils.getInitials(userName);

        // Check if attendance already exists for this student
        // Default to PRESENT for new records if no data exists
        var status = AttendanceStatus.present;

        if (studentIdInt != null && attendanceMap.containsKey(studentIdInt)) {
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
          // If no record exists, default to present for new sheets
          status = AttendanceStatus.present;
        }

        return StudentAttendance(
          id: studentId,
          name: userName,
          initials: initials,
          status: status,
        );
      }).toList();
    } on Exception catch (e) {
      print('Error loading students for course $courseId, section $sectionName: $e');
      return [];
    }
  }

  // Update student attendance status directly
  void updateStudentAttendance(String studentId, AttendanceStatus status) {
    final index = _students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      _students[index] = _students[index].copyWith(status: status);
      notifyListeners();
    }
  }

  // Deprecated: Toggle student attendance status (Cycles: Present -> Absent -> Late)
  @Deprecated('Use updateStudentAttendance instead')
  void toggleStudentAttendance(String studentId) {
    final index = _students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      final student = _students[index];
      AttendanceStatus newStatus;
      switch (student.status) {
        case AttendanceStatus.present:
          newStatus = AttendanceStatus.absent;
          break;
        case AttendanceStatus.absent:
          newStatus = AttendanceStatus.late;
          break;
        case AttendanceStatus.late:
        case AttendanceStatus.excused:
          newStatus = AttendanceStatus.present;
          break;
      }

      _students[index] = student.copyWith(status: newStatus);
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
  Future<bool> saveAttendance(String userUuid, int teacherId, {String? institutionType}) async {
    if (_selectedCourse == null) {
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
      
      // Prepare attendance data for bulk save
      final attendanceData = _students.map((student) {
        String statusString;
        switch (student.status) {
          case AttendanceStatus.present:
            statusString = 'PRESENT';
            break;
          case AttendanceStatus.absent:
            statusString = 'ABSENT';
            break;
          case AttendanceStatus.late:
            statusString = 'LATE';
            break;
          case AttendanceStatus.excused:
            statusString = 'EXCUSED';
            break;
        }
        
        return {
          'studentId': int.tryParse(student.id) ?? 0,
          'status': statusString,
          'remarks': null,
        };
      }).toList();

      // Use different APIs based on institution type
      final isSchool = institutionType == 'SCHOOL';
      late Map<String, dynamic> response;
      
      if (isSchool) {
        // School mode: Use course-based attendance API (no class sections needed)
        response = await attendanceService.markCourseAttendance(
          courseId: _selectedCourse!.id,
          sectionName: _selectedSection ?? _selectedCourse!.sections.first.name,
          date: _selectedDate.toIso8601String().split('T')[0],
          attendanceRecords: attendanceData,
        );
      } else {
        // College mode: Use class-section-based attendance API
        // Find the class section ID for this course and section
        final classSectionService = ClassSectionService();
        
        // Get class sections for the teacher to find a matching section
        final classSectionsResponse = await classSectionService.getClassSections(
          teacherId: teacherId,
          institutionId: null, // Let the backend determine this
          status: 'ACTIVE',
        );
        
        final classSectionsData = classSectionsResponse;
        
        // Find a class section that matches our course and section
        int? matchingSectionId;
        for (final sectionData in classSectionsData) {
          final section = sectionData as Map<String, dynamic>;
          final subject = section['subject'] as Map<String, dynamic>?;
          final course = subject?['course'] as Map<String, dynamic>?;
          
          if (course?['id'] == _selectedCourse!.id && 
              section['sectionName'] == (_selectedSection ?? _selectedCourse!.sections.first.name)) {
            matchingSectionId = int.tryParse(section['id']?.toString() ?? '') ?? section['id'] as int?;
            break;
          }
        }
        
        if (matchingSectionId == null) {
          _error = 'Could not find matching class section for attendance marking';
          return false;
        }
        
        response = await attendanceService.markBulkAttendance(
          teacherUuid: userUuid,
          sectionId: matchingSectionId,
          date: _selectedDate.toIso8601String().split('T')[0],
          attendanceRecords: attendanceData,
        );
      }
      
      final success = response['success'] == true;

      if (success) {
        return true;
      } else {
        _error = 'Failed to save attendance';
        return false;
      }
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
  // Load all students in a course for marking mode (across all sections)
  Future<void> _loadAllCourseStudentsForMarking() async {
    if (_selectedCourse == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Use optimized single API call instead of multiple calls per section
      final classSectionService = ClassSectionService();
      final courseData = await classSectionService.getAllCourseStudents(_selectedCourse!.id);

      if (courseData['success'] == true && courseData['data'] != null) {
        final data = courseData['data'];
        
        // Use the flat list of all students
        final allStudentsData = data['allStudents'] as List<dynamic>? ?? [];
        
        _students = allStudentsData
            .map((studentData) => StudentAttendance(
              id: studentData['id']?.toString() ?? '',
              name: studentData['name']?.toString() ?? '',
              initials: UserUtils.getInitials(studentData['name']?.toString() ?? ''),
              status: AttendanceStatus.present, // Default status
            ))
            .toList();

        print('✅ OPTIMIZED: Loaded ${_students.length} students in 1 API call (vs ${_selectedCourse!.sections.length} calls before)');
      } else {
        _students = [];
        print('No students found in course');
      }
    } on Exception catch (e) {
      _error = 'Failed to load course students: $e';
      _students = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load students for a specific section for marking mode
  Future<void> _loadSectionStudentsForMarking() async {
    if (_selectedCourse == null || _selectedSection == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _students = await _loadCourseStudents(_selectedCourse!.id, _selectedSection!);
    } on Exception catch (e) {
      _error = 'Failed to load section students: $e';
      _students = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _mode = 'marking'; // Default to marking mode
    _selectedDate = DateTime.now();
    _selectedCourse = null;
    _selectedSection = null;
    _selectedGradingSystem = null;
    _students = [];
    _attendanceRecords = [];
    _availableSections = [];
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
