import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../utils/extensions.dart';
import '../../../../utils/responsive_utils.dart';
import '../../../../widgets/custom_widgets/custom_bottom_modal_sheet.dart';
import '../providers/teacher_classes_provider.dart';

/// Filter widget for class list.
/// Uses dialog on web/tablet (blocks AI button and nav) and bottom sheet on mobile.
class ClassFilterWidget {
  static void show(BuildContext context, TeacherClassesProvider provider) {
    if (ResponsiveUtils.isMobile(context)) {
      _showBottomSheet(context, provider);
    } else {
      _showDialog(context, provider);
    }
  }

  /// Dialog for web/tablet — full-screen barrier blocks AI button and nav.
  static void _showDialog(
    BuildContext context,
    TeacherClassesProvider provider,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.translate('filter_classes')),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: _FilterContent(
              provider: provider,
              showTitle: false,
              onClear: () {
                provider.clearFilters();
                Navigator.of(dialogContext).pop();
              },
              onApply: () => Navigator.of(dialogContext).pop(),
            ),
          ),
        ),
      ),
    );
  }

  /// Bottom sheet for mobile.
  static void _showBottomSheet(
    BuildContext context,
    TeacherClassesProvider provider,
  ) {
    CustomBottomSheet.showCustomModalBottomSheet(
      context: context,
      config: const BottomSheetConfig(canDismiss: true),
      child: _FilterContent(
        provider: provider,
        showTitle: true,
        onClear: () {
          provider.clearFilters();
          Navigator.pop(context);
        },
        onApply: () => Navigator.pop(context),
      ),
    );
  }
}

class _FilterContent extends StatelessWidget {
  const _FilterContent({
    required this.provider,
    required this.showTitle,
    required this.onClear,
    required this.onApply,
  });

  final TeacherClassesProvider provider;
  final bool showTitle;
  final VoidCallback onClear;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showTitle) ...[
          Text(
            context.translate('filter_classes'),
            style: context.textTheme.titleXl.copyWith(
              color: AppTheme.slate800,
              fontWeight: AppTheme.fontWeightSemibold,
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Subject Filter
        DropdownButtonFormField<String?>(
          initialValue: provider.selectedSubjectFilter,
          decoration: InputDecoration(
            labelText: context.translate('subject'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.book_outlined),
          ),
          items: [
            DropdownMenuItem(
              child: Text(context.translate('all_subjects')),
            ),
            ...provider.availableSubjects.map(
              (subject) =>
                  DropdownMenuItem(value: subject, child: Text(subject)),
            ),
          ],
            onChanged: provider.setSubjectFilter,
          ),
        const SizedBox(height: 16),

        // Section Filter
        DropdownButtonFormField<String?>(
          initialValue: provider.selectedSectionFilter,
          decoration: InputDecoration(
            labelText: context.translate('section'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.class_outlined),
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(context.translate('all_sections')),
            ),
            ...provider.availableSections.map(
              (section) =>
                  DropdownMenuItem(value: section, child: Text(section)),
            ),
          ],
          onChanged: provider.setSectionFilter,
        ),
        const SizedBox(height: 16),

        // Class Teacher Filter
        if (provider.hasClassTeacherAssignments)
          SwitchListTile(
            title: Text(context.translate('filter_show_only_class_teacher')),
            subtitle: Text(context.translate('filter_class_teacher_subtitle')),
            value: provider.showOnlyClassTeacher,
            onChanged: provider.setShowOnlyClassTeacher,
            secondary: const Icon(Icons.star_outline),
          ),

        const SizedBox(height: 24),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onClear,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(context.translate('clear')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(context.translate('apply')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
