import 'package:json_annotation/json_annotation.dart';

part 'super_admin_models.g.dart';

/// System-wide statistics model
/// Maps to SystemStats interface from backend
@JsonSerializable()
class SystemStats {
  const SystemStats({
    required this.totalInstitutions,
    required this.inactiveInstitutions,
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalAdmins,
    required this.totalStaff,
    required this.totalParents,
    required this.totalActiveUsers,
    required this.pendingUsers,
    required this.suspendedUsers,
    required this.lockedUsers,
    required this.newUsers30d,
    required this.newInstitutions30d,
    required this.userHealthPercentage,
  });

  factory SystemStats.fromJson(Map<String, dynamic> json) =>
      _$SystemStatsFromJson(json);
  // Institution metrics
  final int totalInstitutions;
  final int inactiveInstitutions;

  // User metrics by role
  final int totalStudents;
  final int totalTeachers;
  final int totalAdmins;
  final int totalStaff;
  final int totalParents;

  // User status metrics
  final int totalActiveUsers;
  final int pendingUsers;
  final int suspendedUsers;
  final int lockedUsers;

  // Recent activity (30 days)
  final int newUsers30d;
  final int newInstitutions30d;

  // System health
  final double userHealthPercentage;
  Map<String, dynamic> toJson() => _$SystemStatsToJson(this);

  /// Get total users across all categories
  int get totalUsers =>
      totalActiveUsers + pendingUsers + suspendedUsers + lockedUsers;

  /// Get formatted health percentage
  String get formattedHealthPercentage =>
      '${userHealthPercentage.toStringAsFixed(1)}%';
}

/// Institution overview with user statistics
/// Maps to InstitutionOverview interface from backend
@JsonSerializable()
class InstitutionOverview {
  const InstitutionOverview({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.totalUsers,
    required this.activeUsers,
    required this.students,
    required this.teachers,
    required this.staff,
    required this.parents,
    required this.healthPercentage,
    this.adminName,
    this.adminEmail,
    this.adminStatus,
  });

  factory InstitutionOverview.fromJson(Map<String, dynamic> json) =>
      _$InstitutionOverviewFromJson(json);
  final int id;
  final String code;
  final String name;
  final String type; // 'SCHOOL' | 'COLLEGE' | 'UNIVERSITY' | 'INSTITUTE'
  final String status; // 'ACTIVE' | 'INACTIVE'
  final DateTime createdAt;

  // Admin information
  final String? adminName;
  final String? adminEmail;
  final String? adminStatus;

  // User counts
  final int totalUsers;
  final int activeUsers;
  final int students;
  final int teachers;
  final int staff;
  final int parents;

  // Health metrics
  final double healthPercentage;
  Map<String, dynamic> toJson() => _$InstitutionOverviewToJson(this);

  /// Check if institution is active
  bool get isActive => status == 'ACTIVE';

  /// Get formatted health percentage
  String get formattedHealthPercentage =>
      '${healthPercentage.toStringAsFixed(1)}%';

  /// Get user summary string
  String get userSummary {
    final parts = <String>[];
    if (students > 0) parts.add('$students students');
    if (teachers > 0) parts.add('$teachers teachers');
    if (staff > 0) parts.add('$staff staff');
    if (parents > 0) parts.add('$parents parents');
    return parts.join(' • ');
  }
}

/// User growth trend data
/// Maps to UserGrowthTrend interface from backend
@JsonSerializable()
class UserGrowthTrend {
  const UserGrowthTrend({
    required this.month,
    required this.newUsers,
    required this.activeNewUsers,
    required this.cumulativeUsers,
  });

  factory UserGrowthTrend.fromJson(Map<String, dynamic> json) =>
      _$UserGrowthTrendFromJson(json);
  final DateTime month;
  final int newUsers;
  final int activeNewUsers;
  final int cumulativeUsers;
  Map<String, dynamic> toJson() => _$UserGrowthTrendToJson(this);
}

/// Recent activity item
/// Maps to RecentActivity interface from backend
@JsonSerializable()
class RecentActivity {
  const RecentActivity({
    required this.activityType,
    required this.description,
    required this.timestamp,
    this.institutionId,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) =>
      _$RecentActivityFromJson(json);
  final String activityType; // 'user_registration' | 'institution_creation'
  final String description;
  final int? institutionId;
  final DateTime timestamp;
  Map<String, dynamic> toJson() => _$RecentActivityToJson(this);

  /// Check if this is a user registration activity
  bool get isUserRegistration => activityType == 'user_registration';

  /// Check if this is an institution creation activity
  bool get isInstitutionCreation => activityType == 'institution_creation';

  /// Get activity icon based on type
  String get activityIcon {
    switch (activityType) {
      case 'user_registration':
        return '👤';
      case 'institution_creation':
        return '🏢';
      default:
        return '📝';
    }
  }
}

/// Pagination metadata
@JsonSerializable()
class PaginationMeta {
  const PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  Map<String, dynamic> toJson() => _$PaginationMetaToJson(this);
}

/// Institution list response with pagination
@JsonSerializable()
class InstitutionListResponse {
  const InstitutionListResponse({required this.data, required this.meta});

  factory InstitutionListResponse.fromJson(Map<String, dynamic> json) =>
      _$InstitutionListResponseFromJson(json);
  final List<InstitutionOverview> data;
  final PaginationMeta meta;
  Map<String, dynamic> toJson() => _$InstitutionListResponseToJson(this);
}

/// Super Admin dashboard response
/// Aggregated response for dashboard API
@JsonSerializable()
class SuperAdminDashboardResponse {
  const SuperAdminDashboardResponse({
    required this.stats,
    required this.institutions,
    required this.userGrowth,
    required this.recentActivity,
  });

  factory SuperAdminDashboardResponse.fromJson(Map<String, dynamic> json) =>
      _$SuperAdminDashboardResponseFromJson(json);
  final SystemStats stats;
  final InstitutionListResponse institutions;
  final List<UserGrowthTrend> userGrowth;
  final List<RecentActivity> recentActivity;
  Map<String, dynamic> toJson() => _$SuperAdminDashboardResponseToJson(this);
}
