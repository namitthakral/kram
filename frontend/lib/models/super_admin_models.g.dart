// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'super_admin_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SystemStats _$SystemStatsFromJson(Map<String, dynamic> json) => SystemStats(
      totalInstitutions: (json['totalInstitutions'] as num).toInt(),
      inactiveInstitutions: (json['inactiveInstitutions'] as num).toInt(),
      totalStudents: (json['totalStudents'] as num).toInt(),
      totalTeachers: (json['totalTeachers'] as num).toInt(),
      totalAdmins: (json['totalAdmins'] as num).toInt(),
      totalStaff: (json['totalStaff'] as num).toInt(),
      totalParents: (json['totalParents'] as num).toInt(),
      totalActiveUsers: (json['totalActiveUsers'] as num).toInt(),
      pendingUsers: (json['pendingUsers'] as num).toInt(),
      suspendedUsers: (json['suspendedUsers'] as num).toInt(),
      lockedUsers: (json['lockedUsers'] as num).toInt(),
      newUsers30d: (json['newUsers30d'] as num).toInt(),
      newInstitutions30d: (json['newInstitutions30d'] as num).toInt(),
      userHealthPercentage: (json['userHealthPercentage'] as num).toDouble(),
    );

Map<String, dynamic> _$SystemStatsToJson(SystemStats instance) =>
    <String, dynamic>{
      'totalInstitutions': instance.totalInstitutions,
      'inactiveInstitutions': instance.inactiveInstitutions,
      'totalStudents': instance.totalStudents,
      'totalTeachers': instance.totalTeachers,
      'totalAdmins': instance.totalAdmins,
      'totalStaff': instance.totalStaff,
      'totalParents': instance.totalParents,
      'totalActiveUsers': instance.totalActiveUsers,
      'pendingUsers': instance.pendingUsers,
      'suspendedUsers': instance.suspendedUsers,
      'lockedUsers': instance.lockedUsers,
      'newUsers30d': instance.newUsers30d,
      'newInstitutions30d': instance.newInstitutions30d,
      'userHealthPercentage': instance.userHealthPercentage,
    };

InstitutionOverview _$InstitutionOverviewFromJson(Map<String, dynamic> json) =>
    InstitutionOverview(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      totalUsers: (json['totalUsers'] as num).toInt(),
      activeUsers: (json['activeUsers'] as num).toInt(),
      students: (json['students'] as num).toInt(),
      teachers: (json['teachers'] as num).toInt(),
      staff: (json['staff'] as num).toInt(),
      parents: (json['parents'] as num).toInt(),
      healthPercentage: (json['healthPercentage'] as num).toDouble(),
    );

Map<String, dynamic> _$InstitutionOverviewToJson(
        InstitutionOverview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'type': instance.type,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'totalUsers': instance.totalUsers,
      'activeUsers': instance.activeUsers,
      'students': instance.students,
      'teachers': instance.teachers,
      'staff': instance.staff,
      'parents': instance.parents,
      'healthPercentage': instance.healthPercentage,
    };

UserGrowthTrend _$UserGrowthTrendFromJson(Map<String, dynamic> json) =>
    UserGrowthTrend(
      month: DateTime.parse(json['month'] as String),
      newUsers: (json['newUsers'] as num).toInt(),
      activeNewUsers: (json['activeNewUsers'] as num).toInt(),
      cumulativeUsers: (json['cumulativeUsers'] as num).toInt(),
    );

Map<String, dynamic> _$UserGrowthTrendToJson(UserGrowthTrend instance) =>
    <String, dynamic>{
      'month': instance.month.toIso8601String(),
      'newUsers': instance.newUsers,
      'activeNewUsers': instance.activeNewUsers,
      'cumulativeUsers': instance.cumulativeUsers,
    };

RecentActivity _$RecentActivityFromJson(Map<String, dynamic> json) =>
    RecentActivity(
      activityType: json['activityType'] as String,
      description: json['description'] as String,
      institutionId: (json['institutionId'] as num?)?.toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$RecentActivityToJson(RecentActivity instance) =>
    <String, dynamic>{
      'activityType': instance.activityType,
      'description': instance.description,
      'institutionId': instance.institutionId,
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
      userGrowth: (json['userGrowth'] as List<dynamic>)
          .map((e) => UserGrowthTrend.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentActivity: (json['recentActivity'] as List<dynamic>)
          .map((e) => RecentActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SuperAdminDashboardResponseToJson(
        SuperAdminDashboardResponse instance) =>
    <String, dynamic>{
      'stats': instance.stats,
      'institutions': instance.institutions,
      'userGrowth': instance.userGrowth,
      'recentActivity': instance.recentActivity,
    };
