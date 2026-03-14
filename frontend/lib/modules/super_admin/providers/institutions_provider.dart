import 'package:flutter/foundation.dart';

import '../../../core/services/institution_service.dart';

class InstitutionsProvider extends ChangeNotifier {
  final InstitutionService _service = InstitutionService();

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _institutions = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get institutions => _institutions;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(e) {
    _error = e.toString().replaceAll('Exception: ', '');
    debugPrint('InstitutionsProvider Error: $_error');
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadInstitutions() async {
    _setLoading(true);
    try {
      final list = await _service.getPublicInstitutions(limit: 100);
      _institutions =
          list
              .whereType<Map<String, dynamic>>()
              .toList()
              .cast<Map<String, dynamic>>();
      _error = null;
    } on Exception catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Returns true on success, false on failure.
  Future<bool> createInstitution(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _service.createInstitution(data);
      _error = null;
      await loadInstitutions();
      return true;
    } on Exception catch (e) {
      _setError(e);
      _setLoading(false);
      return false;
    }
  }
}
