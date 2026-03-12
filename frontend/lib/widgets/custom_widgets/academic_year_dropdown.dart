import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/academic_year_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../utils/extensions.dart';

class AcademicYearDropdown extends StatelessWidget {
  final int? value;
  final ValueChanged<int?>? onChanged;
  final String? label;
  final FormFieldValidator<int?>? validator;
  final bool isRequired;

  const AcademicYearDropdown({
    super.key,
    this.value,
    this.onChanged,
    this.label = 'Academic Year',
    this.validator,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AcademicYearProvider>(
      builder: (context, provider, child) {
        if (provider.academicYears.isEmpty && !provider.isLoading) {
          // Trigger load if empty
          Future.microtask(() => provider.loadAcademicYears());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) ...[
              Text(
                '$label${isRequired ? ' *' : ''}',
                style: context.textTheme.labelSm.copyWith(
                  color: AppTheme.slate600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
            ],
            DropdownButtonFormField<int>(
              value: value ?? provider.selectedAcademicYearId,
              hint: Text(
                provider.isLoading ? 'Loading...' : 'Select Academic Year',
                style: context.textTheme.bodyBase.copyWith(
                  color: AppTheme.slate500,
                ),
              ),
              items: provider.academicYears.map((year) {
                return DropdownMenuItem<int>(
                  value: year.id,
                  child: Text(
                    '${year.yearName} (${year.startDate.year} - ${year.endDate.year})',
                    style: context.textTheme.bodyBase,
                  ),
                );
              }).toList(),
              onChanged: provider.isLoading ? null : (newValue) {
                if (onChanged != null) {
                  onChanged!(newValue);
                } else {
                  provider.setSelectedAcademicYearId(newValue);
                }
              },
              validator: validator ?? (isRequired 
                ? (v) => v == null ? 'Selection required' : null 
                : null),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.slate200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.slate200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.blue500, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}
