class RouteConstants {
  // Auth Routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Main App Routes
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String about = '/about';

  // Teacher Routes
  static const String teacherClasses = '/classes';
  static const String teacherAcademic = '/academic';

  // Student Routes
  static const String studentGrades = '/grades';
  static const String studentTimetable = '/timetable';
  static const String studentAssignments = '/assignments';
  static const String studentAssignmentDetail = 'detail';
  static const String studentAttendance = '/attendance';
  static const String studentEvents = '/events';

  // Admin Routes
  static const String adminStudents = '/students';
  static const String adminStaff = '/staff';
  static const String adminFees = '/fees';
  static const String adminTransport = '/transport';
  static const String adminAcademic = '/academic';
  static const String adminReports = '/reports';

  // Parent Routes
  static const String parentChildProgress = '/child-progress';
  static const String parentFeePayment = '/fee-payment';
  static const String parentAnnouncements = '/announcements';

  // Librarian Routes
  static const String librarianBooks = '/books';
  static const String librarianIssuedBooks = '/issued-books';

  // Staff Routes
  static const String staffSchedule = '/schedule';
  static const String staffMessages = '/messages';

  // Super Admin Routes
  static const String superAdminInstitutions = '/institutions';
  static const String superAdminAnalytics = '/analytics';
  static const String superAdminSettings = '/system-settings';
  static const String superAdminSecurity = '/security';

  // Academic Management Nested Routes
  static const String academicAttendance = '/academic/attendance';
  static const String academicMarks = '/academic/marks';
  static const String academicMarksList = '/academic/marks';
  static const String academicEnterMarks = '/academic/marks/enter';
  static const String academicAssignments = '/academic/assignments';
  static const String academicCreateAssignment = '/academic/assignments/create';
  static const String academicTimetables = '/academic/timetables';
  static const String academicTimetableView = '/academic/timetables/view';
  static const String academicCreateTimetable = '/academic/timetables/create';
  static const String academicClasses = '/academic/classes';
  static const String academicExams = '/academic/exams';
  static const String academicCreateExam = '/academic/exams/create';
  static const String academicQuestionPapers = '/academic/question-paper';
  static const String academicCreateQuestionPaper =
      '/academic/question-paper/create';

  // Feature Routes (legacy - may be deprecated)
  static const String courseDetail = '/course-detail';
  static const String lessonDetail = '/lesson-detail';
  static const String quiz = '/quiz';
  static const String assignment = '/assignment';

  // Nested Routes (legacy - may be deprecated)
  static const String profileEdit = '/profile/edit';
  static const String settingsTheme = '/settings/theme';
  static const String settingsLanguage = '/settings/language';
  static const String settingsNotifications = '/settings/notifications';
}
