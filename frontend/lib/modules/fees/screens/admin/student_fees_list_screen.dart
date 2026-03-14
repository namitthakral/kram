import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';
import '../../models/student_fee.dart';
import '../../providers/fees_provider.dart';
import '../../widgets/fee_status_chip.dart';

class StudentFeesListScreen extends StatefulWidget {
  const StudentFeesListScreen({super.key});

  @override
  State<StudentFeesListScreen> createState() => _StudentFeesListScreenState();
}

class _StudentFeesListScreenState extends State<StudentFeesListScreen> {
  final int _institutionId = 1; // Hardcoded
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeesProvider>(
        context,
        listen: false,
      ).loadStudentFees(institutionId: _institutionId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: const Text('Student Fees'),
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppStyles.headlineSmall.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () {
        Navigator.pushNamed(context, '/admin/fees/assign');
      },
      label: const Text('Assign Fee'),
      icon: const Icon(Icons.assignment_ind),
      backgroundColor: AppColors.primary,
    ),
    body: Consumer<FeesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.studentFees.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.studentFees.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No student fees found',
                  style: AppStyles.titleMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by Student Name or ID',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
                onChanged: (value) {
                  // TODO: Implement local filtering or debounce API search
                },
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.studentFees.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final studentFee = provider.studentFees[index];
                  return _buildStudentFeeCard(context, studentFee);
                },
              ),
            ),
          ],
        );
      },
    ),
  );

  Widget _buildStudentFeeCard(BuildContext context, StudentFee studentFee) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    final studentName =
        studentFee.student?['user']?['name'] ?? 'Unknown Student';
    final rollNumber = studentFee.student?['rollNumber'] ?? 'N/A';
    final feeName = studentFee.feeStructure?.feeName ?? 'Unknown Fee';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: AppStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Roll No: $rollNumber',
                        style: AppStyles.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                FeeStatusChip(status: studentFee.status),
              ],
            ),
            const Divider(height: 24),
            Text(
              feeName,
              style: AppStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Due Date',
                      style: AppStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      dateFormat.format(studentFee.dueDate),
                      style: AppStyles.bodyMedium,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Amount Due',
                      style: AppStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      currencyFormat.format(studentFee.remainingAmount),
                      style: AppStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (studentFee.status != 'PAID') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/admin/fees/payments/record',
                      arguments: studentFee,
                    );
                  },
                  child: const Text('Record Payment'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
