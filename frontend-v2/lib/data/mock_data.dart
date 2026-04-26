// Dummy data for frontend-v2 prototype - no backend integration

class MockData {
  MockData._();

  static const String teacherName = 'Kram';
  static const String teacherAvatarUrl =
      'https://www.figma.com/api/mcp/asset/723a01f1-75be-4008-afdc-26513257982a';
  static const String dateLabel = 'Monday, Oct 24';
  static const String courseName = 'English 101';
  static const String sectionName = 'Section A';

  static const int totalLogs = 42;
  static const String totalLogsTrend = '12% vs last week';
  static const int assessmentsCount = 3;
  static const int activeStudents = 18;
  static const int totalStudents = 24;

  static const List<String> studentAvatarUrls = [
    'https://www.figma.com/api/mcp/asset/d5577808-7150-46e6-9c06-f9aaa7465fbf',
    'https://www.figma.com/api/mcp/asset/4720a927-3bee-48cf-bf74-bb0bec7bcbd9',
    'https://www.figma.com/api/mcp/asset/c3c88c6b-d522-4374-99c3-1827de8dee3d',
  ];

  // Class selection screen - teacher's classes for the day
  static const List<TeacherClass> teacherClasses = [
    TeacherClass(
      id: '1',
      name: 'English 101 - Section A',
      period: 'Period 3',
      time: '10:15 AM',
      room: 'Room 402',
      studentCount: 28,
      isActiveNow: true,
    ),
    TeacherClass(
      id: '2',
      name: 'English 101 - Section B',
      period: 'Period 5',
      time: '1:30 PM',
      room: 'Room 402',
      studentCount: 32,
      isActiveNow: false,
    ),
    TeacherClass(
      id: '3',
      name: 'History 202',
      period: 'Period 6',
      time: '2:45 PM',
      room: 'Hall B',
      studentCount: 45,
      isActiveNow: false,
    ),
  ];

  // Insights screen - Class Insights data
  static const String insightsClassName = 'Grade 11 - Advanced Biology';
  static const int insightsWeekNumber = 12;
  static const int insightsParticipationPercent = 80;
  static const int insightsUnderstandingPercent = 65;
  static const int insightsBehaviorPercent = 88;

  static const List<InsightsAttentionItem> insightsNeedsAttention = [
    InsightsAttentionItem(
      initials: 'JM',
      name: 'Julian Miller',
      issue: '3 sessions missed',
    ),
    InsightsAttentionItem(
      initials: 'SB',
      name: 'Sarah Bloom',
      issue: 'Drop in understanding',
    ),
    InsightsAttentionItem(
      initials: 'AK',
      name: 'Alex Kim',
      issue: 'Submission pending',
    ),
  ];

  static const List<InsightsTopPerformer> insightsTopPerformers = [
    InsightsTopPerformer(
      name: 'Lena Vance',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/49ce90e0-5c31-46ce-9a2f-4e7d36272246',
      growthPercent: 12,
      rank: 1,
    ),
    InsightsTopPerformer(
      name: 'Maya R.',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/962d3959-7734-4d64-8fc0-4430e35bb15a',
      growthPercent: 8,
      rank: 2,
    ),
    InsightsTopPerformer(
      name: 'Leo Scott',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/708099f3-e0ee-4470-9c9e-6d37a6a6a617',
      growthPercent: 7,
      rank: 3,
    ),
  ];

  static const List<InsightsSubjectMastery> insightsSubjectMastery = [
    InsightsSubjectMastery(name: 'Cellular Biology', percent: 92),
    InsightsSubjectMastery(name: 'Genetic Engineering', percent: 84),
    InsightsSubjectMastery(name: 'Bioinformatics', percent: 78),
  ];

