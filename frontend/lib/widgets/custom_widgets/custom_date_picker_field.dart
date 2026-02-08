import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../provider/theme_provider.dart';

/// A custom date picker field that matches the design system
class CustomDatePickerField extends StatelessWidget {
  const CustomDatePickerField({
    required this.label,
    required this.onDateSelected,
    super.key,
    this.selectedDate,
    this.hintText,
    this.prefixIcon,
    this.firstDate,
    this.lastDate,
    this.filled = true,
    this.border,
  });

  /// Label text displayed above the field
  final String label;

  /// Currently selected date
  final DateTime? selectedDate;

  /// Hint text when no date is selected
  final String? hintText;

  /// Callback when date is selected
  final void Function(DateTime?) onDateSelected;

  /// Prefix icon widget
  final Widget? prefixIcon;

  /// First selectable date
  final DateTime? firstDate;

  /// Last selectable date
  final DateTime? lastDate;

  /// Whether the field should have a filled background
  final bool filled;

  /// Custom border styling
  final InputBorder? border;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.themeData;
    final primaryColor = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(15),
          child: InputDecorator(
            decoration: InputDecoration(
              filled: filled,
              fillColor: filled ? const Color(0xFFFBFBFD) : null,
              prefixIcon: prefixIcon,
              hintText: hintText,
              hintStyle: const TextStyle(color: Color(0xFFA7AEC1)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border:
                  border ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Color(0xFFF3F3F3)),
                  ),
              enabledBorder:
                  border ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Color(0xFFF3F3F3)),
                  ),
              focusedBorder:
                  border ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat('MMM dd, yyyy').format(selectedDate!)
                      : hintText ?? 'Select date',
                  style: TextStyle(
                    color:
                        selectedDate != null
                            ? textColor
                            : const Color(0xFFA7AEC1),
                    fontSize: 14,
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Color(0xFFA7AEC1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final initialDate = selectedDate ?? DateTime.now();

    // Ensure firstDate and lastDate encompass the initialDate
    // This prevents crashes if the selected date (e.g. from editing an old record)
    // is outside the restricted range (e.g. future dates only).
    var effectiveFirstDate =
        firstDate ?? DateTime.now().subtract(const Duration(days: 365));
    if (initialDate.isBefore(effectiveFirstDate)) {
      effectiveFirstDate = initialDate;
    }

    var effectiveLastDate =
        lastDate ?? DateTime.now().add(const Duration(days: 365));
    if (initialDate.isAfter(effectiveLastDate)) {
      effectiveLastDate = initialDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: effectiveFirstDate,
      lastDate: effectiveLastDate,
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }
}
