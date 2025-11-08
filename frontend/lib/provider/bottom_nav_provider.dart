import 'package:flutter/material.dart';

import '../core/constants/role_navigation_config.dart';
import '../models/navigation_item_model.dart';

class BottomNavProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int? _currentRoleId;
  List<NavigationItemModel> _navigationItems = [];
  List<Widget> _pages = [];

  int get currentIndex => _currentIndex;
  int? get currentRoleId => _currentRoleId;
  List<NavigationItemModel> get navigationItems => _navigationItems;
  List<Widget> get pages => _pages;

  /// Initialize navigation based on user's role
  void initializeForRole(int roleId) {
    // Only skip if already initialized for this role AND pages are not empty
    if (_currentRoleId == roleId && _pages.isNotEmpty) {
      return; // Already initialized for this role
    }

    _currentRoleId = roleId;
    _navigationItems = RoleNavigationConfig.getNavigationItems(roleId);
    _pages = RoleNavigationConfig.getPages(roleId);
    _currentIndex = 0; // Reset to first page
    notifyListeners();
  }

  /// Set current navigation index
  void setIndex(int index) {
    if (index < 0 || index >= _pages.length) return;
    _currentIndex = index;
    notifyListeners();
  }

  /// Reset navigation state (useful for logout)
  void reset() {
    _currentIndex = 0;
    _currentRoleId = null;
    _navigationItems = [];
    _pages = [];
    notifyListeners();
  }
}
