class FeeStructure {
  FeeStructure({
    required this.id,
    required this.institutionId,
    required this.academicYearId,
    required this.feeType,
    required this.feeName,
    required this.amount,
    required this.isRecurring,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.courseId,
    this.dueDate,
    this.lateFeeAmount,
    this.lateFeeAfterDays,
    this.recurringFrequency,
    this.description,
    this.institution,
    this.course,
    this.academicYear,
    this.studentFeesCount,
  });

  factory FeeStructure.fromJson(Map<String, dynamic> json) => FeeStructure(
    id: _int(json['id']),
    institutionId: _int(json['institutionId'] ?? json['institution_id']),
    courseId: _intOrNull(json['courseId'] ?? json['course_id']),
    academicYearId: _int(json['academicYearId'] ?? json['academic_year_id']),
    feeType:
        (json['feeType'] ?? json['fee_type'] ?? 'MISCELLANEOUS').toString(),
    feeName: (json['feeName'] ?? json['fee_name'] ?? '').toString(),
    amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0,
    dueDate:
        json['dueDate'] != null || json['due_date'] != null
            ? DateTime.tryParse(
              (json['dueDate'] ?? json['due_date'])?.toString() ?? '',
            )
            : null,
    lateFeeAmount:
        json['lateFeeAmount'] != null || json['late_fee_amount'] != null
            ? double.tryParse(
              (json['lateFeeAmount'] ?? json['late_fee_amount'])?.toString() ??
                  '',
            )
            : null,
    lateFeeAfterDays: _intOrNull(
      json['lateFeeAfterDays'] ?? json['late_fee_after_days'],
    ),
    isRecurring: json['isRecurring'] ?? json['is_recurring'] ?? false,
    recurringFrequency:
        (json['recurringFrequency'] ?? json['recurring_frequency'])?.toString(),
    description: json['description']?.toString(),
    status: (json['status'] ?? 'ACTIVE').toString(),
    createdAt:
        DateTime.tryParse(
          (json['createdAt'] ?? json['created_at'])?.toString() ?? '',
        ) ??
        DateTime.now(),
    updatedAt:
        DateTime.tryParse(
          (json['updatedAt'] ?? json['updated_at'])?.toString() ?? '',
        ) ??
        DateTime.now(),
    institution:
        json['institution'] is Map<String, dynamic>
            ? json['institution'] as Map<String, dynamic>
            : null,
    course:
        json['course'] is Map<String, dynamic>
            ? json['course'] as Map<String, dynamic>
            : null,
    academicYear:
        json['academicYear'] is Map<String, dynamic>
            ? json['academicYear'] as Map<String, dynamic>
            : null,
    studentFeesCount: _intOrNull(json['_count']?['studentFees']),
  );
  final int id;
  final int institutionId;
  final int? courseId;
  final int academicYearId;
  final String feeType;
  final String feeName;
  final double amount;
  final DateTime? dueDate;
  final double? lateFeeAmount;
  final int? lateFeeAfterDays;
  final bool isRecurring;
  final String? recurringFrequency;
  final String? description;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? institution;
  final Map<String, dynamic>? course;
  final Map<String, dynamic>? academicYear;
  final int? studentFeesCount;

  static int _int(v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static int? _intOrNull(v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'institutionId': institutionId,
    'courseId': courseId,
    'academicYearId': academicYearId,
    'feeType': feeType,
    'feeName': feeName,
    'amount': amount,
    'dueDate': dueDate?.toIso8601String(),
    'lateFeeAmount': lateFeeAmount,
    'lateFeeAfterDays': lateFeeAfterDays,
    'isRecurring': isRecurring,
    'recurringFrequency': recurringFrequency,
    'description': description,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'institution': institution,
    'course': course,
    'academicYear': academicYear,
  };
}
