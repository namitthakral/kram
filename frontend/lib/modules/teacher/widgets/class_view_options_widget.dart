import 'package:flutter/material.dart';

import '../../../../utils/custom_colors.dart';

/// Widget for toggling between grid and list view modes
class ClassViewOptionsWidget extends StatelessWidget {
  const ClassViewOptionsWidget({
    required this.isGridView,
    required this.onViewModeChanged,
    this.sortOption = ClassSortOption.name,
    this.onSortChanged,
    super.key,
  });

  final bool isGridView;
  final ValueChanged<bool> onViewModeChanged;
  final ClassSortOption sortOption;
  final ValueChanged<ClassSortOption>? onSortChanged;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Sort Dropdown
      if (onSortChanged != null)
        PopupMenuButton<ClassSortOption>(
          initialValue: sortOption,
          onSelected: onSortChanged,
          icon: const Icon(Icons.sort, size: 20),
          tooltip: 'Sort by',
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: ClassSortOption.name,
                  child: Row(
                    children: [
                      Icon(Icons.sort_by_alpha, size: 18),
                      SizedBox(width: 8),
                      Text('Name'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ClassSortOption.subject,
                  child: Row(
                    children: [
                      Icon(Icons.book_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Subject'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ClassSortOption.studentCount,
                  child: Row(
                    children: [
                      Icon(Icons.people_outline, size: 18),
                      SizedBox(width: 8),
                      Text('Student Count'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ClassSortOption.classTeacher,
                  child: Row(
                    children: [
                      Icon(Icons.star_outline, size: 18),
                      SizedBox(width: 8),
                      Text('Class Teacher First'),
                    ],
                  ),
                ),
              ],
        ),
      const SizedBox(width: 8),
      // View Mode Toggle
      DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildViewButton(
              icon: Icons.view_list,
              isSelected: !isGridView,
              onTap: () => onViewModeChanged(false),
            ),
            _buildViewButton(
              icon: Icons.grid_view,
              isSelected: isGridView,
              onTap: () => onViewModeChanged(true),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildViewButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? CustomAppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        icon,
        size: 20,
        color: isSelected ? Colors.white : Colors.grey.shade600,
      ),
    ),
  );
}

enum ClassSortOption { name, subject, studentCount, classTeacher }
