/// Teacher Dashboard Statistics Model
class DashboardStats {
  const DashboardStats({
    required this.totalStudents,
    required this.presentToday,
    required this.absentToday,
    required this.avgAttendance,
  });
  final int totalStudents;
  final int presentToday;
  final int absentToday;
  final double avgAttendance;

  int get activeStudents => totalStudents;
  double get attendancePercentage => presentToday / totalStudents * 100;
}

/// Student Activity Model
class StudentActivity {
  const StudentActivity({
    required this.name,
    required this.initials,
    required this.lastActive,
    required this.grade,
    required this.percentage,
    this.avatarColor = '#4F7CFF',
  });
  final String name;
  final String initials;
  final String lastActive;
  final String grade;
  final double percentage;
  final String avatarColor;
}

/// Subject Performance Model
class SubjectPerformance {
  const SubjectPerformance({required this.subject, required this.percentage});
  final String subject;
  final double percentage;
}

/// Attendance Data Model
class AttendanceData {
  const AttendanceData({
    required this.day,
    required this.present,
    required this.absent,
  });
  final String day;
  final int present;
  final int absent;

  int get total => present + absent;
}

/// Grade Distribution Model
class GradeDistribution {
  const GradeDistribution({
    required this.grade,
    required this.percentage,
    required this.color,
  });
  final String grade;
  final double percentage;
  final String color;
}
