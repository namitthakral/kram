import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../modules/admin/screens/admin_dashboard_screen.dart';
import '../modules/admin/screens/admin_reports_screen.dart';
import '../modules/admin/screens/fees_management_screen.dart';
import '../modules/admin/screens/transport_screen.dart';
import '../modules/library/screens/books_management_screen.dart';
import '../modules/library/screens/issued_books_screen.dart';
import '../modules/library/screens/library_dashboard_screen.dart';
import '../modules/parent/screens/announcements_screen.dart';
import '../modules/parent/screens/child_progress_screen.dart';
import '../modules/parent/screens/fee_payment_screen.dart';
import '../modules/parent/screens/parent_dashboard_screen.dart';
import '../modules/staff/screens/staff_messages_screen.dart';
import '../modules/staff/screens/staff_schedule_screen.dart';
import '../modules/student/screens/assignments_screen.dart';
import '../modules/student/screens/events_screen.dart';
import '../modules/student/screens/my_grades_screen.dart';
import '../modules/student/screens/student_dashboard_screen.dart';
import '../modules/student/screens/timetable_screen.dart';
import '../modules/super_admin/screens/analytics_screen.dart';
import '../modules/super_admin/screens/institutions_screen.dart';
import '../modules/super_admin/screens/security_screen.dart';
import '../modules/super_admin/screens/system_settings_screen.dart';
import '../modules/teacher/screens/academic_management_screen.dart';
import '../modules/teacher/screens/assignments_list_screen.dart';
import '../modules/teacher/screens/attendance_screen.dart';
import '../modules/teacher/screens/attendance_view_screen.dart';
import '../modules/teacher/screens/class_detail_screen.dart';
import '../modules/teacher/screens/create_assignment_screen.dart';
import '../modules/teacher/screens/examination_form_screen.dart';
import '../modules/teacher/screens/examinations_list_screen.dart';
import '../modules/teacher/screens/marks_list_screen.dart';
import '../modules/teacher/screens/my_classes_screen.dart';
import '../modules/teacher/screens/question_paper_template_screen.dart';
import '../modules/teacher/screens/question_papers_list_screen.dart';
import '../modules/teacher/screens/student_detail_screen.dart';
import '../modules/teacher/screens/teacher_dashboard_screen.dart';
import '../modules/teacher/screens/timetable_management_screen.dart';
import '../modules/teacher/screens/timetable_template_screen.dart';
import '../modules/teacher/screens/timetable_view_screen.dart';
import '../provider/login_signup/login_provider.dart';
import '../views/dashboard/staff_dashboard_screen.dart';
import '../views/dashboard/super_admin_dashboard_screen.dart';
import '../views/home_screen.dart';
import '../views/login_register/login_register_main.dart';
import '../views/onboarding/onboarding_main.dart';
import '../views/profile/profile_screen.dart';
import '../views/splash_screen.dart';

/// A singleton service to handle routing with go_router
class RouterService {
  factory RouterService() => _instance;
  RouterService._internal();
  // Singleton instance
  static final RouterService _instance = RouterService._internal();

  // Login provider for auth state
  LoginProvider? _loginProvider;

  // Router configuration
  late final GoRouter router;

  // Navigator key for ShellRoute
  final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  // Stream controller for route changes
  final StreamController<String> _routeStreamController =
      StreamController<String>.broadcast();
  Stream<String> get routeStream => _routeStreamController.stream;

  // Initialize the router
  void init(LoginProvider loginProvider) {
    _loginProvider = loginProvider;

    router = GoRouter(
      initialLocation: '/splash',
      // errorBuilder: (context, state) => const NotFoundPage(),
      routes: _routes,
      redirect: _globalRedirect,
      refreshListenable: Listenable.merge([
        GoRouterRefreshStream(routeStream),
        loginProvider,
      ]),
      observers: [RouteObserver()],
    );
  }

