import 'package:flutter/material.dart';

import '../../models/navigation_item_model.dart';
import '../../modules/admin/screens/admin_dashboard_screen.dart';
import '../../modules/admin/screens/admin_student_management_screen.dart';
import '../../modules/admin/screens/admin_teachers_screen.dart';
import '../../modules/library/screens/books_management_screen.dart';
import '../../modules/library/screens/issued_books_screen.dart';
import '../../modules/library/screens/library_dashboard_screen.dart';
import '../../modules/parent/screens/child_progress_screen.dart';
import '../../modules/parent/screens/parent_dashboard_screen.dart';
import '../../modules/staff/screens/staff_messages_screen.dart';
import '../../modules/staff/screens/staff_schedule_screen.dart';
import '../../modules/student/screens/student_academic_screen.dart';
import '../../modules/student/screens/student_dashboard_screen.dart';
import '../../modules/super_admin/screens/analytics_screen.dart';
import '../../modules/super_admin/screens/institutions_screen.dart';
import '../../modules/super_admin/screens/security_screen.dart';
import '../../modules/super_admin/screens/system_settings_screen.dart';
import '../../modules/teacher/screens/academic_management_screen.dart';
import '../../modules/teacher/screens/my_classes_screen.dart';
import '../../modules/teacher/screens/teacher_dashboard_screen.dart';
import '../../utils/custom_images.dart';
import '../../views/dashboard/staff_dashboard_screen.dart';
import '../../views/dashboard/super_admin_dashboard_screen.dart';
import '../../views/profile/profile_screen.dart';

/// Role-based navigation configuration
/// Maps each role ID to its navigation items and pages
/// ⚠️ CRITICAL: NEVER CHANGE THESE ROLE IDs - They match the database schema
/// 1 = super_admin, 2 = admin, 3 = student, 4 = parent, 5 = teacher, 6 = librarian, 7 = staff
class RoleNavigationConfig {
  RoleNavigationConfig._();

  /// Get navigation items for a specific role
  static List<NavigationItemModel> getNavigationItems(int roleId) =>
      switch (roleId) {
        1 => _superAdminNavigationItems, // Super Admin
        2 => _adminNavigationItems, // Admin
        3 => _studentNavigationItems, // Student
        4 => _parentNavigationItems, // Parent
        5 => _teacherNavigationItems, // Teacher
        6 => _librarianNavigationItems, // Librarian
        7 => _staffNavigationItems, // Staff
        _ => _defaultNavigationItems, // Default fallback
      };

  /// Get pages for a specific role
  static List<Widget> getPages(int roleId) => switch (roleId) {
    1 => _superAdminPages, // Super Admin
    2 => _adminPages, // Admin
    3 => _studentPages, // Student
    4 => _parentPages, // Parent
    5 => _teacherPages, // Teacher
    6 => _librarianPages, // Librarian
    7 => _staffPages, // Staff
    _ => _defaultPages, // Default fallback
  };

  // ========== STUDENT (Role ID: 3) ==========
  static const List<NavigationItemModel> _studentNavigationItems = [
    NavigationItemModel(
      iconUrl: CustomImages.iconHome,
      iconFilledUrl: CustomImages.iconHomeFilled,
      labelKey: 'home',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconAcademic, // Academic Master Screen
      iconFilledUrl: CustomImages.iconAcademicFilled,
      labelKey: 'academic',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconProfile, // Placeholder for Fees
      iconFilledUrl: CustomImages.iconProfileFilled,
      labelKey: 'fees',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconProfile,
      iconFilledUrl: CustomImages.iconProfileFilled,
      labelKey: 'profile',
    ),
  ];

  static final List<Widget> _studentPages = [
    const StudentDashboardScreen(),
    const StudentAcademicScreen(),
    const Center(
      child: Text('Fees Screen Placeholder'),
    ), // Will be replaced by router
    const ProfileScreen(),
  ];

  // ========== PARENT (Role ID: 4) ==========
  static const List<NavigationItemModel> _parentNavigationItems = [
    NavigationItemModel(
      iconUrl: CustomImages.iconHome,
      iconFilledUrl: CustomImages.iconHomeFilled,
      labelKey: 'home',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconUser, // Placeholder for child progress
      iconFilledUrl: CustomImages.iconUser,
      labelKey: 'child_progress',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconProfile,
      iconFilledUrl: CustomImages.iconProfileFilled,
      labelKey: 'profile',
    ),
  ];

  static final List<Widget> _parentPages = [
    const ParentDashboardScreen(),
    const ChildProgressScreen(),
    const ProfileScreen(),
  ];

