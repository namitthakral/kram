import 'package:flutter/material.dart';

import '../../../../models/auth_models.dart';
import '../services/student_service.dart';

class StudentEventsProvider with ChangeNotifier {
  final StudentService _studentService = StudentService();

  bool _isLoading = false;
  String? _error;
  List<dynamic> _events = [];
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedFilter = 'upcoming';

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get events => _events;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get selectedFilter => _selectedFilter;

  Future<void> loadEvents(User user) async {
    if (user.uuid == null) {
      _error = 'User UUID not found';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _studentService.getUpcomingEvents(
        user.uuid!,
        startDate: _startDate?.toIso8601String().split('T')[0],
        endDate: _endDate?.toIso8601String().split('T')[0],
      );
      _events = data;
    } on Exception catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(
    String filter,
    User user, {
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    _selectedFilter = filter;
    final now = DateTime.now();

    switch (filter) {
      case 'today':
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'week':
        _startDate = now.subtract(Duration(days: now.weekday - 1));
        _startDate = DateTime(
          _startDate!.year,
          _startDate!.month,
          _startDate!.day,
        );
        _endDate = _startDate!.add(
          const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
        );
        break;
      case 'month':
        _startDate = DateTime(now.year, now.month);
        _endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case 'custom':
        _startDate = customStart;
        _endDate = customEnd;
        break;
      default:
        _startDate = null;
        _endDate = null;
    }

    loadEvents(user);
  }
}
