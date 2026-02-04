import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../utils/extensions.dart';
import '../../../../widgets/custom_widgets/custom_bottom_modal_sheet.dart';
import '../providers/teacher_classes_provider.dart';

/// Filter widget for class list
class ClassFilterWidget {
  static void show(BuildContext context, TeacherClassesProvider provider) {
    CustomBottomSheet.showCustomModalBottomSheet(
      context: context,
      config: const BottomSheetConfig(canDismiss: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.translate('filter_classes'),
            style: context.textTheme.titleXl.copyWith(
              color: AppTheme.slate800,
              fontWeight: AppTheme.fontWeightSemibold,
            ),
          ),
          const SizedBox(height: 24),

          // Subject Filter
          DropdownButtonFormField<String>(
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
          DropdownButtonFormField<String>(
            initialValue: provider.selectedSectionFilter,
            decoration: InputDecoration(
              labelText: context.translate('section'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.class_outlined),
            ),
            items: [
              DropdownMenuItem(
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
              title: const Text('Show only my class teacher assignments'),
              subtitle: const Text('Classes where you are the class teacher'),
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
                  onPressed: () {
                    provider.clearFilters();
                    Navigator.pop(context);
                  },
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
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
      ),
    );
  }
}
