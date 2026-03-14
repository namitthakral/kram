class Payment {
  Payment({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.paymentDate,
    required this.createdAt,
    this.studentFeeId,
    this.transactionId,
    this.receiptNumber,
    this.remarks,
    this.student,
    this.studentFee,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: _int(json['id']),
    studentFeeId: _intOrNull(json['studentFeeId'] ?? json['student_fee_id']),
    amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0,
    paymentMethod:
        (json['paymentMethod'] ?? json['payment_method'] ?? 'CASH').toString(),
    transactionId:
        json['transactionId']?.toString() ?? json['transaction_id']?.toString(),
    receiptNumber:
        json['receiptNumber']?.toString() ?? json['receipt_number']?.toString(),
    status: (json['status'] ?? 'PENDING').toString(),
    remarks: json['remarks']?.toString(),
    paymentDate:
        DateTime.tryParse(
          (json['paymentDate'] ?? json['payment_date'])?.toString() ?? '',
        ) ??
        DateTime.now(),
    createdAt:
        DateTime.tryParse(
          (json['createdAt'] ?? json['created_at'])?.toString() ?? '',
        ) ??
        DateTime.now(),
    student:
        json['student'] is Map<String, dynamic>
            ? json['student'] as Map<String, dynamic>
            : null,
    studentFee:
        json['studentFee'] is Map<String, dynamic>
            ? json['studentFee'] as Map<String, dynamic>
            : null,
  );
  final int id;
  final int? studentFeeId;
  final double amount;
  final String paymentMethod;
  final String? transactionId;
  final String? receiptNumber;
  final String status;
  final String? remarks;
  final DateTime paymentDate;
  final DateTime createdAt;
  final Map<String, dynamic>? student;
  final Map<String, dynamic>? studentFee;

  static int _int(v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static int? _intOrNull(v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
