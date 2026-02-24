import 'payment.dart';
import 'fee_structure.dart';

class StudentFee {
  final int id;
  final int studentId;
  final int feeStructureId;
  final int? semesterId;
  final double amountDue;
  final double amountPaid;
  final double lateFeeApplied;
  final double discount;
  final DateTime dueDate;
  final String status;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? student;
  final FeeStructure? feeStructure;
  final Map<String, dynamic>? semester;
  final List<Payment>? payments;

  StudentFee({
    required this.id,
    required this.studentId,
    required this.feeStructureId,
    this.semesterId,
    required this.amountDue,
    required this.amountPaid,
    required this.lateFeeApplied,
    required this.discount,
    required this.dueDate,
    required this.status,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
    this.student,
    this.feeStructure,
    this.semester,
    this.payments,
  });

  static int _int(dynamic v) {
    if (v == null) throw FormatException('Expected int but got null');
    if (v is int) return v;
    final parsed = int.tryParse(v.toString());
    if (parsed == null) throw FormatException('Expected int but got: $v');
    return parsed;
  }

  static int? _intOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  factory StudentFee.fromJson(Map<String, dynamic> json) {
    return StudentFee(
      id: _int(json['id']),
      studentId: _int(json['studentId'] ?? json['student_id']),
      feeStructureId: _int(json['feeStructureId'] ?? json['fee_structure_id']),
      semesterId: _intOrNull(json['semesterId'] ?? json['semester_id']),
      amountDue: double.tryParse((json['amountDue'] ?? json['amount_due'])?.toString() ?? '') ?? 0,
      amountPaid: double.tryParse((json['amountPaid'] ?? json['amount_paid'])?.toString() ?? '') ?? 0,
      lateFeeApplied: double.tryParse((json['lateFeeApplied'] ?? json['late_fee_applied'])?.toString() ?? '') ?? 0,
      discount: double.tryParse((json['discount'])?.toString() ?? '') ?? 0,
      dueDate: DateTime.tryParse((json['dueDate'] ?? json['due_date'])?.toString() ?? '') ?? DateTime.now(),
      status: (json['status'] ?? 'PENDING').toString(),
      remarks: json['remarks']?.toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? json['created_at'])?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? json['updated_at'])?.toString() ?? '') ?? DateTime.now(),
      student: json['student'] is Map<String, dynamic> ? json['student'] as Map<String, dynamic> : null,
      feeStructure:
          json['feeStructure'] != null
              ? FeeStructure.fromJson(json['feeStructure'] as Map<String, dynamic>)
              : json['fee_structure'] != null
                  ? FeeStructure.fromJson(json['fee_structure'] as Map<String, dynamic>)
                  : null,
      semester: json['semester'] is Map<String, dynamic> ? json['semester'] as Map<String, dynamic> : null,
      payments:
          json['payments'] != null && json['payments'] is List
              ? (json['payments'] as List)
                  .map((i) => Payment.fromJson(i as Map<String, dynamic>))
                  .toList()
              : null,
    );
  }

  double get totalAmount => amountDue + lateFeeApplied;
  double get remainingAmount => totalAmount - amountPaid;
}
