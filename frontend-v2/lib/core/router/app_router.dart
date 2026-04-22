import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../screens/auth/login_screen.dart';
import '../../screens/admin/admin_home_screen.dart';
import '../../screens/student/student_home_screen.dart';
import '../../screens/teacher/teacher_home_screen.dart';
import '../../screens/parent/parent_home_screen.dart';
import '../../screens/super_admin/super_admin_home_screen.dart';
import '../../screens/staff/staff_home_screen.dart';
import '../services/auth_service.dart';

/// Navigation service using go_router with role-based routing
class AppRouter {
  static final _instance = AppRouter._internal();
  factory AppRouter() => _instance;
  AppRouter._internal();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  late final GoRouter router;

  void initialize() {
    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/login',
      redirect: _globalRedirect,
      routes: [
        // Auth routes
        GoRoute(
          path: '/login',
          name: 'login',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const LoginScreen(),
          ),
        ),

        // Dashboard route - redirects to role-based home screen
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: _getRoleBasedHome(context),
          ),
        ),

        // Home route alias
        GoRoute(
          path: '/home',
          name: 'home',
          redirect: (context, state) => '/dashboard',
        ),

        // Role-specific routes
        GoRoute(
          path: '/admin',
          name: 'admin_home',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const AdminHomeScreen(),
          ),
        ),
        GoRoute(
          path: '/teacher',
          name: 'teacher_home',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const TeacherHomeScreen(),
          ),
        ),
        GoRoute(
          path: '/student',
          name: 'student_home',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const StudentHomeScreen(),
          ),
        ),
        GoRoute(
          path: '/parent',
          name: 'parent_home',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const ParentHomeScreen(),
          ),
        ),
        GoRoute(
          path: '/super-admin',
          name: 'super_admin_home',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const SuperAdminHomeScreen(),
          ),
        ),
        GoRoute(
          path: '/staff',
          name: 'staff_home',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const StaffHomeScreen(),
          ),
        ),
      ],
    );
  }

  /// Global redirect logic for authentication and role-based routing
  String? _globalRedirect(BuildContext context, GoRouterState state) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isLoggedIn = authService.isLoggedIn;
    final currentLocation = state.matchedLocation;

    // If not logged in and not going to login, redirect to login
    if (!isLoggedIn && currentLocation != '/login') {
      return '/login';
    }

    // If logged in and going to login, redirect to dashboard
    if (isLoggedIn && currentLocation == '/login') {
      return '/dashboard';
    }

    return null; // No redirect needed
  }

  /// Get the appropriate home screen based on user role
  Widget _getRoleBasedHome(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    final roleName = user?.role?.roleName.toLowerCase();

    return switch (roleName) {
      'super_admin' || 'super admin' => const SuperAdminHomeScreen(),
      'admin' => const AdminHomeScreen(),
      'teacher' => const TeacherHomeScreen(),
      'student' => const StudentHomeScreen(),
      'parent' => const ParentHomeScreen(),
      'staff' => const StaffHomeScreen(),
      _ => _buildUnknownRoleScreen(context, roleName),
    };
  }

  /// Fallback screen for unknown or null roles
  Widget _buildUnknownRoleScreen(BuildContext context, String? roleName) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Error'),
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Dashboard not configured for role: ${roleName ?? 'Unknown'}',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => logout(),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  // Navigation methods
  void goToLogin() => router.goNamed('login');
  void goToDashboard() => router.goNamed('dashboard');
  void goToHome() => router.goNamed('dashboard');

  void logout() {
    final context = _rootNavigatorKey.currentContext;
    if (context != null) {
      final authService = Provider.of<AuthService>(context, listen: false);
      authService.logout();
    }
    goToLogin();
  }
}