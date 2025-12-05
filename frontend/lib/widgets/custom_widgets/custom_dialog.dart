import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../provider/theme_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/extensions.dart';
import 'custom_elevated_button.dart';

/// Custom dialog widget following the project's design system
class CustomDialog {
  /// Show a confirmation dialog with custom styling
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    Color? confirmColor,
    IconData? icon,
    Color? iconColor,
  }) async => showDialog<bool>(
    context: context,
    builder:
        (context) => _ConfirmationDialog(
          title: title,
          message: message,
          confirmText: confirmText ?? context.translate('confirm'),
          cancelText: cancelText ?? context.translate('cancel'),
          confirmColor: confirmColor,
          icon: icon,
          iconColor: iconColor,
        ),
  );

  /// Show a delete confirmation dialog
  static Future<bool?> showDeleteConfirmation({
    required BuildContext context,
    required String title,
    required String message,
  }) async => showConfirmation(
    context: context,
    title: title,
    message: message,
    confirmText: context.translate('delete'),
    cancelText: context.translate('cancel'),
    confirmColor: AppTheme.danger,
    icon: Icons.delete_outline,
    iconColor: AppTheme.danger,
  );

  /// Show an info dialog
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    IconData? icon,
    Color? iconColor,
  }) async => showDialog<void>(
    context: context,
    builder:
        (context) => _InfoDialog(
          title: title,
          message: message,
          buttonText: buttonText ?? context.translate('ok'),
          icon: icon,
          iconColor: iconColor,
        ),
  );

  /// Show an error dialog
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
  }) async => showInfo(
    context: context,
    title: title,
    message: message,
    buttonText: buttonText ?? context.translate('ok'),
    icon: Icons.error_outline,
    iconColor: AppTheme.danger,
  );

  /// Show a success dialog
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
  }) async => showInfo(
    context: context,
    title: title,
    message: message,
    buttonText: buttonText ?? context.translate('ok'),
    icon: Icons.check_circle_outline,
    iconColor: AppTheme.success,
  );

  /// Show a selection dialog with list of items
  static Future<T?> showSelection<T>({
    required BuildContext context,
    required String title,
    required List<SelectionItem<T>> items,
    String? subtitle,
    IconData? headerIcon,
    T? selectedValue,
  }) async => showDialog<T>(
    context: context,
    builder:
        (context) => _SelectionDialog<T>(
          title: title,
          subtitle: subtitle,
          headerIcon: headerIcon,
          items: items,
          selectedValue: selectedValue,
        ),
  );
}

/// Model for selection items
class SelectionItem<T> {
  const SelectionItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });

  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
}

class _ConfirmationDialog extends StatelessWidget {
  const _ConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    this.confirmColor,
    this.icon,
    this.iconColor,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).themeData;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppTheme.blue500).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor ?? AppTheme.blue500,
                ),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              title,
              style: context.textTheme.titleXl.copyWith(
                color: AppTheme.slate800,
                fontWeight: AppTheme.fontWeightSemibold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: context.textTheme.bodySm.copyWith(
                color: AppTheme.slate600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: confirmColor ?? theme.primaryColor,
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoDialog extends StatelessWidget {
  const _InfoDialog({
    required this.title,
    required this.message,
    required this.buttonText,
    this.icon,
    this.iconColor,
  });

  final String title;
  final String message;
  final String buttonText;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.info).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: iconColor ?? AppTheme.info),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            title,
            style: context.textTheme.titleXl.copyWith(
              color: AppTheme.slate800,
              fontWeight: AppTheme.fontWeightSemibold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: context.textTheme.bodySm.copyWith(color: AppTheme.slate600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: CustomElevatedButton(
              text: buttonText,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    ),
  );
}

class _SelectionDialog<T> extends StatelessWidget {
  const _SelectionDialog({
    required this.title,
    required this.items,
    this.subtitle,
    this.headerIcon,
    this.selectedValue,
  });

  final String title;
  final String? subtitle;
  final IconData? headerIcon;
  final List<SelectionItem<T>> items;
  final T? selectedValue;

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Container(
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: CustomAppColors.slate50,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                if (headerIcon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.blue500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(headerIcon, color: AppTheme.blue500, size: 24),
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
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Items List
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item.value == selectedValue;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context, item.value),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppTheme.blue500.withValues(alpha: 0.08)
                                  : CustomAppColors.slate50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppTheme.blue500
                                    : CustomAppColors.slate200,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (item.icon != null) ...[
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? AppTheme.blue500
                                          : CustomAppColors.slate200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  item.icon,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : AppTheme.slate600,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.label,
                                    style: TextStyle(
                                      fontSize: AppTheme.fontSizeBase,
                                      fontWeight: AppTheme.fontWeightSemibold,
                                      color:
                                          isSelected
                                              ? AppTheme.blue500
                                              : AppTheme.slate800,
                                    ),
                                  ),
                                  if (item.subtitle != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      item.subtitle!,
                                      style: TextStyle(
                                        fontSize: AppTheme.fontSizeXs,
                                        color:
                                            isSelected
                                                ? AppTheme.blue500.withValues(
                                                  alpha: 0.8,
                                                )
                                                : AppTheme.slate600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppTheme.blue500,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
