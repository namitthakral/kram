import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../services/admin_service.dart';

class CreateAcademicYearDialog extends StatefulWidget {
  const CreateAcademicYearDialog({super.key});

  @override
  State<CreateAcademicYearDialog> createState() =>
      _CreateAcademicYearDialogState();
}

class _CreateAcademicYearDialogState extends State<CreateAcademicYearDialog> {
  final TextEditingController _yearNameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedStatus = 'FUTURE';
  bool _isLoading = false;

  final AdminService _adminService = AdminService();

  @override
  void dispose() {
    _yearNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Row(
      children: [
        const Icon(Icons.calendar_view_month_rounded, color: AppTheme.blue500),
        const SizedBox(width: 12),
        Text(context.translate('create_academic_year')),
      ],
    ),
    content: SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            label: context.translate('year_name'),
            hintText: 'e.g. 2024-25, 2025-26',
            controller: _yearNameController,
          ),
          const SizedBox(height: 16),
          _buildDateField(
            label: context.translate('start_date'),
            controller: _startDateController,
            onDateSelected: (date) {
              setState(() {
                _startDate = date;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDateField(
            label: context.translate('end_date'),
            controller: _endDateController,
            onDateSelected: (date) {
              setState(() {
                _endDate = date;
              });
            },
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.translate('status'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.slate700,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.slate300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'FUTURE',
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(context.translate('future')),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'CURRENT',
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(context.translate('current')),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'PAST',
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(context.translate('past')),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
            ],
          ),
          if (_selectedStatus == 'CURRENT') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: Colors.orange[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.translate('current_year_warning'),
                      style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        child: Text(context.translate('cancel')),
      ),
      ElevatedButton(
        onPressed: _isLoading ? null : _createAcademicYear,
        child:
            _isLoading
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : Text(context.translate('create')),
      ),
    ],
  );

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required Function(DateTime) onDateSelected,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.slate700,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          hintText: 'Select date',
          suffixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.slate300),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (date != null) {
            controller.text = '${date.day}/${date.month}/${date.year}';
            onDateSelected(date);
          }
        },
      ),
    ],
  );

  Future<void> _createAcademicYear() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _adminService.createAcademicYear(
        yearName: _yearNameController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        status: _selectedStatus,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.translate('academic_year_created_successfully'),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_formatErrorMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateForm() {
    if (_yearNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('enter_year_name')),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('select_start_date')),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    if (_endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('select_end_date')),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.translate('start_date_must_be_before_end_date'),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    return true;
  }

  String _formatErrorMessage(String error) {
    if (error.contains('already exists')) {
      return context.translate('academic_year_already_exists');
    }
    if (error.contains('Start date must be before end date')) {
      return context.translate('start_date_must_be_before_end_date');
    }
    // Clean up technical error prefixes
    if (error.startsWith('Exception: ')) {
      error = error.substring(11);
    }
    return error;
  }
}
