import 'package:flutter/foundation.dart';

import '../../../core/services/timetable_service.dart';

/// Provider for managing timetable data and state
class TimetableProvider extends ChangeNotifier {
  final TimetableService _timetableService = TimetableService();

  // Loading states
  bool _isLoadingTimetable = false;
  bool _isLoadingTimeSlots = false;
  bool _isLoadingRooms = false;
  bool _isCreating = false;

  // Error states
  String? _timetableError;
  String? _timeSlotsError;
  String? _roomsError;
  String? _createError;

  // Data
  Map<String, dynamic>? _classTimetable;
  Map<String, dynamic>? _teacherTimetable;
  Map<String, dynamic>? _roomTimetable;
  List<dynamic>? _timeSlots;
  List<dynamic>? _rooms;
  List<dynamic>? _allEntries;

  // Getters for loading states
  bool get isLoadingTimetable => _isLoadingTimetable;
  bool get isLoadingTimeSlots => _isLoadingTimeSlots;
  bool get isLoadingRooms => _isLoadingRooms;
  bool get isCreating => _isCreating;

  // Getters for errors
  String? get timetableError => _timetableError;
  String? get timeSlotsError => _timeSlotsError;
  String? get roomsError => _roomsError;
  String? get createError => _createError;

  // Getters for data
  Map<String, dynamic>? get classTimetable => _classTimetable;
  Map<String, dynamic>? get teacherTimetable => _teacherTimetable;
  Map<String, dynamic>? get roomTimetable => _roomTimetable;
  List<dynamic>? get timeSlots => _timeSlots;
  List<dynamic>? get rooms => _rooms;
  List<dynamic>? get allEntries => _allEntries;

  // Check if there's any loading in progress
  bool get isLoading =>
      _isLoadingTimetable ||
      _isLoadingTimeSlots ||
      _isLoadingRooms ||
      _isCreating;

  /// Load timetable for a specific class
  Future<void> loadClassTimetable(
    int courseId,
    String section,
    int semesterId,
  ) async {
    _isLoadingTimetable = true;
    _timetableError = null;
    notifyListeners();

    try {
      _classTimetable = await _timetableService.getTimetableByClass(
        courseId,
        section,
        semesterId,
      );
      _timetableError = null;
      debugPrint('✅ Class timetable loaded successfully');
    } on Exception catch (e) {
      _timetableError = e.toString().replaceAll('Exception: ', '');
      _classTimetable = null;
      debugPrint('❌ Error loading class timetable: $e');
    } finally {
      _isLoadingTimetable = false;
      notifyListeners();
    }
  }

  /// Load timetable for a specific teacher
  Future<void> loadTeacherTimetable(int teacherId, int semesterId) async {
    _isLoadingTimetable = true;
    _timetableError = null;
    notifyListeners();

    try {
      _teacherTimetable = await _timetableService.getTimetableByTeacher(
        teacherId,
        semesterId,
      );
      _timetableError = null;
      debugPrint('✅ Teacher timetable loaded successfully');
    } on Exception catch (e) {
      _timetableError = e.toString().replaceAll('Exception: ', '');
      _teacherTimetable = null;
      debugPrint('❌ Error loading teacher timetable: $e');
    } finally {
      _isLoadingTimetable = false;
      notifyListeners();
    }
  }

  /// Load timetable for a specific room
  Future<void> loadRoomTimetable(int roomId, int semesterId) async {
    _isLoadingTimetable = true;
    _timetableError = null;
    notifyListeners();

    try {
      _roomTimetable = await _timetableService.getTimetableByRoom(
        roomId,
        semesterId,
      );
      _timetableError = null;
      debugPrint('✅ Room timetable loaded successfully');
    } on Exception catch (e) {
      _timetableError = e.toString().replaceAll('Exception: ', '');
      _roomTimetable = null;
      debugPrint('❌ Error loading room timetable: $e');
    } finally {
      _isLoadingTimetable = false;
      notifyListeners();
    }
  }

  /// Load all time slots
  Future<void> loadTimeSlots({
    int? institutionId,
    String? slotType,
    bool? isActive,
  }) async {
    _isLoadingTimeSlots = true;
    _timeSlotsError = null;
    notifyListeners();

    try {
      _timeSlots = await _timetableService.getAllTimeSlots(
        institutionId: institutionId,
        slotType: slotType,
        isActive: isActive,
      );
      _timeSlotsError = null;
      debugPrint('✅ Time slots loaded successfully');
    } on Exception catch (e) {
      _timeSlotsError = e.toString().replaceAll('Exception: ', '');
      _timeSlots = null;
      debugPrint('❌ Error loading time slots: $e');
    } finally {
      _isLoadingTimeSlots = false;
      notifyListeners();
    }
  }

