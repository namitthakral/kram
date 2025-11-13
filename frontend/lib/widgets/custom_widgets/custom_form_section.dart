import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../utils/extensions.dart';

/// Custom form section card widget to group related form fields
class CustomFormSection extends StatelessWidget {
  const CustomFormSection({
    required this.title,
    required this.children,
    super.key,
    this.subtitle,
    this.icon,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget> children;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.blue500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppTheme.blue500),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleBase.copyWith(
                      color: AppTheme.slate800,
                      fontWeight: AppTheme.fontWeightSemibold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: context.textTheme.bodySm.copyWith(
                        color: AppTheme.slate500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 1, color: AppTheme.slate100),
        Padding(
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    ),
  );
}
