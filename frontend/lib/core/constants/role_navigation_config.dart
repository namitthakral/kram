import 'package:flutter/material.dart';

import '../../models/navigation_item_model.dart';
import '../../modules/parent/screens/parent_dashboard_screen.dart';
import '../../modules/student/screens/student_dashboard_screen.dart';
import '../../modules/teacher/screens/teacher_dashboard_screen.dart';
import '../../utils/custom_images.dart';
import '../../views/dashboard/admin_dashboard_screen.dart';
import '../../views/dashboard/librarian_dashboard_screen.dart';
import '../../views/dashboard/staff_dashboard_screen.dart';
import '../../views/dashboard/super_admin_dashboard_screen.dart';
import '../../views/profile/profile_screen.dart';

/// Role-based navigation configuration
/// Maps each role ID to its navigation items and pages
class RoleNavigationConfig {
  RoleNavigationConfig._();

  /// Get navigation items for a specific role
  static List<NavigationItemModel> getNavigationItems(int roleId) =>
      switch (roleId) {
        1 => _parentNavigationItems, // Parent
        2 => _studentNavigationItems, // Student
        3 => _librarianNavigationItems, // Librarian
        4 => _teacherNavigationItems, // Teacher
        5 => _adminNavigationItems, // Admin
        6 => _staffNavigationItems, // Staff
        7 => _superAdminNavigationItems, // Super Admin
        _ => _defaultNavigationItems, // Default fallback
      };

  /// Get pages for a specific role
  static List<Widget> getPages(int roleId) => switch (roleId) {
    1 => _parentPages, // Parent
    2 => _studentPages, // Student
    3 => _librarianPages, // Librarian
    4 => _teacherPages, // Teacher
    5 => _adminPages, // Admin
    6 => _staffPages, // Staff
    7 => _superAdminPages, // Super Admin
    _ => _defaultPages, // Default fallback
  };

  // ========== STUDENT (Role ID: 2) ==========
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

  // ========== PARENT (Role ID: 1) ==========
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

  // ========== TEACHER (Role ID: 4) ==========
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
    const Center(child: Text('Messages Screen')), // TODO: Implement
    const ProfileScreen(),
  ];

  // ========== LIBRARIAN (Role ID: 3) ==========
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
    const LibrarianDashboardScreen(),
    const Center(child: Text('Books Management Screen')), // TODO: Implement
    const Center(child: Text('Issued Books Screen')), // TODO: Implement
    const ProfileScreen(),
  ];

  // ========== ADMIN (Role ID: 5) ==========
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

  // ========== STAFF (Role ID: 6) ==========
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

  // ========== SUPER ADMIN (Role ID: 7) ==========
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
    1 => 'Parent Dashboard',
    2 => 'Student Dashboard',
    3 => 'Library Dashboard',
    4 => 'Teacher Dashboard',
    5 => 'Admin Dashboard',
    6 => 'Staff Dashboard',
    7 => 'Super Admin Dashboard',
    _ => 'Dashboard',
  };

  /// Check if a role has access to a specific feature
  static bool hasFeatureAccess(int roleId, String featureName) {
    // Define feature access per role
    final roleFeatures = <int, List<String>>{
      1: ['view_child_data', 'approve_gatepass', 'view_fees'],
      2: [
        'view_own_data',
        'submit_assignments',
        'view_grades',
        'request_gatepass',
      ],
      3: ['manage_books', 'manage_issues', 'view_library_reports'],
      4: [
        'view_students',
        'manage_courses',
        'mark_attendance',
        'grade_assignments',
      ],
      5: [
        'manage_users',
        'manage_students',
        'manage_teachers',
        'access_reports',
      ],
      6: ['view_own_data', 'mark_attendance', 'view_notices'],
      7: [
        'manage_institutions',
        'manage_all_data',
        'access_reports',
        'system_settings',
      ],
    };

    return roleFeatures[roleId]?.contains(featureName) ?? false;
  }
}
