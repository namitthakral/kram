class ExaminationScheduleItem {
  ExaminationScheduleItem({
    required this.id,
    required this.examName,
    required this.examType,
    required this.examDate,
    required this.startTime,
    required this.durationMinutes,
    required this.totalMarks,
    required this.venue,
    required this.status,
    required this.subject,
    required this.semester,
    required this.creator,
    required this.statistics,
  });

  factory ExaminationScheduleItem.fromJson(Map<String, dynamic> json) =>
      ExaminationScheduleItem(
        id: json['id'] as int? ?? 0,
        examName: json['examName']?.toString() ?? '',
        examType: json['examType']?.toString() ?? '',
        examDate:
            json['examDate'] != null
                ? DateTime.parse(json['examDate'].toString())
                : DateTime.now(),
        startTime: json['startTime']?.toString(),
        durationMinutes: json['durationMinutes'] as int?,
        totalMarks: json['totalMarks'] as int? ?? 0,
        venue: json['venue']?.toString(),
        status: json['status']?.toString() ?? '',
        subject: ExamSubjectInfo.fromJson(json['subject'] ?? {}),
        semester: ExamSemesterInfo.fromJson(json['semester'] ?? {}),
        creator: ExamCreatorInfo.fromJson(json['creator'] ?? {}),
        statistics: ExamStatistics.fromJson(json['statistics'] ?? {}),
      );

  final int id;
  final String examName;
  final String examType;
  final DateTime examDate;
  final String? startTime;
  final int? durationMinutes;
  final int totalMarks;
  final String? venue;
  final String status;
  final ExamSubjectInfo subject;
  final ExamSemesterInfo semester;
  final ExamCreatorInfo creator;
  final ExamStatistics statistics;
}

class ExamSubjectInfo {
  ExamSubjectInfo({
    required this.id,
    required this.subjectName,
    required this.subjectCode,
  });

  factory ExamSubjectInfo.fromJson(Map<String, dynamic> json) =>
      ExamSubjectInfo(
        id: json['id'] as int? ?? 0,
        subjectName: json['subjectName']?.toString() ?? '',
        subjectCode: json['subjectCode']?.toString() ?? '',
      );

  final int id;
  final String subjectName;
  final String subjectCode;
}

class ExamSemesterInfo {
  ExamSemesterInfo({
    required this.id,
    required this.semesterName,
    required this.academicYear,
  });

  factory ExamSemesterInfo.fromJson(Map<String, dynamic> json) =>
      ExamSemesterInfo(
        id: json['id'] as int? ?? 0,
        semesterName: json['semesterName']?.toString() ?? '',
        academicYear:
            json['academicYear'] != null
                ? ExamAcademicYearInfo.fromJson(json['academicYear'])
                : ExamAcademicYearInfo(yearName: ''),
      );

  final int id;
  final String semesterName;
  final ExamAcademicYearInfo academicYear;
}

class ExamAcademicYearInfo {
  ExamAcademicYearInfo({required this.yearName});

  factory ExamAcademicYearInfo.fromJson(Map<String, dynamic> json) =>
      ExamAcademicYearInfo(yearName: json['yearName']?.toString() ?? '');

  final String yearName;
}

class ExamCreatorInfo {
  ExamCreatorInfo({required this.id, required this.name, required this.email});

  factory ExamCreatorInfo.fromJson(Map<String, dynamic> json) =>
      ExamCreatorInfo(
        id: json['id'] as int? ?? 0,
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
      );

  final int id;
  final String name;
  final String email;
}

class ExamStatistics {
  ExamStatistics({
    required this.totalStudents,
    required this.completedEvaluations,
    required this.pendingEvaluations,
    required this.absentStudents,
    required this.completionPercentage,
  });

  factory ExamStatistics.fromJson(Map<String, dynamic> json) => ExamStatistics(
    totalStudents: json['totalStudents'] as int? ?? 0,
    completedEvaluations: json['completedEvaluations'] as int? ?? 0,
    pendingEvaluations: json['pendingEvaluations'] as int? ?? 0,
    absentStudents: json['absentStudents'] as int? ?? 0,
    completionPercentage: json['completionPercentage'] as int? ?? 0,
  );

  final int totalStudents;
  final int completedEvaluations;
  final int pendingEvaluations;
  final int absentStudents;
  final int completionPercentage;
}

class ExaminationScheduleResponse {
  ExaminationScheduleResponse({
    required this.examinations,
    required this.pagination,
  });

  factory ExaminationScheduleResponse.fromJson(Map<String, dynamic> json) =>
      ExaminationScheduleResponse(
        examinations:
            ((json['examinations'] ?? []) as List<dynamic>)
                .map((item) => ExaminationScheduleItem.fromJson(item))
                .toList(),
        pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
      );

