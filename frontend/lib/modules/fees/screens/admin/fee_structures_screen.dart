import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';
import '../../models/fee_structure.dart';
import '../../providers/fees_provider.dart';

class FeeStructuresScreen extends StatefulWidget {
  const FeeStructuresScreen({super.key});

  @override
  State<FeeStructuresScreen> createState() => _FeeStructuresScreenState();
}

class _FeeStructuresScreenState extends State<FeeStructuresScreen> {
  // Hardcoded for now
  final int _institutionId = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeesProvider>(
        context,
        listen: false,
      ).loadFeeStructures(institutionId: _institutionId);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: const Text('Fee Structures'),
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
        Navigator.pushNamed(context, '/admin/fees/structures/create');
      },
      label: const Text('Create New'),
      icon: const Icon(Icons.add),
      backgroundColor: AppColors.primary,
    ),
    body: Consumer<FeesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.feeStructures.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.feeStructures.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No fee structures found',
                  style: AppStyles.titleMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/admin/fees/structures/create',
                    );
                  },
                  child: const Text('Create One'),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: provider.feeStructures.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final structure = provider.feeStructures[index];
            return _buildFeeStructureCard(context, structure);
          },
        );
      },
    ),
  );

  Widget _buildFeeStructureCard(BuildContext context, FeeStructure structure) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

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
                        structure.feeName,
                        style: AppStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        structure.feeType.toUpperCase(),
                        style: AppStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  currencyFormat.format(structure.amount),
                  style: AppStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                _buildInfoItem(
                  Icons.calendar_today,
                  'Due Date',
                  structure.dueDate != null
                      ? dateFormat.format(structure.dueDate!)
                      : 'N/A',
                ),
                const SizedBox(width: 24),
                _buildInfoItem(
                  Icons.repeat,
                  'Recurring',
                  structure.isRecurring
                      ? structure.recurringFrequency ?? 'Yes'
                      : 'No',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (structure.academicYear != null)
              _buildInfoItem(
                Icons.school,
                'Academic Year',
                structure.academicYear!['yearName'] ?? 'N/A',
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // TODO: Navigate to edit
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _confirmDelete(context, structure),
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) => Row(
    children: [
      Icon(icon, size: 16, color: Colors.grey[600]),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppStyles.bodySmall.copyWith(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ],
  );

  Future<void> _confirmDelete(
    BuildContext context,
    FeeStructure structure,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Fee Structure'),
            content: Text(
              'Are you sure you want to delete "${structure.feeName}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      final success = await Provider.of<FeesProvider>(
        context,
        listen: false,
      ).deleteFeeStructure(structure.id);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fee structure deleted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete fee structure')),
          );
        }
      }
    }
  }
}
