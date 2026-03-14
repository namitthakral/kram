import 'package:flutter/foundation.dart';

/// A generic provider for managing segmented control state
/// This allows any component to access and update the selected segment value
class SegmentedControlProvider<T extends Object> extends ChangeNotifier {
  SegmentedControlProvider({required T initialValue, required this.segments})
    : _selectedValue = initialValue;

  final Map<T, String> segments;
  T _selectedValue;

  /// Get the currently selected value
  T get selectedValue => _selectedValue;

  /// Update the selected value and notify listeners
  void updateSelectedValue(T value) {
    if (_selectedValue != value) {
      _selectedValue = value;
      notifyListeners();
    }
  }

  /// Reset to a specific value
  void reset(T value) {
    _selectedValue = value;
    notifyListeners();
  }
}
