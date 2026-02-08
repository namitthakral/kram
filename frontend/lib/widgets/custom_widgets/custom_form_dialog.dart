import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../utils/custom_colors.dart';

/// Custom form dialog widget for complex forms with multiple fields
/// Follows the project's design system and theme patterns
class CustomFormDialog extends StatelessWidget {
  const CustomFormDialog({
    required this.title,
    required this.content,
    this.subtitle,
    this.headerIcon,
    this.confirmText = 'Save',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.confirmColor,
    this.maxWidth = 600,
    this.showActions = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? headerIcon;
  final Widget content;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;
  final double maxWidth;
  final bool showActions;

  @override
  Widget build(BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: CustomAppColors.slate50,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    if (headerIcon != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (confirmColor ?? AppTheme.blue500)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          headerIcon,
                          color: confirmColor ?? AppTheme.blue500,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeXl,
                              fontWeight: AppTheme.fontWeightBold,
                              color: AppTheme.slate800,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle!,
                              style: const TextStyle(
                                fontSize: AppTheme.fontSizeSm,
                                color: AppTheme.slate600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: AppTheme.slate600,
                      onPressed: onCancel ?? () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: content,
                ),
              ),

              // Actions
              if (showActions)
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: onCancel ?? () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: AppTheme.slate500),
                        ),
                        child: Text(
                          cancelText,
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeBase,
                            fontWeight: AppTheme.fontWeightMedium,
                            color: AppTheme.slate600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: onConfirm ?? () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          backgroundColor: confirmColor ?? AppTheme.blue500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          confirmText,
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeBase,
                            fontWeight: AppTheme.fontWeightMedium,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );

  /// Show a form dialog with custom content
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    String? subtitle,
    IconData? headerIcon,
    String confirmText = 'Save',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? confirmColor,
    double maxWidth = 600,
    bool showActions = true,
  }) =>
      showDialog<T>(
        context: context,
        builder: (context) => CustomFormDialog(
          title: title,
          subtitle: subtitle,
          headerIcon: headerIcon,
          content: content,
          confirmText: confirmText,
          cancelText: cancelText,
          onConfirm: onConfirm,
          onCancel: onCancel,
          confirmColor: confirmColor,
          maxWidth: maxWidth,
          showActions: showActions,
        ),
      );
}

/// Helper widget for form field labels with consistent styling
class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel({
    required this.label,
    this.required = false,
    super.key,
  });

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeBase,
                fontWeight: AppTheme.fontWeightMedium,
                color: AppTheme.slate800,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeBase,
                  color: AppTheme.danger,
                ),
              ),
          ],
        ),
      );
}

/// Helper widget for styled dropdown fields within forms
class FormDropdownField<T> extends StatelessWidget {
  const FormDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.required = false,
    super.key,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final bool required;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormFieldLabel(label: label, required: required),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: CustomAppColors.slate200),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: DropdownButton<T>(
              isExpanded: true,
              value: value,
              underline: const SizedBox(),
              hint: hint != null
                  ? Text(
                      hint!,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeBase,
                        color: AppTheme.slate500,
                      ),
                    )
                  : null,
              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
              style: const TextStyle(
                fontSize: AppTheme.fontSizeBase,
                color: AppTheme.slate800,
              ),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ],
      );
}

/// Helper widget for checkbox fields within forms
class FormCheckboxField extends StatelessWidget {
  const FormCheckboxField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CustomAppColors.slate50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: value ? AppTheme.blue500 : CustomAppColors.slate200,
              width: value ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppTheme.blue500,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeBase,
                        fontWeight: AppTheme.fontWeightMedium,
                        color: AppTheme.slate800,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeSm,
                          color: AppTheme.slate600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
