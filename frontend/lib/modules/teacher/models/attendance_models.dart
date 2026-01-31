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
    this.subjectName,
    this.className,
  });
  final String id;
  final String
  name; // This is often used as a display label (e.g., Subject + Section)
  final int totalStudents;
  final int courseId;
  final String sectionName;
  final int? sectionId; // The actual ClassSection database ID


  final String? subjectName;
  final String? className; // The actual Class Name (e.g. "Class 10", "Grade 5")

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ClassInfo &&
        other.id == id &&
        other.name == name &&
        other.totalStudents == totalStudents &&
        other.courseId == courseId &&
        other.sectionName == sectionName &&
        other.sectionId == sectionId &&
        other.subjectName == subjectName &&
        other.className == className;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        totalStudents.hashCode ^
        courseId.hashCode ^
        sectionName.hashCode ^
        sectionId.hashCode ^
        subjectName.hashCode ^
        className.hashCode;
  }
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
