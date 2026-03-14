import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';
import '../../models/student_fee.dart';
import '../../providers/fees_provider.dart';
import '../../widgets/fee_status_chip.dart';

class StudentFeesScreen extends StatefulWidget {
  const StudentFeesScreen({super.key});

  @override
  State<StudentFeesScreen> createState() => _StudentFeesScreenState();
}

class _StudentFeesScreenState extends State<StudentFeesScreen> {
  // Hardcoded for now, normally get from auth context
  final int _studentId = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<FeesProvider>(context, listen: false);
      provider.loadStudentFees(studentId: _studentId);
      provider.loadStudentFeeSummary(_studentId);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: const Text('My Fees'),
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppStyles.headlineSmall.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    body: Consumer<FeesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.studentFees.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (provider.studentFeeSummary != null)
                _buildSummaryCard(provider.studentFeeSummary!.pendingAmount),
              const SizedBox(height: 24),
              const Text('Fee Breakdown', style: AppStyles.headlineSmall),
              const SizedBox(height: 16),
              if (provider.studentFees.isEmpty)
                _buildEmptyState()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.studentFees.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 12),
                  itemBuilder:
                      (context, index) =>
                          _buildFeeCard(context, provider.studentFees[index]),
                ),
            ],
          ),
        );
      },
    ),
  );

  Widget _buildSummaryCard(double pendingAmount) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total Pending Amount',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          '₹${pendingAmount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Integrate Payment Gateway
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment Gateway Integration Pending'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'PAY NOW',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildFeeCard(BuildContext context, StudentFee fee) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: Border.all(color: Colors.transparent),
        title: Text(
          fee.feeStructure?.feeName ?? 'Fee',
          style: AppStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Due: ${dateFormat.format(fee.dueDate)}',
              style: AppStyles.bodySmall.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormat.format(fee.remainingAmount),
              style: AppStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: fee.status == 'PAID' ? Colors.green : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            FeeStatusChip(status: fee.status),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                const Divider(),
                _buildDetailRow(
                  'Original Amount',
                  currencyFormat.format(fee.amountDue),
                ),
                if (fee.lateFeeApplied > 0)
                  _buildDetailRow(
                    'Late Fee',
                    currencyFormat.format(fee.lateFeeApplied),
                    color: Colors.red,
                  ),
                if (fee.discount > 0)
                  _buildDetailRow(
                    'Discount',
                    '-${currencyFormat.format(fee.discount)}',
                    color: Colors.green,
                  ),
                const Divider(),
                _buildDetailRow(
                  'Paid Amount',
                  currencyFormat.format(fee.amountPaid),
                  isBold: true,
                ),
                const SizedBox(height: 8),
                if (fee.payments != null && fee.payments!.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Payment History', style: AppStyles.titleSmall),
                  ),
                  const SizedBox(height: 8),
                  ...fee.payments!.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateFormat.format(p.paymentDate),
                            style: AppStyles.bodySmall,
                          ),
                          Text(
                            currencyFormat.format(p.amount),
                            style: AppStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppStyles.bodyMedium.copyWith(color: Colors.grey[600]),
        ),
        Text(
          value,
          style: AppStyles.bodyMedium.copyWith(
            color: color ?? Colors.black87,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );

  Widget _buildEmptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.green[200]),
          const SizedBox(height: 16),
          Text(
            'No fees due!',
            style: AppStyles.titleMedium.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    ),
  );
}
