class Semester {
  Semester({
    required this.id,
    required this.academicYearId,
    required this.semesterName,
    required this.semesterNumber,
    required this.startDate,
    required this.endDate,
    this.registrationStart,
    this.registrationEnd,
    required this.status,
    this.createdAt,
  });

  factory Semester.fromJson(Map<String, dynamic> json) => Semester(
        id: json['id'],
        academicYearId: json['academicYearId'],
        semesterName: json['semesterName'],
        semesterNumber: json['semesterNumber'],
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        registrationStart: json['registrationStart'] != null
            ? DateTime.parse(json['registrationStart'])
            : null,
        registrationEnd: json['registrationEnd'] != null
            ? DateTime.parse(json['registrationEnd'])
            : null,
        status: json['status'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
      );

  final int id;
  final int academicYearId;
  final String semesterName;
  final int semesterNumber;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? registrationStart;
  final DateTime? registrationEnd;
  final String status;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'academicYearId': academicYearId,
        'semesterName': semesterName,
        'semesterNumber': semesterNumber,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'registrationStart': registrationStart?.toIso8601String(),
        'registrationEnd': registrationEnd?.toIso8601String(),
        'status': status,
        'createdAt': createdAt?.toIso8601String(),
      };
}
