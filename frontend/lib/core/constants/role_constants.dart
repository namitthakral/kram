/// Role definition with ID, name, description, and permissions
class RoleDefinition {
  const RoleDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
    this.usesLocalDatabase = false,
  });

  final int id;
  final String name;
  final String description;
  final List<String> permissions;
  final bool usesLocalDatabase;
}

/// Role constants for the EdVerse application
class RoleConstants {
  // Role Definitions
  static const RoleDefinition parent = RoleDefinition(
    id: 1,
    name: 'parent',
    description: 'Parent/Guardian',
    permissions: [
      'canViewChildData',
      'canViewChildGrades',
      'canViewChildAttendance',
      'canViewNotices',
      'canApproveGatePass',
      'canViewFees',
    ],
    usesLocalDatabase: true,
  );

  static const RoleDefinition student = RoleDefinition(
    id: 2,
    name: 'student',
    description: 'Student',
    permissions: [
      'canViewOwnData',
      'canSubmitAssignments',
      'canViewGrades',
      'canViewTimetable',
      'canViewNotices',
      'canRequestGatePass',
    ],
    usesLocalDatabase: true,
  );

  static const RoleDefinition librarian = RoleDefinition(
    id: 3,
    name: 'librarian',
    description: 'Library Staff',
    permissions: [
      'canManageBooks',
      'canManageBookIssues',
      'canViewLibraryReports',
      'canManageLibrarySettings',
    ],
  );

  static const RoleDefinition teacher = RoleDefinition(
    id: 4,
    name: 'teacher',
    description: 'Teaching Faculty',
    permissions: [
      'canViewStudents',
      'canManageCourses',
      'canMarkAttendance',
      'canGradeAssignments',
      'canCreateAssignments',
      'canViewTimetable',
    ],
  );

  static const RoleDefinition admin = RoleDefinition(
    id: 5,
    name: 'admin',
    description: 'Institution Administrator',
    permissions: [
      'canManageUsers',
      'canManageStudents',
      'canManageTeachers',
      'canManageCourses',
      'canAccessReports',
      'canManageFees',
      'canManageLibrary',
    ],
  );

  static const RoleDefinition staff = RoleDefinition(
    id: 6,
    name: 'staff',
    description: 'Support Staff',
    permissions: [
      'canViewOwnData',
      'canMarkAttendance',
      'canViewNotices',
    ],
  );

  static const RoleDefinition superAdmin = RoleDefinition(
    id: 7,
    name: 'super_admin',
    description: 'System Super Administrator',
    permissions: [
      'canManageUsers',
      'canManageInstitutions',
      'canManageAllData',
      'canAccessReports',
      'canManageSystemSettings',
    ],
  );

  // All roles list for easy iteration
  static const List<RoleDefinition> allRoles = [
    parent,
    student,
    librarian,
    teacher,
    admin,
    staff,
    superAdmin,
  ];

  // Helper methods
  static RoleDefinition? getRoleById(int roleId) {
    for (final role in allRoles) {
      if (role.id == roleId) {
        return role;
      }
    }
    return null;
  }

  static RoleDefinition? getRoleByName(String roleName) {
    for (final role in allRoles) {
      if (role.name.toLowerCase() == roleName.toLowerCase()) {
        return role;
      }
    }
    return null;
  }

  static bool usesLocalDatabase(int roleId) {
    final role = getRoleById(roleId);
    return role?.usesLocalDatabase ?? false;
  }

  static bool hasPermission(int roleId, String permission) {
    final role = getRoleById(roleId);
    return role?.permissions.contains(permission) ?? false;
  }
}
