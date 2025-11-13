class GradingConfig {
  final int id;
  final int institutionId;

  // Grading Formula Weights
  final double attendanceWeight;
  final double assignmentWeight;
  final double examWeight;
  final double participationWeight;

  // Grade Boundaries
  final double gradeAPlusThreshold;
  final double gradeAThreshold;
  final double gradeBPlusThreshold;
  final double gradeBThreshold;
  final double gradeCThreshold;

  // Grade Points Mapping
  final double gradeAPlusPoints;
  final double gradeAPoints;
  final double gradeBPlusPoints;
  final double gradeBPoints;
  final double gradeCPoints;
  final double gradeDPoints;

  // Risk Status Thresholds
  final double atRiskAttendance;
  final double atRiskAssignment;
  final double atRiskExam;
  final double atRiskGradePoints;

  final double needsImprovementAttendance;
  final double needsImprovementAssignment;
  final double needsImprovementExam;
  final double needsImprovementGradePoints;

  final double excellentAttendance;
  final double excellentAssignment;
  final double excellentExam;
  final double excellentGradePoints;

  final double goodAttendance;
  final double goodAssignment;
  final double goodExam;
  final double goodGradePoints;

  // Metadata
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  GradingConfig({
    required this.id,
    required this.institutionId,
    required this.attendanceWeight,
    required this.assignmentWeight,
    required this.examWeight,
    required this.participationWeight,
    required this.gradeAPlusThreshold,
    required this.gradeAThreshold,
    required this.gradeBPlusThreshold,
    required this.gradeBThreshold,
    required this.gradeCThreshold,
    required this.gradeAPlusPoints,
    required this.gradeAPoints,
    required this.gradeBPlusPoints,
    required this.gradeBPoints,
    required this.gradeCPoints,
    required this.gradeDPoints,
    required this.atRiskAttendance,
    required this.atRiskAssignment,
    required this.atRiskExam,
    required this.atRiskGradePoints,
    required this.needsImprovementAttendance,
    required this.needsImprovementAssignment,
    required this.needsImprovementExam,
    required this.needsImprovementGradePoints,
    required this.excellentAttendance,
    required this.excellentAssignment,
    required this.excellentExam,
    required this.excellentGradePoints,
    required this.goodAttendance,
    required this.goodAssignment,
    required this.goodExam,
    required this.goodGradePoints,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GradingConfig.fromJson(Map<String, dynamic> json) {
    return GradingConfig(
      id: json['id'] as int,
      institutionId: json['institutionId'] as int,
      attendanceWeight: _parseDouble(json['attendanceWeight']),
      assignmentWeight: _parseDouble(json['assignmentWeight']),
      examWeight: _parseDouble(json['examWeight']),
      participationWeight: _parseDouble(json['participationWeight']),
      gradeAPlusThreshold: _parseDouble(json['gradeAPlusThreshold']),
      gradeAThreshold: _parseDouble(json['gradeAThreshold']),
      gradeBPlusThreshold: _parseDouble(json['gradeBPlusThreshold']),
      gradeBThreshold: _parseDouble(json['gradeBThreshold']),
      gradeCThreshold: _parseDouble(json['gradeCThreshold']),
      gradeAPlusPoints: _parseDouble(json['gradeAPlusPoints']),
      gradeAPoints: _parseDouble(json['gradeAPoints']),
      gradeBPlusPoints: _parseDouble(json['gradeBPlusPoints']),
      gradeBPoints: _parseDouble(json['gradeBPoints']),
      gradeCPoints: _parseDouble(json['gradeCPoints']),
      gradeDPoints: _parseDouble(json['gradeDPoints']),
      atRiskAttendance: _parseDouble(json['atRiskAttendance']),
      atRiskAssignment: _parseDouble(json['atRiskAssignment']),
      atRiskExam: _parseDouble(json['atRiskExam']),
      atRiskGradePoints: _parseDouble(json['atRiskGradePoints']),
      needsImprovementAttendance:
          _parseDouble(json['needsImprovementAttendance']),
      needsImprovementAssignment:
          _parseDouble(json['needsImprovementAssignment']),
      needsImprovementExam: _parseDouble(json['needsImprovementExam']),
      needsImprovementGradePoints:
          _parseDouble(json['needsImprovementGradePoints']),
      excellentAttendance: _parseDouble(json['excellentAttendance']),
      excellentAssignment: _parseDouble(json['excellentAssignment']),
      excellentExam: _parseDouble(json['excellentExam']),
      excellentGradePoints: _parseDouble(json['excellentGradePoints']),
      goodAttendance: _parseDouble(json['goodAttendance']),
      goodAssignment: _parseDouble(json['goodAssignment']),
      goodExam: _parseDouble(json['goodExam']),
      goodGradePoints: _parseDouble(json['goodGradePoints']),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Default configuration
  factory GradingConfig.defaults(int institutionId) {
    final now = DateTime.now();
    return GradingConfig(
      id: 0,
      institutionId: institutionId,
      attendanceWeight: 10,
      assignmentWeight: 30,
      examWeight: 50,
      participationWeight: 10,
      gradeAPlusThreshold: 93,
      gradeAThreshold: 85,
      gradeBPlusThreshold: 77,
      gradeBThreshold: 70,
      gradeCThreshold: 60,
      gradeAPlusPoints: 4.0,
      gradeAPoints: 3.7,
      gradeBPlusPoints: 3.3,
      gradeBPoints: 3.0,
      gradeCPoints: 2.0,
      gradeDPoints: 1.0,
      atRiskAttendance: 75,
      atRiskAssignment: 60,
      atRiskExam: 60,
      atRiskGradePoints: 2.0,
      needsImprovementAttendance: 85,
      needsImprovementAssignment: 70,
      needsImprovementExam: 70,
      needsImprovementGradePoints: 3.0,
      excellentAttendance: 95,
      excellentAssignment: 90,
      excellentExam: 90,
      excellentGradePoints: 3.7,
      goodAttendance: 90,
      goodAssignment: 80,
      goodExam: 80,
      goodGradePoints: 3.3,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }
}

class UpdateGradingConfigDto {
  final double? attendanceWeight;
  final double? assignmentWeight;
  final double? examWeight;
  final double? participationWeight;
  final double? gradeAPlusThreshold;
  final double? gradeAThreshold;
  final double? gradeBPlusThreshold;
  final double? gradeBThreshold;
  final double? gradeCThreshold;
  final double? gradeAPlusPoints;
  final double? gradeAPoints;
  final double? gradeBPlusPoints;
  final double? gradeBPoints;
  final double? gradeCPoints;
  final double? gradeDPoints;
  final double? atRiskAttendance;
  final double? atRiskAssignment;
  final double? atRiskExam;
  final double? atRiskGradePoints;
  final double? needsImprovementAttendance;
  final double? needsImprovementAssignment;
  final double? needsImprovementExam;
  final double? needsImprovementGradePoints;
  final double? excellentAttendance;
  final double? excellentAssignment;
  final double? excellentExam;
  final double? excellentGradePoints;
  final double? goodAttendance;
  final double? goodAssignment;
  final double? goodExam;
  final double? goodGradePoints;
  final bool? isActive;

  UpdateGradingConfigDto({
    this.attendanceWeight,
    this.assignmentWeight,
    this.examWeight,
    this.participationWeight,
    this.gradeAPlusThreshold,
    this.gradeAThreshold,
    this.gradeBPlusThreshold,
    this.gradeBThreshold,
    this.gradeCThreshold,
    this.gradeAPlusPoints,
    this.gradeAPoints,
    this.gradeBPlusPoints,
    this.gradeBPoints,
    this.gradeCPoints,
    this.gradeDPoints,
    this.atRiskAttendance,
    this.atRiskAssignment,
    this.atRiskExam,
    this.atRiskGradePoints,
    this.needsImprovementAttendance,
    this.needsImprovementAssignment,
    this.needsImprovementExam,
    this.needsImprovementGradePoints,
    this.excellentAttendance,
    this.excellentAssignment,
    this.excellentExam,
    this.excellentGradePoints,
    this.goodAttendance,
    this.goodAssignment,
    this.goodExam,
    this.goodGradePoints,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (attendanceWeight != null) map['attendanceWeight'] = attendanceWeight;
    if (assignmentWeight != null) map['assignmentWeight'] = assignmentWeight;
    if (examWeight != null) map['examWeight'] = examWeight;
    if (participationWeight != null) {
      map['participationWeight'] = participationWeight;
    }
    if (gradeAPlusThreshold != null) {
      map['gradeAPlusThreshold'] = gradeAPlusThreshold;
    }
    if (gradeAThreshold != null) map['gradeAThreshold'] = gradeAThreshold;
    if (gradeBPlusThreshold != null) {
      map['gradeBPlusThreshold'] = gradeBPlusThreshold;
    }
    if (gradeBThreshold != null) map['gradeBThreshold'] = gradeBThreshold;
    if (gradeCThreshold != null) map['gradeCThreshold'] = gradeCThreshold;
    if (gradeAPlusPoints != null) map['gradeAPlusPoints'] = gradeAPlusPoints;
    if (gradeAPoints != null) map['gradeAPoints'] = gradeAPoints;
    if (gradeBPlusPoints != null) map['gradeBPlusPoints'] = gradeBPlusPoints;
    if (gradeBPoints != null) map['gradeBPoints'] = gradeBPoints;
    if (gradeCPoints != null) map['gradeCPoints'] = gradeCPoints;
    if (gradeDPoints != null) map['gradeDPoints'] = gradeDPoints;
    if (atRiskAttendance != null) map['atRiskAttendance'] = atRiskAttendance;
    if (atRiskAssignment != null) map['atRiskAssignment'] = atRiskAssignment;
    if (atRiskExam != null) map['atRiskExam'] = atRiskExam;
    if (atRiskGradePoints != null) {
      map['atRiskGradePoints'] = atRiskGradePoints;
    }
    if (needsImprovementAttendance != null) {
      map['needsImprovementAttendance'] = needsImprovementAttendance;
    }
    if (needsImprovementAssignment != null) {
      map['needsImprovementAssignment'] = needsImprovementAssignment;
    }
    if (needsImprovementExam != null) {
      map['needsImprovementExam'] = needsImprovementExam;
    }
    if (needsImprovementGradePoints != null) {
      map['needsImprovementGradePoints'] = needsImprovementGradePoints;
    }
    if (excellentAttendance != null) {
      map['excellentAttendance'] = excellentAttendance;
    }
    if (excellentAssignment != null) {
      map['excellentAssignment'] = excellentAssignment;
    }
    if (excellentExam != null) map['excellentExam'] = excellentExam;
    if (excellentGradePoints != null) {
      map['excellentGradePoints'] = excellentGradePoints;
    }
    if (goodAttendance != null) map['goodAttendance'] = goodAttendance;
    if (goodAssignment != null) map['goodAssignment'] = goodAssignment;
    if (goodExam != null) map['goodExam'] = goodExam;
    if (goodGradePoints != null) map['goodGradePoints'] = goodGradePoints;
    if (isActive != null) map['isActive'] = isActive;
    return map;
  }
}