  /// Load all rooms
  Future<void> loadRooms({
    int? institutionId,
    String? roomType,
    bool? isActive,
    String? building,
  }) async {
    _isLoadingRooms = true;
    _roomsError = null;
    notifyListeners();

    try {
      _rooms = await _timetableService.getAllRooms(
        institutionId: institutionId,
        roomType: roomType,
        isActive: isActive,
        building: building,
      );
      _roomsError = null;
      debugPrint('✅ Rooms loaded successfully');
    } on Exception catch (e) {
      _roomsError = e.toString().replaceAll('Exception: ', '');
      _rooms = null;
      debugPrint('❌ Error loading rooms: $e');
    } finally {
      _isLoadingRooms = false;
      notifyListeners();
    }
  }

  /// Load all timetable entries with filters
  Future<void> loadAllEntries({
    int? institutionId,
    int? academicYearId,
    int? semesterId,
    int? courseId,
    String? section,
    String? dayOfWeek,
    int? teacherId,
    int? subjectId,
    int? roomId,
  }) async {
    _isLoadingTimetable = true;
    _timetableError = null;
    notifyListeners();

    try {
      _allEntries = await _timetableService.getAllTimetableEntries(
        institutionId: institutionId,
        academicYearId: academicYearId,
        semesterId: semesterId,
        courseId: courseId,
        section: section,
        dayOfWeek: dayOfWeek,
        teacherId: teacherId,
        subjectId: subjectId,
        roomId: roomId,
      );
      _timetableError = null;
      debugPrint('✅ All timetable entries loaded successfully');
    } on Exception catch (e) {
      _timetableError = e.toString().replaceAll('Exception: ', '');
      _allEntries = null;
      debugPrint('❌ Error loading timetable entries: $e');
    } finally {
      _isLoadingTimetable = false;
      notifyListeners();
    }
  }

  /// Create a new timetable entry
  Future<Map<String, dynamic>?> createTimetableEntry(
    Map<String, dynamic> data,
  ) async {
    _isCreating = true;
    _createError = null;
    notifyListeners();

    try {
      final result = await _timetableService.createTimetableEntry(data);
      _createError = null;
      debugPrint('✅ Timetable entry created successfully');
      return result;
    } on Exception catch (e) {
      _createError = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Error creating timetable entry: $e');
      return null;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  /// Bulk create timetable entries
  Future<bool> bulkCreateTimetable(Map<String, dynamic> data) async {
    _isCreating = true;
    _createError = null;
    notifyListeners();

    try {
      await _timetableService.bulkCreateTimetable(data);
      _createError = null;
      debugPrint('✅ Timetable bulk created successfully');
      return true;
    } on Exception catch (e) {
      _createError = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Error bulk creating timetable: $e');
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  /// Update a timetable entry
  Future<bool> updateTimetableEntry(int id, Map<String, dynamic> data) async {
    _isCreating = true;
    _createError = null;
    notifyListeners();

    try {
      await _timetableService.updateTimetableEntry(id, data);
      _createError = null;
      debugPrint('✅ Timetable entry updated successfully');
      return true;
    } on Exception catch (e) {
      _createError = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Error updating timetable entry: $e');
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  /// Delete a timetable entry
  Future<bool> deleteTimetableEntry(int id) async {
    _isCreating = true;
    _createError = null;
    notifyListeners();

    try {
      await _timetableService.deleteTimetableEntry(id);
      _createError = null;
      debugPrint('✅ Timetable entry deleted successfully');
      return true;
    } on Exception catch (e) {
      _createError = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Error deleting timetable entry: $e');
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  /// Clear all timetable data
  void clearTimetable() {
    _classTimetable = null;
    _teacherTimetable = null;
    _roomTimetable = null;
    _allEntries = null;
    _timetableError = null;
    _isLoadingTimetable = false;
    notifyListeners();
  }

  /// Create a new time slot
  Future<bool> createTimeSlot(Map<String, dynamic> data) async {
    _isCreating = true;
    _createError = null;
    notifyListeners();

    try {
      await _timetableService.createTimeSlot(data);
      _createError = null;
      debugPrint('✅ Time slot created successfully');
      return true;
    } on Exception catch (e) {
      _createError = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Error creating time slot: $e');
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  /// Update a time slot
  Future<bool> updateTimeSlot(int id, Map<String, dynamic> data) async {
    _isCreating = true;
    _createError = null;
    notifyListeners();

    try {
      await _timetableService.updateTimeSlot(id, data);
      _createError = null;
      debugPrint('✅ Time slot updated successfully');
      return true;
    } on Exception catch (e) {
      _createError = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Error updating time slot: $e');
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  /// Delete a time slot
  Future<bool> deleteTimeSlot(int id) async {
    _isCreating = true;
    _createError = null;
    notifyListeners();

    try {
      await _timetableService.deleteTimeSlot(id);
      _createError = null;
      debugPrint('✅ Time slot deleted successfully');
      return true;
    } on Exception catch (e) {
      _createError = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Error deleting time slot: $e');
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  /// Clear time slots
  void clearTimeSlots() {
    _timeSlots = null;
    _timeSlotsError = null;
    _isLoadingTimeSlots = false;
    notifyListeners();
  }

  /// Clear rooms
  void clearRooms() {
    _rooms = null;
    _roomsError = null;
    _isLoadingRooms = false;
    notifyListeners();
  }
}