  // ========== TEACHER (Role ID: 5) ==========
  static const List<NavigationItemModel> _teacherNavigationItems = [
    NavigationItemModel(
      iconUrl: CustomImages.iconHome,
      iconFilledUrl: CustomImages.iconHomeFilled,
      labelKey: 'home',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconUser,
      iconFilledUrl: CustomImages.iconUser,
      labelKey: 'my_classes',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconSetting4,
      iconFilledUrl: CustomImages.iconSetting4,
      labelKey: 'academic',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconProfile,
      iconFilledUrl: CustomImages.iconProfileFilled,
      labelKey: 'profile',
    ),
  ];

  static final List<Widget> _teacherPages = [
    const TeacherDashboardScreen(),
    const MyClassesScreen(),
    const AcademicManagementScreen(),
    const ProfileScreen(),
  ];

  // ========== LIBRARIAN (Role ID: 6) ==========
  static const List<NavigationItemModel> _librarianNavigationItems = [
    NavigationItemModel(
      iconUrl: CustomImages.iconHome,
      iconFilledUrl: CustomImages.iconHomeFilled,
      labelKey: 'home',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconSchedule,
      iconFilledUrl: CustomImages.iconScheduleFilled,
      labelKey: 'books',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconMessage,
      iconFilledUrl: CustomImages.iconMessageFilled,
      labelKey: 'issued_books',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconProfile,
      iconFilledUrl: CustomImages.iconProfileFilled,
      labelKey: 'profile',
    ),
  ];

  static final List<Widget> _librarianPages = [
    const LibraryDashboardScreen(),
    const BooksManagementScreen(),
    const IssuedBooksScreen(),
    const ProfileScreen(),
  ];

  // ========== ADMIN (Role ID: 2) ==========
  static const List<NavigationItemModel> _adminNavigationItems = [
    NavigationItemModel(
      iconUrl: CustomImages.iconHome,
      iconFilledUrl: CustomImages.iconHomeFilled,
      labelKey: 'home',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconUser,
      iconFilledUrl: CustomImages.iconUser,
      labelKey: 'students',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconAcademic,
      iconFilledUrl: CustomImages.iconAcademicFilled,
      labelKey: 'teachers',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconProfile,
      iconFilledUrl: CustomImages.iconProfileFilled,
      labelKey: 'fees',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconProfile,
      iconFilledUrl: CustomImages.iconProfileFilled,
      labelKey: 'profile',
    ),
  ];

  static final List<Widget> _adminPages = [
    const AdminDashboardScreen(),
    const AdminStudentManagementScreen(),
    const AdminTeachersScreen(),
    const Center(
      child: Text('Fees Screen Placeholder'), ), // Will be replaced by router
    const ProfileScreen(),
  ];

  // ========== STAFF (Role ID: 7) ==========
  static const List<NavigationItemModel> _staffNavigationItems = [
    NavigationItemModel(
      iconUrl: CustomImages.iconHome,
      iconFilledUrl: CustomImages.iconHomeFilled,
      labelKey: 'home',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconSchedule,
      iconFilledUrl: CustomImages.iconScheduleFilled,
      labelKey: 'schedule',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconMessage,
      iconFilledUrl: CustomImages.iconMessageFilled,
      labelKey: 'messages',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconProfile,
      iconFilledUrl: CustomImages.iconProfileFilled,
      labelKey: 'profile',
    ),
  ];

  static final List<Widget> _staffPages = [
    const StaffDashboardScreen(),
    const StaffScheduleScreen(),
    const StaffMessagesScreen(),
    const ProfileScreen(),
  ];

  // ========== SUPER ADMIN (Role ID: 1) ==========
  static const List<NavigationItemModel> _superAdminNavigationItems = [
    NavigationItemModel(
      iconUrl: CustomImages.iconHome,
      iconFilledUrl: CustomImages.iconHomeFilled,
      labelKey: 'home',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconSchedule,
      iconFilledUrl: CustomImages.iconScheduleFilled,
      labelKey: 'institutions',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconReport, // Analytics
      iconFilledUrl: CustomImages.iconReportFilled,
      labelKey: 'analytics',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconSetting4,
      iconFilledUrl: CustomImages.iconSetting4,
      labelKey: 'settings',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconLock,
      iconFilledUrl: CustomImages.iconLock,
      labelKey: 'security',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconProfile,
      iconFilledUrl: CustomImages.iconProfileFilled,
      labelKey: 'profile',
    ),
  ];

  static final List<Widget> _superAdminPages = [
    const SuperAdminDashboardScreen(),
    const InstitutionsScreen(),
    const AnalyticsScreen(),
    const SystemSettingsScreen(),
    const SecurityScreen(),
    const ProfileScreen(),
  ];