  final List<ExaminationScheduleItem> examinations;
  final PaginationInfo pagination;
}

class PaginationInfo {
  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) => PaginationInfo(
    page: json['page'] as int? ?? 1,
    limit: json['limit'] as int? ?? 10,
    total: json['total'] as int? ?? 0,
    totalPages: json['totalPages'] as int? ?? 0,
  );

  final int page;
  final int limit;
  final int total;
  final int totalPages;
}

class ExaminationCompletionStats {
  ExaminationCompletionStats({
    required this.overview,
    required this.examTypeDistribution,
    required this.recentActivity,
  });

  factory ExaminationCompletionStats.fromJson(Map<String, dynamic> json) =>
      ExaminationCompletionStats(
        overview: CompletionOverview.fromJson(json['overview'] ?? {}),
        examTypeDistribution:
            ((json['examTypeDistribution'] ?? []) as List<dynamic>)
                .map((item) => ExamTypeDistribution.fromJson(item))
                .toList(),
        recentActivity:
            ((json['recentActivity'] ?? []) as List<dynamic>)
                .map((item) => RecentExamActivity.fromJson(item))
                .toList(),
      );

  final CompletionOverview overview;
  final List<ExamTypeDistribution> examTypeDistribution;
  final List<RecentExamActivity> recentActivity;
}

class CompletionOverview {
  CompletionOverview({
    required this.totalExams,
    required this.scheduledExams,
    required this.ongoingExams,
    required this.completedExams,
    required this.cancelledExams,
    required this.upcomingExams,
    required this.overdueEvaluations,
  });

  factory CompletionOverview.fromJson(Map<String, dynamic> json) =>
      CompletionOverview(
        totalExams: json['totalExams'] as int? ?? 0,
        scheduledExams: json['scheduledExams'] as int? ?? 0,
        ongoingExams: json['ongoingExams'] as int? ?? 0,
        completedExams: json['completedExams'] as int? ?? 0,
        cancelledExams: json['cancelledExams'] as int? ?? 0,
        upcomingExams: json['upcomingExams'] as int? ?? 0,
        overdueEvaluations: json['overdueEvaluations'] as int? ?? 0,
      );

  final int totalExams;
  final int scheduledExams;
  final int ongoingExams;
  final int completedExams;
  final int cancelledExams;
  final int upcomingExams;
  final int overdueEvaluations;
}

class ExamTypeDistribution {
  ExamTypeDistribution({required this.examType, required this.count});

  factory ExamTypeDistribution.fromJson(Map<String, dynamic> json) =>
      ExamTypeDistribution(
        examType: json['examType']?.toString() ?? '',
        count: json['count'] as int? ?? 0,
      );

  final String examType;
  final int count;
}

class RecentExamActivity {
  RecentExamActivity({
    required this.id,
    required this.examName,
    required this.examType,
    required this.subject,
    required this.creator,
    required this.status,
    required this.examDate,
    required this.updatedAt,
  });

  factory RecentExamActivity.fromJson(Map<String, dynamic> json) =>
      RecentExamActivity(
        id: json['id'] as int? ?? 0,
        examName: json['examName']?.toString() ?? '',
        examType: json['examType']?.toString() ?? '',
        subject: json['subject']?.toString() ?? '',
        creator: json['creator']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        examDate:
            json['examDate'] != null
                ? DateTime.parse(json['examDate'].toString())
                : DateTime.now(),
        updatedAt:
            json['updatedAt'] != null
                ? DateTime.parse(json['updatedAt'].toString())
                : DateTime.now(),
      );

  final int id;
  final String examName;
  final String examType;
  final String subject;
  final String creator;
  final String status;
  final DateTime examDate;
  final DateTime updatedAt;
}

class ExaminationPolicy {
  ExaminationPolicy({
    required this.id,
    required this.institutionId,
    required this.minAdvanceNoticeDays,
    required this.maxExamDurationMinutes,
    required this.maxExamsPerDay,
    required this.minGapBetweenExamsDays,
    required this.maxEvaluationDays,
    required this.requireEvaluatorApproval,
    required this.allowSelfEvaluation,
    required this.requireDoubleEvaluation,
    required this.resultPublicationDelayDays,
    required this.requireAdminApprovalForPublication,
    required this.allowResultModification,
    required this.resultModificationWindowDays,
    required this.defaultPassingPercentage,
    required this.enforceGradingScale,
    required this.allowGradeInflation,
    required this.minAttendanceForExam,
    required this.allowMakeupExams,
    required this.makeupExamWindowDays,
    required this.makeupExamPenaltyPercentage,
    required this.requireProctoring,
    required this.allowOpenBook,
    required this.requirePlagiarismCheck,
    required this.examConductGuidelines,
    required this.notifyStudentsOnSchedule,
    required this.notifyParentsOnResults,
    required this.sendReminderNotifications,
    required this.reminderDaysBeforeExam,
    required this.isActive,
    required this.notes,
  });

