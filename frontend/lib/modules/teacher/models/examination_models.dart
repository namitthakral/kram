/// Models for Examination management
class Examination {
  Examination({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.semesterId,
    required this.examName,
    required this.examType,
    required this.totalMarks,
    required this.passingMarks,
    required this.durationMinutes,
    required this.examDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.semesterName,
    this.startTime,
    this.endTime,
    this.venue,
    this.instructions,
  });

  factory Examination.fromJson(Map<String, dynamic> json) => Examination(
    id: json['id'] as int,
    courseId: json['subjectId'] as int,
    courseName: json['subject']?['subjectName'] ?? json['courseName'] ?? '',
    semesterId: json['semesterId'] as int,
    semesterName: json['semester']?['semesterName'] ?? json['semesterName'],
    examName: json['examName'] as String,
    examType: json['examType'] as String,
    totalMarks: json['totalMarks'] as int,
    passingMarks: json['passingMarks'] as int,
    durationMinutes: json['durationMinutes'] as int,
    examDate: DateTime.parse(json['examDate'] as String),
    startTime:
        json['startTime'] != null
            ? DateTime.parse(json['startTime'] as String)
            : null,
    endTime:
        json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
    venue: json['venue'] as String?,
    instructions: json['instructions'] as String?,
    status: json['status'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
  final int id;
  final int courseId;
  final String courseName;
  final int semesterId;
  final String? semesterName;
  final String examName;
  final String examType; // QUIZ, MIDTERM, FINAL, PRACTICAL, OTHER
  final int totalMarks;
  final int passingMarks;
  final int durationMinutes;
  final DateTime examDate;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? venue;
  final String? instructions;
  final String status; // SCHEDULED, ONGOING, COMPLETED, CANCELLED
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'courseId': courseId,
    'semesterId': semesterId,
    'examName': examName,
    'examType': examType,
    'totalMarks': totalMarks,
    'passingMarks': passingMarks,
    'durationMinutes': durationMinutes,
    'examDate': examDate.toIso8601String(),
    if (startTime != null) 'startTime': startTime!.toIso8601String(),
    if (endTime != null) 'endTime': endTime!.toIso8601String(),
    if (venue != null) 'venue': venue,
    if (instructions != null) 'instructions': instructions,
    'status': status,
  };
}

class CreateExaminationDto {
  CreateExaminationDto({
    required this.courseId,
    required this.semesterId,
    required this.examName,
    required this.examType,
    required this.totalMarks,
    required this.passingMarks,
    required this.durationMinutes,
    required this.examDate,
    this.startTime,
    this.endTime,
    this.venue,
    this.instructions,
    this.status = 'SCHEDULED',
  });
  final int courseId;
  final int semesterId;
  final String examName;
  final String examType;
  final int totalMarks;
  final int passingMarks;
  final int durationMinutes;
  final DateTime examDate;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? venue;
  final String? instructions;
  final String status;

  Map<String, dynamic> toJson() => {
    'courseId': courseId,
    'semesterId': semesterId,
    'examName': examName,
    'examType': examType,
    'totalMarks': totalMarks,
    'passingMarks': passingMarks,
    'durationMinutes': durationMinutes,
    'examDate': examDate.toIso8601String(),
    if (startTime != null) 'startTime': startTime!.toIso8601String(),
    if (endTime != null) 'endTime': endTime!.toIso8601String(),
    if (venue != null) 'venue': venue,
    if (instructions != null) 'instructions': instructions,
    'status': status,
  };
}

class UpdateExaminationDto {
  UpdateExaminationDto({
    this.examName,
    this.examType,
    this.totalMarks,
    this.passingMarks,
    this.durationMinutes,
    this.examDate,
    this.startTime,
    this.endTime,
    this.venue,
    this.instructions,
    this.status,
  });
  final String? examName;
  final String? examType;
  final int? totalMarks;
  final int? passingMarks;
  final int? durationMinutes;
  final DateTime? examDate;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? venue;
  final String? instructions;
  final String? status;

  Map<String, dynamic> toJson() => {
    if (examName != null) 'examName': examName,
    if (examType != null) 'examType': examType,
    if (totalMarks != null) 'totalMarks': totalMarks,
    if (passingMarks != null) 'passingMarks': passingMarks,
    if (durationMinutes != null) 'durationMinutes': durationMinutes,
    if (examDate != null) 'examDate': examDate!.toIso8601String(),
    if (startTime != null) 'startTime': startTime!.toIso8601String(),
    if (endTime != null) 'endTime': endTime!.toIso8601String(),
    if (venue != null) 'venue': venue,
    if (instructions != null) 'instructions': instructions,
    if (status != null) 'status': status,
  };
}

class Semester {
  Semester({
    required this.id,
    required this.semesterName,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory Semester.fromJson(Map<String, dynamic> json) => Semester(
    id: json['id'] as int,
    semesterName: json['semesterName'] as String,
    startDate: DateTime.parse(json['startDate'] as String),
    endDate: DateTime.parse(json['endDate'] as String),
    status: json['status'] as String,
  );
  final int id;
  final String semesterName;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
}
