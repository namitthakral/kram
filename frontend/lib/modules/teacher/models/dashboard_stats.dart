/// Teacher Dashboard Statistics Model
class DashboardStats {
  const DashboardStats({
    required this.totalStudents,
    required this.presentToday,
    required this.absentToday,
    required this.avgAttendance,
    this.lateToday = 0,
    this.attendancePercentageToday = 0.0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
    totalStudents: json['totalStudents'] ?? 0,
    presentToday: json['presentToday'] ?? 0,
    absentToday: json['absentToday'] ?? 0,
    lateToday: json['lateToday'] ?? 0,
    attendancePercentageToday: (json['attendancePercentageToday'] ?? 0.0).toDouble(),
    avgAttendance: (json['avgAttendanceThisMonth'] ?? 0.0).toDouble(),
  );

  final int totalStudents;
  final int presentToday;
  final int absentToday;
  final int lateToday;
  final double attendancePercentageToday;
  final double avgAttendance;

  int get activeStudents => totalStudents;
  double get attendancePercentage => totalStudents > 0 ? (presentToday / totalStudents * 100) : 0.0;

  Map<String, dynamic> toJson() => {
    'totalStudents': totalStudents,
    'presentToday': presentToday,
    'absentToday': absentToday,
    'lateToday': lateToday,
    'attendancePercentageToday': attendancePercentageToday,
    'avgAttendanceThisMonth': avgAttendance,
  };
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
    this.id,
    this.firstName,
    this.lastName,
    this.attendancePercentage,
    this.admissionNumber,
    this.rollNumber,
  });

  factory StudentActivity.fromJson(Map<String, dynamic> json) {
    // Generate initials from firstName and lastName or use provided initials
    String initials = '';
    if (json['firstName'] != null && json['lastName'] != null) {
      final firstName = json['firstName'] as String;
      final lastName = json['lastName'] as String;
      initials = '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
    } else if (json['initials'] != null) {
      initials = json['initials'];
    }

    return StudentActivity(
      id: json['id'],
      name: json['name'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      initials: initials,
      lastActive: json['lastActive'] ?? '',
      grade: json['grade'] ?? '',
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      attendancePercentage: json['attendancePercentage'] != null
          ? (json['attendancePercentage'] as num).toDouble()
          : null,
      admissionNumber: json['admissionNumber'],
      rollNumber: json['rollNumber'],
      avatarColor: json['avatarColor'] ?? '#4F7CFF',
    );
  }

  final int? id;
  final String name;
  final String? firstName;
  final String? lastName;
  final String initials;
  final String lastActive;
  final String grade;
  final double percentage;
  final double? attendancePercentage;
  final String? admissionNumber;
  final String? rollNumber;
  final String avatarColor;

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    if (firstName != null) 'firstName': firstName,
    if (lastName != null) 'lastName': lastName,
    'initials': initials,
    'lastActive': lastActive,
    'grade': grade,
    'percentage': percentage,
    if (attendancePercentage != null) 'attendancePercentage': attendancePercentage,
    if (admissionNumber != null) 'admissionNumber': admissionNumber,
    if (rollNumber != null) 'rollNumber': rollNumber,
    'avatarColor': avatarColor,
  };
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
