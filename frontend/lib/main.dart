import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'core/services/api_service.dart';
import 'core/services/app_lifecycle_service.dart';
import 'modules/admin/providers/admin_analytics_tab_provider.dart';
import 'modules/admin/providers/admin_dashboard_provider.dart';
import 'modules/admin/providers/grading_config_provider.dart';
import 'modules/library/providers/library_dashboard_provider.dart';
import 'modules/library/providers/library_filter_provider.dart';
import 'modules/library/providers/library_tab_provider.dart';
import 'modules/parent/providers/parent_dashboard_provider.dart';
import 'modules/parent/providers/parent_tab_provider.dart';
import 'modules/student/providers/dashboard_tab_provider.dart';
import 'modules/student/providers/report_card_provider.dart';
import 'modules/student/providers/student_attendance_provider.dart';
import 'modules/student/providers/student_dashboard_provider.dart';
import 'modules/student/providers/student_provider.dart';
import 'modules/teacher/providers/assignment_provider.dart';
import 'modules/teacher/providers/attendance_provider.dart';
import 'modules/teacher/providers/examination_provider.dart';
import 'modules/teacher/providers/marks_provider.dart';
import 'modules/teacher/providers/performance_tab_provider.dart';
import 'modules/teacher/providers/question_paper_provider.dart';
import 'modules/teacher/providers/teacher_classes_provider.dart';
import 'modules/teacher/providers/teacher_dashboard_provider.dart';
import 'modules/teacher/providers/timetable_provider.dart';
import 'modules/teacher/screens/teacher_dashboard_screen.dart';
import 'provider/bottom_nav_provider.dart';
import 'provider/courses_provider.dart';
import 'provider/dashboard/favourite_provider.dart';
import 'provider/language_provider.dart';
import 'provider/login_signup/login_provider.dart';
import 'provider/login_signup/signup_provider.dart';
import 'provider/onboarding_provider.dart';
import 'provider/profile/change_password_provider.dart';
import 'provider/profile/edit_profile_provider.dart';
import 'provider/profile/security/security_provider.dart';
import 'provider/segmented_control_provider.dart';
import 'provider/teachers_provider.dart';
import 'provider/theme_provider.dart';
import 'utils/global_constants.dart';
import 'utils/localization/app_localizations.dart';
import 'utils/router_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure web-specific settings
  if (kIsWeb) {
    // Use path-based URL strategy (removes # from URLs)
    usePathUrlStrategy();

    // Add custom error handling for web
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (kDebugMode) {
        // Log to console in debug mode
        log('Error==>${details.toString()}');
      }
    };
  }

  final loginProvider = LoginProvider();
  ApiService().init();
  RouterService().init(loginProvider);
  await loginProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()..loadLocale()),
        ChangeNotifierProvider(create: (_) => BottomNavProvider()),
        ChangeNotifierProvider(create: (_) => ProfileSecurityProvider()),
        ChangeNotifierProvider(create: (_) => ChangePasswordProvider()),
        ChangeNotifierProvider(create: (_) => EditProfileProvider()),
        ChangeNotifierProvider(create: (_) => FavouriteProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => SignUpProvider()),
        ChangeNotifierProvider.value(value: loginProvider),
        ChangeNotifierProvider<PerformanceTabProvider>(
          create: (_) => PerformanceTabProvider(),
        ),
        ChangeNotifierProvider<SegmentedControlProvider<PerformanceTab>>(
          create: (_) => PerformanceTabProvider(),
        ),
        ChangeNotifierProvider<DashboardTabProvider>(
          create: (_) => DashboardTabProvider(),
        ),
        ChangeNotifierProvider<TeacherDashboardProvider>(
          create: (_) => TeacherDashboardProvider(),
        ),
        ChangeNotifierProvider<AssignmentProvider>(
          create: (_) => AssignmentProvider(),
        ),
        ChangeNotifierProvider<ExaminationProvider>(
          create: (_) => ExaminationProvider(),
        ),
        ChangeNotifierProvider<AttendanceProvider>(
          create: (_) => AttendanceProvider(),
        ),
        ChangeNotifierProvider<MarksProvider>(create: (_) => MarksProvider()),
        ChangeNotifierProvider<ParentDashboardProvider>(
          create: (_) => ParentDashboardProvider(),
        ),
        ChangeNotifierProvider<ParentTabProvider>(
          create: (_) => ParentTabProvider(),
        ),
        ChangeNotifierProvider(create: (_) => StudentDashboardProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => StudentAttendanceProvider()),
        ChangeNotifierProvider<LibraryDashboardProvider>(
          create: (_) => LibraryDashboardProvider(),
        ),
        ChangeNotifierProvider<LibraryTabProvider>(
          create: (_) => LibraryTabProvider(),
        ),
        ChangeNotifierProvider<LibraryFilterProvider>(
          create: (_) => LibraryFilterProvider(),
        ),
        ChangeNotifierProvider<AdminDashboardProvider>(
          create: (_) => AdminDashboardProvider(),
        ),
        ChangeNotifierProvider<AdminAnalyticsTabProvider>(
          create: (_) => AdminAnalyticsTabProvider(),
        ),
        ChangeNotifierProvider<SegmentedControlProvider<AdminAnalyticsTab>>(
          create: (_) => AdminAnalyticsTabProvider(),
        ),
        ChangeNotifierProvider<GradingConfigProvider>(
          create: (_) => GradingConfigProvider(),
        ),
        ChangeNotifierProvider<ReportCardProvider>(
          create: (_) => ReportCardProvider(),
        ),
        ChangeNotifierProvider<TimetableProvider>(
          create: (_) => TimetableProvider(),
        ),
        ChangeNotifierProvider<QuestionPaperProvider>(
          create: (_) => QuestionPaperProvider(),
        ),
        ChangeNotifierProvider<CoursesProvider>(
          create: (_) => CoursesProvider(),
        ),
        ChangeNotifierProvider<TeachersProvider>(
          create: (_) => TeachersProvider(),
        ),
        ChangeNotifierProvider<TeacherClassesProvider>(
          create: (_) => TeacherClassesProvider(),
        ),
      ],
      child: const EdVerseApp(),
    ),
  );
}

class EdVerseApp extends StatefulWidget {
  const EdVerseApp({super.key});

  @override
  State<EdVerseApp> createState() => _EdVerseAppState();
}

class _EdVerseAppState extends State<EdVerseApp> {
  final AppLifecycleService _lifecycleService = AppLifecycleService();

  @override
  void initState() {
    super.initState();
    // Initialize lifecycle service after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _lifecycleService.init(context);
      }
    });
  }

  @override
  void dispose() {
    _lifecycleService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        }
      },
      child: Consumer<LanguageProvider>(
        builder:
            (context, languageProvider, child) => MaterialApp.router(
              title: 'EdVerse',
              // title: context.translate('app_name'),
              scaffoldMessengerKey: GlobalConstants.snackbarKey,
              debugShowCheckedModeBanner: false,
              themeMode: themeProvider.themeMode,
              theme: themeProvider.lightTheme,
              darkTheme: themeProvider.darkTheme,
              locale: languageProvider.locale,
              supportedLocales: languageProvider.supportedLocales,
              localizationsDelegates: const [
                AppLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: RouterService().router,
            ),
      ),
    );
  }
}
