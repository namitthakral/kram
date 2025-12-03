import 'package:flutter/material.dart';

import '../../models/navigation_item_model.dart';
import '../../modules/admin/screens/admin_dashboard_screen.dart';
import '../../modules/library/screens/library_dashboard_screen.dart';
import '../../modules/parent/screens/parent_dashboard_screen.dart';
import '../../modules/student/screens/student_dashboard_screen.dart';
import '../../modules/teacher/screens/academic_management_screen.dart';
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

  static final List<Widget> _studentPages = [
    const StudentDashboardScreen(),
    const Center(child: Text('Schedule Screen')), // TODO: Implement
    const Center(child: Text('Messages Screen')), // TODO: Implement
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
      iconUrl: CustomImages.iconSchedule,
      iconFilledUrl: CustomImages.iconScheduleFilled,
      labelKey: 'children',
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

  static final List<Widget> _parentPages = [
    const ParentDashboardScreen(),
    const Center(child: Text('Children Screen')), // TODO: Implement
    const Center(child: Text('Messages Screen')), // TODO: Implement
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
      iconUrl: CustomImages.iconSchedule,
      iconFilledUrl: CustomImages.iconScheduleFilled,
      labelKey: 'classes',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconAcademic,
      iconFilledUrl: CustomImages.iconAcademicFilled,
      labelKey: 'academic',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconReport,
      iconFilledUrl: CustomImages.iconReportFilled,
      labelKey: 'reports',
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

  static final List<Widget> _teacherPages = [
    const TeacherDashboardScreen(),
    const Center(child: Text('Classes Screen')), // TODO: Implement
    const AcademicManagementScreen(),
    const Center(
      child: Text('Reports Screen\n(Student Reports, Marksheets)'),
    ), // TODO: Implement
    const Center(child: Text('Messages Screen')), // TODO: Implement
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
    const Center(child: Text('Books Management Screen')), // TODO: Implement
    const Center(child: Text('Issued Books Screen')), // TODO: Implement
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
      iconUrl: CustomImages.iconSchedule,
      iconFilledUrl: CustomImages.iconScheduleFilled,
      labelKey: 'management',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconMessage,
      iconFilledUrl: CustomImages.iconMessageFilled,
      labelKey: 'reports',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconProfile,
      iconFilledUrl: CustomImages.iconProfileFilled,
      labelKey: 'profile',
    ),
  ];

  static final List<Widget> _adminPages = [
    const AdminDashboardScreen(),
    const Center(child: Text('Management Screen')), // TODO: Implement
    const Center(child: Text('Reports Screen')), // TODO: Implement
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
    const Center(child: Text('Schedule Screen')), // TODO: Implement
    const Center(child: Text('Messages Screen')), // TODO: Implement
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
      iconUrl: CustomImages.iconMessage,
      iconFilledUrl: CustomImages.iconMessageFilled,
      labelKey: 'analytics',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconProfile,
      iconFilledUrl: CustomImages.iconProfileFilled,
      labelKey: 'profile',
    ),
  ];

  static final List<Widget> _superAdminPages = [
    const SuperAdminDashboardScreen(),
    const Center(child: Text('Institutions Screen')), // TODO: Implement
    const Center(child: Text('Analytics Screen')), // TODO: Implement
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
}
