class AcademicYear {
  AcademicYear({
    required this.id,
    required this.institutionId,
    required this.yearName,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.createdAt,
  });

  factory AcademicYear.fromJson(Map<String, dynamic> json) => AcademicYear(
        id: json['id'],
        institutionId: json['institutionId'],
        yearName: json['yearName'],
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        status: json['status'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
      );

  final int id;
  final int institutionId;
  final String yearName;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'institutionId': institutionId,
        'yearName': yearName,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': status,
        'createdAt': createdAt?.toIso8601String(),
      };
}
