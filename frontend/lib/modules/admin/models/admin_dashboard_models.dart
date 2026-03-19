class AdminDashboardStats {
  AdminDashboardStats({
    required this.totalStudents,
    required this.activeStudents,
    required this.inactiveStudents,
    required this.totalTeachers,
    required this.totalStaff,
    required this.totalClasses,
    required this.attendanceRate,
    required this.feeCollection,
    required this.pendingFees,
  });

  factory AdminDashboardStats.fromJson(
    Map<String, dynamic> json,
  ) => AdminDashboardStats(
    totalStudents:
        (json['totalStudents'] ?? json['total_students']) as int? ?? 0,
    activeStudents:
        (json['activeStudents'] ?? json['active_students']) as int? ?? 0,
    inactiveStudents:
        (json['inactiveStudents'] ?? json['inactive_students']) as int? ?? 0,
    totalTeachers:
        (json['totalTeachers'] ?? json['total_teachers']) as int? ?? 0,
    totalStaff: (json['totalStaff'] ?? json['total_staff']) as int? ?? 0,
    totalClasses: (json['totalClasses'] ?? json['total_classes']) as int? ?? 0,
    attendanceRate: _parseDouble(
      json['attendanceRate'] ?? json['attendance_rate'],
    ),
    feeCollection: _parseDouble(
      json['feeCollection'] ?? json['fee_collection'],
    ),
    pendingFees: _parseDouble(json['pendingFees'] ?? json['pending_fees']),
  );

  static double _parseDouble(value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  final int totalStudents;
  final int activeStudents;
  final int inactiveStudents;
  final int totalTeachers;
  final int totalStaff;
  final int totalClasses;
  final double attendanceRate;
  final double feeCollection;
  final double pendingFees;
}

class TeacherPerformance {
  TeacherPerformance({
    required this.teacherName,
    required this.subject,
    required this.students,
    required this.avgGrade,
    required this.rating,
  });

  factory TeacherPerformance.fromJson(Map<String, dynamic> json) =>
      TeacherPerformance(
        teacherName:
            (json['teacher'] ?? json['teacher_name'])?.toString() ?? '',
        subject: json['subject']?.toString() ?? '',
        students:
            (json['student'] ?? json['students'] ?? json['student_count'])
                as int? ??
            0,
        avgGrade: _parseDouble(json['avgGrade'] ?? json['avg_grade']),
        rating: _parseDouble(json['rating']),
      );

  static double _parseDouble(value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  final String teacherName;
  final String subject;
  final int students;
  final double avgGrade;
  final double rating;
}

class AttendanceTrend {
  AttendanceTrend({
    required this.month,
    required this.actualAttendance,
    required this.targetAttendance,
  });

  factory AttendanceTrend.fromJson(Map<String, dynamic> json) =>
      AttendanceTrend(
        month: json['month']?.toString() ?? '',
        actualAttendance: _parseDouble(
          json['actualAttendance'] ?? json['actual_attendance'],
        ),
        targetAttendance:
            _parseDouble(
                      json['targetAttendance'] ?? json['target_attendance'],
                    ) ==
                    0.0
                ? 95.0
                : _parseDouble(
                  json['targetAttendance'] ?? json['target_attendance'],
                ),
      );

  static double _parseDouble(value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  final String month;
  final double actualAttendance;
  final double targetAttendance;
}

class GradeDistribution {
  GradeDistribution({required this.grade, required this.count});

  factory GradeDistribution.fromJson(Map<String, dynamic> json) =>
      GradeDistribution(
        grade: json['grade']?.toString() ?? '',
        count: json['count'] as int? ?? 0,
      );
  final String grade;
  final int count;
}

class ClassPerformance {
  ClassPerformance({
    required this.className,
    required this.studentCount,
    required this.avgGrade,
    required this.attendanceRate,
  });

  factory ClassPerformance.fromJson(Map<String, dynamic> json) =>
      ClassPerformance(
        className: (json['class'] ?? json['class_name'])?.toString() ?? '',
        studentCount:
            (json['studentCount'] ?? json['student_count']) as int? ?? 0,
        avgGrade: _parseDouble(json['avgGrade'] ?? json['avg_grade']),
        attendanceRate: _parseDouble(
          json['attendanceRate'] ?? json['attendance_rate'],
        ),
      );

  static double _parseDouble(value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  final String className;
  final int studentCount;
  final double avgGrade;
  final double attendanceRate;
}

class FinancialOverview {
  FinancialOverview({
    required this.month,
    required this.expenses,
    required this.feeCollection,
    required this.profit,
  });

  factory FinancialOverview.fromJson(Map<String, dynamic> json) =>
      FinancialOverview(
        month: json['month']?.toString() ?? '',
        expenses: _parseDouble(json['expenses']),
        feeCollection: _parseDouble(
          json['feeCollection'] ?? json['fee_collection'],
        ),
        profit: _parseDouble(json['profit']),
      );

  static double _parseDouble(value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  final String month;
  final double expenses;
  final double feeCollection;
  final double profit;
}

class SystemAlert {
  SystemAlert({
    required this.category,
    required this.message,
    required this.severity,
    required this.timestamp,
  });

  factory SystemAlert.fromJson(Map<String, dynamic> json) => SystemAlert(
    category: json['category']?.toString() ?? '',
    message: json['message']?.toString() ?? '',
    severity: json['severity']?.toString() ?? 'low',
    timestamp:
        json['timestamp'] != null
            ? DateTime.parse(json['timestamp'].toString())
            : DateTime.now(),
  );
  final String category;
  final String message;
  final String severity; // 'high', 'medium', 'low'
  final DateTime timestamp;
}

class ExaminationOverview {
  ExaminationOverview({
    required this.summary,
    required this.examTypeDistribution,
    required this.recentActivity,
  });

  factory ExaminationOverview.fromJson(Map<String, dynamic> json) =>
      ExaminationOverview(
        summary: ExaminationSummary.fromJson(json['summary'] ?? {}),
        examTypeDistribution:
            ((json['examTypeDistribution'] ?? json['exam_type_distribution'])
                    as List<dynamic>?)
                ?.map((item) => ExamTypeDistribution.fromJson(item))
                .toList() ??
            [],
        recentActivity:
            ((json['recentActivity'] ?? json['recent_activity'])
                    as List<dynamic>?)
                ?.map((item) => RecentExamActivity.fromJson(item))
                .toList() ??
            [],
      );

  final ExaminationSummary summary;
  final List<ExamTypeDistribution> examTypeDistribution;
  final List<RecentExamActivity> recentActivity;
}

class ExaminationSummary {
  ExaminationSummary({
    required this.totalExams,
    required this.thisWeekExams,
    required this.thisMonthExams,
    required this.upcomingExams,
    required this.completedExams,
    required this.pendingEvaluations,
    required this.averageScore,
  });

  factory ExaminationSummary.fromJson(
    Map<String, dynamic> json,
  ) => ExaminationSummary(
    totalExams: (json['totalExams'] ?? json['total_exams']) as int? ?? 0,
    thisWeekExams:
        (json['thisWeekExams'] ?? json['this_week_exams']) as int? ?? 0,
    thisMonthExams:
        (json['thisMonthExams'] ?? json['this_month_exams']) as int? ?? 0,
    upcomingExams:
        (json['upcomingExams'] ?? json['upcoming_exams']) as int? ?? 0,
    completedExams:
        (json['completedExams'] ?? json['completed_exams']) as int? ?? 0,
    pendingEvaluations:
        (json['pendingEvaluations'] ?? json['pending_evaluations']) as int? ??
        0,
    averageScore: _parseDouble(json['averageScore'] ?? json['average_score']),
  );

  static double _parseDouble(value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  final int totalExams;
  final int thisWeekExams;
  final int thisMonthExams;
  final int upcomingExams;
  final int completedExams;
  final int pendingEvaluations;
  final double averageScore;
}

class ExamTypeDistribution {
  ExamTypeDistribution({required this.type, required this.count});

  factory ExamTypeDistribution.fromJson(Map<String, dynamic> json) =>
      ExamTypeDistribution(
        type: json['type']?.toString() ?? '',
        count: json['count'] as int? ?? 0,
      );

  final String type;
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
    required this.studentsCount,
    required this.createdAt,
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
        studentsCount:
            (json['studentsCount'] ?? json['students_count']) as int? ?? 0,
        createdAt:
            json['createdAt'] != null
                ? DateTime.parse(json['createdAt'].toString())
                : DateTime.now(),
      );

  final int id;
  final String examName;
  final String examType;
  final String subject;
  final String creator;
  final String status;
  final DateTime examDate;
  final int studentsCount;
  final DateTime createdAt;
}

class AdminDashboardResponse {
  AdminDashboardResponse({
    required this.stats,
    required this.teacherPerformance,
    required this.attendanceTrends,
    required this.gradeDistribution,
    required this.classPerformance,
    required this.financialOverview,
    required this.systemAlerts,
    required this.examinationOverview,
  });

  factory AdminDashboardResponse.fromJson(Map<String, dynamic> json) =>
      AdminDashboardResponse(
        stats: AdminDashboardStats.fromJson(json['stats'] ?? {}),
        teacherPerformance:
            ((json['teacherPerformance'] ?? json['teacher_performance'])
                    as List<dynamic>?)
                ?.map((item) => TeacherPerformance.fromJson(item))
                .toList() ??
            [],
        attendanceTrends:
            ((json['attendanceTrends'] ?? json['attendance_trends'])
                    as List<dynamic>?)
                ?.map((item) => AttendanceTrend.fromJson(item))
                .toList() ??
            [],
        gradeDistribution:
            ((json['gradeDistribution'] ?? json['grade_distribution'])
                    as List<dynamic>?)
                ?.map((item) => GradeDistribution.fromJson(item))
                .toList() ??
            [],
        classPerformance:
            ((json['classPerformance'] ?? json['class_performance'])
                    as List<dynamic>?)
                ?.map((item) => ClassPerformance.fromJson(item))
                .toList() ??
            [],
        financialOverview:
            ((json['financialOverview'] ?? json['financial_overview'])
                    as List<dynamic>?)
                ?.map((item) => FinancialOverview.fromJson(item))
                .toList() ??
            [],
        systemAlerts:
            ((json['systemAlerts'] ?? json['system_alerts']) as List<dynamic>?)
                ?.map((item) => SystemAlert.fromJson(item))
                .toList() ??
            [],
        examinationOverview: ExaminationOverview.fromJson(
          json['examinationOverview'] ?? json['examination_overview'] ?? {},
        ),
      );

  final AdminDashboardStats stats;
  final List<TeacherPerformance> teacherPerformance;
  final List<AttendanceTrend> attendanceTrends;
  final List<GradeDistribution> gradeDistribution;
  final List<ClassPerformance> classPerformance;
  final List<FinancialOverview> financialOverview;
  final List<SystemAlert> systemAlerts;
  final ExaminationOverview examinationOverview;
}
