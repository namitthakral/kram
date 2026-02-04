class StudentMarks {
  StudentMarks({
    required this.id,
    required this.name,
    required this.initials,
    this.marks,
  });

  final String id;
  final String name;
  final String initials;
  double? marks;

  StudentMarks copyWith({
    String? id,
    String? name,
    String? initials,
    double? marks,
  }) => StudentMarks(
    id: id ?? this.id,
    name: name ?? this.name,
    initials: initials ?? this.initials,
    marks: marks ?? this.marks,
  );
}

class SubjectInfo {
  SubjectInfo({required this.id, required this.name});

  final String id;
  final String name;
}

class ExamType {
  ExamType({required this.id, required this.name});

  final String id;
  final String name;
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
    this.semesterId,
  });

  final String id;
  final String name; // Display label (e.g., Subject + Section)
  final int totalStudents;
  final int courseId;
  final String sectionName;
  final int? sectionId; // The actual ClassSection database ID
  final String? subjectName;
  final String? className; // The actual Class Name (e.g. "Class 10")
  final int? semesterId;

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
  int get hashCode => id.hashCode ^
        name.hashCode ^
        totalStudents.hashCode ^
        courseId.hashCode ^
        sectionName.hashCode ^
        sectionId.hashCode ^
        subjectName.hashCode ^
        className.hashCode;
}

class MarksSummary {
  MarksSummary({
    required this.totalStudents,
    required this.entered,
    required this.pending,
    required this.averageMarks,
  });

  final int totalStudents;
  final int entered;
  final int pending;
  final double averageMarks;

  double get completionPercentage =>
      totalStudents > 0 ? (entered / totalStudents) * 100 : 0.0;
}