  factory ExaminationPolicy.fromJson(
    Map<String, dynamic> json,
  ) => ExaminationPolicy(
    id: json['id'] as int? ?? 0,
    institutionId: json['institutionId'] as int? ?? 0,
    minAdvanceNoticeDays: json['minAdvanceNoticeDays'] as int?,
    maxExamDurationMinutes: json['maxExamDurationMinutes'] as int?,
    maxExamsPerDay: json['maxExamsPerDay'] as int?,
    minGapBetweenExamsDays: json['minGapBetweenExamsDays'] as int?,
    maxEvaluationDays: json['maxEvaluationDays'] as int?,
    requireEvaluatorApproval: json['requireEvaluatorApproval'] as bool?,
    allowSelfEvaluation: json['allowSelfEvaluation'] as bool?,
    requireDoubleEvaluation: json['requireDoubleEvaluation'] as bool?,
    resultPublicationDelayDays: json['resultPublicationDelayDays'] as int?,
    requireAdminApprovalForPublication:
        json['requireAdminApprovalForPublication'] as bool?,
    allowResultModification: json['allowResultModification'] as bool?,
    resultModificationWindowDays: json['resultModificationWindowDays'] as int?,
    defaultPassingPercentage: _parseDouble(json['defaultPassingPercentage']),
    enforceGradingScale: json['enforceGradingScale'] as bool?,
    allowGradeInflation: json['allowGradeInflation'] as bool?,
    minAttendanceForExam: _parseDouble(json['minAttendanceForExam']),
    allowMakeupExams: json['allowMakeupExams'] as bool?,
    makeupExamWindowDays: json['makeupExamWindowDays'] as int?,
    makeupExamPenaltyPercentage: _parseDouble(
      json['makeupExamPenaltyPercentage'],
    ),
    requireProctoring: json['requireProctoring'] as bool?,
    allowOpenBook: json['allowOpenBook'] as bool?,
    requirePlagiarismCheck: json['requirePlagiarismCheck'] as bool?,
    examConductGuidelines: json['examConductGuidelines']?.toString(),
    notifyStudentsOnSchedule: json['notifyStudentsOnSchedule'] as bool?,
    notifyParentsOnResults: json['notifyParentsOnResults'] as bool?,
    sendReminderNotifications: json['sendReminderNotifications'] as bool?,
    reminderDaysBeforeExam: json['reminderDaysBeforeExam'] as int?,
    isActive: json['isActive'] as bool? ?? true,
    notes: json['notes']?.toString(),
  );

  static double? _parseDouble(value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  final int id;
  final int institutionId;
  final int? minAdvanceNoticeDays;
  final int? maxExamDurationMinutes;
  final int? maxExamsPerDay;
  final int? minGapBetweenExamsDays;
  final int? maxEvaluationDays;
  final bool? requireEvaluatorApproval;
  final bool? allowSelfEvaluation;
  final bool? requireDoubleEvaluation;
  final int? resultPublicationDelayDays;
  final bool? requireAdminApprovalForPublication;
  final bool? allowResultModification;
  final int? resultModificationWindowDays;
  final double? defaultPassingPercentage;
  final bool? enforceGradingScale;
  final bool? allowGradeInflation;
  final double? minAttendanceForExam;
  final bool? allowMakeupExams;
  final int? makeupExamWindowDays;
  final double? makeupExamPenaltyPercentage;
  final bool? requireProctoring;
  final bool? allowOpenBook;
  final bool? requirePlagiarismCheck;
  final String? examConductGuidelines;
  final bool? notifyStudentsOnSchedule;
  final bool? notifyParentsOnResults;
  final bool? sendReminderNotifications;
  final int? reminderDaysBeforeExam;
  final bool isActive;
  final String? notes;
}

class ExaminationComplianceReport {
  ExaminationComplianceReport({
    required this.policyConfiguration,
    required this.violations,
    required this.summary,
  });

  factory ExaminationComplianceReport.fromJson(Map<String, dynamic> json) =>
      ExaminationComplianceReport(
        policyConfiguration:
            json['policyConfiguration'] != null
                ? ExaminationPolicy.fromJson(json['policyConfiguration'])
                : null,
        violations: ComplianceViolations.fromJson(json['violations'] ?? {}),
        summary: ComplianceSummary.fromJson(json['summary'] ?? {}),
      );

