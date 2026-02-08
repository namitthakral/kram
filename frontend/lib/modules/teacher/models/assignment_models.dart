/// Models for Assignment management
class Assignment {
  Assignment({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.title,
    required this.description,
    required this.maxMarks,
    required this.assignedDate,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.sectionId,
    this.sectionName,
    this.instructions,
    this.referenceCourseId,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) => Assignment(
    id: json['id'] as int,
    courseId: json['subjectId'] as int,
    // Store the actual Course ID (e.g. B.Sc) if available, for edit mode
    referenceCourseId: json['subject']?['courseId'] as int?,
    courseName: json['subject']?['subjectName'] ?? json['courseName'] ?? '',
    sectionId: json['sectionId'] as int?,
    sectionName: json['section']?['sectionName'] ?? json['sectionName'],
    title: json['title'] as String,
    description: json['description'] as String,
    instructions: json['instructions'] as String?,
    maxMarks: json['maxMarks'] as int,
    assignedDate: DateTime.parse(json['assignedDate'] as String),
    dueDate: DateTime.parse(json['dueDate'] as String),
    status: json['status'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
  final int id;
  final int courseId;
  final int? referenceCourseId;
  final String courseName;
  final int? sectionId;
  final String? sectionName;
  final String title;
  final String description;
  final String? instructions;
  final int maxMarks;
  final DateTime assignedDate;
  final DateTime dueDate;
  final String status; // DRAFT, PUBLISHED, CLOSED
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'courseId': courseId,
    'sectionId': sectionId,
    'title': title,
    'description': description,
    'instructions': instructions,
    'maxMarks': maxMarks,
    'assignedDate': assignedDate.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'status': status,
  };
}

class CreateAssignmentDto {
  CreateAssignmentDto({
    required this.subjectId,
    required this.title,
    required this.description,
    required this.maxMarks,
    required this.dueDate,
    this.sectionId,
    this.instructions,
    this.status = 'DRAFT',
  });
  final int subjectId;
  final int? sectionId;
  final String title;
  final String description;
  final String? instructions;
  final int maxMarks;
  final DateTime dueDate;
  final String status;

  Map<String, dynamic> toJson() => {
    'subjectId': subjectId,
    if (sectionId != null) 'sectionId': sectionId,
    'title': title,
    'description': description,
    if (instructions != null) 'instructions': instructions,
    'maxMarks': maxMarks,
    'dueDate': dueDate.toIso8601String(),
    'status': status,
  };
}

class UpdateAssignmentDto {
  UpdateAssignmentDto({
    this.title,
    this.description,
    this.instructions,
    this.maxMarks,
    this.dueDate,
    this.status,
  });
  final String? title;
  final String? description;
  final String? instructions;
  final int? maxMarks;
  final DateTime? dueDate;
  final String? status;

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (instructions != null) 'instructions': instructions,
    if (maxMarks != null) 'maxMarks': maxMarks,
    if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
    if (status != null) 'status': status,
  };
}

// Subject model - represents academic subjects like Mathematics, History, etc.
class Subject {
  Subject({required this.id, required this.name, required this.code});

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
    id: json['id'] as int,
    name: (json['name'] ?? json['subjectName'] ?? 'Unknown Subject') as String,
    code: (json['code'] ?? json['subjectCode'] ?? '') as String,
  );
  final int id;
  final String name;
  final String code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subject && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Class section model - represents a class with subject and section info
class ClassSection {
  ClassSection({
    required this.id,
    required this.subjectId,
    required this.courseId,
    required this.subjectName,
    required this.sectionName,
    required this.displayName,
    this.studentCount = 0,
    this.classTeacherName,
    this.isClassTeacher = false,
  });

  factory ClassSection.fromJson(Map<String, dynamic> json) {
    final sectionName = json['sectionName'] as String;
    final subject = json['subject'] as Map<String, dynamic>?;
    final course = json['course'] as Map<String, dynamic>?;

    // Use nested object if available, otherwise check root level (standard fallback)
    final subjectName =
        subject?['name'] ??
        subject?['subjectName'] ??
        json['subjectName'] ??
        'Unknown Subject';

    // Use nested object if available, otherwise check root level
    final courseName = course?['name'] ?? json['courseName'] ?? '';

    final subjectId = subject?['id'] as int? ?? json['subjectId'] as int? ?? 0;
    final courseId =
        subject?['courseId'] as int? ?? json['courseId'] as int? ?? 0;

    // Format: "B.Sc. CS - A" or "Class 10 - A"
    // User requested Class Name instead of Subject Name
    final displayName =
        (courseName as String).isNotEmpty
            ? '$courseName - $sectionName'
            : sectionName;

    // Backend returns currentEnrollment, not studentCount
    final studentCount =
        json['currentEnrollment'] as int? ?? json['studentCount'] as int? ?? 0;

    return ClassSection(
      id: json['id'] as int,
      subjectId: subjectId,
      courseId: courseId,
      subjectName: subjectName as String,
      sectionName: sectionName,
      displayName: displayName,
      studentCount: studentCount,
      classTeacherName: json['classTeacher'] as String?,
      isClassTeacher: json['isClassTeacher'] as bool? ?? false,
    );
  }

  final int id;
  final int subjectId;
  final int courseId;
  final String subjectName;
  final String sectionName;
  final String displayName;
  final int studentCount;
  final String? classTeacherName;
  final bool isClassTeacher; // True if current teacher is the class teacher
}

// Legacy models for backward compatibility
class Course {
  Course({
    required this.id,
    required this.courseName,
    required this.courseCode,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: (json['id'] ?? json['courseId']) as int,
    // Handle both 'courseName' (old) and 'name' (backend) field names
    courseName:
        (json['courseName'] ?? json['name'] ?? 'Unknown Course') as String,
    // Handle both 'courseCode' (old) and 'code' (backend) field names
    courseCode: (json['courseCode'] ?? json['code'] ?? '') as String,
  );
  final int id;
  final String courseName;
  final String courseCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Section {
  Section({
    required this.id,
    required this.sectionName,
    required this.courseId,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    // Extract courseId from nested structure or direct field
    int courseId;
    if (json['courseId'] != null) {
      // Direct field (old format)
      courseId = json['courseId'] as int;
    } else if (json['subject'] != null) {
      // Nested structure (new format from class-sections API)
      final subject = json['subject'] as Map<String, dynamic>;
      // Use the courseId field from subject instead of nested course.id
      courseId = subject['courseId'] as int;
    } else {
      throw Exception('Unable to extract courseId from Section data');
    }

    final sectionName = (json['sectionName'] ?? 'Unknown Section') as String;
    // Generate a unique fallback ID to prevent dropdown collisions
    final fallbackId =
        (sectionName +
                courseId.toString() +
                DateTime.now().microsecondsSinceEpoch.toString())
            .hashCode;

    return Section(
      id: json['id'] as int? ?? fallbackId,
      sectionName: sectionName,
      courseId: courseId,
    );
  }
  final int id;
  final String sectionName;
  final int courseId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Section && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
