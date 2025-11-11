class DashboardStats {
  const DashboardStats({
    required this.totalStudents,
    required this.presentToday,
    required this.absentToday,
    required this.avgAttendance,
    this.lateToday = 0,
    this.attendancePercentageToday = 0.0,
    this.hasAttendanceAccess = true,
    this.attendanceAccessReason,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
    totalStudents: json['totalStudents'] ?? 0,
    presentToday: json['presentToday'] ?? 0,
    absentToday: json['absentToday'] ?? 0,
    lateToday: json['lateToday'] ?? 0,
    attendancePercentageToday:
        (json['attendancePercentageToday'] ?? 0.0).toDouble(),
    avgAttendance: (json['avgAttendanceThisMonth'] ?? 0.0).toDouble(),
    hasAttendanceAccess: json['hasAttendanceAccess'] ?? true,
    attendanceAccessReason: json['attendanceAccessReason'],
  );

  final int totalStudents;
  final int presentToday;
  final int absentToday;
  final int lateToday;
  final double attendancePercentageToday;
  final double avgAttendance;
  final bool hasAttendanceAccess;
  final String? attendanceAccessReason;

  int get activeStudents => totalStudents;
  double get attendancePercentage =>
      totalStudents > 0 ? (presentToday / totalStudents * 100) : 0.0;

  Map<String, dynamic> toJson() => {
    'totalStudents': totalStudents,
    'presentToday': presentToday,
    'absentToday': absentToday,
    'lateToday': lateToday,
    'attendancePercentageToday': attendancePercentageToday,
    'avgAttendanceThisMonth': avgAttendance,
    'hasAttendanceAccess': hasAttendanceAccess,
    if (attendanceAccessReason != null)
      'attendanceAccessReason': attendanceAccessReason,
  };
}

class StudentActivity {
  const StudentActivity({
    required this.name,
    required this.initials,
    required this.lastActive,
    required this.grade,
    required this.percentage,
    this.avatarColor = '#4F7CFF',
    this.id,
    this.firstName,
    this.lastName,
    this.attendancePercentage,
    this.admissionNumber,
    this.rollNumber,
  });

  factory StudentActivity.fromJson(Map<String, dynamic> json) {
    // Generate initials from firstName and lastName or use provided initials
    var initials = '';
    if (json['firstName'] != null && json['lastName'] != null) {
      final firstName = json['firstName'] as String;
      final lastName = json['lastName'] as String;
      initials =
          '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
              .toUpperCase();
    } else if (json['initials'] != null) {
      initials = json['initials'];
    }

    return StudentActivity(
      id: json['id'],
      name: json['name'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      initials: initials,
      lastActive: json['lastActive'] ?? '',
      grade: json['grade'] ?? '',
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      attendancePercentage:
          json['attendancePercentage'] != null
              ? (json['attendancePercentage'] as num).toDouble()
              : null,
      admissionNumber: json['admissionNumber'],
      rollNumber: json['rollNumber'],
      avatarColor: json['avatarColor'] ?? '#4F7CFF',
    );
  }

  final int? id;
  final String name;
  final String? firstName;
  final String? lastName;
  final String initials;
  final String lastActive;
  final String grade;
  final double percentage;
  final double? attendancePercentage;
  final String? admissionNumber;
  final String? rollNumber;
  final String avatarColor;

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    if (firstName != null) 'firstName': firstName,
    if (lastName != null) 'lastName': lastName,
    'initials': initials,
    'lastActive': lastActive,
    'grade': grade,
    'percentage': percentage,
    if (attendancePercentage != null)
      'attendancePercentage': attendancePercentage,
    if (admissionNumber != null) 'admissionNumber': admissionNumber,
    if (rollNumber != null) 'rollNumber': rollNumber,
    'avatarColor': avatarColor,
  };
}

class SubjectPerformance {
  const SubjectPerformance({required this.subject, required this.percentage});
  final String subject;
  final double percentage;
}

class AttendanceData {
  const AttendanceData({
    required this.day,
    required this.present,
    required this.absent,
  });
  final String day;
  final int present;
  final int absent;

  int get total => present + absent;
}

class GradeDistribution {
  const GradeDistribution({
    required this.grade,
    required this.percentage,
    required this.color,
  });
  final String grade;
  final double percentage;
  final String color;
}

class AttendanceTrendsResponse {
  const AttendanceTrendsResponse({
    required this.weeklyOverview,
    required this.monthlyTrends,
    required this.attendancePatterns,
  });

  factory AttendanceTrendsResponse.fromJson(Map<String, dynamic> json) =>
      AttendanceTrendsResponse(
        weeklyOverview: WeeklyOverview.fromJson(json['weeklyOverview']),
        monthlyTrends: MonthlyTrends.fromJson(json['monthlyTrends']),
        attendancePatterns: AttendancePatterns.fromJson(
          json['attendancePatterns'],
        ),
      );

  final WeeklyOverview weeklyOverview;
  final MonthlyTrends monthlyTrends;
  final AttendancePatterns attendancePatterns;
}

class WeeklyOverview {
  const WeeklyOverview({
    required this.weekStartDate,
    required this.weekEndDate,
    required this.dailyAttendance,
    required this.weeklyAverage,
  });

  factory WeeklyOverview.fromJson(Map<String, dynamic> json) => WeeklyOverview(
    weekStartDate: json['weekStartDate'],
    weekEndDate: json['weekEndDate'],
    dailyAttendance:
        (json['dailyAttendance'] as List)
            .map((e) => DailyAttendanceDetail.fromJson(e))
            .toList(),
    weeklyAverage: json['weeklyAverage'],
  );

  final String weekStartDate;
  final String weekEndDate;
  final List<DailyAttendanceDetail> dailyAttendance;
  final int weeklyAverage;
}

class DailyAttendanceDetail {
  const DailyAttendanceDetail({
    required this.day,
    required this.date,
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
    required this.total,
    required this.percentage,
  });

  factory DailyAttendanceDetail.fromJson(Map<String, dynamic> json) =>
      DailyAttendanceDetail(
        day: json['day'],
        date: json['date'],
        present: json['present'],
        absent: json['absent'],
        late: json['late'] ?? 0,
        excused: json['excused'] ?? 0,
        total: json['total'],
        percentage: json['percentage'],
      );

  final String day;
  final String date;
  final int present;
  final int absent;
  final int late;
  final int excused;
  final int total;
  final int percentage;
}

class MonthlyTrends {
  const MonthlyTrends({
    required this.monthYear,
    required this.weeklyBreakdown,
    required this.monthlyAverage,
  });

  factory MonthlyTrends.fromJson(Map<String, dynamic> json) => MonthlyTrends(
    monthYear: json['monthYear'],
    weeklyBreakdown:
        (json['weeklyBreakdown'] as List)
            .map((e) => WeeklyBreakdown.fromJson(e))
            .toList(),
    monthlyAverage: json['monthlyAverage'],
  );

  final String monthYear;
  final List<WeeklyBreakdown> weeklyBreakdown;
  final int monthlyAverage;
}

class WeeklyBreakdown {
  const WeeklyBreakdown({
    required this.weekNumber,
    required this.weekStartDate,
    required this.averageAttendance,
    required this.totalStudents,
  });

  factory WeeklyBreakdown.fromJson(Map<String, dynamic> json) =>
      WeeklyBreakdown(
        weekNumber: json['weekNumber'],
        weekStartDate: json['weekStartDate'],
        averageAttendance: json['averageAttendance'],
        totalStudents: json['totalStudents'],
      );

  final int weekNumber;
  final String weekStartDate;
  final int averageAttendance;
  final int totalStudents;
}

class AttendancePatterns {
  const AttendancePatterns({
    required this.bestAttendanceDay,
    required this.worstAttendanceDay,
    required this.consistentAttendees,
    required this.irregularAttendees,
  });

  factory AttendancePatterns.fromJson(Map<String, dynamic> json) =>
      AttendancePatterns(
        bestAttendanceDay: json['bestAttendanceDay'],
        worstAttendanceDay: json['worstAttendanceDay'],
        consistentAttendees: json['consistentAttendees'],
        irregularAttendees: json['irregularAttendees'],
      );

  final String bestAttendanceDay;
  final String worstAttendanceDay;
  final int consistentAttendees;
  final int irregularAttendees;
}

class SubjectPerformanceResponse {
  const SubjectPerformanceResponse({
    required this.subjects,
    required this.overallClassAverage,
    required this.bestPerformingSubject,
    required this.subjectNeedingAttention,
  });

  factory SubjectPerformanceResponse.fromJson(Map<String, dynamic> json) =>
      SubjectPerformanceResponse(
        subjects:
            (json['subjects'] as List)
                .map((e) => SubjectDetail.fromJson(e))
                .toList(),
        overallClassAverage: (json['overallClassAverage'] ?? 0.0).toDouble(),
        bestPerformingSubject: BestPerformingSubject.fromJson(
          json['bestPerformingSubject'],
        ),
        subjectNeedingAttention: SubjectNeedingAttention.fromJson(
          json['subjectNeedingAttention'],
        ),
      );

  final List<SubjectDetail> subjects;
  final double overallClassAverage;
  final BestPerformingSubject bestPerformingSubject;
  final SubjectNeedingAttention subjectNeedingAttention;
}

class SubjectDetail {
  const SubjectDetail({
    required this.id,
    required this.name,
    required this.code,
    required this.averageScore,
    required this.totalStudents,
    required this.performanceTrend,
    required this.lastUpdated,
  });

  factory SubjectDetail.fromJson(Map<String, dynamic> json) => SubjectDetail(
    id: json['id'],
    name: json['name'],
    code: json['code'],
    averageScore: (json['averageScore'] ?? 0.0).toDouble(),
    totalStudents: json['totalStudents'],
    performanceTrend: json['performanceTrend'],
    lastUpdated: json['lastUpdated'],
  );

  final int id;
  final String name;
  final String code;
  final double averageScore;
  final int totalStudents;
  final String performanceTrend;
  final String lastUpdated;
}

class BestPerformingSubject {
  const BestPerformingSubject({required this.name, required this.averageScore});

  factory BestPerformingSubject.fromJson(Map<String, dynamic> json) =>
      BestPerformingSubject(
        name: json['name'],
        averageScore: (json['averageScore'] ?? 0.0).toDouble(),
      );

  final String name;
  final double averageScore;
}

class SubjectNeedingAttention {
  const SubjectNeedingAttention({
    required this.name,
    required this.averageScore,
    required this.studentsAtRisk,
  });

  factory SubjectNeedingAttention.fromJson(Map<String, dynamic> json) =>
      SubjectNeedingAttention(
        name: json['name'],
        averageScore: (json['averageScore'] ?? 0.0).toDouble(),
        studentsAtRisk: json['studentsAtRisk'] ?? 0,
      );

  final String name;
  final double averageScore;
  final int studentsAtRisk;
}

class GradeDistributionResponse {
  const GradeDistributionResponse({
    required this.overallDistribution,
    required this.subjectWiseDistribution,
    required this.topPerformers,
  });

  factory GradeDistributionResponse.fromJson(Map<String, dynamic> json) =>
      GradeDistributionResponse(
        overallDistribution: OverallDistribution.fromJson(
          json['overallDistribution'],
        ),
        subjectWiseDistribution:
            (json['subjectWiseDistribution'] as List)
                .map((e) => SubjectWiseDistribution.fromJson(e))
                .toList(),
        topPerformers:
            (json['topPerformers'] as List)
                .map((e) => TopPerformer.fromJson(e))
                .toList(),
      );

  final OverallDistribution overallDistribution;
  final List<SubjectWiseDistribution> subjectWiseDistribution;
  final List<TopPerformer> topPerformers;
}

class OverallDistribution {
  const OverallDistribution({
    required this.gradeBreakdown,
    required this.percentageBreakdown,
    required this.totalStudents,
  });

  factory OverallDistribution.fromJson(Map<String, dynamic> json) =>
      OverallDistribution(
        gradeBreakdown: Map<String, int>.from(json['gradeBreakdown'] ?? {}),
        percentageBreakdown: Map<String, int>.from(
          json['percentageBreakdown'] ?? {},
        ),
        totalStudents: json['totalStudents'] ?? 0,
      );

  final Map<String, int> gradeBreakdown;
  final Map<String, int> percentageBreakdown;
  final int totalStudents;
}

class SubjectWiseDistribution {
  const SubjectWiseDistribution({
    required this.subjectId,
    required this.subjectName,
    required this.gradeDistribution,
    required this.averageGrade,
    required this.medianGrade,
  });

  factory SubjectWiseDistribution.fromJson(Map<String, dynamic> json) =>
      SubjectWiseDistribution(
        subjectId: json['subjectId'],
        subjectName: json['subjectName'],
        gradeDistribution: Map<String, int>.from(
          json['gradeDistribution'] ?? {},
        ),
        averageGrade: json['averageGrade'],
        medianGrade: json['medianGrade'],
      );

  final int subjectId;
  final String subjectName;
  final Map<String, int> gradeDistribution;
  final String averageGrade;
  final String medianGrade;
}

class TopPerformer {
  const TopPerformer({
    required this.studentId,
    required this.studentName,
    required this.overallGrade,
    required this.subjectGrades,
  });

  factory TopPerformer.fromJson(Map<String, dynamic> json) => TopPerformer(
    studentId: json['studentId'],
    studentName: json['studentName'],
    overallGrade: json['overallGrade'],
    subjectGrades: Map<String, String>.from(json['subjectGrades'] ?? {}),
  );

  final String studentId;
  final String studentName;
  final String overallGrade;
  final Map<String, String> subjectGrades;
}
