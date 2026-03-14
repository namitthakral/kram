import 'package:flutter/material.dart';

import '../services/admin_service.dart';

class UserManagementProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  // State
  bool _isLoading = false;
  String? _error;
  List<dynamic> _users = [];
  Map<String, dynamic>? _userStats;
  int _currentPage = 1;
  int _totalPages = 1;
  int _limit = 10;
  String? _searchQuery;
  int? _selectedRoleFilter;
  String? _selectedStatusFilter;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get users => _users;
  Map<String, dynamic>? get userStats => _userStats;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get limit => _limit;
  String? get searchQuery => _searchQuery;
  int? get selectedRoleFilter => _selectedRoleFilter;
  String? get selectedStatusFilter => _selectedStatusFilter;

  void setLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    _currentPage = 1; // Reset to first page
    fetchUsers();
  }

  void setRoleFilter(int? roleId) {
    _selectedRoleFilter = roleId;
    _currentPage = 1; // Reset to first page
    fetchUsers();
  }

  void setStatusFilter(String? status) {
    _selectedStatusFilter = status;
    _currentPage = 1; // Reset to first page
    fetchUsers();
  }

  void setPage(int page) {
    _currentPage = page;
    fetchUsers();
  }

  void setLimit(int newLimit) {
    _limit = newLimit;
    _currentPage = 1; // Reset to first page
    fetchUsers();
  }

  /// Fetch all users with filters
  Future<void> fetchUsers() async {
    try {
      setLoading(value: true);
      setError(null);

      final response = await _adminService.getAllUsers(
        page: _currentPage,
        limit: _limit,
        search: _searchQuery,
        roleId: _selectedRoleFilter,
        status: _selectedStatusFilter,
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        _users = data['users'] as List<dynamic>;
        final pagination = data['pagination'] as Map<String, dynamic>?;
        if (pagination != null) {
          _totalPages = pagination['totalPages'] as int? ?? 1;
        }
      } else {
        setError('Failed to load users');
      }
    } on Exception catch (e) {
      setError(e.toString());
    } finally {
      setLoading(value: false);
    }
  }

  /// Fetch user statistics
  Future<void> fetchUserStats() async {
    try {
      final response = await _adminService.getUsersStats();
      if (response['success'] == true) {
        _userStats = response['data'] as Map<String, dynamic>?;
        notifyListeners();
      }
    } on Exception catch (e) {
      // Silently fail for stats, don't disrupt main flow
      debugPrint('Failed to fetch user stats: $e');
    }
  }

  /// Create new user
  Future<bool> createUser(Map<String, dynamic> userData) async {
    try {
      setLoading(value: true);
      setError(null);

      final response = await _adminService.createInstitutionalUser(userData);

      if (response['success'] == true) {
        // Refresh the list
        await fetchUsers();
        await fetchUserStats();
        return true;
      } else {
        setError(response['message'] as String? ?? 'Failed to create user');
        return false;
      }
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(value: false);
    }
  }

  /// Update user
  Future<bool> updateUser(
    String userUuid,
    Map<String, dynamic> updateData,
  ) async {
    try {
      setLoading(value: true);
      setError(null);

      final response = await _adminService.updateUser(userUuid, updateData);

      if (response['success'] == true) {
        // Refresh the list
        await fetchUsers();
        return true;
      } else {
        setError(response['message'] as String? ?? 'Failed to update user');
        return false;
      }
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(value: false);
    }
  }

  /// Delete user (soft delete)
  Future<bool> deleteUser(String userUuid) async {
    try {
      setLoading(value: true);
      setError(null);

      await _adminService.deleteUser(userUuid);
      // Refresh the list
      await fetchUsers();
      await fetchUserStats();
      return true;
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(value: false);
    }
  }

  /// Hard delete user (permanent)
  Future<bool> hardDeleteUser(String userUuid) async {
    try {
      setLoading(value: true);
      setError(null);

      await _adminService.hardDeleteUser(userUuid);
      // Refresh the list
      await fetchUsers();
      await fetchUserStats();
      return true;
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(value: false);
    }
  }

  /// Unlock user account
  Future<bool> unlockUser(String userUuid) async {
    try {
      setLoading(value: true);
      setError(null);

      final response = await _adminService.unlockUserAccount(userUuid);

      if (response['success'] == true) {
        // Refresh the list
        await fetchUsers();
        return true;
      } else {
        setError(response['message'] as String? ?? 'Failed to unlock user');
        return false;
      }
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(value: false);
    }
  }

  /// Bulk import users
  Future<Map<String, dynamic>?> bulkImportUsers(
    List<Map<String, dynamic>> users,
  ) async {
    try {
      setLoading(value: true);
      setError(null);

      final response = await _adminService.bulkImportUsers(users);

      if (response['success'] == true) {
        // Refresh the list
        await fetchUsers();
        await fetchUserStats();
        return response['data'] as Map<String, dynamic>?;
      } else {
        setError(response['message'] as String? ?? 'Failed to import users');
        return null;
      }
    } on Exception catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(value: false);
    }
  }

  /// Get user by Kram ID
  Future<Map<String, dynamic>?> getUserByKramid(String kramid) async {
    try {
      setLoading(value: true);
      setError(null);

      final response = await _adminService.getUserByKramid(kramid);

      if (response['success'] == true) {
        return response['data'] as Map<String, dynamic>?;
      } else {
        setError('User not found');
        return null;
      }
    } on Exception catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(value: false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
