/// Teacher Dashboard Statistics Model
class DashboardStats {
  final int totalStudents;
  final int presentToday;
  final int absentToday;
  final double avgAttendance;

  const DashboardStats({
    required this.totalStudents,
    required this.presentToday,
    required this.absentToday,
    required this.avgAttendance,
  });

  int get activeStudents => totalStudents;
  double get attendancePercentage => presentToday / totalStudents * 100;
}

/// Student Activity Model
class StudentActivity {
  final String name;
  final String initials;
  final String lastActive;
  final String grade;
  final double percentage;
  final String avatarColor;

  const StudentActivity({
    required this.name,
    required this.initials,
    required this.lastActive,
    required this.grade,
    required this.percentage,
    this.avatarColor = '#4F7CFF',
  });
}

/// Subject Performance Model
class SubjectPerformance {
  final String subject;
  final double percentage;

  const SubjectPerformance({
    required this.subject,
    required this.percentage,
  });
}

/// Attendance Data Model
class AttendanceData {
  final String day;
  final int present;
  final int absent;

  const AttendanceData({
    required this.day,
    required this.present,
    required this.absent,
  });

  int get total => present + absent;
}

/// Grade Distribution Model
class GradeDistribution {
  final String grade;
  final double percentage;
  final String color;

  const GradeDistribution({
    required this.grade,
    required this.percentage,
    required this.color,
  });
}
