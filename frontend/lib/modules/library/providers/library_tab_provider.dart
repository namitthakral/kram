import 'package:flutter/foundation.dart';

import '../../../provider/segmented_control_provider.dart';
import '../models/library_models.dart';

/// Provider for managing library tab state
class LibraryTabProvider extends ChangeNotifier
    implements SegmentedControlProvider<LibraryTab> {
  LibraryTabProvider() : _selectedTab = LibraryTab.issuedBooks;

  LibraryTab _selectedTab;

  LibraryTab get selectedTab => _selectedTab;

  @override
  LibraryTab get selectedValue => _selectedTab;

  @override
  Map<LibraryTab, String> segments = {
    LibraryTab.issuedBooks: 'Issued Books',
    LibraryTab.bookInventory: 'Book Inventory',
    LibraryTab.analytics: 'Analytics',
    LibraryTab.overdue: 'Overdue',
  };

  void setTab(LibraryTab tab) {
    if (_selectedTab != tab) {
      _selectedTab = tab;
      notifyListeners();
    }
  }

  @override
  void updateSelectedValue(LibraryTab value) {
    setTab(value);
  }

  @override
  void reset(LibraryTab value) {
    _selectedTab = value;
    notifyListeners();
  }
}
