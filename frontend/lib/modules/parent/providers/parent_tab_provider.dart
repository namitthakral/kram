import 'package:flutter/material.dart';

import '../models/parent_dashboard_models.dart';

class ParentTabProvider extends ChangeNotifier {
  ParentDashboardTab _selectedTab = ParentDashboardTab.academicPerformance;

  ParentDashboardTab get selectedTab => _selectedTab;

  void updateSelectedTab(ParentDashboardTab tab) {
    _selectedTab = tab;
    notifyListeners();
  }
}
