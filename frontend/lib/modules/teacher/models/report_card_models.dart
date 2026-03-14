/// Models for batch report card API and PDF generation.
/// Matches backend BatchReportCardResponse and ReportCard types.
library;

class ReportCardStudentInfo {
  ReportCardStudentInfo({
    required this.name,
    required this.admissionNumber,
    required this.institutionName,
    this.kramid,
    this.rollNumber,
    this.courseName,
    this.courseCode,
    this.currentSemester,
    this.currentYear,
    this.section,
  });

  factory ReportCardStudentInfo.fromJson(Map<String, dynamic> json) =>
      ReportCardStudentInfo(
        name: json['name'] as String? ?? '',
        kramid: json['kramid'] as String?,
        admissionNumber: json['admissionNumber'] as String? ?? '',
        rollNumber: json['rollNumber'] as String?,
        courseName: json['courseName'] as String?,
        courseCode: json['courseCode'] as String?,
        currentSemester: json['currentSemester'] as int?,
        currentYear: json['currentYear'] as int?,
        section: json['section'] as String?,
        institutionName: json['institutionName'] as String? ?? '',
      );

  final String name;
  final String? kramid;
  final String admissionNumber;
  final String? rollNumber;
  final String? courseName;
  final String? courseCode;
  final int? currentSemester;
  final int? currentYear;
  final String? section;
  final String institutionName;
}

class ReportCardSemesterInfo {
  ReportCardSemesterInfo({
    required this.semesterId,
    required this.semesterName,
    required this.semesterNumber,
    required this.academicYear,
    required this.startDate,
    required this.endDate,
  });

  factory ReportCardSemesterInfo.fromJson(Map<String, dynamic> json) =>
      ReportCardSemesterInfo(
        semesterId: json['semesterId'] as int? ?? 0,
        semesterName: json['semesterName'] as String? ?? '',
        semesterNumber: json['semesterNumber'] as int? ?? 0,
        academicYear: json['academicYear'] as String? ?? '',
        startDate: json['startDate'] as String? ?? '',
        endDate: json['endDate'] as String? ?? '',
      );

  final int semesterId;
  final String semesterName;
  final int semesterNumber;
  final String academicYear;
  final String startDate;
  final String endDate;
}

class ReportCardSubjectRecord {
  ReportCardSubjectRecord({
    required this.subjectName,
    required this.subjectCode,
    required this.credits,
    required this.status,
    this.marksObtained,
    this.maxMarks,
    this.percentage,
    this.grade,
    this.gradePoints,
    this.teacherRemarks,
  });

  factory ReportCardSubjectRecord.fromJson(Map<String, dynamic> json) =>
      ReportCardSubjectRecord(
        subjectName: json['subjectName'] as String? ?? '',
        subjectCode: json['subjectCode'] as String? ?? '',
        credits: json['credits'] as int? ?? 0,
        marksObtained: json['marksObtained'] as num?,
        maxMarks: json['maxMarks'] as num?,
        percentage: json['percentage'] as num?,
        grade: json['grade'] as String?,
        gradePoints: json['gradePoints'] as num?,
        status: json['status'] as String? ?? 'INCOMPLETE',
        teacherRemarks: json['teacherRemarks'] as String?,
      );

  final String subjectName;
  final String subjectCode;
  final int credits;
  final num? marksObtained;
  final num? maxMarks;
  final num? percentage;
  final String? grade;
  final num? gradePoints;
  final String status;
  final String? teacherRemarks;
}

class ReportCardExamSummary {
  ReportCardExamSummary({
    required this.examType,
    required this.examName,
    required this.totalMarks,
    required this.marksObtained,
    required this.percentage,
    required this.grade,
    this.rank,
  });

  factory ReportCardExamSummary.fromJson(Map<String, dynamic> json) =>
      ReportCardExamSummary(
        examType: json['examType'] as String? ?? '',
        examName: json['examName'] as String? ?? '',
        totalMarks: json['totalMarks'] as int? ?? 0,
        marksObtained: json['marksObtained'] as num? ?? 0,
        percentage: json['percentage'] as num? ?? 0,
        grade: json['grade'] as String? ?? '',
        rank: json['rank'] as int?,
      );

  final String examType;
  final String examName;
  final int totalMarks;
  final num marksObtained;
  final num percentage;
  final String grade;
  final int? rank;
}

