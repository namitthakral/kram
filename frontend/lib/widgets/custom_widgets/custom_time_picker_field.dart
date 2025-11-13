import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/theme_provider.dart';

/// A custom time picker field that matches the design system
class CustomTimePickerField extends StatelessWidget {
  const CustomTimePickerField({
    required this.label,
    required this.onTimeSelected,
    super.key,
    this.selectedTime,
    this.hintText,
    this.prefixIcon,
    this.filled = true,
    this.border,
  });

  /// Label text displayed above the field
  final String label;

  /// Currently selected time
  final TimeOfDay? selectedTime;

  /// Hint text when no time is selected
  final String? hintText;

  /// Callback when time is selected
  final void Function(TimeOfDay?) onTimeSelected;

  /// Prefix icon widget
  final Widget? prefixIcon;

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
          onTap: () => _selectTime(context),
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
                  selectedTime != null
                      ? selectedTime!.format(context)
                      : hintText ?? 'Select time',
                  style: TextStyle(
                    color: selectedTime != null
                        ? textColor
                        : const Color(0xFFA7AEC1),
                    fontSize: 14,
                  ),
                ),
                const Icon(
                  Icons.access_time,
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

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      onTimeSelected(picked);
    }
  }
}
