import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';
import '../../providers/fees_provider.dart';

// Using DropdownSearch or simple Dropdown for now.
// Real app would likely need a searchable student picker.

class AssignFeeScreen extends StatefulWidget {
  const AssignFeeScreen({super.key});

  @override
  State<AssignFeeScreen> createState() => _AssignFeeScreenState();
}

class _AssignFeeScreenState extends State<AssignFeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final int _institutionId = 1;

  int? _selectedFeeStructureId;
  int? _selectedStudentId; // For simplicity, single student assignment for now
  // Real implementation should probably allow multiple selection or class selection

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeesProvider>(
        context,
        listen: false,
      ).loadFeeStructures(institutionId: _institutionId);
      // Also need to load students - assuming a StudentProvider exists
      // Provider.of<StudentProvider>(context, listen: false).loadStudents();
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      // This logic is for finding the fee structure details to autopopulate due date/amount
      // But API handles creation based on structure ID usually.

      final data = {
        'studentId': _selectedStudentId,
        'feeStructureId': _selectedFeeStructureId,
        'institutionId': _institutionId,
        // Optional: override amount/dueDate if needed
      };

      final success = await Provider.of<FeesProvider>(
        context,
        listen: false,
      ).assignFeeToStudent(data);

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fee assigned successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Failed to assign fee')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: const Text('Assign Fee'),
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
            Text(
              'Assign Fee to Student',
              style: AppStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Placeholder for Student Picker
            // Real implementation: Searchable dropdown/modal
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Student ID (Placeholder)',
                hintText: 'Enter Student ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              keyboardType: TextInputType.number,
              validator:
                  (value) => value == null || value.isEmpty ? 'Required' : null,
              onChanged: (value) => _selectedStudentId = int.tryParse(value),
            ),
            const SizedBox(height: 16),

            Consumer<FeesProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.feeStructures.isEmpty) {
                  return const LinearProgressIndicator();
                }

                return DropdownButtonFormField<int>(
                  initialValue: _selectedFeeStructureId,
                  decoration: InputDecoration(
                    labelText: 'Select Fee Structure',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  items:
                      provider.feeStructures
                          .map(
                            (structure) => DropdownMenuItem(
                              value: structure.id,
                              child: Text(
                                '${structure.feeName} (₹${structure.amount})',
                              ),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (value) =>
                          setState(() => _selectedFeeStructureId = value),
                  validator:
                      (value) =>
                          value == null
                              ? 'Please select a fee structure'
                              : null,
                );
              },
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
                          'Assign Fee',
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
