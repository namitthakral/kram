import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../core/services/super_admin_service.dart';
import '../../models/super_admin_models.dart';

/// Provider for Super Admin dashboard state management
/// Handles loading states, data caching, and error handling
class SuperAdminProvider extends ChangeNotifier {
  final SuperAdminService _superAdminService = SuperAdminService();

  // Loading states
  bool _isLoadingDashboard = false;
  bool _isLoadingStats = false;
  bool _isLoadingInstitutions = false;
  bool _isRefreshing = false;

  // Data
  SystemStats? _systemStats;
  List<InstitutionOverview> _institutions = [];
  List<UserGrowthTrend> _userGrowthTrends = [];
  List<RecentActivity> _recentActivity = [];
  PaginationMeta? _institutionsMeta;
  Map<String, dynamic>? _storageStats;
  int? _activeSessionsCount;

  // Error handling
  String? _error;
  DateTime? _lastUpdated;

  // Getters
  bool get isLoadingDashboard => _isLoadingDashboard;
  bool get isLoadingStats => _isLoadingStats;
  bool get isLoadingInstitutions => _isLoadingInstitutions;
  bool get isRefreshing => _isRefreshing;
  bool get hasError => _error != null;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;

  SystemStats? get systemStats => _systemStats;
  List<InstitutionOverview> get institutions => _institutions;
  List<UserGrowthTrend> get userGrowthTrends => _userGrowthTrends;
  List<RecentActivity> get recentActivity => _recentActivity;
  PaginationMeta? get institutionsMeta => _institutionsMeta;
  Map<String, dynamic>? get storageStats => _storageStats;
  int? get activeSessionsCount => _activeSessionsCount;

  // Computed getters
  bool get hasData => _systemStats != null;
  bool get isDataStale => _lastUpdated == null || 
      DateTime.now().difference(_lastUpdated!).inMinutes > 5;

  /// Load complete dashboard data
  Future<void> loadDashboardData({bool forceRefresh = false}) async {
    if (_isLoadingDashboard && !forceRefresh) return;

    try {
      _isLoadingDashboard = true;
      _error = null;
      notifyListeners();

      log('📊 Loading super admin dashboard data...');

      final dashboardData = await _superAdminService.getDashboardData(
        institutionLimit: 5, // Show top 5 institutions on dashboard
      );

      log('🔍 Dashboard data received: ${dashboardData.stats.totalInstitutions} institutions');
      _systemStats = dashboardData.stats;
      _institutions = dashboardData.institutions.data;
      _institutionsMeta = dashboardData.institutions.meta;
      _userGrowthTrends = dashboardData.userGrowth;
      _recentActivity = dashboardData.recentActivity;
      _lastUpdated = DateTime.now();

      // Load additional data in parallel
      loadActiveSessionsCount();
      loadStorageStats();

      log('✅ Dashboard data loaded successfully');
    } catch (e) {
      log('❌ Error loading dashboard data: $e');
      _error = _getErrorMessage(e);
    } finally {
      _isLoadingDashboard = false;
      notifyListeners();
    }
  }

