import 'package:flutter/material.dart';
import '../../../../models/auth_models.dart';
import '../services/student_service.dart';

class StudentEventsProvider with ChangeNotifier {
  final StudentService _studentService = StudentService();

  bool _isLoading = false;
  String? _error;
  List<dynamic> _events = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get events => _events;

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

      final data = await _studentService.getUpcomingEvents(user.uuid!);
      _events = data;
    } on Exception catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
