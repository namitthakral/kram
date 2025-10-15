// import 'package:flutter/material.dart';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TimeOfDaySlot { morning, afternoon, evening }

class BookAppointmentProvider extends ChangeNotifier {
  BookAppointmentProvider() {
    _updateMonthYear();
  }
  DateTime _selectedDate = DateTime.now();
  String? _monthYear;
  TimeSlot? _selectedTimeSlot;
  TimeOfDaySlot? _selectedTimeOfDay;

  // Initialize time slots only once
  final List<TimeSlot> _morningTimeSlots = TimeSlot.morningSlot();
  final List<TimeSlot> _afternoonTimeSlots = TimeSlot.afternoonSlot();
  final List<TimeSlot> _eveningTimeSlots = TimeSlot.eveningSlot();

  // Getters
  DateTime get selectedDate => _selectedDate;
  String? get monthYear => _monthYear;
  List<TimeSlot> get morningTimeSlots => _morningTimeSlots;
  List<TimeSlot> get afternoonTimeSlots => _afternoonTimeSlots;
  List<TimeSlot> get eveningTimeSlots => _eveningTimeSlots;
  TimeSlot? get selectedTimeSlot => _selectedTimeSlot;
  TimeOfDaySlot? get selectedTimeOfDay => _selectedTimeOfDay;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _updateMonthYear();
    notifyListeners();
  }

  void _updateMonthYear() {
    _monthYear =
        "${DateFormat('MMMM').format(DateTime(_selectedDate.year, _selectedDate.month))} ${_selectedDate.year}";
  }

  void selectTimeSlot(TimeSlot slot, TimeOfDaySlot timeOfDay) {
    if (_selectedTimeSlot != null) {
      _selectedTimeSlot!.isSelected = false;
    }

    _selectedTimeOfDay = timeOfDay;
    _selectedTimeSlot = slot;
    slot.isSelected = true;

    notifyListeners();
  }

  void bookAppointment() {
    log(_selectedDate.toString());
    log(_selectedTimeSlot.toString());
  }

  TimeSlot? getSelectedSlotForTimeOfDay(TimeOfDaySlot timeOfDay) {
    if (_selectedTimeOfDay != timeOfDay) {
      return null;
    }
    return _selectedTimeSlot;
  }

  TimeSlot? get selectedMorningTimeSlot =>
      getSelectedSlotForTimeOfDay(TimeOfDaySlot.morning);

  TimeSlot? get selectedAfternoonTimeSlot =>
      getSelectedSlotForTimeOfDay(TimeOfDaySlot.afternoon);

  TimeSlot? get selectedEveningTimeSlot =>
      getSelectedSlotForTimeOfDay(TimeOfDaySlot.evening);
}

class TimeSlot {
  TimeSlot({required this.id, required this.time, this.isSelected = false});
  final int id;
  final String time;
  bool isSelected;

  static List<TimeSlot> morningSlot() => [
    TimeSlot(id: 1, time: '08:30 AM'),
    TimeSlot(id: 2, time: '09:00 AM'),
    TimeSlot(id: 3, time: '09:30 AM'),
    TimeSlot(id: 4, time: '10:00 AM'),
    TimeSlot(id: 5, time: '10:30 AM'),
    TimeSlot(id: 6, time: '11:00 AM'),
    TimeSlot(id: 7, time: '11:30 AM'),
  ];

  static List<TimeSlot> afternoonSlot() => [
    TimeSlot(id: 8, time: '12:00 PM'),
    TimeSlot(id: 9, time: '12:30 PM'),
    TimeSlot(id: 10, time: '01:00 PM'),
    TimeSlot(id: 11, time: '01:30 PM'),
    TimeSlot(id: 12, time: '02:00 PM'),
    TimeSlot(id: 13, time: '02:30 PM'),
    TimeSlot(id: 14, time: '03:00 PM'),
    TimeSlot(id: 15, time: '03:30 PM'),
    TimeSlot(id: 16, time: '04:00 PM'),
  ];

  static List<TimeSlot> eveningSlot() => [
    TimeSlot(id: 17, time: '04:30 PM'),
    TimeSlot(id: 18, time: '05:00 PM'),
    TimeSlot(id: 19, time: '05:30 PM'),
    TimeSlot(id: 20, time: '06:00 PM'),
    TimeSlot(id: 21, time: '06:30 PM'),
    TimeSlot(id: 22, time: '07:00 PM'),
    TimeSlot(id: 23, time: '07:30 PM'),
    TimeSlot(id: 24, time: '08:00 PM'),
  ];

  @override
  String toString() => 'TimeSlot(id: $id, time: $time, selected: $isSelected)';
}
