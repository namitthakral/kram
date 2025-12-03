import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/theme_provider.dart';
import '../../utils/extensions.dart';

/// A custom dropdown form field with generic type support
/// Uses type inference to handle any type T
class DropDownFormField<T> extends StatelessWidget {
  const DropDownFormField({
    required this.items,
    required this.onChanged,
    required this.displayText,
    super.key,
    this.label,
    this.hintText,
    this.value,
    this.validator,
    this.prefixIcon,
    this.isEnabled = true,
    this.filled = true,
    this.border,
  });

  /// Label text displayed above the dropdown
  final String? label;

  /// Hint text when no value is selected
  final String? hintText;

  /// Current selected value
  final T? value;

  /// List of items to display in dropdown
  final List<T> items;

  /// Callback when value changes
  final void Function(T?)? onChanged;

  /// Function to convert item T to display string
  final String Function(T) displayText;

  /// Validator function
  final String? Function(T?)? validator;

  /// Prefix icon widget
  final Widget? prefixIcon;

  /// Whether the field is enabled
  final bool isEnabled;

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
        if (label != null) ...[
          Text(
            label ?? '',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
        ],
        DropdownButtonFormField<T>(
          key: ValueKey<T?>(value),
          initialValue: value,
          isExpanded: true,
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFF3F3F3), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          style: context.textTheme.bodySm.copyWith(color: textColor),
          dropdownColor: const Color(0xFFFBFBFD),
          icon: Icon(Icons.keyboard_arrow_down, color: textColor),
          items:
              items
                  .map(
                    (item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(
                        displayText(item),
                        style: context.textTheme.bodySm.copyWith(
                          color: textColor,
                        ),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: isEnabled ? onChanged : null,
          validator: validator,
        ),
      ],
    );
  }
}
