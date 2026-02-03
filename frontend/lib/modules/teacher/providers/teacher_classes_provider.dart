import 'package:flutter/foundation.dart';
import '../models/assignment_models.dart';
import '../../../core/services/class_section_service.dart';


class TeacherClassesProvider extends ChangeNotifier {


  bool _isLoading = false;
  String? _error;
  List<ClassSection> _classes = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ClassSection> get classes => _classes;

  Future<void> loadTeacherClasses(String userUuid, {int? semesterId, int? teacherId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final classSectionService = ClassSectionService();
      // Use ClassSectionService with institutionId=1
      final rawClasses = await classSectionService.getClassSections(
        institutionId: 1,
        teacherId: teacherId,
        semesterId: semesterId,
        status: 'ACTIVE',
      );

      _classes =
          rawClasses
              .map(
                (json) => ClassSection.fromJson(json as Map<String, dynamic>),
              )
              .toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _classes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
