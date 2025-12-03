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
  }) =>
      StudentMarks(
        id: id ?? this.id,
        name: name ?? this.name,
        initials: initials ?? this.initials,
        marks: marks ?? this.marks,
      );
}

class SubjectInfo {
  SubjectInfo({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}

class ExamType {
  ExamType({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}

class ClassInfo {
  ClassInfo({
    required this.id,
    required this.name,
    required this.totalStudents,
  });

  final String id;
  final String name;
  final int totalStudents;
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
