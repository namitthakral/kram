import 'package:flutter/material.dart';

/// Child Information Model
class ChildInfo {
  const ChildInfo({
    required this.name,
    required this.initials,
    required this.grade,
    required this.rollNumber,
    required this.overallGrade,
    required this.attendance,
  });

  final String name;
  final String initials;
  final String grade;
  final String rollNumber;
  final String overallGrade;
  final double attendance;
}

/// Academic Activity Model
class AcademicActivity {
  const AcademicActivity({
    required this.title,
    required this.date,
    required this.type,
    this.score,
    this.grade,
  });

  final String title;
  final String date;
  final ActivityType type;
  final String? score;
  final String? grade;
}

enum ActivityType { test, project, assignment, quiz }

/// School Announcement Model
class SchoolAnnouncement {
  const SchoolAnnouncement({
    required this.title,
    required this.description,
    required this.date,
    required this.priority,
  });

  final String title;
  final String description;
  final String date;
  final AnnouncementPriority priority;
}

enum AnnouncementPriority { high, medium, low }

/// Subject Performance Model for Parent
class ParentSubjectPerformance {
  const ParentSubjectPerformance({
    required this.subject,
    required this.lastTest,
    required this.grade,
    required this.improvement,
  });

  final String subject;
  final String lastTest;
  final String grade;
  final int improvement;
}

/// Performance Trend Data Point
class PerformanceTrendPoint {
  const PerformanceTrendPoint({
    required this.month,
    required this.english,
    required this.mathematics,
    required this.science,
  });

  final String month;
  final double english;
  final double mathematics;
  final double science;
}

/// Attendance Trend Data Point
class AttendanceTrendPoint {
  const AttendanceTrendPoint({required this.month, required this.percentage});

  final String month;
  final double percentage;
}

/// Subject Breakdown Data
class SubjectBreakdown {
  const SubjectBreakdown({
    required this.subject,
    required this.percentage,
    required this.grade,
    required this.change,
    required this.color,
  });

  final String subject;
  final double percentage;
  final String grade;
  final int change;
  final Color color;
}

/// Dashboard Tab Enum
enum ParentDashboardTab {
  academicPerformance,
  attendanceHistory,
  subjectBreakdown,
}
