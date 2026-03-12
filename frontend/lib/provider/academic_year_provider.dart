import 'package:flutter/material.dart';
import '../models/academic_year.dart';
import '../modules/admin/services/admin_service.dart';

class AcademicYearProvider extends ChangeNotifier {
  List<AcademicYear> _academicYears = [];
  bool _isLoading = false;
  String? _error;
  int? _selectedAcademicYearId;

  List<AcademicYear> get academicYears => _academicYears;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get selectedAcademicYearId => _selectedAcademicYearId;

  AcademicYear? get selectedAcademicYear {
    if (_selectedAcademicYearId == null) return null;
    try {
      return _academicYears.firstWhere((y) => y.id == _selectedAcademicYearId);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadAcademicYears() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final years = await AdminService().getAcademicYears();
      _academicYears = years;
      
      // Auto-select active year if none selected
      if (_selectedAcademicYearId == null && _academicYears.isNotEmpty) {
        final activeYear = _academicYears.firstWhere(
          (y) => y.status == 'ACTIVE',
          orElse: () => _academicYears.first,
        );
        _selectedAcademicYearId = activeYear.id;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedAcademicYearId(int? id) {
    if (_selectedAcademicYearId != id) {
      _selectedAcademicYearId = id;
      notifyListeners();
    }
  }
}