  static const List<InsightsRosterStudent> insightsRosterStudents = [
    InsightsRosterStudent(
      name: 'Lena Vance',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/49ce90e0-5c31-46ce-9a2f-4e7d36272246',
    ),
    InsightsRosterStudent(
      name: 'Maya Rodriguez',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/962d3959-7734-4d64-8fc0-4430e35bb15a',
    ),
    InsightsRosterStudent(
      name: 'Leo Scott',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/708099f3-e0ee-4470-9c9e-6d37a6a6a617',
    ),
    InsightsRosterStudent(
      name: 'Ana Chen',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/96f71ae4-c0a4-41ff-8c06-42dd7bb15f28',
    ),
    InsightsRosterStudent(
      name: 'David Onuoha',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/e03e80cd-aeea-45a1-815d-9b71d7cc0e0e',
    ),
    InsightsRosterStudent(name: 'Julian Miller', initials: 'JM'),
    InsightsRosterStudent(name: 'Sarah Bloom', initials: 'SB'),
    InsightsRosterStudent(name: 'Alex Kim', initials: 'AK'),
  ];

  static const List<ObservationItem> recentObservations = [
    ObservationItem(
      studentName: 'Julian S.',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/e48f0841-4c09-4ad2-99e0-4fd64157439a',
      timeAgo: '12m ago',
      snippet: 'Showed exceptional…',
      tags: ['Leadership', 'Positive'],
    ),
    ObservationItem(
      studentName: 'Aria L.',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/4f8287f8-2da7-4088-a1f1-c76d352d1ffa',
      timeAgo: '45m ago',
      snippet: 'Self-corrected during…',
      tags: ['Literacy', 'Growth'],
    ),
  ];
}

class TeacherClass {
  final String id;
  final String name;
  final String period;
  final String time;
  final String room;
  final int studentCount;
  final bool isActiveNow;

  const TeacherClass({
    required this.id,
    required this.name,
    required this.period,
    required this.time,
    required this.room,
    required this.studentCount,
    required this.isActiveNow,
  });
}

class ObservationItem {
  final String studentName;
  final String avatarUrl;
  final String timeAgo;
  final String snippet;
  final List<String> tags;

  const ObservationItem({
    required this.studentName,
    required this.avatarUrl,
    required this.timeAgo,
    required this.snippet,
    required this.tags,
  });
}

// Class Roster / Start Logging screen - dummy data
class ClassRosterMockData {
  ClassRosterMockData._();

  static const List<RosterStudent> students = [
    RosterStudent(
      name: 'Alex Rivera',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/ffd96a76-ff83-4dde-99db-3a60d1ade78c',
      isLogged: true,
    ),
    RosterStudent(
      name: 'Mina Sato',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/7a0c4d1a-d77e-43f0-bd82-1bd8ed87c5d0',
      isLogged: false,
    ),
    RosterStudent(
      name: 'Leo Thorne',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/9881b8a4-e738-45a1-b8ee-d59745357156',
      isLogged: true,
    ),
    RosterStudent(
      name: 'Sarah Chen',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/e6b5d35f-091f-4d2f-ada5-3dbe6e4d6ee1',
      isLogged: true,
    ),
    RosterStudent(
      name: 'Ava Dubois',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/bcc7b597-6176-4363-8314-c896863083ac',
      isLogged: false,
    ),
    RosterStudent(
      name: 'Julian Moss',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/25290a16-15a7-4406-b071-22448b63a6a8',
      isLogged: true,
    ),
    RosterStudent(
      name: 'Toby James',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/34dd812a-0e34-425c-86f8-f11cf1bbac3c',
      isLogged: false,
    ),
    RosterStudent(
      name: 'Elena Vance',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/d3788b30-9729-45de-865e-286386873719',
      isLogged: true,
    ),
    RosterStudent(
      name: 'Noah Smith',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/44f64117-837a-406b-b955-97480ffab6e4',
      isLogged: false,
    ),
  ];

  static const int loggedPercent = 65;
  static const int attendanceImprovement = 12;
}

class RosterStudent {
  final String name;
  final String avatarUrl;
  final bool isLogged;

  const RosterStudent({
    required this.name,
    required this.avatarUrl,
    required this.isLogged,
  });
}

class InsightsAttentionItem {
  final String initials;
  final String name;
  final String issue;

  const InsightsAttentionItem({
    required this.initials,
    required this.name,
    required this.issue,
  });
}

