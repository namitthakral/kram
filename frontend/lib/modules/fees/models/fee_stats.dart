class StudentFeeSummary {
  StudentFeeSummary({
    required this.totalFees,
    required this.paidFees,
    required this.pendingFees,
    required this.overdueFees,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.lateFeeAmount,
  });

  factory StudentFeeSummary.fromJson(Map<String, dynamic> json) =>
      StudentFeeSummary(
        totalFees: json['totalFees'] ?? 0,
        paidFees: json['paidFees'] ?? 0,
        pendingFees: json['pendingFees'] ?? 0,
        overdueFees: json['overdueFees'] ?? 0,
        totalAmount: double.parse((json['totalAmount'] ?? 0).toString()),
        paidAmount: double.parse((json['paidAmount'] ?? 0).toString()),
        pendingAmount: double.parse((json['pendingAmount'] ?? 0).toString()),
        lateFeeAmount: double.parse((json['lateFeeAmount'] ?? 0).toString()),
      );
  final int totalFees;
  final int paidFees;
  final int pendingFees;
  final int overdueFees;
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;
  final double lateFeeAmount;
}

class FeeCollectionSummary {
  FeeCollectionSummary({
    required this.totalExpected,
    required this.totalCollected,
    required this.totalPending,
    required this.collectionRate,
  });

  factory FeeCollectionSummary.fromJson(Map<String, dynamic> json) =>
      FeeCollectionSummary(
        totalExpected: double.parse((json['total_expected'] ?? 0).toString()),
        totalCollected: double.parse((json['total_collected'] ?? 0).toString()),
        totalPending: double.parse((json['total_pending'] ?? 0).toString()),
        collectionRate: double.parse((json['collection_rate'] ?? 0).toString()),
      );
  final double totalExpected;
  final double totalCollected;
  final double totalPending;
  final double collectionRate;
}

/// Overdue fee row from GET /fees/overdue
class OverdueFee {
  OverdueFee({
    required this.studentFeeId,
    required this.studentId,
    required this.rollNumber,
    required this.studentName,
    required this.feeName,
    required this.totalOverdueAmount,
    required this.dueDate,
    required this.daysOverdue,
    required this.status,
  });

  factory OverdueFee.fromJson(Map<String, dynamic> json) => OverdueFee(
    studentFeeId:
        int.tryParse(
          (json['student_fee_id'] ?? json['studentFeeId'] ?? 0).toString(),
        ) ??
        0,
    studentId:
        int.tryParse(
          (json['student_id'] ?? json['studentId'] ?? 0).toString(),
        ) ??
        0,
    rollNumber: (json['roll_number'] ?? json['rollNumber'] ?? '').toString(),
    studentName: (json['student_name'] ?? json['studentName'] ?? '').toString(),
    feeName: (json['fee_name'] ?? json['feeName'] ?? '').toString(),
    totalOverdueAmount:
        double.tryParse(
          (json['total_overdue_amount'] ?? json['totalOverdueAmount'] ?? 0)
              .toString(),
        ) ??
        0,
    dueDate:
        DateTime.tryParse(
          (json['due_date'] ?? json['dueDate'])?.toString() ?? '',
        ) ??
        DateTime.now(),
    daysOverdue:
        int.tryParse(
          (json['days_overdue'] ?? json['daysOverdue'] ?? 0).toString(),
        ) ??
        0,
    status: (json['status'] ?? 'PENDING').toString(),
  );
  final int studentFeeId;
  final int studentId;
  final String rollNumber;
  final String studentName;
  final String feeName;
  final double totalOverdueAmount;
  final DateTime dueDate;
  final int daysOverdue;
  final String status;
}

/// Response from GET /fees/overdue
class OverdueSummary {
  OverdueSummary({
    required this.count,
    required this.totalOverdue,
    required this.fees,
  });

  factory OverdueSummary.fromJson(Map<String, dynamic> json) {
    final List<dynamic> feesList = json['fees'] ?? [];
    return OverdueSummary(
      count: int.tryParse((json['count'] ?? 0).toString()) ?? 0,
      totalOverdue:
          double.tryParse((json['totalOverdue'] ?? 0).toString()) ?? 0,
      fees:
          feesList
              .map(
                (e) => OverdueFee.fromJson(
                  e is Map<String, dynamic>
                      ? e
                      : Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList(),
    );
  }
  final int count;
  final double totalOverdue;
  final List<OverdueFee> fees;
}

/// Response from GET /fees/payments/summary/institution (analytics)
class PaymentSummary {
  PaymentSummary({
    required this.totalPayments,
    required this.totalAmount,
    required this.byMethod,
    required this.byMode,
    required this.monthlyTrends,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    final monthly = json['monthlyTrends'] ?? json['monthly_trends'] ?? [];
    return PaymentSummary(
      totalPayments:
          int.tryParse(
            (json['totalPayments'] ?? json['total_payments'] ?? 0).toString(),
          ) ??
          0,
      totalAmount:
          double.tryParse(
            (json['totalAmount'] ?? json['total_amount'] ?? 0).toString(),
          ) ??
          0,
      byMethod:
          json['byMethod'] is Map
              ? Map<String, dynamic>.from(json['byMethod'] as Map)
              : {},
      byMode:
          json['byMode'] is Map
              ? Map<String, dynamic>.from(json['byMode'] as Map)
              : {},
      monthlyTrends:
          monthly is List
              ? monthly
                  .map(
                    (e) =>
                        e is Map
                            ? Map<String, dynamic>.from(e)
                            : <String, dynamic>{},
                  )
                  .toList()
              : [],
    );
  }
  final int totalPayments;
  final double totalAmount;
  final Map<String, dynamic> byMethod;
  final Map<String, dynamic> byMode;
  final List<Map<String, dynamic>> monthlyTrends;
}
