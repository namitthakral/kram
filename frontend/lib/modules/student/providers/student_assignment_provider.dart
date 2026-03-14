import 'package:flutter/material.dart';
import '../../../../models/auth_models.dart';
import '../models/student_dashboard_models.dart';
import '../services/student_service.dart';

class StudentAssignmentProvider with ChangeNotifier {
  final StudentService _studentService = StudentService();

  bool _isLoading = false;
  String? _error;
  List<Assignment> _assignments = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Assignment> get assignments => _assignments;

  List<Assignment> get pendingAssignments =>
      _assignments.where((a) => a.status == AssignmentStatus.pending).toList();

  List<Assignment> get completedAssignments =>
      _assignments.where((a) => a.status != AssignmentStatus.pending).toList();

  Future<void> loadAssignments(User user) async {
    if (user.uuid == null) {
      _error = 'User UUID not found';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Fetch all assignments without status filter to categorize them manually
      // Or fetch pending and completed separately?
      // For now, let's fetch all (implied limit might need adjustment or pagination in future)
      final data = await _studentService.getAssignments(user.uuid!, limit: 50);

      _assignments =
          data.map((json) {
            // Map dynamic json to Assignment model
            return Assignment(
              id:
                  json['id'] is int
                      ? json['id']
                      : int.tryParse(json['id'].toString()) ?? 0,
              title: json['title'] ?? '',
              subject: json['subject'] ?? '',
              dueDate: json['dueDate'] ?? '',
              status: _parseStatus(json['status']),
              type:
                  AssignmentType
                      .assignment, // Default to assignment as this endpoint returns assignments
              grade: json['grade'],
              score: json['score'],
              description: json['description'],
              instructions: json['instructions'],
            );
          }).toList();
    } on Exception catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  AssignmentStatus _parseStatus(String? status) {
    if (status == 'graded') return AssignmentStatus.graded;
    if (status == 'submitted') return AssignmentStatus.submitted;
    return AssignmentStatus.pending;
  }
}
