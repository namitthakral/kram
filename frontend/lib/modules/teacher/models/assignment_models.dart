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
  });

  factory Assignment.fromJson(Map<String, dynamic> json) => Assignment(
    id: json['id'] as int,
    courseId: json['subjectId'] as int,
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
    required this.courseId,
    required this.title,
    required this.description,
    required this.maxMarks,
    required this.assignedDate,
    required this.dueDate,
    this.sectionId,
    this.instructions,
    this.status = 'DRAFT',
  });
  final int courseId;
  final int? sectionId;
  final String title;
  final String description;
  final String? instructions;
  final int maxMarks;
  final DateTime assignedDate;
  final DateTime dueDate;
  final String status;

  Map<String, dynamic> toJson() => {
    'courseId': courseId,
    if (sectionId != null) 'sectionId': sectionId,
    'title': title,
    'description': description,
    if (instructions != null) 'instructions': instructions,
    'maxMarks': maxMarks,
    'assignedDate': assignedDate.toIso8601String(),
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
    this.assignedDate,
    this.dueDate,
    this.status,
  });
  final String? title;
  final String? description;
  final String? instructions;
  final int? maxMarks;
  final DateTime? assignedDate;
  final DateTime? dueDate;
  final String? status;

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (instructions != null) 'instructions': instructions,
    if (maxMarks != null) 'maxMarks': maxMarks,
    if (assignedDate != null) 'assignedDate': assignedDate!.toIso8601String(),
    if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
    if (status != null) 'status': status,
  };
}

class Course {
  Course({
    required this.id,
    required this.courseName,
    required this.courseCode,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json['id'] as int,
    courseName: json['courseName'] as String,
    courseCode: json['courseCode'] as String,
  );
  final int id;
  final String courseName;
  final String courseCode;
}

class Section {
  Section({
    required this.id,
    required this.sectionName,
    required this.courseId,
  });

  factory Section.fromJson(Map<String, dynamic> json) => Section(
    id: json['id'] as int,
    sectionName: json['sectionName'] as String,
    courseId: json['courseId'] as int,
  );
  final int id;
  final String sectionName;
  final int courseId;
}