class ReportCardAttendanceSummary {
  ReportCardAttendanceSummary({
    required this.totalClasses,
    required this.classesAttended,
    required this.classesAbsent,
    required this.percentage,
    required this.status,
  });

  factory ReportCardAttendanceSummary.fromJson(Map<String, dynamic> json) =>
      ReportCardAttendanceSummary(
        totalClasses: json['totalClasses'] as int? ?? 0,
        classesAttended: json['classesAttended'] as int? ?? 0,
        classesAbsent: json['classesAbsent'] as int? ?? 0,
        percentage: json['percentage'] as num? ?? 0,
        status: json['status'] as String? ?? 'satisfactory',
      );

  final int totalClasses;
  final int classesAttended;
  final int classesAbsent;
  final num percentage;
  final String status;
}

class ReportCardPerformanceSummary {
  ReportCardPerformanceSummary({
    required this.sgpa,
    required this.cgpa,
    required this.totalCreditsEarned,
    required this.totalCreditsAttempted,
    required this.overallGrade,
    required this.overallStatus,
    this.classRank,
    this.totalStudents,
    this.percentile,
  });

  factory ReportCardPerformanceSummary.fromJson(Map<String, dynamic> json) =>
      ReportCardPerformanceSummary(
        sgpa: json['sgpa'] as num? ?? 0,
        cgpa: json['cgpa'] as num? ?? 0,
        totalCreditsEarned: json['totalCreditsEarned'] as int? ?? 0,
        totalCreditsAttempted: json['totalCreditsAttempted'] as int? ?? 0,
        classRank: json['classRank'] as int?,
        totalStudents: json['totalStudents'] as int?,
        percentile: json['percentile'] as num?,
        overallGrade: json['overallGrade'] as String? ?? '',
        overallStatus: json['overallStatus'] as String? ?? 'PASSED',
      );

  final num sgpa;
  final num cgpa;
  final int totalCreditsEarned;
  final int totalCreditsAttempted;
  final int? classRank;
  final int? totalStudents;
  final num? percentile;
  final String overallGrade;
  final String overallStatus;
}

class ReportCardRemarks {
  ReportCardRemarks({
    this.principalRemarks,
    this.classTeacherRemarks,
    this.strengths = const [],
    this.areasForImprovement = const [],
  });

