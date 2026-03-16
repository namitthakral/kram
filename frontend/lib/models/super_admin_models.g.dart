// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'super_admin_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SystemStats _$SystemStatsFromJson(Map<String, dynamic> json) => SystemStats(
      totalInstitutions: (json['total_institutions'] as num).toInt(),
      inactiveInstitutions: (json['inactive_institutions'] as num).toInt(),
      totalStudents: (json['total_students'] as num).toInt(),
      totalTeachers: (json['total_teachers'] as num).toInt(),
      totalAdmins: (json['total_admins'] as num).toInt(),
      totalStaff: (json['total_staff'] as num).toInt(),
      totalParents: (json['total_parents'] as num).toInt(),
      totalActiveUsers: (json['total_active_users'] as num).toInt(),
      pendingUsers: (json['pending_users'] as num).toInt(),
      suspendedUsers: (json['suspended_users'] as num).toInt(),
      lockedUsers: (json['locked_users'] as num).toInt(),
      newUsers30d: (json['new_users30d'] as num).toInt(),
      newInstitutions30d: (json['new_institutions30d'] as num).toInt(),
      userHealthPercentage: (json['user_health_percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$SystemStatsToJson(SystemStats instance) =>
    <String, dynamic>{
      'total_institutions': instance.totalInstitutions,
      'inactive_institutions': instance.inactiveInstitutions,
      'total_students': instance.totalStudents,
      'total_teachers': instance.totalTeachers,
      'total_admins': instance.totalAdmins,
      'total_staff': instance.totalStaff,
      'total_parents': instance.totalParents,
      'total_active_users': instance.totalActiveUsers,
      'pending_users': instance.pendingUsers,
      'suspended_users': instance.suspendedUsers,
      'locked_users': instance.lockedUsers,
      'new_users30d': instance.newUsers30d,
      'new_institutions30d': instance.newInstitutions30d,
      'user_health_percentage': instance.userHealthPercentage,
    };

InstitutionOverview _$InstitutionOverviewFromJson(Map<String, dynamic> json) =>
    InstitutionOverview(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      totalUsers: (json['total_users'] as num).toInt(),
      activeUsers: (json['active_users'] as num).toInt(),
      students: (json['students'] as num).toInt(),
      teachers: (json['teachers'] as num).toInt(),
      staff: (json['staff'] as num).toInt(),
      parents: (json['parents'] as num).toInt(),
      healthPercentage: (json['health_percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$InstitutionOverviewToJson(
        InstitutionOverview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'type': instance.type,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'total_users': instance.totalUsers,
      'active_users': instance.activeUsers,
      'students': instance.students,
      'teachers': instance.teachers,
      'staff': instance.staff,
      'parents': instance.parents,
      'health_percentage': instance.healthPercentage,
    };

UserGrowthTrend _$UserGrowthTrendFromJson(Map<String, dynamic> json) =>
    UserGrowthTrend(
      month: DateTime.parse(json['month'] as String),
      newUsers: (json['new_users'] as num).toInt(),
      activeNewUsers: (json['active_new_users'] as num).toInt(),
      cumulativeUsers: (json['cumulative_users'] as num).toInt(),
    );

Map<String, dynamic> _$UserGrowthTrendToJson(UserGrowthTrend instance) =>
    <String, dynamic>{
      'month': instance.month.toIso8601String(),
      'new_users': instance.newUsers,
      'active_new_users': instance.activeNewUsers,
      'cumulative_users': instance.cumulativeUsers,
    };

RecentActivity _$RecentActivityFromJson(Map<String, dynamic> json) =>
    RecentActivity(
      activityType: json['activity_type'] as String,
      description: json['description'] as String,
      institutionName: json['institution_name'] as String?,
      role: json['role'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$RecentActivityToJson(RecentActivity instance) =>
    <String, dynamic>{
      'activity_type': instance.activityType,
      'description': instance.description,
      'institution_name': instance.institutionName,
      'role': instance.role,
      'timestamp': instance.timestamp.toIso8601String(),
    };

PaginationMeta _$PaginationMetaFromJson(Map<String, dynamic> json) =>
    PaginationMeta(
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$PaginationMetaToJson(PaginationMeta instance) =>
    <String, dynamic>{
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'totalPages': instance.totalPages,
    };

InstitutionListResponse _$InstitutionListResponseFromJson(
        Map<String, dynamic> json) =>
    InstitutionListResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => InstitutionOverview.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$InstitutionListResponseToJson(
        InstitutionListResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'meta': instance.meta,
    };

SuperAdminDashboardResponse _$SuperAdminDashboardResponseFromJson(
        Map<String, dynamic> json) =>
    SuperAdminDashboardResponse(
      stats: SystemStats.fromJson(json['stats'] as Map<String, dynamic>),
      institutions: InstitutionListResponse.fromJson(
          json['institutions'] as Map<String, dynamic>),
      userGrowth: (json['user_growth'] as List<dynamic>)
          .map((e) => UserGrowthTrend.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentActivity: (json['recent_activity'] as List<dynamic>)
          .map((e) => RecentActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SuperAdminDashboardResponseToJson(
        SuperAdminDashboardResponse instance) =>
    <String, dynamic>{
      'stats': instance.stats,
      'institutions': instance.institutions,
      'user_growth': instance.userGrowth,
      'recent_activity': instance.recentActivity,
    };
