import 'package:flutter/material.dart';

import '../utils/enum.dart';
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
      case 1: // Super Admin
        return AppBarConfig.superAdmin(
          userInitials: userInitials,
          userName: userName,
          systemName: 'Kram',
          onNotificationIconPressed: onNotificationIconPressed,
        );

      case 2: // Admin
        return AppBarConfig.admin(
          userInitials: userInitials,
          userName: userName,
          institutionName: 'Institution',
          onNotificationIconPressed: onNotificationIconPressed,
        );

      case 3: // Student
        final student = user.student;
        return AppBarConfig.student(
          userInitials: userInitials,
          userName: userName,
          grade: 'N/A', // Grade level removed - using course instead
          rollNumber: student?.rollNumber ?? 'N/A',
          onNotificationIconPressed: onNotificationIconPressed,
        );

      case 4: // Parent
        return AppBarConfig.parent(
          childInitials: userInitials,
          childName: 'Child',
          grade: 'N/A',
          rollNumber: 'N/A',
          onNotificationIconPressed: onNotificationIconPressed,
        );

      case 5: // Teacher
        final teacher = user.teacher;
        return AppBarConfig.teacher(
          userInitials: userInitials,
          userName: userName,
          designation: teacher?.designation ?? 'Teacher',
          employeeId: teacher?.employeeId ?? 'N/A',
          onNotificationIconPressed: onNotificationIconPressed,
        );

      case 6: // Librarian
        final staff = user.staff;
        return AppBarConfig.librarian(
          userInitials: userInitials,
          userName: userName,
          libraryName: staff?.designation ?? 'Library',
          onNotificationIconPressed: onNotificationIconPressed,
        );

      case 7: // Staff
        final staff = user.staff;
        return AppBarConfig.staff(
          userInitials: userInitials,
          userName: userName,
          department: staff?.staffType ?? staff?.designation ?? 'Staff',
          onNotificationIconPressed: onNotificationIconPressed,
        );

      case 8: // Accountant
        return AppBarConfig.staff(
          userInitials: userInitials,
          userName: userName,
          department: 'Accountant',
          onNotificationIconPressed: onNotificationIconPressed,
        );

      default:
        return const AppBarConfig.standard();
    }
  }

  /// Get simplified AppBarConfig for profile screens showing role + institution name.
  static AppBarConfig _getProfileScreenConfig(
    // ignore: type_annotate_public_apis
    user,
    int roleId,
    String userInitials,
    String userName,
    VoidCallback? onNotificationIconPressed,
  ) {
    final institutionName = user.institution?.name as String?;

    String roleLabel;
    switch (roleId) {
      case 1:
        roleLabel = 'Super Administrator';
      case 2:
        roleLabel = 'Administrator';
      case 3:
        roleLabel = 'Student';
      case 4:
        roleLabel = 'Parent';
      case 5:
        roleLabel = (user.teacher?.designation as String?) ?? 'Teacher';
      case 6:
        roleLabel = 'Librarian';
      case 7:
        roleLabel =
            (user.staff?.staffType as String?) ??
            (user.staff?.designation as String?) ??
            'Staff';
      case 8:
        roleLabel = 'Accountant';
      default:
        return const AppBarConfig.standard();
    }

    return AppBarConfig(
      type: AppBarType.profile,
      showBackButton: false,
      userInitials: userInitials,
      userName: userName,
      userDetails: _buildProfileDetails(roleLabel, institutionName),
      onNotificationIconPressed: onNotificationIconPressed,
    );
  }

  /// Builds "Role • Institution Name" or just "Role" when institution is absent.
  static String _buildProfileDetails(
    String roleLabel,
    String? institutionName,
  ) {
    if (institutionName != null && institutionName.isNotEmpty) {
      return '$roleLabel • $institutionName';
    }
    return roleLabel;
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
