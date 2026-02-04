import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/role_navigation_config.dart';
import '../models/navigation_item_model.dart';

class BottomNavProvider extends ChangeNotifier {
  int? _currentRoleId;
  List<NavigationItemModel> _navigationItems = [];
  final Map<int, String> _routeOverrides = {};
  final Set<int> _hiddenIndices = {};

  int? get currentRoleId => _currentRoleId;

  List<NavigationItemModel> get navigationItems => _navigationItems;

  /// Initialize navigation based on user's role
  void initializeForRole(int roleId) {
    // Always reset/reload when initializing
    _currentRoleId = roleId;
    _navigationItems = List.from(
      RoleNavigationConfig.getNavigationItems(roleId),
    );
    _routeOverrides.clear();
    _hiddenIndices.clear();
    notifyListeners();
  }

  void overrideRoute(int index, String path) {
    _routeOverrides[index] = path;
    notifyListeners();
  }

  void hideItem(int index) {
    _hiddenIndices.add(index);
    notifyListeners();
  }

  bool isItemHidden(int index) => _hiddenIndices.contains(index);

  /// Get the current index based on the current route
  int getCurrentIndex(String currentRoute) {
    if (_currentRoleId == null) return 0;

    final index = RoleNavigationConfig.getIndexFromRoute(
      _currentRoleId!,
      currentRoute,
    );
    return index ?? 0;
  }

  /// Get the route path for a given navigation index
  String getRoutePath(int index) {
    if (_routeOverrides.containsKey(index)) {
      return _routeOverrides[index]!;
    }

    if (_currentRoleId == null ||
        index < 0 ||
        index >= _navigationItems.length) {
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