class InsightsTopPerformer {
  final String name;
  final String avatarUrl;
  final int growthPercent;
  final int rank;

  const InsightsTopPerformer({
    required this.name,
    required this.avatarUrl,
    required this.growthPercent,
    required this.rank,
  });
}

class InsightsSubjectMastery {
  final String name;
  final int percent;

  const InsightsSubjectMastery({required this.name, required this.percent});
}

class InsightsRosterStudent {
  final String name;
  final String? avatarUrl;
  final String? initials;

  const InsightsRosterStudent({
    required this.name,
    this.avatarUrl,
    this.initials,
  });
}

/// Student profile detail - used when viewing a student's profile from Insights
class StudentProfileData {
  final String name;
  final String avatarUrl;
  final String gradeSection;
  final List<String> badges;
  final int participationPercent;
  final int understandingPercent;
  final int behaviorPercent;
  final List<String> keyIndicators;
  final List<int> engagementTrend; // W1, W2, W3, current
  final String aiInsight;
  final List<StudentProfileObservation> recentObservations;

  const StudentProfileData({
    required this.name,
    required this.avatarUrl,
    required this.gradeSection,
    required this.badges,
    required this.participationPercent,
    required this.understandingPercent,
    required this.behaviorPercent,
    required this.keyIndicators,
    required this.engagementTrend,
    required this.aiInsight,
    required this.recentObservations,
  });
}

class StudentProfileObservation {
  final String title;
  final String timeAgo;
  final String description;
  final String variant; // 'assessment' | 'seminar' | 'warning'

  const StudentProfileObservation({
    required this.title,
    required this.timeAgo,
    required this.description,
    required this.variant,
  });
}

/// Get student profile data by name - returns mock data for Julian Miller or generic
StudentProfileData getStudentProfile(String name, String avatarUrl) {
  return StudentProfileData(
    name: name,
    avatarUrl: avatarUrl.isNotEmpty
        ? avatarUrl
        : 'https://i.pravatar.cc/96?u=$name',
    gradeSection: 'Grade 11 • Section B',
    badges: const ['AP History', 'Active Status'],
    participationPercent: 88,
    understandingPercent: 64,
    behaviorPercent: 95,
    keyIndicators: const [
      'Active Voice',
      'Critical Thinker',
      'Needs Review',
      'Collaborative',
      'Self-Starter',
    ],
    engagementTrend: const [30, 50, 85, 75],
    aiInsight:
        'Julian is showing a 15% drop in Understanding metrics compared to last month. Consider a brief 1-on-1 check-in during the next lab to address potential curriculum gaps.',
    recentObservations: const [
      StudentProfileObservation(
        title: 'Mid-term Assessment',
        timeAgo: '2h ago',
        description:
            'Strong performance in evidence gathering, but struggled with structural flow in the final essay.',
        variant: 'assessment',
      ),
      StudentProfileObservation(
        title: 'Socratic Seminar',
        timeAgo: 'Yesterday',
        description:
            'Led the group discussion effectively. Encouraged peer involvement and cited multiple sources.',
        variant: 'seminar',
      ),
      StudentProfileObservation(
        title: 'Late Submission',
        timeAgo: 'Oct 24',
        description:
            'Primary source analysis was submitted 1 day past deadline. Student noted personal issues.',
        variant: 'warning',
      ),
    ],
  );
}

// Attendance Logging screen - dummy data
class AttendanceMockData {
  AttendanceMockData._();

  static const String courseName = 'English 101';
  static const String dateLabel = 'Monday, Oct 24';
  static const String periodLabel = 'Period 3';
  static const int totalEnrolled = 30;