  // Global redirect function for authentication or other global conditions
  String? _globalRedirect(BuildContext context, GoRouterState state) {
    final isLoggedIn = _loginProvider?.currentUser != null;
    final isGoingToLogin = state.matchedLocation == '/login';
    final isSplash = state.matchedLocation == '/splash';
    final isOnboarding = state.matchedLocation == '/onboarding';

    // Specify public routes that don't require authentication
    if (isSplash || isGoingToLogin || isOnboarding) {
      return null;
    }

    if (!isLoggedIn) {
      return '/login';
    }

    // If logged in and going to login page, redirect to dashboard
    if (isLoggedIn && isGoingToLogin) {
      return '/dashboard';
    }

    return null; // No redirect needed
  }

  // Define all routes
  List<RouteBase> get _routes => [
    // Root route - redirects to dashboard
    GoRoute(
      path: '/',
      name: 'root',
      redirect: (context, state) => '/dashboard',
    ),
    GoRoute(
      path: '/splash',
      name: 'splash',
      pageBuilder:
          (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const SplashScreen(),
          ),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      pageBuilder:
          (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const OnboardingMain(),
          ),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder:
          (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const LoginRegisterMain(),
          ),
    ),
    // Legacy /home route - redirects to dashboard
    GoRoute(
      path: '/home',
      name: 'home',
      redirect: (context, state) => '/dashboard',
    ),

    // ShellRoute for main navigation - maintains the home screen layout
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => HomeScreen(child: child),
      routes: [
        // Dashboard route (role-agnostic, shows appropriate dashboard based on user role)
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: _getRoleDashboard(context),
              ),
        ),

