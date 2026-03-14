import 'package:flutter/material.dart';

/// Provider for managing dashboard tab state
class DashboardTabProvider extends ChangeNotifier {
  DashboardTab _selectedTab = DashboardTab.recentAssignments;

  DashboardTab get selectedTab => _selectedTab;

  void updateSelectedTab(DashboardTab newTab) {
    if (_selectedTab != newTab) {
      _selectedTab = newTab;
      notifyListeners();
    }
  }
}

enum DashboardTab { recentAssignments, performanceTrends, attendanceHistory }
