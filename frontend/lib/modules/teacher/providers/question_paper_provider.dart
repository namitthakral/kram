import 'package:flutter/foundation.dart';

import '../../../core/services/question_paper_service.dart';

/// Provider for managing question paper data and state
class QuestionPaperProvider extends ChangeNotifier {
  final QuestionPaperService _questionPaperService = QuestionPaperService();

  // Loading states
  bool _isLoadingPaper = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  // Error states
  String? _paperError;
  String? _createError;
  String? _updateError;
  String? _deleteError;

  // Data
  Map<String, dynamic>? _questionPaper;
  List<Map<String, dynamic>>? _questionPapers;

  // Getters for loading states
  bool get isLoadingPaper => _isLoadingPaper;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;

  // Getters for errors
  String? get paperError => _paperError;
  String? get createError => _createError;
  String? get updateError => _updateError;
  String? get deleteError => _deleteError;

  // Getters for data
  Map<String, dynamic>? get questionPaper => _questionPaper;
  List<Map<String, dynamic>>? get questionPapers => _questionPapers;

  // Check if there's any loading in progress
  bool get isLoading =>
      _isLoadingPaper || _isCreating || _isUpdating || _isDeleting;

  /// Load all question papers for a teacher
  Future<void> loadAllQuestionPapers(String userUuid) async {
    _isLoadingPaper = true;
    _paperError = null;
    notifyListeners();

    try {
      final result = await _questionPaperService.getAllQuestionPapers(userUuid);
      _questionPapers = result.cast<Map<String, dynamic>>();
      _paperError = null;
      debugPrint('✅ All question papers loaded successfully');
    } on Exception catch (e) {
      _paperError = e.toString().replaceAll('Exception: ', '');
      _questionPapers = [];
      debugPrint('❌ Error loading all question papers: $e');
    } finally {
      _isLoadingPaper = false;
      notifyListeners();
    }
  }

  /// Load question paper by examination ID
  Future<void> loadQuestionPaperByExamId(String userUuid, int examId) async {
    _isLoadingPaper = true;
    _paperError = null;
    notifyListeners();

    try {
      _questionPaper = await _questionPaperService.getQuestionPaperByExamId(
        userUuid,
        examId,
      );
      _paperError = null;
      debugPrint('✅ Question paper loaded successfully');
    } on Exception catch (e) {
      _paperError = e.toString().replaceAll('Exception: ', '');
      _questionPaper = null;
      debugPrint('❌ Error loading question paper: $e');
    } finally {
      _isLoadingPaper = false;
      notifyListeners();
    }
  }

  /// Load question paper by paper ID
  Future<void> loadQuestionPaperById(String userUuid, int paperId) async {
    _isLoadingPaper = true;
    _paperError = null;
    notifyListeners();

    try {
      _questionPaper = await _questionPaperService.getQuestionPaperById(
        userUuid,
        paperId,
      );
      _paperError = null;
      debugPrint('✅ Question paper loaded successfully');
    } on Exception catch (e) {
      _paperError = e.toString().replaceAll('Exception: ', '');
      _questionPaper = null;
      debugPrint('❌ Error loading question paper: $e');
    } finally {
      _isLoadingPaper = false;
      notifyListeners();
    }
  }

