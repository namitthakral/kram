import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/services/api_service.dart';
import 'core/services/app_lifecycle_service.dart';
import 'modules/parent/providers/parent_dashboard_provider.dart';
import 'modules/parent/providers/parent_tab_provider.dart';
import 'modules/student/providers/dashboard_tab_provider.dart';
import 'modules/student/providers/student_dashboard_provider.dart';
import 'modules/teacher/providers/performance_tab_provider.dart';
import 'modules/teacher/providers/teacher_dashboard_provider.dart';
import 'modules/teacher/screens/teacher_dashboard_screen.dart';
import 'provider/bottom_nav_provider.dart';
import 'provider/dashboard/favourite_provider.dart';
import 'provider/language_provider.dart';
import 'provider/login_signup/login_provider.dart';
import 'provider/login_signup/signup_provider.dart';
import 'provider/onboarding_provider.dart';
import 'provider/profile/security/security_provider.dart';
import 'provider/segmented_control_provider.dart';
import 'provider/theme_provider.dart';
import 'utils/extensions.dart';
import 'utils/global_constants.dart';
import 'utils/localization/app_localizations.dart';
import 'utils/router_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  RouterService().init();
  ApiService().init();

  // Configure web-specific settings
  if (kIsWeb) {
    // Add custom error handling for web
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (kDebugMode) {
        // Log to console in debug mode
        log('Error==>${details.toString()}');
      }
    };
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()..loadLocale()),
        ChangeNotifierProvider(create: (_) => BottomNavProvider()),
        ChangeNotifierProvider(create: (_) => ProfileSecurityProvider()),
        ChangeNotifierProvider(create: (_) => FavouriteProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => SignUpProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
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
        ChangeNotifierProvider<ParentDashboardProvider>(
          create: (_) => ParentDashboardProvider(),
        ),
        ChangeNotifierProvider<ParentTabProvider>(
          create: (_) => ParentTabProvider(),
        ),
        ChangeNotifierProvider(create: (_) => StudentDashboardProvider()),
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
