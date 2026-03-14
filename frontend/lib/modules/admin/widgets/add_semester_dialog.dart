import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/custom_widgets/custom_form_dialog.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../services/admin_service.dart';

class AddSemesterDialog extends StatefulWidget {
  final int academicYearId;
  final String academicYearName;

  const AddSemesterDialog({
    super.key,
    required this.academicYearId,
    required this.academicYearName,
  });

  @override
  State<AddSemesterDialog> createState() => _AddSemesterDialogState();
}

class _AddSemesterDialogState extends State<AddSemesterDialog> {
  final _adminService = AdminService();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 180));
  DateTime? _regStartDate;
  DateTime? _regEndDate;

  bool _isSaving = false;
  bool _isSchool = false;

  @override
  void initState() {
    super.initState();
    _checkInstitutionType();
  }

  void _checkInstitutionType() {
    final loginProvider = context.read<LoginProvider>();
    setState(() {
      _isSchool = loginProvider.currentUser?.institution?.type == 'SCHOOL';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectRegDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _regStartDate : _regEndDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _regStartDate = picked;
        } else {
          _regEndDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomFormDialog(
      title: context.translate(_isSchool ? 'add_term' : 'add_semester'),
      subtitle: '${context.translate('create_new_semester_for')} ${widget.academicYearName}',
      headerIcon: Icons.calendar_today_rounded,
      confirmText: context.translate('create'),
      cancelText: context.translate('cancel'),
      confirmColor: AppTheme.blue500,
      onConfirm: _isSaving ? null : _handleCreate,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            label: context.translate(_isSchool ? 'term_name' : 'semester_name'),
            hintText: _isSchool ? 'e.g. Term 1' : 'e.g. Fall 2024',
            controller: _nameController,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: context.translate(_isSchool ? 'term_number' : 'semester_number'),
            hintText: 'e.g. 1',
            controller: _numberController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateTile(
                  'Start Date',
                  _startDate,
                  () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateTile(
                  'End Date',
                  _endDate,
                  () => _selectDate(context, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Registration Period (Optional)',
            style: TextStyle(
              fontSize: AppTheme.fontSizeSm,
              fontWeight: AppTheme.fontWeightSemibold,
              color: AppTheme.slate600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDateTile(
                  'Reg. Start',
                  _regStartDate,
                  () => _selectRegDate(context, true),
                  isOptional: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateTile(
                  'Reg. End',
                  _regEndDate,
                  () => _selectRegDate(context, false),
                  isOptional: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTile(
    String label,
    DateTime? date,
    VoidCallback onTap, {
    bool isOptional = false,
  }) {
    final dateStr =
        date != null
            ? DateFormat('dd MMM yyyy').format(date)
            : (isOptional ? 'Select' : '-');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppTheme.fontSizeXs,
            color: AppTheme.slate500,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.slate200),
              borderRadius: BorderRadius.circular(8),
              color: AppTheme.slate50,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  size: 16,
                  color: AppTheme.slate500,
                ),
                const SizedBox(width: 8),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeSm,
                    color: date != null ? AppTheme.slate800 : AppTheme.slate400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleCreate() async {
    if (_nameController.text.isEmpty) {
      showCustomSnackbar(
        message: context.translate(_isSchool ? 'enter_term_name' : 'enter_semester_name'),
        type: SnackbarType.warning,
      );
      return;
    }
    if (_numberController.text.isEmpty) {
      showCustomSnackbar(
        message: context.translate(_isSchool ? 'enter_term_number' : 'enter_semester_number'),
        type: SnackbarType.warning,
      );
      return;
    }

    final semesterNumber = int.tryParse(_numberController.text);
    if (semesterNumber == null) {
      showCustomSnackbar(
        message: context.translate(_isSchool ? 'invalid_term_number' : 'invalid_semester_number'),
        type: SnackbarType.warning,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _adminService.createSemester({
        'academicYearId': widget.academicYearId,
        'semesterName': _nameController.text.trim(),
        'semesterNumber': semesterNumber,
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate.toIso8601String(),
        'registrationStart': _regStartDate?.toIso8601String(),
        'registrationEnd': _regEndDate?.toIso8601String(),
      });

      if (mounted) {
        Navigator.pop(context, true);
        showCustomSnackbar(
          message: context.translate(_isSchool ? 'term_created' : 'semester_created'),
          type: SnackbarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(
          message: e.toString().replaceFirst('Exception: ', ''),
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
