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

/// Role constants for the Kram application
/// ⚠️ CRITICAL: NEVER CHANGE THESE ROLE IDs - They match the database schema
/// 1 = super_admin, 2 = admin, 3 = student, 4 = parent, 5 = teacher, 6 = librarian, 7 = staff
class RoleConstants {
  // Role Definitions (in order of ID: 1-7)
  
  // ID 1: Super Admin
  static const RoleDefinition superAdmin = RoleDefinition(
    id: 1,
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

  // ID 2: Admin
  static const RoleDefinition admin = RoleDefinition(
    id: 2,
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

  // ID 3: Student
  static const RoleDefinition student = RoleDefinition(
    id: 3,
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

  // ID 4: Parent
  static const RoleDefinition parent = RoleDefinition(
    id: 4,
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

  // ID 5: Teacher
  static const RoleDefinition teacher = RoleDefinition(
    id: 5,
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

  // ID 6: Librarian
  static const RoleDefinition librarian = RoleDefinition(
    id: 6,
    name: 'librarian',
    description: 'Library Staff',
    permissions: [
      'canManageBooks',
      'canManageBookIssues',
      'canViewLibraryReports',
      'canManageLibrarySettings',
    ],
  );

  // ID 7: Staff
  static const RoleDefinition staff = RoleDefinition(
    id: 7,
    name: 'staff',
    description: 'Support Staff',
    permissions: [
      'canViewOwnData',
      'canMarkAttendance',
      'canViewNotices',
    ],
  );

  // All roles list for easy iteration (in order of ID: 1-7)
  static const List<RoleDefinition> allRoles = [
    superAdmin,
    admin,
    student,
    parent,
    teacher,
    librarian,
    staff,
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
