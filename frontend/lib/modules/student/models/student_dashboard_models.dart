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
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.status,
    required this.type,
    this.grade,
    this.score,
    this.description,
    this.instructions,
  });

  final int id;
  final String title;
  final String subject;
  final String dueDate;
  final AssignmentStatus status;
  final AssignmentType type;
  final String? grade;
  final String? score;
  final String? description;
  final String? instructions;
}

enum AssignmentStatus { submitted, graded, pending }

enum AssignmentType { assignment, test, exam }

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

enum EventType { test, assignment, event }

/// Attendance History Data Model
class AttendanceHistory {
  const AttendanceHistory({required this.month, required this.percentage});
  final String month;
  final double percentage;
}

/// Performance Trend Data Model
class PerformanceTrend {
  const PerformanceTrend({required this.month, required this.subjects});
  final String month;
  final Map<String, double> subjects;
}

class StudentExamination {
  const StudentExamination({
    required this.id,
    required this.name,
    required this.subject,
    required this.date,
    required this.startTime,
    required this.duration,
    required this.totalMarks,
    required this.status,
    this.score,
    this.grade,
  });

  factory StudentExamination.fromJson(Map<String, dynamic> json) =>
      StudentExamination(
        id: json['id'] as int,
        name: json['name'] as String,
        subject: json['subject'] as String,
        date: json['date'] as String,
        startTime: json['startTime'] as String?,
        duration: json['duration'] as int?,
        totalMarks: json['totalMarks'] as int,
        status: json['status'] as String,
        score: json['score'] as String?,
        grade: json['grade'] as String?,
      );

  final int id;
  final String name;
  final String subject;
  final String date;
  final String? startTime;
  final int? duration;
  final int totalMarks;
  final String status;
  final String? score;
  final String? grade;
}
