import 'package:flutter/material.dart';

enum AttendanceStatus { PRESENT, ABSENT, LATE, EXCUSED }

class StudentAttendanceRecord {

  StudentAttendanceRecord({
    required this.id,
    required this.studentId,
    required this.sectionId,
    required this.date,
    required this.status,
    this.remarks,
    this.subjectName,
    this.subjectCode,
  });

  factory StudentAttendanceRecord.fromJson(Map<String, dynamic> json) => StudentAttendanceRecord(
      id: json['id'],
      studentId: json['studentId'],
      sectionId: json['sectionId'],
      date: DateTime.parse(json['date']),
      status: _parseStatus(json['status']),
      remarks: json['remarks'],
      subjectName: json['section']?['subject']?['subjectName'],
      subjectCode: json['section']?['subject']?['subjectCode'],
    );
  final int id;
  final int studentId;
  final int sectionId;
  final DateTime date;
  final AttendanceStatus status;
  final String? remarks;
  final String? subjectName;
  final String? subjectCode;

  static AttendanceStatus _parseStatus(String status) => AttendanceStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status,
      orElse: () => AttendanceStatus.PRESENT,
    );

  Color get statusColor {
    switch (status) {
      case AttendanceStatus.PRESENT:
        return Colors.green;
      case AttendanceStatus.ABSENT:
        return Colors.red;
      case AttendanceStatus.LATE:
        return Colors.orange;
      case AttendanceStatus.EXCUSED:
        return Colors.blue;
    }
  }

  String get statusText => status.toString().split('.').last;
}

class AttendanceStats {

  AttendanceStats({
    required this.totalClasses,
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
  });
  final int totalClasses;
  final int present;
  final int absent;
  final int late;
  final int excused;

  double get attendancePercentage {
    if (totalClasses == 0) return 0.0;
    return (present / totalClasses) * 100;
  }
}
