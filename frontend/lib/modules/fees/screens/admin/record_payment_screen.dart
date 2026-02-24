import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';
import '../../providers/fees_provider.dart';
import '../../models/student_fee.dart';

class RecordPaymentScreen extends StatefulWidget {
  final StudentFee? studentFee;

  const RecordPaymentScreen({super.key, this.studentFee});

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _transactionIdController = TextEditingController();
  final _remarksController = TextEditingController();

  String _paymentMethod = 'CASH';
  String _paymentMode = 'OFFLINE';
  DateTime _paymentDate = DateTime.now();

  final List<String> _methods = [
    'CASH',
    'CHEQUE',
    'UPI',
    'BANK_TRANSFER',
    'CARD',
  ];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.studentFee != null) {
      _amountController.text = widget.studentFee!.remainingAmount.toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _transactionIdController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final data = {
        'studentId': widget.studentFee?.studentId,
        'studentFeeId': widget.studentFee?.id,
        'amount': double.parse(_amountController.text),
        'paymentDate': _paymentDate.toIso8601String(),
        'paymentMethod': _paymentMethod,
        'paymentMode': _paymentMode,
        'transactionId':
            _transactionIdController.text.isNotEmpty
                ? _transactionIdController.text
                : null,
        'remarks':
            _remarksController.text.isNotEmpty ? _remarksController.text : null,
      };

      final success = await Provider.of<FeesProvider>(
        context,
        listen: false,
      ).recordPayment(data);

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment recorded successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to record payment')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.studentFee == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Record Payment')),
        body: const Center(child: Text('Please select a student fee first.')),
      );
    }

    final fee = widget.studentFee!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Record Payment'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppStyles.headlineSmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(fee),
              const SizedBox(height: 24),
              _buildSectionTitle('Payment Details'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Amount (₹)', '0.00'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter amount';
                  final amount = double.tryParse(value);
                  if (amount == null) return 'Invalid amount';
                  if (amount > fee.remainingAmount) return 'Amount exceeds due';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: _inputDecoration('Payment Method', ''),
                items:
                    _methods
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                onChanged: (val) => setState(() => _paymentMethod = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _transactionIdController,
                decoration: _inputDecoration(
                  'Transaction ID / Cheque No.',
                  'Optional',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remarksController,
                maxLines: 2,
                decoration: _inputDecoration('Remarks', 'Optional'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            'Confirm Payment',
                            style: AppStyles.titleMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(StudentFee fee) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          _buildInfoRow('Student', fee.student?['user']?['name'] ?? 'N/A'),
          const SizedBox(height: 8),
          _buildInfoRow('Fee Type', fee.feeStructure?.feeName ?? 'N/A'),
          const SizedBox(height: 8),
          _buildInfoRow('Total Due', '₹${fee.totalAmount.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Remaining',
            '₹${fee.remainingAmount.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppStyles.bodyMedium.copyWith(color: Colors.grey[700]),
        ),
        Text(
          value,
          style: AppStyles.bodyMedium.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppColors.primary : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppStyles.titleMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      fillColor: Colors.white,
      filled: true,
    );
  }
}
