/// Mock service for student API - Use this for testing when backend is not ready
///
/// To use: In student_dashboard_provider.dart, change:
/// ```dart
/// final StudentService _studentService = StudentService();
/// ```
/// to:
/// ```dart
/// final StudentServiceMock _studentService = StudentServiceMock();
/// ```
class StudentServiceMock {
  factory StudentServiceMock() => _instance;
  StudentServiceMock._internal();
  static final StudentServiceMock _instance = StudentServiceMock._internal();

  // Simulate network delay
  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 500));

  /// Get student dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats(String userUuid) async {
    await _delay();

    return {
      'gpa': 3.8,
      'attendancePercentage': 96.2,
      'classRank': '#5',
      'assignmentsDue': 3,
      'totalSubjects': 5,
      'averageGrade': 'A-',
    };
  }

  /// Get student subject performance
  Future<Map<String, dynamic>> getSubjectPerformance(String userUuid) async {
    await _delay();

    return {
      'subjects': [
        {
          'name': 'Mathematics',
          'teacherName': 'Mr. Smith',
          'nextTest': 'Oct 25',
          'grade': 'A',
          'percentage': 92,
          'color': '#4F7CFF',
        },
        {
          'name': 'Physics',
          'teacherName': 'Dr. Johnson',
          'nextTest': 'Oct 28',
          'grade': 'A-',
          'percentage': 89,
          'color': '#10b981',
        },
        {
          'name': 'Chemistry',
          'teacherName': 'Ms. Davis',
          'nextTest': 'Nov 2',
          'grade': 'B+',
          'percentage': 85,
          'color': '#8B5CF6',
        },
        {
          'name': 'English',
          'teacherName': 'Mrs. Wilson',
          'nextTest': 'Nov 5',
          'grade': 'A',
          'percentage': 94,
          'color': '#f59e0b',
        },
        {
          'name': 'History',
          'teacherName': 'Mr. Brown',
          'nextTest': 'Nov 8',
          'grade': 'B',
          'percentage': 82,
          'color': '#ef4444',
        },
      ],
    };
  }

  /// Get upcoming events
  Future<List<dynamic>> getUpcomingEvents(
    String userUuid, {
    int limit = 10,
  }) async {
    await _delay();

    return [
      {
        'title': 'Mathematics Test',
        'date': 'Oct 25, 2024',
        'time': '10:00 AM',
        'type': 'test',
      },
      {
        'title': 'Science Fair Project Due',
        'date': 'Oct 30, 2024',
        'time': '11:59 PM',
        'type': 'assignment',
      },
      {
        'title': 'Parent-Teacher Conference',
        'date': 'Nov 5, 2024',
        'time': '2:00 PM',
        'type': 'event',
      },
      {
        'title': 'Sports Day',
        'date': 'Nov 12, 2024',
        'time': '9:00 AM',
        'type': 'event',
      },
    ];
  }

  /// Get assignments
  Future<List<dynamic>> getAssignments(
    String userUuid, {
    int limit = 10,
    String? status,
  }) async {
    await _delay();

    return [
      {
        'title': 'Calculus Problem Set',
        'subject': 'Mathematics',
        'dueDate': '2024-09-22',
        'status': 'submitted',
        'grade': 'A',
        'score': '45/50',
      },
      {
        'title': 'Lab Report - Momentum',
        'subject': 'Physics',
        'dueDate': '2024-09-20',
        'status': 'graded',
        'grade': 'B+',
        'score': '38/40',
      },
      {
        'title': 'Essay - Climate Change',
        'subject': 'English',
        'dueDate': '2024-09-25',
        'status': 'pending',
      },
      {
        'title': 'Organic Compounds Quiz',
        'subject': 'Chemistry',
        'dueDate': '2024-09-18',
        'status': 'graded',
        'grade': 'A-',
        'score': '28/30',
      },
    ];
  }

  /// Get performance trends
  Future<Map<String, dynamic>> getPerformanceTrends(
    String userUuid, {
    String? startMonth,
    String? endMonth,
  }) async {
    await _delay();

    return {
      'trends': [
        {
          'month': 'Jan',
          'performances': [
            {'subject': 'Mathematics', 'percentage': 90, 'color': '#4F7CFF'},
            {'subject': 'Physics', 'percentage': 88, 'color': '#10b981'},
            {'subject': 'Chemistry', 'percentage': 85, 'color': '#8B5CF6'},
            {'subject': 'English', 'percentage': 92, 'color': '#f59e0b'},
            {'subject': 'History', 'percentage': 80, 'color': '#ef4444'},
          ],
        },
        {
          'month': 'Feb',
          'performances': [
            {'subject': 'Mathematics', 'percentage': 90, 'color': '#4F7CFF'},
            {'subject': 'Physics', 'percentage': 88, 'color': '#10b981'},
            {'subject': 'Chemistry', 'percentage': 87, 'color': '#8B5CF6'},
            {'subject': 'English', 'percentage': 93, 'color': '#f59e0b'},
            {'subject': 'History', 'percentage': 82, 'color': '#ef4444'},
          ],
        },
        {
          'month': 'Mar',
          'performances': [
            {'subject': 'Mathematics', 'percentage': 91, 'color': '#4F7CFF'},
            {'subject': 'Physics', 'percentage': 89, 'color': '#10b981'},
            {'subject': 'Chemistry', 'percentage': 86, 'color': '#8B5CF6'},
            {'subject': 'English', 'percentage': 94, 'color': '#f59e0b'},
            {'subject': 'History', 'percentage': 81, 'color': '#ef4444'},
          ],
        },
        {
          'month': 'Apr',
          'performances': [
            {'subject': 'Mathematics', 'percentage': 90, 'color': '#4F7CFF'},
            {'subject': 'Physics', 'percentage': 88, 'color': '#10b981'},
            {'subject': 'Chemistry', 'percentage': 88, 'color': '#8B5CF6'},
            {'subject': 'English', 'percentage': 94, 'color': '#f59e0b'},
            {'subject': 'History', 'percentage': 83, 'color': '#ef4444'},
          ],
        },
        {
          'month': 'May',
          'performances': [
            {'subject': 'Mathematics', 'percentage': 91, 'color': '#4F7CFF'},
            {'subject': 'Physics', 'percentage': 89, 'color': '#10b981'},
            {'subject': 'Chemistry', 'percentage': 87, 'color': '#8B5CF6'},
            {'subject': 'English', 'percentage': 95, 'color': '#f59e0b'},
            {'subject': 'History', 'percentage': 83, 'color': '#ef4444'},
          ],
        },
        {
          'month': 'Jun',
          'performances': [
            {'subject': 'Mathematics', 'percentage': 92, 'color': '#4F7CFF'},
            {'subject': 'Physics', 'percentage': 89, 'color': '#10b981'},
            {'subject': 'Chemistry', 'percentage': 89, 'color': '#8B5CF6'},
            {'subject': 'English', 'percentage': 95, 'color': '#f59e0b'},
            {'subject': 'History', 'percentage': 84, 'color': '#ef4444'},
          ],
        },
      ],
    };
  }

  /// Get attendance history
  Future<Map<String, dynamic>> getAttendanceHistory(
    String userUuid, {
    int? semesterId,
  }) async {
    await _delay();

    return {
      'history': [
        {'month': 'Jan', 'percentage': 98},
        {'month': 'Feb', 'percentage': 94},
        {'month': 'Mar', 'percentage': 97},
        {'month': 'Apr', 'percentage': 93},
        {'month': 'May', 'percentage': 95},
        {'month': 'Jun', 'percentage': 96},
      ],
    };
  }

  /// Get student by UUID
  Future<Map<String, dynamic>> getStudentByUuid(String userUuid) async {
    await _delay();

    return {
      'uuid': userUuid,
      'name': 'John Doe',
      'grade': 'Grade 10B',
      'rollNumber': '123',
      'email': 'john.doe@example.com',
    };
  }

  /// Get academic records
  Future<Map<String, dynamic>> getAcademicRecords(String userUuid) async {
    await _delay();

    return {
      'records': [
        {'semester': 'Fall 2023', 'gpa': 3.7, 'rank': 6},
        {'semester': 'Spring 2024', 'gpa': 3.8, 'rank': 5},
      ],
    };
  }

  /// Get attendance
  Future<Map<String, dynamic>> getAttendance(
    String userUuid, {
    String? startDate,
    String? endDate,
  }) async {
    await _delay();

    return {'overall': 96.2, 'present': 145, 'absent': 5, 'total': 150};
  }

  /// Get all students (admin/teacher only)
  Future<Map<String, dynamic>> getAllStudents({
    int page = 1,
    int limit = 10,
  }) async {
    await _delay();

    return {'students': [], 'total': 0, 'page': page, 'limit': limit};
  }
}
