import 'package:flutter/material.dart';

import '../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

/// Helper class to get AppBarConfig based on user role
class AppBarConfigHelper {
  /// Get AppBarConfig for the current user based on their role
  static AppBarConfig getConfigForUser(
    // ignore: type_annotate_public_apis
    user, {
    VoidCallback? onNotificationIconPressed,
    bool isProfileScreen = false,
  }) {
    if (user == null) {
      return const AppBarConfig.standard();
    }

    final roleId = user.role?.id ?? 0;
    final userInitials = _getInitials(user.name ?? '');
    final userName = user.name ?? '';

    // For profile screens, use simplified configs with just designation/role
    if (isProfileScreen) {
      return _getProfileScreenConfig(
        user,
        roleId,
        userInitials,
        userName,
        onNotificationIconPressed,
      );
    }

    switch (roleId) {
      case 2: // Student
        final student = user.student;
        return AppBarConfig.student(
          userInitials: userInitials,
          userName: userName,
          grade: student?.gradeLevel ?? 'N/A',
          rollNumber: student?.rollNumber ?? 'N/A',
          onNotificationIconPressed: onNotificationIconPressed,
        );

      case 4: // Teacher
        final teacher = user.teacher;
        return AppBarConfig.teacher(
          userInitials: userInitials,
          userName: userName,
          designation: teacher?.designation ?? 'Teacher',
          employeeId: teacher?.employeeId ?? 'N/A',
          onNotificationIconPressed: onNotificationIconPressed,
        );

      case 3: // Librarian
        // Librarian may use staff model with staffType
        final staff = user.staff;
        return AppBarConfig.librarian(
          userInitials: userInitials,
          userName: userName,
          libraryName: staff?.designation ?? 'Library',
          onNotificationIconPressed: onNotificationIconPressed,
        );

      case 5: // Admin
        return AppBarConfig.admin(
          userInitials: userInitials,
          userName: userName,
          institutionName: 'Institution',
          onNotificationIconPressed: onNotificationIconPressed,
        );

      case 6: // Staff
        final staff = user.staff;
        return AppBarConfig.staff(
          userInitials: userInitials,
          userName: userName,
          department: staff?.staffType ?? staff?.designation ?? 'Staff',
          onNotificationIconPressed: onNotificationIconPressed,
        );

      case 7: // Super Admin
        return AppBarConfig.superAdmin(
          userInitials: userInitials,
          userName: userName,
          systemName: 'EdVerse',
          onNotificationIconPressed: onNotificationIconPressed,
        );

      case 1: // Parent
        // Parent model doesn't include children data, use fallback
        return AppBarConfig.parent(
          childInitials: userInitials,
          childName: 'Child',
          grade: 'N/A',
          rollNumber: 'N/A',
          onNotificationIconPressed: onNotificationIconPressed,
        );

      default:
        return const AppBarConfig.standard();
    }
  }

  /// Get simplified AppBarConfig for profile screens (without employee ID, etc.)
  static AppBarConfig _getProfileScreenConfig(
    // ignore: type_annotate_public_apis
    user,
    int roleId,
    String userInitials,
    String userName,
    VoidCallback? onNotificationIconPressed,
  ) {
    switch (roleId) {
      case 2: // Student
        return AppBarConfig.student(
          userInitials: userInitials,
          userName: userName,
          grade: user.student?.gradeLevel ?? '',
          rollNumber: '',
          onNotificationIconPressed: onNotificationIconPressed,
        );

      case 4: // Teacher
        final teacher = user.teacher;
        return AppBarConfig.teacher(
          userInitials: userInitials,
          userName: userName,
          designation: teacher?.designation ?? 'Teacher',
          employeeId: '', // Hide employee ID in profile
          onNotificationIconPressed: onNotificationIconPressed,
        );

      case 3: // Librarian
        return AppBarConfig.librarian(
          userInitials: userInitials,
          userName: userName,
          libraryName: '', // Hide library name in profile
          onNotificationIconPressed: onNotificationIconPressed,
        );

      case 5: // Admin
        return AppBarConfig.admin(
          userInitials: userInitials,
          userName: userName,
          institutionName: '', // Hide institution in profile
          onNotificationIconPressed: onNotificationIconPressed,
        );

      case 6: // Staff
        final staff = user.staff;
        return AppBarConfig.staff(
          userInitials: userInitials,
          userName: userName,
          department: staff?.designation ?? 'Staff',
          onNotificationIconPressed: onNotificationIconPressed,
        );

      case 7: // Super Admin
        return AppBarConfig.superAdmin(
          userInitials: userInitials,
          userName: userName,
          systemName: '', // Hide system name in profile
          onNotificationIconPressed: onNotificationIconPressed,
        );

      case 1: // Parent
        return AppBarConfig.parent(
          childInitials: userInitials,
          childName: '',
          grade: '',
          rollNumber: '',
          onNotificationIconPressed: onNotificationIconPressed,
        );

      default:
        return const AppBarConfig.standard();
    }
  }

  /// Extract initials from a full name
  static String _getInitials(String name) {
    if (name.isEmpty) {
      return '?';
    }

    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }

    return '${parts[0].substring(0, 1)}${parts[parts.length - 1].substring(0, 1)}'
        .toUpperCase();
  }
}
