class AdminDashboardStats {
  AdminDashboardStats({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalClasses,
    required this.attendanceRate,
    required this.feeCollection,
    required this.pendingFees,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) =>
      AdminDashboardStats(
        totalStudents: json['total_students'] ?? 0,
        totalTeachers: json['total_teachers'] ?? 0,
        totalClasses: json['total_classes'] ?? 0,
        attendanceRate: (json['attendance_rate'] ?? 0.0).toDouble(),
        feeCollection: (json['fee_collection'] ?? 0.0).toDouble(),
        pendingFees: (json['pending_fees'] ?? 0.0).toDouble(),
      );
  final int totalStudents;
  final int totalTeachers;
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
        teacherName: json['teacher_name'] ?? '',
        subject: json['subject'] ?? '',
        students: json['students'] ?? 0,
        avgGrade: (json['avg_grade'] ?? 0.0).toDouble(),
        rating: (json['rating'] ?? 0.0).toDouble(),
      );
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
        month: json['month'] ?? '',
        actualAttendance: (json['actual_attendance'] ?? 0.0).toDouble(),
        targetAttendance: (json['target_attendance'] ?? 95.0).toDouble(),
      );
  final String month;
  final double actualAttendance;
  final double targetAttendance;
}

class GradeDistribution {
  GradeDistribution({required this.grade, required this.count});

  factory GradeDistribution.fromJson(Map<String, dynamic> json) =>
      GradeDistribution(grade: json['grade'] ?? '', count: json['count'] ?? 0);
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
        className: json['class_name'] ?? '',
        studentCount: json['student_count'] ?? 0,
        avgGrade: (json['avg_grade'] ?? 0.0).toDouble(),
        attendanceRate: (json['attendance_rate'] ?? 0.0).toDouble(),
      );
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
        month: json['month'] ?? '',
        expenses: (json['expenses'] ?? 0.0).toDouble(),
        feeCollection: (json['fee_collection'] ?? 0.0).toDouble(),
        profit: (json['profit'] ?? 0.0).toDouble(),
      );
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
    category: json['category'] ?? '',
    message: json['message'] ?? '',
    severity: json['severity'] ?? 'low',
    timestamp:
        json['timestamp'] != null
            ? DateTime.parse(json['timestamp'])
            : DateTime.now(),
  );
  final String category;
  final String message;
  final String severity; // 'high', 'medium', 'low'
  final DateTime timestamp;
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
  });

  factory AdminDashboardResponse.fromJson(Map<String, dynamic> json) =>
      AdminDashboardResponse(
        stats: AdminDashboardStats.fromJson(json['stats'] ?? {}),
        teacherPerformance:
            (json['teacher_performance'] as List<dynamic>?)
                ?.map((item) => TeacherPerformance.fromJson(item))
                .toList() ??
            [],
        attendanceTrends:
            (json['attendance_trends'] as List<dynamic>?)
                ?.map((item) => AttendanceTrend.fromJson(item))
                .toList() ??
            [],
        gradeDistribution:
            (json['grade_distribution'] as List<dynamic>?)
                ?.map((item) => GradeDistribution.fromJson(item))
                .toList() ??
            [],
        classPerformance:
            (json['class_performance'] as List<dynamic>?)
                ?.map((item) => ClassPerformance.fromJson(item))
                .toList() ??
            [],
        financialOverview:
            (json['financial_overview'] as List<dynamic>?)
                ?.map((item) => FinancialOverview.fromJson(item))
                .toList() ??
            [],
        systemAlerts:
            (json['system_alerts'] as List<dynamic>?)
                ?.map((item) => SystemAlert.fromJson(item))
                .toList() ??
            [],
      );
  final AdminDashboardStats stats;
  final List<TeacherPerformance> teacherPerformance;
  final List<AttendanceTrend> attendanceTrends;
  final List<GradeDistribution> gradeDistribution;
  final List<ClassPerformance> classPerformance;
  final List<FinancialOverview> financialOverview;
  final List<SystemAlert> systemAlerts;
}
