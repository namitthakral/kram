import '../data/mock_data.dart';

/// Shared attendance state for Mark Present flow from Home screen.
/// Allows instant mark-all-present from home, with undo support.
class AttendanceState {
  AttendanceState._();

  static final AttendanceState instance = AttendanceState._();

  Map<String, bool> _state = {};
  Map<String, bool>? _previousState;

  /// Current attendance state (studentId -> isPresent).
  Map<String, bool> get state => Map.unmodifiable(_state);

  /// Initialize from mock data if not already set.
  void ensureInitialized() {
    if (_state.isEmpty) {
      _state = {
        for (final s in AttendanceMockData.students) s.studentId: s.isPresent,
      };
    }
  }

  /// Mark all students present. Saves previous state for undo.
  void markAllPresent() {
    ensureInitialized();
    _previousState = Map.from(_state);
    _state = {
      for (final id in _state.keys) id: true,
    };
  }

  /// Revert to state before markAllPresent.
  void undo() {
    if (_previousState != null) {
      _state = Map.from(_previousState!);
      _previousState = null;
    }
  }

  /// Get initial state for AttendanceLoggingScreen.
  Map<String, bool> getInitialState() {
    ensureInitialized();
    return Map.from(_state);
  }

  /// Update state (from AttendanceLoggingScreen).
  void updateState(Map<String, bool> newState) {
    _state = Map.from(newState);
  }
}
