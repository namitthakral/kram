enum AttendanceStatus { present, absent, late, excused }

class StudentAttendance {
  StudentAttendance({
    required this.id,
    required this.name,
    required this.initials,
    this.status = AttendanceStatus.present,
  });
  final String id;
  final String name;
  final String initials;
  AttendanceStatus status;

  StudentAttendance copyWith({
    String? id,
    String? name,
    String? initials,
    AttendanceStatus? status,
  }) => StudentAttendance(
      id: id ?? this.id,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      status: status ?? this.status,
    );
}

class ClassInfo {
  ClassInfo({
    required this.id,
    required this.name,
    required this.totalStudents,
    required this.courseId,
    required this.sectionName,
    this.sectionId,
  });
  final String id;
  final String name;
  final int totalStudents;
  final int courseId;
  final String sectionName;
  final int? sectionId; // The actual ClassSection database ID
}

class AttendanceSummary {
  AttendanceSummary({
    required this.totalStudents,
    required this.present,
    required this.absent,
  });
  final int totalStudents;
  final int present;
  final int absent;

  double get presentPercentage =>
      totalStudents > 0 ? (present / totalStudents) * 100 : 0.0;
}

class GradingSystem {
  GradingSystem({
    required this.id,
    required this.name,
    required this.description,
  });
  final String id;
  final String name;
  final String description;
}
