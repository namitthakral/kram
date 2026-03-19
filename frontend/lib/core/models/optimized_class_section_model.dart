/// Optimized Class Section Model
///
/// This model represents the comprehensive class section data returned
/// by the optimized backend endpoint, eliminating the need for multiple API calls.
library;

class OptimizedClassSectionResponse {
  OptimizedClassSectionResponse({
    required this.success,
    required this.data,
    required this.count,
    required this.executionTime,
  });

  factory OptimizedClassSectionResponse.fromJson(Map<String, dynamic> json) =>
      OptimizedClassSectionResponse(
        success: json['success'] ?? false,
        data:
            (json['data'] as List<dynamic>? ?? [])
                .map((item) => OptimizedClassSection.fromJson(item))
                .toList(),
        count: json['count'] ?? 0,
        executionTime: json['executionTime'] ?? 0,
      );
  final bool success;
  final List<OptimizedClassSection> data;
  final int count;
  final int executionTime;

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data.map((item) => item.toJson()).toList(),
    'count': count,
    'executionTime': executionTime,
  };
}

class OptimizedClassSection {
  OptimizedClassSection({
    required this.id,
    required this.sectionName,
    required this.maxCapacity,
    required this.currentEnrollment,
    required this.status,
    required this.subject,
    required this.semester,
    required this.academicYear,
    required this.institution,
    this.roomNumber,
    this.schedule,
    this.course,
    this.teacher,
  });

  factory OptimizedClassSection.fromJson(
    Map<String, dynamic> json,
  ) => OptimizedClassSection(
    id: json['id'] ?? 0,
    sectionName: json['sectionName'] ?? '',
    maxCapacity: json['maxCapacity'] ?? 0,
    currentEnrollment: json['currentEnrollment'] ?? 0,
    roomNumber: json['roomNumber'],
    schedule: json['schedule'] as Map<String, dynamic>?,
    status: json['status'] ?? 'ACTIVE',
    subject: ClassSectionSubject.fromJson(json['subject'] ?? {}),
    course:
        json['course'] != null
            ? ClassSectionCourse.fromJson(json['course'])
            : null,
    semester: ClassSectionSemester.fromJson(json['semester'] ?? {}),
    academicYear: ClassSectionAcademicYear.fromJson(json['academicYear'] ?? {}),
    teacher:
        json['teacher'] != null
            ? ClassSectionTeacher.fromJson(json['teacher'])
            : null,
    institution: ClassSectionInstitution.fromJson(json['institution'] ?? {}),
  );
  final int id;
  final String sectionName;
  final int maxCapacity;
  final int currentEnrollment;
  final String? roomNumber;
  final Map<String, dynamic>? schedule;
  final String status;
  final ClassSectionSubject subject;
  final ClassSectionCourse? course;
  final ClassSectionSemester semester;
  final ClassSectionAcademicYear academicYear;
  final ClassSectionTeacher? teacher;
  final ClassSectionInstitution institution;

  Map<String, dynamic> toJson() => {
    'id': id,
    'sectionName': sectionName,
    'maxCapacity': maxCapacity,
    'currentEnrollment': currentEnrollment,
    'roomNumber': roomNumber,
    'schedule': schedule,
    'status': status,
    'subject': subject.toJson(),
    'course': course?.toJson(),
    'semester': semester.toJson(),
    'academicYear': academicYear.toJson(),
    'teacher': teacher?.toJson(),
    'institution': institution.toJson(),
  };

  // Helper getters
  double get enrollmentPercentage =>
      maxCapacity > 0 ? (currentEnrollment / maxCapacity) * 100 : 0;

  bool get isFullyEnrolled => currentEnrollment >= maxCapacity;

  String get displayName => '${subject.name} - Section $sectionName';

  String get teacherName => teacher?.name ?? 'No Teacher Assigned';
}

class ClassSectionSubject {
  ClassSectionSubject({
    required this.id,
    required this.name,
    this.code,
    this.credits,
    this.type,
  });

  factory ClassSectionSubject.fromJson(Map<String, dynamic> json) =>
      ClassSectionSubject(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        code: json['code'],
        credits: json['credits'],
        type: json['type'],
      );
  final int id;
  final String name;
  final String? code;
  final int? credits;
  final String? type;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'credits': credits,
    'type': type,
  };
}

class ClassSectionCourse {
  ClassSectionCourse({
    required this.id,
    required this.name,
    this.code,
    this.degreeType,
  });

  factory ClassSectionCourse.fromJson(Map<String, dynamic> json) =>
      ClassSectionCourse(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        code: json['code'],
        degreeType: json['degreeType'],
      );
  final int id;
  final String name;
  final String? code;
  final String? degreeType;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'degreeType': degreeType,
  };
}

class ClassSectionSemester {
  ClassSectionSemester({
    required this.id,
    required this.name,
    required this.number,
    required this.status,
    this.startDate,
    this.endDate,
  });

  factory ClassSectionSemester.fromJson(Map<String, dynamic> json) =>
      ClassSectionSemester(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        number: json['number'] ?? 0,
        startDate:
            json['startDate'] != null
                ? DateTime.tryParse(json['startDate'].toString())
                : null,
        endDate:
            json['endDate'] != null
                ? DateTime.tryParse(json['endDate'].toString())
                : null,
        status: json['status'] ?? 'ACTIVE',
      );
  final int id;
  final String name;
  final int number;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'number': number,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'status': status,
  };
}

class ClassSectionAcademicYear {
  ClassSectionAcademicYear({
    required this.id,
    required this.name,
    required this.status,
    this.startDate,
    this.endDate,
  });

  factory ClassSectionAcademicYear.fromJson(Map<String, dynamic> json) =>
      ClassSectionAcademicYear(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        startDate:
            json['startDate'] != null
                ? DateTime.tryParse(json['startDate'].toString())
                : null,
        endDate:
            json['endDate'] != null
                ? DateTime.tryParse(json['endDate'].toString())
                : null,
        status: json['status'] ?? 'CURRENT',
      );
  final int id;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'status': status,
  };
}

class ClassSectionTeacher {
  ClassSectionTeacher({
    required this.id,
    required this.name,
    this.uuid,
    this.email,
  });

  factory ClassSectionTeacher.fromJson(Map<String, dynamic> json) =>
      ClassSectionTeacher(
        id: json['id'] ?? 0,
        uuid: json['uuid'],
        name: json['name'] ?? '',
        email: json['email'],
      );
  final int id;
  final String? uuid;
  final String name;
  final String? email;

  Map<String, dynamic> toJson() => {
    'id': id,
    'uuid': uuid,
    'name': name,
    'email': email,
  };
}

class ClassSectionInstitution {
  ClassSectionInstitution({
    required this.id,
    required this.name,
    this.code,
    this.type,
  });

  factory ClassSectionInstitution.fromJson(Map<String, dynamic> json) =>
      ClassSectionInstitution(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        code: json['code'],
        type: json['type'],
      );
  final int id;
  final String name;
  final String? code;
  final String? type;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'type': type,
  };
}
