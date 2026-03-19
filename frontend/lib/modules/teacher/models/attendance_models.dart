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

class CourseInfo {
  CourseInfo({
    required this.id,
    required this.name,
    required this.code,
    required this.totalStudents,
    required this.sections,
  });
  
  final int id;
  final String name; // e.g., "Class 10", "Grade 5", "B.Sc. Computer Science"
  final String code; // e.g., "CLS10", "GRD5", "BSC_CS"
  final int totalStudents; // Total across all sections
  final List<SectionInfo> sections; // Available sections

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourseInfo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class SectionInfo {
  SectionInfo({
    required this.name,
    required this.studentCount,
    this.classTeacher,
  });
  
  final String name; // e.g., "A", "B", "C"
  final int studentCount;
  final String? classTeacher;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SectionInfo && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
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
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      totalStudents.hashCode ^
      courseId.hashCode ^
      sectionName.hashCode ^
      sectionId.hashCode ^
      subjectName.hashCode ^
      className.hashCode;
}

class AttendanceSummary {
  AttendanceSummary({
    required this.totalStudents,
    required this.present,
    required this.absent,
    required this.late,
  });
  final int totalStudents;
  final int present;
  final int absent;
  final int late;

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

/// Model for attendance records returned by class-level attendance API
class AttendanceRecord {
  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.date,
    required this.status,
    required this.studentName,
    required this.sectionName,
    this.admissionNumber,
    this.subjectName,
    this.remarks,
    this.markedAt,
  });

  final int id;
  final int studentId;
  final DateTime date;
  final String status; // 'PRESENT', 'ABSENT', 'LATE', 'EXCUSED'
  final String studentName;
  final String sectionName;
  final String? admissionNumber;
  final String? subjectName;
  final String? remarks;
  final DateTime? markedAt;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    final student = json['student'] as Map<String, dynamic>?;
    final user = student?['user'] as Map<String, dynamic>?;
    final section = json['section'] as Map<String, dynamic>?;
    final subject = section?['subject'] as Map<String, dynamic>?;

    final firstName = user?['firstName'] as String? ?? '';
    final lastName = user?['lastName'] as String? ?? '';
    final fullName = '$firstName $lastName'.trim();

    return AttendanceRecord(
      id: json['id'] as int,
      studentId: json['studentId'] as int,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      studentName: fullName.isEmpty ? 'Unknown Student' : fullName,
      sectionName: section?['sectionName'] as String? ?? 'Unknown Section',
      admissionNumber: student?['admissionNumber'] as String?,
      subjectName: subject?['subjectName'] as String?,
      remarks: json['remarks'] as String?,
      markedAt: json['markedAt'] != null 
          ? DateTime.parse(json['markedAt'] as String)
          : null,
    );
  }

  /// Get display status with icon
  String get displayStatus {
    switch (status.toUpperCase()) {
      case 'PRESENT':
        return '✅ Present';
      case 'ABSENT':
        return '❌ Absent';
      case 'LATE':
        return '⏰ Late';
      case 'EXCUSED':
        return '📋 Excused';
      default:
        return '❓ $status';
    }
  }

  /// Get status color
  String get statusColor {
    switch (status.toUpperCase()) {
      case 'PRESENT':
        return '#22c55e'; // Green
      case 'ABSENT':
        return '#ef4444'; // Red
      case 'LATE':
        return '#f59e0b'; // Amber
      case 'EXCUSED':
        return '#3b82f6'; // Blue
      default:
        return '#6b7280'; // Gray
    }
  }
}
