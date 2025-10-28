/// Student Dashboard Statistics Model
class StudentDashboardStats {
  const StudentDashboardStats({
    required this.currentGpa,
    required this.maxGpa,
    required this.gpaChange,
    required this.attendance,
    required this.attendanceChange,
    required this.classRank,
    required this.totalStudents,
    required this.rankChange,
    required this.assignmentsDue,
  });
  final double currentGpa;
  final double maxGpa;
  final double gpaChange;
  final double attendance;
  final double attendanceChange;
  final int classRank;
  final int totalStudents;
  final int rankChange;
  final int assignmentsDue;
}

/// Subject Performance Model for Student
class SubjectPerformance {
  const SubjectPerformance({
    required this.subject,
    required this.teacher,
    required this.nextTest,
    required this.grade,
    required this.percentage,
    required this.color,
  });
  final String subject;
  final String teacher;
  final String nextTest;
  final String grade;
  final double percentage;
  final String color;
}

/// Assignment Model
class Assignment {
  const Assignment({
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.status,
    this.grade,
    this.score,
  });
  final String title;
  final String subject;
  final String dueDate;
  final AssignmentStatus status;
  final String? grade;
  final String? score;
}

enum AssignmentStatus {
  submitted,
  graded,
  pending,
}

/// Upcoming Event Model
class UpcomingEvent {
  const UpcomingEvent({
    required this.title,
    required this.date,
    required this.time,
    required this.type,
  });
  final String title;
  final String date;
  final String time;
  final EventType type;
}

enum EventType {
  test,
  assignment,
  event,
}

/// Attendance History Data Model
class AttendanceHistory {
  const AttendanceHistory({
    required this.month,
    required this.percentage,
  });
  final String month;
  final double percentage;
}

/// Performance Trend Data Model
class PerformanceTrend {
  const PerformanceTrend({
    required this.month,
    required this.subjects,
  });
  final String month;
  final Map<String, double> subjects;
}
