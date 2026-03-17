import 'dart:developer';

import '../../models/super_admin_models.dart';
import 'api_service.dart';

/// Service for Super Admin dashboard APIs
/// Handles all super admin related API calls with proper error handling
class SuperAdminService {
  factory SuperAdminService() => _instance;
  SuperAdminService._internal();
  static final SuperAdminService _instance = SuperAdminService._internal();

  final ApiService _apiService = ApiService();

  /// Get complete dashboard data
  /// Returns aggregated data for super admin dashboard
  Future<SuperAdminDashboardResponse> getDashboardData({
    int institutionPage = 1,
    int institutionLimit = 5,
  }) async {
    try {
      log('📊 Fetching super admin dashboard data...');
      
      // The backend dashboard API doesn't accept query parameters
      // It returns a fixed set of data optimized for dashboard
      final response = await _apiService.dio.get('/super-admin/dashboard');

      log('✅ Dashboard data fetched successfully');
      log('🔍 Raw response stats: ${response.data['stats']}');
      
      final dashboardResponse = SuperAdminDashboardResponse.fromJson(response.data);
      log('🔍 Parsed stats: totalInstitutions=${dashboardResponse.stats.totalInstitutions}');
      
      return dashboardResponse;
    } catch (e) {
      log('❌ Error fetching dashboard data: $e');
      rethrow;
    }
  }

  /// Get system statistics only
  /// Returns system-wide statistics for quick overview
  Future<SystemStats> getSystemStats() async {
    try {
      log('📈 Fetching system statistics...');
      
      final response = await _apiService.dio.get('/super-admin/stats');

      log('✅ System stats fetched successfully');
      return SystemStats.fromJson(response.data);
    } catch (e) {
      log('❌ Error fetching system stats: $e');
      rethrow;
    }
  }

  /// Get institution overview with pagination
  /// Returns paginated list of institutions with user counts
  Future<InstitutionListResponse> getInstitutions({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
    String? type,
  }) async {
    try {
      log('🏢 Fetching institutions (page: $page, limit: $limit)...');
      
      // Convert page to offset for backend API
      final offset = (page - 1) * limit;
      
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      final response = await _apiService.dio.get(
        '/super-admin/institutions',
        queryParameters: queryParams,
      );

      log('✅ Institutions fetched successfully');
      return InstitutionListResponse.fromJson(response.data);
    } catch (e) {
      log('❌ Error fetching institutions: $e');
      rethrow;
    }
  }

  /// Get user growth trends
  /// Returns monthly user growth data for the last 12 months
  Future<List<UserGrowthTrend>> getUserGrowthTrends({
    int months = 12,
  }) async {
    try {
      log('📊 Fetching user growth trends...');
      
      final response = await _apiService.dio.get(
        '/super-admin/user-growth',
        queryParameters: {
          'months': months,
        },
      );

      log('✅ User growth trends fetched successfully');
      final List<dynamic> data = response.data;
      return data.map((json) => UserGrowthTrend.fromJson(json)).toList();
    } catch (e) {
      log('❌ Error fetching user growth trends: $e');
      rethrow;
    }
  }

  /// Get recent activity
  /// Returns recent system activity for activity feed
  Future<List<RecentActivity>> getRecentActivity({
    int limit = 20,
    int days = 7,
  }) async {
    try {
      log('📝 Fetching recent activity...');
      
      final response = await _apiService.dio.get(
        '/super-admin/recent-activity',
        queryParameters: {
          'limit': limit,
          'days': days,
        },
      );

      log('✅ Recent activity fetched successfully');
      final List<dynamic> data = response.data;
      return data.map((json) => RecentActivity.fromJson(json)).toList();
    } catch (e) {
      log('❌ Error fetching recent activity: $e');
      rethrow;
    }
  }

  /// Get detailed institution information
  /// Returns detailed stats for a specific institution
  Future<InstitutionOverview> getInstitutionDetails(int institutionId) async {
    try {
      log('🔍 Fetching institution details for ID: $institutionId...');
      
      final response = await _apiService.dio.get(
        '/super-admin/institutions/$institutionId',
      );

      log('✅ Institution details fetched successfully');
      return InstitutionOverview.fromJson(response.data);
    } catch (e) {
      log('❌ Error fetching institution details: $e');
      rethrow;
    }
  }

  /// Get system health metrics
  /// Returns aggregated health metrics for monitoring
  Future<Map<String, dynamic>> getSystemHealth() async {
    try {
      log('🏥 Fetching system health metrics...');
      
      // Use system stats as health metrics since there's no separate health endpoint
      final response = await _apiService.dio.get('/super-admin/stats');

      log('✅ System health metrics fetched successfully');
      return response.data;
    } catch (e) {
      log('❌ Error fetching system health: $e');
      rethrow;
    }
  }

  /// Get storage statistics
  /// Returns system storage usage metrics
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      log('💾 Fetching storage statistics...');
      
      final response = await _apiService.dio.get('/super-admin/storage-stats');

      log('✅ Storage stats fetched successfully');
      return response.data;
    } catch (e) {
      log('❌ Error fetching storage stats: $e');
      rethrow;
    }
  }

  /// Get active sessions count
  /// Returns number of currently active user sessions
  Future<int> getActiveSessionsCount() async {
    try {
      log('👥 Fetching active sessions count...');
      
      final response = await _apiService.dio.get('/super-admin/active-sessions');

      log('✅ Active sessions count fetched successfully');
      return response.data as int;
    } catch (e) {
      log('❌ Error fetching active sessions count: $e');
      rethrow;
    }
  }

  /// Create a new institution
  /// Returns success response with created institution data
  Future<Map<String, dynamic>> createInstitution(Map<String, dynamic> data) async {
    try {
      log('🏢 Creating new institution: ${data['name']}...');
      
      final response = await _apiService.dio.post(
        '/institutions',
        data: data,
      );

      log('✅ Institution created successfully');
      return response.data;
    } catch (e) {
      log('❌ Error creating institution: $e');
      rethrow;
    }
  }

  /// Refresh all dashboard data
  /// Force refresh all cached data (if any caching is implemented)
  Future<void> refreshDashboard() async {
    try {
      log('🔄 Refreshing dashboard data...');
      
      // For now, this just clears any potential cache
      // In the future, this could trigger cache invalidation
      
      log('✅ Dashboard refresh completed');
    } catch (e) {
      log('❌ Error refreshing dashboard: $e');
      rethrow;
    }
  }
}