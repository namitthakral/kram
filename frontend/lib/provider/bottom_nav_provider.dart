import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/role_navigation_config.dart';
import '../models/navigation_item_model.dart';

class BottomNavProvider extends ChangeNotifier {
  int? _currentRoleId;
  List<NavigationItemModel> _navigationItems = [];

  int? get currentRoleId => _currentRoleId;
  List<NavigationItemModel> get navigationItems => _navigationItems;

  /// Initialize navigation based on user's role
  void initializeForRole(int roleId) {
    // Only skip if already initialized for this role AND items are not empty
    if (_currentRoleId == roleId && _navigationItems.isNotEmpty) {
      return; // Already initialized for this role
    }

    _currentRoleId = roleId;
    _navigationItems = RoleNavigationConfig.getNavigationItems(roleId);
    notifyListeners();
  }

  /// Get the current index based on the current route
  int getCurrentIndex(String currentRoute) {
    if (_currentRoleId == null) return 0;

    final index = RoleNavigationConfig.getIndexFromRoute(_currentRoleId!, currentRoute);
    return index ?? 0;
  }

  /// Get the route path for a given navigation index
  String getRoutePath(int index) {
    if (_currentRoleId == null || index < 0 || index >= _navigationItems.length) {
      return '/dashboard';
    }

    return RoleNavigationConfig.getRoutePath(_currentRoleId!, index);
  }

  /// Navigate to a specific index using go_router
  void navigateToIndex(BuildContext context, int index) {
    final route = getRoutePath(index);
    context.go(route);
  }

  /// Reset navigation state (useful for logout)
  void reset() {
    _currentRoleId = null;
    _navigationItems = [];
    notifyListeners();
  }
}