  // First 9 students shown in list (28 present + 2 absent = 30 total in design)
  static List<AttendanceStudent> get students => [
    const AttendanceStudent(
      name: 'Aaron Bennett',
      studentId: '#10024',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/51cf797b-fbf3-4502-93ad-af18a517f421',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Blake Harrison',
      studentId: '#10025',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/5a04e19d-eda5-4b2c-ba40-70f180eae902',
      isPresent: false,
    ),
    const AttendanceStudent(
      name: 'Chloe Adams',
      studentId: '#10026',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/0fff43b4-0f60-482d-b7c1-356eac5c8585',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Daniel Foster',
      studentId: '#10027',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/68bd8dfa-8f88-4ab5-9121-95542c36a86f',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Elena Rodriguez',
      studentId: '#10028',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/9d5c68a6-397b-450e-b49a-53bd76c4e699',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Felix Wright',
      studentId: '#10029',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/43ed8622-3e0a-47c0-ad80-0f7117237557',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Grace Lee',
      studentId: '#10030',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/d59a4da6-1f5c-4ea1-9c43-ec24654ee867',
      isPresent: false,
    ),
    const AttendanceStudent(
      name: 'Henry Owens',
      studentId: '#10031',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/28811172-e490-4e1d-975b-d1be8b3eff89',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Isla Fisher',
      studentId: '#10032',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/0a1ef463-f2e6-498e-bde5-6e54be0bd0ca',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Jack Miller',
      studentId: '#10033',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/51cf797b-fbf3-4502-93ad-af18a517f421',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Kate Nelson',
      studentId: '#10034',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/5a04e19d-eda5-4b2c-ba40-70f180eae902',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Liam Parker',
      studentId: '#10035',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/0fff43b4-0f60-482d-b7c1-356eac5c8585',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Mia Quinn',
      studentId: '#10036',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/68bd8dfa-8f88-4ab5-9121-95542c36a86f',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Noah Reed',
      studentId: '#10037',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/9d5c68a6-397b-450e-b49a-53bd76c4e699',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Olivia Scott',
      studentId: '#10038',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/43ed8622-3e0a-47c0-ad80-0f7117237557',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Paul Turner',
      studentId: '#10039',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/d59a4da6-1f5c-4ea1-9c43-ec24654ee867',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Quinn Underwood',
      studentId: '#10040',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/28811172-e490-4e1d-975b-d1be8b3eff89',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Rachel Vance',
      studentId: '#10041',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/0a1ef463-f2e6-498e-bde5-6e54be0bd0ca',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Sam Wilson',
      studentId: '#10042',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/51cf797b-fbf3-4502-93ad-af18a517f421',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Tina Young',
      studentId: '#10043',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/5a04e19d-eda5-4b2c-ba40-70f180eae902',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Uma Zhang',
      studentId: '#10044',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/0fff43b4-0f60-482d-b7c1-356eac5c8585',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Victor Adams',
      studentId: '#10045',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/68bd8dfa-8f88-4ab5-9121-95542c36a86f',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Wendy Brown',
      studentId: '#10046',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/9d5c68a6-397b-450e-b49a-53bd76c4e699',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Xavier Clark',
      studentId: '#10047',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/43ed8622-3e0a-47c0-ad80-0f7117237557',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Yara Davis',
      studentId: '#10048',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/d59a4da6-1f5c-4ea1-9c43-ec24654ee867',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Zach Evans',
      studentId: '#10049',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/28811172-e490-4e1d-975b-d1be8b3eff89',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Amy Foster',
      studentId: '#10050',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/0a1ef463-f2e6-498e-bde5-6e54be0bd0ca',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Ben Green',
      studentId: '#10051',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/51cf797b-fbf3-4502-93ad-af18a517f421',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Cara Hill',
      studentId: '#10052',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/5a04e19d-eda5-4b2c-ba40-70f180eae902',
      isPresent: true,
    ),
    const AttendanceStudent(
      name: 'Drew Jones',
      studentId: '#10053',
      avatarUrl:
          'https://www.figma.com/api/mcp/asset/0fff43b4-0f60-482d-b7c1-356eac5c8585',
      isPresent: true,
    ),
  ];
}

class AttendanceStudent {
  final String name;
  final String studentId;
  final String avatarUrl;
  final bool isPresent;

  const AttendanceStudent({
    required this.name,
    required this.studentId,
    required this.avatarUrl,
    required this.isPresent,
  });
}