  // ========== DEFAULT ==========
  static const List<NavigationItemModel> _defaultNavigationItems = [
    NavigationItemModel(
      iconUrl: CustomImages.iconHome,
      iconFilledUrl: CustomImages.iconHomeFilled,
      labelKey: 'home',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconProfile,
      iconFilledUrl: CustomImages.iconProfileFilled,
      labelKey: 'profile',
    ),
  ];

  static final List<Widget> _defaultPages = [
    const Center(child: Text('Dashboard not configured for this role')),
    const ProfileScreen(),
  ];

  /// Get the dashboard name for a specific role
  static String getDashboardName(int roleId) => switch (roleId) {
    1 => 'Super Admin Dashboard',
    2 => 'Admin Dashboard',
    3 => 'Student Dashboard',
    4 => 'Parent Dashboard',
    5 => 'Teacher Dashboard',
    6 => 'Library Dashboard',
    7 => 'Staff Dashboard',
    _ => 'Dashboard',
  };

  /// Check if a role has access to a specific feature
  static bool hasFeatureAccess(int roleId, String featureName) {
    // Define feature access per role
    final roleFeatures = <int, List<String>>{
      1: [
        'manage_institutions',
        'manage_all_data',
        'access_reports',
        'system_settings',
      ],
      2: [
        'manage_users',
        'manage_students',
        'manage_teachers',
        'access_reports',
      ],
      3: [
        'view_own_data',
        'submit_assignments',
        'view_grades',
        'request_gatepass',
      ],
      4: ['view_child_data', 'approve_gatepass', 'view_fees'],
      5: [
        'view_students',
        'manage_courses',
        'mark_attendance',
        'grade_assignments',
        'manage_exams',
        'manage_timetables',
        'manage_assignments',
        'view_student_reports',
        'generate_marksheets',
      ],
      6: ['manage_books', 'manage_issues', 'view_library_reports'],
      7: ['view_own_data', 'mark_attendance', 'view_notices'],
    };

    return roleFeatures[roleId]?.contains(featureName) ?? false;
  }

  /// Get the route path for a specific role and navigation index
  static String getRoutePath(int roleId, int index) {
    final routes = _getRoutePathsForRole(roleId);
    if (index < 0 || index >= routes.length) {
      return '/dashboard';
    }
    return routes[index];
  }

  /// Get the navigation index from a route path for a specific role
  static int? getIndexFromRoute(int roleId, String route) {
    final routes = _getRoutePathsForRole(roleId);

    // Normalize the route (remove trailing slashes, handle nested routes)
    final normalizedRoute = route.split('?').first; // Remove query params

    // Check for exact match first
    final exactIndex = routes.indexOf(normalizedRoute);
    if (exactIndex != -1) {
      return exactIndex;
    }

    // Check if it's a nested route under /academic
    if (normalizedRoute.startsWith('/academic/') ||
        normalizedRoute.startsWith('/student-academic/')) {
      return routes.indexOf(
        normalizedRoute.startsWith('/student-academic/')
            ? '/student-academic'
            : '/academic',
      );
    }

    // Check for Student Academic sub-routes
    // These are top-level routes but belong to the 'Academic' tab (index 1)
    if (roleId == 3) {
      const studentAcademicRoutes = [
        '/grades',
        '/timetable',
        '/assignments',
        '/exams',
        '/events',
      ];
      if (studentAcademicRoutes.any(normalizedRoute.startsWith)) {
        return routes.indexOf('/student-academic');
      }
    }

    // Check if it's a nested route under /classes
    if (normalizedRoute.startsWith('/classes/')) {
      return routes.indexOf('/classes');
    }

    // Default to dashboard
    return 0;
  }

  /// Get route paths for a specific role
  static List<String> _getRoutePathsForRole(int roleId) => switch (roleId) {
    // Super Admin routes
    1 => [
      '/dashboard',
      '/institutions',
      '/analytics',
      '/system-settings',
      '/security',
      '/profile',
    ],
    // Admin routes (index 0 = dashboard so /dashboard highlights first tab)
    2 => ['/dashboard', '/students', '/teachers', '/fees', '/profile'],
    // Student routes
    3 => ['/dashboard', '/student-academic', '/my-fees', '/profile'],
    // Parent routes
    4 => ['/dashboard', '/child-progress', '/profile'],
    // Teacher routes
    5 => ['/dashboard', '/classes', '/academic', '/profile'],
    // Librarian routes
    6 => ['/dashboard', '/books', '/issued-books', '/profile'],
    // Staff routes
    7 => ['/dashboard', '/schedule', '/messages', '/profile'],
    // Default
    _ => ['/dashboard', '/profile'],
  };
}