        // Profile route (common to all roles)
        GoRoute(
          path: '/profile',
          name: 'profile',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const ProfileScreen(),
              ),
        ),

        // Teacher-specific routes
        GoRoute(
          path: '/classes',
          name: 'my_classes',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const MyClassesScreen(),
              ),
          routes: [
            GoRoute(
              path: ':className/:sectionId',
              name: 'class_detail',
              pageBuilder: (context, state) {
                final className = state.pathParameters['className'] ?? 'Class';
                final sectionId =
                    int.tryParse(state.pathParameters['sectionId'] ?? '') ?? 0;
                final courseId = int.tryParse(
                  state.uri.queryParameters['courseId'] ?? '',
                );

                return _buildPageWithTransition(
                  key: state.pageKey,
                  child: ClassDetailScreen(
                    className: className,
                    sectionId: sectionId,
                    courseId: courseId,
                  ),
                );
              },
              routes: [
                GoRoute(
                  path: 'student/:studentId',
                  name: 'student_detail',
                  pageBuilder: (context, state) {
                    final studentId = state.pathParameters['studentId'] ?? '0';
                    final className =
                        state.pathParameters['className'] ?? 'Class';
                    final sectionId = state.pathParameters['sectionId'] ?? '0';
                    final studentData =
                        state.extra as Map<String, dynamic>? ?? {};

                    return _buildPageWithTransition(
                      key: state.pageKey,
                      child: StudentDetailScreen(
                        studentId: studentId,
                        className: className,
                        sectionId: sectionId,
                        studentData: studentData,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),

        // Academic route (for teachers and admins)
        GoRoute(
          path: '/academic',
          name: 'academic_management',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const AcademicManagementScreen(),
              ),
          routes: [
            GoRoute(
              path: 'attendance',
              name: 'attendance_view',
              pageBuilder:
                  (context, state) => _buildPageWithTransition(
                    key: state.pageKey,
                    child: const AttendanceViewScreen(),
                  ),
            ),
            GoRoute(
              path: 'mark-attendance',
              name: 'mark_attendance',
              pageBuilder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                return _buildPageWithTransition(
                  key: state.pageKey,
                  child: AttendanceScreen(
                    sectionId: extra?['sectionId'] as int?,
                    className: extra?['className'] as String?,
                  ),
                );
              },
            ),
            GoRoute(
              path: 'marks',
              name: 'marks_list',
              pageBuilder:
                  (context, state) => _buildPageWithTransition(
                    key: state.pageKey,
                    child: const MarksListScreen(),
                  ),
            ),
            GoRoute(
              path: 'assignments',
              name: 'assignments_list',
              pageBuilder:
                  (context, state) => _buildPageWithTransition(
                    key: state.pageKey,
                    child: const AssignmentsListScreen(),
                  ),
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'create_assignment',
                  pageBuilder:
                      (context, state) => _buildPageWithTransition(
                        key: state.pageKey,
                        child: const CreateAssignmentScreen(),
                      ),
                ),
              ],
            ),
            GoRoute(
              path: 'timetables',
              name: 'timetables_list',
              pageBuilder:
                  (context, state) => _buildPageWithTransition(
                    key: state.pageKey,
                    child: const TimetableManagementScreen(),
                  ),
              routes: [
                GoRoute(
                  path: 'view',
                  name: 'timetable_view',
                  pageBuilder:
                      (context, state) => _buildPageWithTransition(
                        key: state.pageKey,
                        child: const TimetableViewScreen(),
                      ),
                ),
                GoRoute(
                  path: 'create',
                  name: 'create_timetable',
                  pageBuilder:
                      (context, state) => _buildPageWithTransition(
                        key: state.pageKey,
                        child: const TimetableTemplateScreen(),
                      ),
                ),
              ],
            ),
            GoRoute(
              path: 'exams',
              name: 'examinations_list',
              pageBuilder:
                  (context, state) => _buildPageWithTransition(
                    key: state.pageKey,
                    child: const ExaminationsListScreen(),
                  ),
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'create_exam',
                  pageBuilder:
                      (context, state) => _buildPageWithTransition(
                        key: state.pageKey,
                        child: const ExaminationFormScreen(),
                      ),
                ),
                GoRoute(
                  path: ':id',
                  name: 'edit_exam',
                  pageBuilder: (context, state) {
                    final id = int.tryParse(state.pathParameters['id'] ?? '');
                    return _buildPageWithTransition(
                      key: state.pageKey,
                      child: ExaminationFormScreen(examinationId: id),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: 'question-paper',
              name: 'question_papers_list',
              pageBuilder:
                  (context, state) => _buildPageWithTransition(
                    key: state.pageKey,
                    child: const QuestionPapersListScreen(),
                  ),
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'create_question_paper',
                  pageBuilder:
                      (context, state) => _buildPageWithTransition(
                        key: state.pageKey,
                        child: const QuestionPaperTemplateScreen(),
                      ),
                ),
              ],
            ),
          ],
        ),

        // Student-specific routes
        GoRoute(
          path: '/grades',
          name: 'student_grades',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const MyGradesScreen(),
              ),
        ),
        GoRoute(
          path: '/timetable',
          name: 'student_timetable',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const TimetableScreen(),
              ),
        ),
        GoRoute(
          path: '/assignments',
          name: 'student_assignments',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const AssignmentsScreen(),
              ),
        ),
        GoRoute(
          path: '/events',
          name: 'student_events',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const EventsScreen(),
              ),
        ),

        // Admin-specific routes
        GoRoute(
          path: '/students',
          name: 'admin_students',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const StudentDashboardScreen(),
              ),
        ),
        GoRoute(
          path: '/staff',
          name: 'admin_staff',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const StaffDashboardScreen(),
              ),
        ),
        GoRoute(
          path: '/fees',
          name: 'admin_fees',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const FeesManagementScreen(),
              ),
        ),
        GoRoute(
          path: '/transport',
          name: 'admin_transport',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const TransportScreen(),
              ),
        ),
        GoRoute(
          path: '/reports',
          name: 'admin_reports',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const AdminReportsScreen(),
              ),
        ),

        // Parent-specific routes
        GoRoute(
          path: '/child-progress',
          name: 'parent_child_progress',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const ChildProgressScreen(),
              ),
        ),
        GoRoute(
          path: '/fee-payment',
          name: 'parent_fee_payment',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const FeePaymentScreen(),
              ),
        ),
        GoRoute(
          path: '/announcements',
          name: 'parent_announcements',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const AnnouncementsScreen(),
              ),
        ),

        // Librarian-specific routes
        GoRoute(
          path: '/books',
          name: 'librarian_books',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const BooksManagementScreen(),
              ),
        ),
        GoRoute(
          path: '/issued-books',
          name: 'librarian_issued_books',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const IssuedBooksScreen(),
              ),
        ),

        // Staff-specific routes
        GoRoute(
          path: '/schedule',
          name: 'staff_schedule',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const StaffScheduleScreen(),
              ),
        ),
        GoRoute(
          path: '/messages',
          name: 'staff_messages',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const StaffMessagesScreen(),
              ),
        ),

        // Super Admin-specific routes
        GoRoute(
          path: '/institutions',
          name: 'super_admin_institutions',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const InstitutionsScreen(),
              ),
        ),
        GoRoute(
          path: '/analytics',
          name: 'super_admin_analytics',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const AnalyticsScreen(),
              ),
        ),
        GoRoute(
          path: '/system-settings',
          name: 'super_admin_settings',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const SystemSettingsScreen(),
              ),
        ),
        GoRoute(
          path: '/security',
          name: 'super_admin_security',
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const SecurityScreen(),
              ),
        ),
      ],
    ),
  ];

  // Helper method to get the appropriate dashboard based on user role
  Widget _getRoleDashboard(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final roleId = loginProvider.currentUser?.role?.id;

    return switch (roleId) {
      1 => const SuperAdminDashboardScreen(), // Super Admin
      2 => const AdminDashboardScreen(), // Admin
      3 => const StudentDashboardScreen(), // Student
      4 => const ParentDashboardScreen(), // Parent
      5 => const TeacherDashboardScreen(), // Teacher
      6 => const LibraryDashboardScreen(), // Librarian
      7 => const StaffDashboardScreen(), // Staff
      _ => const Center(child: Text('Dashboard not configured for this role')),
    };
  }

  // Helper method to build pages with consistent fade transition (better for web)
  CustomTransitionPage<void> _buildPageWithTransition({
    required LocalKey key,
    required Widget child,
  }) => CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Use fade transition for web (no slide), looks more native
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 200),
  );

  // Navigation methods
  void goToHome() => router.goNamed('home');

  void goToOnboarding() => router.pushNamed('onboarding');

  void goToProfile(String userId) =>
      router.pushNamed('profile', pathParameters: {'userId': userId});

  void goToSearch() => router.pushNamed('search');

  void goToLogin() => router.goNamed('login');

  void goToCart() => router.pushNamed('cart');

  void goToCheckout() => router.pushNamed('checkout');

  void gotToProduct(String productId) => router.pushNamed(
    'product_detail',
    pathParameters: {'productId': productId},
  );

  void goBack() => router.pop();

  // Method to navigate by string path (useful for deep links)
  void navigateToPath(String path) => router.go(path);

  // Utility method for deep link handling
  Future<void> handleDeepLink(String link) async {
    final uri = Uri.parse(link);
    final path = uri.path.isEmpty ? '/' : uri.path;

    // Convert URI query parameters to a map
    // final queryParams = uri.queryParameters;

    // Determine the correct route based on path
    if (path.startsWith('/profile/')) {
      final userId = path.split('/').last;
      goToProfile(userId);
    } /*  else if (path == '/settings') {
      goToSettings();
    }  else if (path == '/details') {
      goToDetails(
        productId: queryParams['id'],
        category: queryParams['category'],
      );
    } */ else if (path == '/' || path.isEmpty) {
      goToHome();
    } else {
      // Handle unknown paths or custom deep link formats
      navigateToPath(path);
    }

    // Notify stream about route change
    _routeStreamController.add(path);
  }

  // Perform full logout
  Future<void> performLogout() async {
    log('🚪 RouterService: Performing full logout...');
    if (_loginProvider != null) {
      await _loginProvider!.logout();
    }
    goToLogin();
  }

  // Clean up resources
  void dispose() {
    _routeStreamController.close();
  }
}

// Extension to make the router globally accessible
extension RouterServiceExtension on BuildContext {
  RouterService get router => RouterService();
}

// Helper class to allow Stream to work with GoRouter's refreshListenable
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