  final ExaminationPolicy? policyConfiguration;
  final ComplianceViolations violations;
  final ComplianceSummary summary;
}

class ComplianceViolations {
  ComplianceViolations({
    required this.overdueEvaluations,
    required this.shortNoticeExams,
    required this.longDurationExams,
  });

  factory ComplianceViolations.fromJson(Map<String, dynamic> json) =>
      ComplianceViolations(
        overdueEvaluations:
            ((json['overdueEvaluations'] ?? []) as List<dynamic>)
                .map((item) => OverdueEvaluation.fromJson(item))
                .toList(),
        shortNoticeExams:
            ((json['shortNoticeExams'] ?? []) as List<dynamic>)
                .map((item) => ShortNoticeExam.fromJson(item))
                .toList(),
        longDurationExams:
            ((json['longDurationExams'] ?? []) as List<dynamic>)
                .map((item) => LongDurationExam.fromJson(item))
                .toList(),
      );

  final List<OverdueEvaluation> overdueEvaluations;
  final List<ShortNoticeExam> shortNoticeExams;
  final List<LongDurationExam> longDurationExams;
}

class OverdueEvaluation {
  OverdueEvaluation({
    required this.examId,
    required this.examName,
    required this.subject,
    required this.examDate,
    required this.creator,
    required this.daysOverdue,
  });

  factory OverdueEvaluation.fromJson(Map<String, dynamic> json) =>
      OverdueEvaluation(
        examId: json['examId'] as int? ?? 0,
        examName: json['examName']?.toString() ?? '',
        subject: json['subject']?.toString() ?? '',
        examDate:
            json['examDate'] != null
                ? DateTime.parse(json['examDate'].toString())
                : DateTime.now(),
        creator: json['creator']?.toString() ?? '',
        daysOverdue: json['daysOverdue'] as int? ?? 0,
      );

  final int examId;
  final String examName;
  final String subject;
  final DateTime examDate;
  final String creator;
  final int daysOverdue;
}

class ShortNoticeExam {
  ShortNoticeExam({
    required this.examId,
    required this.examName,
    required this.subject,
    required this.examDate,
    required this.creator,
    required this.noticeGiven,
    required this.minimumRequired,
  });

  factory ShortNoticeExam.fromJson(Map<String, dynamic> json) =>
      ShortNoticeExam(
        examId: json['examId'] as int? ?? 0,
        examName: json['examName']?.toString() ?? '',
        subject: json['subject']?.toString() ?? '',
        examDate:
            json['examDate'] != null
                ? DateTime.parse(json['examDate'].toString())
                : DateTime.now(),
        creator: json['creator']?.toString() ?? '',
        noticeGiven: json['noticeGiven'] as int? ?? 0,
        minimumRequired: json['minimumRequired'] as int? ?? 0,
      );

  final int examId;
  final String examName;
  final String subject;
  final DateTime examDate;
  final String creator;
  final int noticeGiven;
  final int minimumRequired;
}

class LongDurationExam {
  LongDurationExam({
    required this.examId,
    required this.examName,
    required this.subject,
    required this.duration,
    required this.maximumAllowed,
    required this.creator,
  });

  factory LongDurationExam.fromJson(Map<String, dynamic> json) =>
      LongDurationExam(
        examId: json['examId'] as int? ?? 0,
        examName: json['examName']?.toString() ?? '',
        subject: json['subject']?.toString() ?? '',
        duration: json['duration'] as int? ?? 0,
        maximumAllowed: json['maximumAllowed'] as int? ?? 0,
        creator: json['creator']?.toString() ?? '',
      );

  final int examId;
  final String examName;
  final String subject;
  final int duration;
  final int maximumAllowed;
  final String creator;
}

class ComplianceSummary {
  ComplianceSummary({
    required this.totalViolations,
    required this.overdueEvaluationsCount,
    required this.shortNoticeExamsCount,
    required this.longDurationExamsCount,
  });

  factory ComplianceSummary.fromJson(Map<String, dynamic> json) =>
      ComplianceSummary(
        totalViolations: json['totalViolations'] as int? ?? 0,
        overdueEvaluationsCount: json['overdueEvaluationsCount'] as int? ?? 0,
        shortNoticeExamsCount: json['shortNoticeExamsCount'] as int? ?? 0,
        longDurationExamsCount: json['longDurationExamsCount'] as int? ?? 0,
      );

  final int totalViolations;
  final int overdueEvaluationsCount;
  final int shortNoticeExamsCount;
  final int longDurationExamsCount;
}
