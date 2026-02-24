import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';
import '../../providers/fees_provider.dart';

class CreateFeeStructureScreen extends StatefulWidget {
  const CreateFeeStructureScreen({super.key});

  @override
  State<CreateFeeStructureScreen> createState() =>
      _CreateFeeStructureScreenState();
}

class _CreateFeeStructureScreenState extends State<CreateFeeStructureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lateFeeAmountController = TextEditingController();
  final _lateFeeDaysController = TextEditingController(); // lateFeeAfterDays

  String _selectedFeeType = 'TUITION'; // Default
  int? _selectedAcademicYearId = 1; // Hardcoded default for now
  bool _isRecurring = false;
  String? _recurringFrequency;
  DateTime? _selectedDueDate;

  // Hardcoded constants for dropdowns (replace with API data later)
  final List<String> _feeTypes = [
    'TUITION',
    'LIBRARY',
    'EXAM',
    'TRANSPORT',
    'HOSTEL',
    'OTHER',
  ];
  final List<String> _frequencies = ['MONTHLY', 'QUARTERLY', 'YEARLY'];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _lateFeeAmountController.dispose();
    _lateFeeDaysController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final data = {
        'institutionId': 1, // Hardcoded
        'academicYearId': _selectedAcademicYearId,
        'feeName': _nameController.text,
        'feeType': _selectedFeeType,
        'amount': double.parse(_amountController.text),
        'dueDate': _selectedDueDate?.toIso8601String(),
        'description':
            _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
        'lateFeeAmount':
            _lateFeeAmountController.text.isEmpty
                ? null
                : double.parse(_lateFeeAmountController.text),
        'lateFeeAfterDays':
            _lateFeeDaysController.text.isEmpty
                ? null
                : int.parse(_lateFeeDaysController.text),
        'isRecurring': _isRecurring,
        'recurringFrequency': _isRecurring ? _recurringFrequency : null,
        'status': 'ACTIVE',
      };

      final success = await Provider.of<FeesProvider>(
        context,
        listen: false,
      ).createFeeStructure(data);

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fee structure created successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create fee structure')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Fee Structure'),
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
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(
                  'Fee Name',
                  'e.g. Tuition Fee 2024',
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter fee name'
                            : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedFeeType,
                decoration: _inputDecoration('Fee Type', ''),
                items:
                    _feeTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                onChanged: (value) => setState(() => _selectedFeeType = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Amount (₹)', '0.00'),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter amount';
                  if (double.tryParse(value) == null) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Schedule'),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: _inputDecoration('Due Date', ''),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDueDate != null
                            ? DateFormat(
                              'MMM dd, yyyy',
                            ).format(_selectedDueDate!)
                            : 'Select Date',
                        style:
                            _selectedDueDate != null
                                ? AppStyles.bodyMedium
                                : AppStyles.bodyMedium.copyWith(
                                  color: Colors.grey,
                                ),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Recurring Fee?'),
                subtitle: const Text('Does this fee repeat periodically?'),
                value: _isRecurring,
                onChanged: (val) => setState(() => _isRecurring = val),
                contentPadding: EdgeInsets.zero,
              ),
              if (_isRecurring) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _recurringFrequency,
                  decoration: _inputDecoration('Frequency', 'Select Frequency'),
                  items:
                      _frequencies.map((freq) {
                        return DropdownMenuItem(value: freq, child: Text(freq));
                      }).toList(),
                  onChanged:
                      (value) => setState(() => _recurringFrequency = value),
                  validator:
                      (value) =>
                          _isRecurring && value == null
                              ? 'Please select frequency'
                              : null,
                ),
              ],
              const SizedBox(height: 24),

              _buildSectionTitle('Late Fees (Optional)'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lateFeeAmountController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Late Fee Amount', '0.00'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lateFeeDaysController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        'Grace Days',
                        'Days after due date',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Description (Optional)'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _inputDecoration(
                  'Description',
                  'Add details about this fee...',
                ),
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
                            'Create Fee Structure',
                            style: AppStyles.titleMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
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
    );
  }
}