  /// Load system stats only (for quick refresh)
  Future<void> loadSystemStats({bool forceRefresh = false}) async {
    if (_isLoadingStats && !forceRefresh) return;

    try {
      _isLoadingStats = true;
      _error = null;
      notifyListeners();

      log('📈 Loading system statistics...');

      final stats = await _superAdminService.getSystemStats();
      _systemStats = stats;
      _lastUpdated = DateTime.now();

      log('✅ System stats loaded successfully');
    } catch (e) {
      log('❌ Error loading system stats: $e');
      _error = _getErrorMessage(e);
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  /// Load institutions with pagination
  Future<void> loadInstitutions({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
    String? type,
    bool append = false,
  }) async {
    if (_isLoadingInstitutions) return;

    try {
      _isLoadingInstitutions = true;
      if (!append) {
        _error = null;
      }
      notifyListeners();

      log('🏢 Loading institutions (page: $page)...');

      final response = await _superAdminService.getInstitutions(
        page: page,
        limit: limit,
        search: search,
        status: status,
        type: type,
      );

      if (append && page > 1) {
        _institutions.addAll(response.data);
      } else {
        _institutions = response.data;
      }
      _institutionsMeta = response.meta;

      log('✅ Institutions loaded successfully (${response.data.length} items)');
    } catch (e) {
      log('❌ Error loading institutions: $e');
      _error = _getErrorMessage(e);
    } finally {
      _isLoadingInstitutions = false;
      notifyListeners();
    }
  }

  /// Refresh all dashboard data
  Future<void> refreshDashboard() async {
    if (_isRefreshing) return;

    try {
      _isRefreshing = true;
      notifyListeners();

      log('🔄 Refreshing dashboard...');

      await loadDashboardData(forceRefresh: true);

      log('✅ Dashboard refreshed successfully');
    } catch (e) {
      log('❌ Error refreshing dashboard: $e');
      _error = _getErrorMessage(e);
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Clear all data and reset state
  void clearData() {
    _systemStats = null;
    _institutions = [];
    _userGrowthTrends = [];
    _recentActivity = [];
    _institutionsMeta = null;
    _error = null;
    _lastUpdated = null;
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('Session expired')) {
      return 'Your session has expired. Please login again.';
    } else if (error.toString().contains('Network')) {
      return 'Network error. Please check your connection.';
    } else if (error.toString().contains('403')) {
      return 'You don\'t have permission to access this data.';
    } else if (error.toString().contains('500')) {
      return 'Server error. Please try again later.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Get formatted stats for display
  Map<String, String> get formattedStats {
    if (_systemStats == null) {
      log('⚠️ SystemStats is null, returning default values');
      return {
        'institutions': '0',
        'users': '0',
        'sessions': '0',
        'health': '0%',
      };
    }

    log('✅ SystemStats available: ${_systemStats!.totalInstitutions} institutions, ${_systemStats!.totalActiveUsers} users');
    return {
      'institutions': _systemStats!.totalInstitutions.toString(),
      'users': _formatNumber(_systemStats!.totalActiveUsers),
      'sessions': _activeSessionsCount != null ? _formatNumber(_activeSessionsCount!) : '0',
      'health': _systemStats!.formattedHealthPercentage,
    };
  }

  /// Format large numbers for display
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  /// Get recent institutions (top 5)
  List<InstitutionOverview> get recentInstitutions {
    return _institutions.take(5).toList();
  }

  /// Check if more institutions can be loaded
  bool get canLoadMoreInstitutions {
    if (_institutionsMeta == null) return false;
    return _institutionsMeta!.page < _institutionsMeta!.totalPages;
  }

  /// Load storage statistics
  Future<void> loadStorageStats() async {
    try {
      log('💾 Loading storage statistics...');
      
      final stats = await _superAdminService.getStorageStats();
      _storageStats = stats;
      
      log('✅ Storage stats loaded successfully');
      notifyListeners();
    } catch (e) {
      log('❌ Error loading storage stats: $e');
    }
  }

  /// Load active sessions count
  Future<void> loadActiveSessionsCount() async {
    try {
      log('👥 Loading active sessions count...');
      
      final count = await _superAdminService.getActiveSessionsCount();
      _activeSessionsCount = count;
      
      log('✅ Active sessions count loaded successfully');
      notifyListeners();
    } catch (e) {
      log('❌ Error loading active sessions count: $e');
    }
  }

  /// Create a new institution
  /// Returns true on success, false on failure
  Future<bool> createInstitution(Map<String, dynamic> data) async {
    try {
      log('🏢 Creating institution: ${data['name']}...');
      
      final response = await _superAdminService.createInstitution(data);
      
      // Refresh institutions list after creation
      await loadInstitutions(page: 1, limit: 20);
      
      log('✅ Institution created successfully');
      return true;
    } catch (e) {
      log('❌ Error creating institution: $e');
      _error = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }
}