  /// Create an empty question paper
  Future<bool> createQuestionPaper(
    String userUuid,
    int examId,
    Map<String, dynamic> data,
  ) async {
    _isCreating = true;
    _createError = null;
    notifyListeners();

    try {
      final result = await _questionPaperService.createQuestionPaper(
        userUuid,
        examId,
        data,
      );
      _questionPaper = result;
      _createError = null;
      debugPrint('✅ Question paper created successfully');
      return true;
    } on Exception catch (e) {
      _createError = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Error creating question paper: $e');
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  /// Create a complete question paper with sections and questions
  Future<bool> createFullQuestionPaper(
    String userUuid,
    Map<String, dynamic> data,
  ) async {
    _isCreating = true;
    _createError = null;
    notifyListeners();

    try {
      final result = await _questionPaperService.createFullQuestionPaper(
        userUuid,
        data,
      );
      _questionPaper = result;
      _createError = null;
      debugPrint('✅ Full question paper created successfully');
      return true;
    } on Exception catch (e) {
      _createError = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Error creating full question paper: $e');
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  /// Update question paper details
  Future<bool> updateQuestionPaper(
    String userUuid,
    int paperId,
    Map<String, dynamic> data,
  ) async {
    _isUpdating = true;
    _updateError = null;
    notifyListeners();

    try {
      final result = await _questionPaperService.updateQuestionPaper(
        userUuid,
        paperId,
        data,
      );
      _questionPaper = result;
      _updateError = null;
      debugPrint('✅ Question paper updated successfully');
      return true;
    } on Exception catch (e) {
      _updateError = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Error updating question paper: $e');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// Publish a question paper
  Future<bool> publishQuestionPaper(String userUuid, int paperId) async {
    _isUpdating = true;
    _updateError = null;
    notifyListeners();

    try {
      final result = await _questionPaperService.publishQuestionPaper(
        userUuid,
        paperId,
      );
      _questionPaper = result;
      _updateError = null;
      debugPrint('✅ Question paper published successfully');
      return true;
    } on Exception catch (e) {
      _updateError = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Error publishing question paper: $e');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// Delete a question paper
  Future<bool> deleteQuestionPaper(String userUuid, int paperId) async {
    _isDeleting = true;
    _deleteError = null;
    notifyListeners();

    try {
      await _questionPaperService.deleteQuestionPaper(userUuid, paperId);
      _questionPaper = null;
      _deleteError = null;
      debugPrint('✅ Question paper deleted successfully');
      return true;
    } on Exception catch (e) {
      _deleteError = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Error deleting question paper: $e');
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  // ============ Section Methods ============

  /// Add a section to the current question paper
  Future<bool> addSection(
    String userUuid,
    int paperId,
    Map<String, dynamic> data,
  ) async {
    _isUpdating = true;
    _updateError = null;
    notifyListeners();

    try {
      await _questionPaperService.addSection(userUuid, paperId, data);
      // Reload the question paper to get updated data
      await loadQuestionPaperById(userUuid, paperId);
      _updateError = null;
      debugPrint('✅ Section added successfully');
      return true;
    } on Exception catch (e) {
      _updateError = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Error adding section: $e');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// Update a section
  Future<bool> updateSection(
    String userUuid,
    int sectionId,
    Map<String, dynamic> data,
  ) async {
    _isUpdating = true;
    _updateError = null;
    notifyListeners();

    try {
      await _questionPaperService.updateSection(userUuid, sectionId, data);
      _updateError = null;
      debugPrint('✅ Section updated successfully');
      return true;
    } on Exception catch (e) {
      _updateError = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Error updating section: $e');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// Delete a section
  Future<bool> deleteSection(String userUuid, int sectionId) async {
    _isDeleting = true;
    _deleteError = null;
    notifyListeners();

    try {
      await _questionPaperService.deleteSection(userUuid, sectionId);
      _deleteError = null;
      debugPrint('✅ Section deleted successfully');
      return true;
    } on Exception catch (e) {
      _deleteError = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Error deleting section: $e');
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  // ============ Question Methods ============

  /// Add a question to a section
  Future<bool> addQuestion(
    String userUuid,
    int sectionId,
    Map<String, dynamic> data,
  ) async {
    _isUpdating = true;
    _updateError = null;
    notifyListeners();

    try {
      await _questionPaperService.addQuestion(userUuid, sectionId, data);
      _updateError = null;
      debugPrint('✅ Question added successfully');
      return true;
    } on Exception catch (e) {
      _updateError = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Error adding question: $e');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// Bulk add questions to a section
  Future<bool> bulkAddQuestions(
    String userUuid,
    int sectionId,
    Map<String, dynamic> data,
  ) async {
    _isUpdating = true;
    _updateError = null;
    notifyListeners();

    try {
      await _questionPaperService.bulkAddQuestions(userUuid, sectionId, data);
      _updateError = null;
      debugPrint('✅ Questions bulk added successfully');
      return true;
    } on Exception catch (e) {
      _updateError = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Error bulk adding questions: $e');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// Update a question
  Future<bool> updateQuestion(
    String userUuid,
    int questionId,
    Map<String, dynamic> data,
  ) async {
    _isUpdating = true;
    _updateError = null;
    notifyListeners();

    try {
      await _questionPaperService.updateQuestion(userUuid, questionId, data);
      _updateError = null;
      debugPrint('✅ Question updated successfully');
      return true;
    } on Exception catch (e) {
      _updateError = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Error updating question: $e');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// Delete a question
  Future<bool> deleteQuestion(String userUuid, int questionId) async {
    _isDeleting = true;
    _deleteError = null;
    notifyListeners();

    try {
      await _questionPaperService.deleteQuestion(userUuid, questionId);
      _deleteError = null;
      debugPrint('✅ Question deleted successfully');
      return true;
    } on Exception catch (e) {
      _deleteError = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Error deleting question: $e');
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  /// Clear question paper data
  void clearQuestionPaper() {
    _questionPaper = null;
    _paperError = null;
    _isLoadingPaper = false;
    notifyListeners();
  }

  /// Get sections from current question paper
  List<Map<String, dynamic>> get sections {
    if (_questionPaper == null) {
      return [];
    }
    final data = _questionPaper!['data'];
    if (data is Map<String, dynamic>) {
      final sections = data['sections'];
      if (sections is List) {
        return sections.cast<Map<String, dynamic>>();
      }
    }
    return [];
  }

  /// Get total marks from current question paper
  int? get totalMarks {
    if (_questionPaper == null) {
      return null;
    }
    return _questionPaper!['totalMarks'] as int?;
  }

  /// Check if paper is published
  bool get isPublished {
    if (_questionPaper == null) {
      return false;
    }
    return _questionPaper!['isPublished'] as bool? ?? false;
  }
}