  factory ReportCardRemarks.fromJson(Map<String, dynamic> json) =>
      ReportCardRemarks(
        principalRemarks: json['principalRemarks'] as String?,
        classTeacherRemarks: json['classTeacherRemarks'] as String?,
        strengths:
            (json['strengths'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        areasForImprovement:
            (json['areasForImprovement'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );

  final String? principalRemarks;
  final String? classTeacherRemarks;
  final List<String> strengths;
  final List<String> areasForImprovement;
}

class ReportCardData {
  ReportCardData({
    required this.studentInfo,
    required this.semesterInfo,
    required this.subjectRecords,
    required this.examSummaries,
    required this.attendanceSummary,
    required this.performanceSummary,
    required this.remarks,
    required this.generatedAt,
    required this.reportCardNumber,
  });

  factory ReportCardData.fromJson(Map<String, dynamic> json) => ReportCardData(
    studentInfo: ReportCardStudentInfo.fromJson(
      json['studentInfo'] as Map<String, dynamic>? ?? {},
    ),
    semesterInfo: ReportCardSemesterInfo.fromJson(
      json['semesterInfo'] as Map<String, dynamic>? ?? {},
    ),
    subjectRecords:
        (json['subjectRecords'] as List<dynamic>?)
            ?.map(
              (e) =>
                  ReportCardSubjectRecord.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [],
    examSummaries:
        (json['examSummaries'] as List<dynamic>?)
            ?.map(
              (e) => ReportCardExamSummary.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [],
    attendanceSummary: ReportCardAttendanceSummary.fromJson(
      json['attendanceSummary'] as Map<String, dynamic>? ?? {},
    ),
    performanceSummary: ReportCardPerformanceSummary.fromJson(
      json['performanceSummary'] as Map<String, dynamic>? ?? {},
    ),
    remarks: ReportCardRemarks.fromJson(
      json['remarks'] as Map<String, dynamic>? ?? {},
    ),
    generatedAt: json['generatedAt'] as String? ?? '',
    reportCardNumber: json['reportCardNumber'] as String? ?? '',
  );

  final ReportCardStudentInfo studentInfo;
  final ReportCardSemesterInfo semesterInfo;
  final List<ReportCardSubjectRecord> subjectRecords;
  final List<ReportCardExamSummary> examSummaries;
  final ReportCardAttendanceSummary attendanceSummary;
  final ReportCardPerformanceSummary performanceSummary;
  final ReportCardRemarks remarks;
  final String generatedAt;
  final String reportCardNumber;
}

class BatchReportCardStudentSummary {
  BatchReportCardStudentSummary({
    required this.studentId,
    required this.studentName,
    required this.admissionNumber,
    required this.sgpa,
    required this.cgpa,
    required this.attendancePercentage,
    required this.overallGrade,
    required this.overallStatus,
    required this.reportCardNumber,
    this.rollNumber,
    this.classRank,
  });

  factory BatchReportCardStudentSummary.fromJson(Map<String, dynamic> json) =>
      BatchReportCardStudentSummary(
        studentId: json['studentId'] as int? ?? 0,
        studentName: json['studentName'] as String? ?? '',
        admissionNumber: json['admissionNumber'] as String? ?? '',
        rollNumber: json['rollNumber'] as String?,
        sgpa: json['sgpa'] as num? ?? 0,
        cgpa: json['cgpa'] as num? ?? 0,
        attendancePercentage: json['attendancePercentage'] as num? ?? 0,
        overallGrade: json['overallGrade'] as String? ?? '',
        overallStatus: json['overallStatus'] as String? ?? 'PASSED',
        classRank: json['classRank'] as int?,
        reportCardNumber: json['reportCardNumber'] as String? ?? '',
      );

  final int studentId;
  final String studentName;
  final String admissionNumber;
  final String? rollNumber;
  final num sgpa;
  final num cgpa;
  final num attendancePercentage;
  final String overallGrade;
  final String overallStatus;
  final int? classRank;
  final String reportCardNumber;
}

class BatchReportCardSummary {
  BatchReportCardSummary({
    required this.totalStudents,
    required this.generated,
    required this.failed,
    required this.averageSgpa,
    required this.averageAttendance,
    required this.passCount,
    required this.failCount,
    this.gradeDistribution = const [],
  });

  factory BatchReportCardSummary.fromJson(Map<String, dynamic> json) =>
      BatchReportCardSummary(
        totalStudents: json['totalStudents'] as int? ?? 0,
        generated: json['generated'] as int? ?? 0,
        failed: json['failed'] as int? ?? 0,
        averageSgpa: json['averageSgpa'] as num? ?? 0,
        averageAttendance: json['averageAttendance'] as num? ?? 0,
        passCount: json['passCount'] as int? ?? 0,
        failCount: json['failCount'] as int? ?? 0,
        gradeDistribution:
            (json['gradeDistribution'] as List<dynamic>?)
                ?.map(
                  (e) => Map<String, dynamic>.from(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
      );

  final int totalStudents;
  final int generated;
  final int failed;
  final num averageSgpa;
  final num averageAttendance;
  final int passCount;
  final int failCount;
  final List<Map<String, dynamic>> gradeDistribution;
}

class BatchReportCardResponse {
  BatchReportCardResponse({
    required this.success,
    required this.reportCards,
    required this.summary,
    required this.studentSummaries,
    required this.generatedAt,
    required this.batchId,
  });

  factory BatchReportCardResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return BatchReportCardResponse(
      success: json['success'] as bool? ?? false,
      reportCards:
          (data['reportCards'] as List<dynamic>?)
              ?.map((e) => ReportCardData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary: BatchReportCardSummary.fromJson(
        data['summary'] as Map<String, dynamic>? ?? {},
      ),
      studentSummaries:
          (data['studentSummaries'] as List<dynamic>?)
              ?.map(
                (e) => BatchReportCardStudentSummary.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      generatedAt: data['generatedAt'] as String? ?? '',
      batchId: data['batchId'] as String? ?? '',
    );
  }

  final bool success;
  final List<ReportCardData> reportCards;
  final BatchReportCardSummary summary;
  final List<BatchReportCardStudentSummary> studentSummaries;
  final String generatedAt;
  final String batchId;
}
