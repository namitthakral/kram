import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/theme_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/extensions.dart';

class CustomChip extends StatelessWidget {
  const CustomChip({
    required this.label,
    required this.onChipSelected,
    super.key,
    this.isSelected = false,
    this.type,
  });
  final dynamic label;
  final void Function()? onChipSelected;
  final bool isSelected;
  final String? type;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).themeData;

    return GestureDetector(
      onTap: onChipSelected,
      child: Card(
        elevation: 0,
        color:
            type == 'rating'
                ? theme.colorScheme.onPrimary
                : isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color:
                isSelected ? theme.colorScheme.primary : CustomAppColors.grey04,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
          child:
              label is Widget
                  ? label
                  : Text(
                    label,
                    style: context.textTheme.labelXs.copyWith(
                      color:
                          isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                    ),
                  ),
        ),
      ),
    );

    // ChoiceChip(
    //   label: Text(
    //     'label',
    //     style: context.textTheme.pm12.copyWith(color: Colors.white),
    //   ),
    //   selected: false,
    //   color: WidgetStateProperty.resolveWith((state)=> state.contains(WidgetState.selected) ? theme.:,
    //   ),
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
    // );
  }
}
