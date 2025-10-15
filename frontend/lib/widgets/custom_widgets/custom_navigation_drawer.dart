import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/navigation_item_model.dart';
import '../../provider/bottom_nav_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/custom_images.dart';
import '../../utils/images/base_image.dart';
import '../../utils/images/image_asset.dart';
import '../../utils/localization/app_localizations.dart';

class CustomNavigationDrawer extends StatelessWidget {
  const CustomNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!.translate;
    final theme = Theme.of(context);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(right: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          // User Header Section
          _buildUserHeader(context, theme, translate),

          const Divider(height: 1),

          // Navigation Items
          Expanded(
            child: Consumer<BottomNavProvider>(
              builder:
                  (context, navProvider, child) => ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children:
                        NavigationItems.items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final isSelected = navProvider.currentIndex == index;

                          return _buildNavigationItem(
                            context,
                            theme,
                            item: item,
                            isSelected: isSelected,
                            onTap: () => navProvider.setIndex(index),
                            translate: translate,
                          );
                        }).toList(),
                  ),
            ),
          ),

          // Footer Section (optional - settings, logout, etc.)
          _buildFooter(context, theme, translate),
        ],
      ),
    );
  }

  Widget _buildUserHeader(
    BuildContext context,
    ThemeData theme,
    String Function(String, {Map<String, dynamic>? params}) translate,
  ) => Container(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        // User Avatar
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CustomAppColors.primary.withValues(alpha: 0.1),
            border: Border.all(color: CustomAppColors.primary, width: 2),
          ),
          child: const Center(
            child: Icon(Icons.person, size: 40, color: CustomAppColors.primary),
          ),
        ),

        const SizedBox(height: 16),

        // User Name
        Text(
          'Deepak Jha',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 4),

        // User Email or Role
        Text(
          'deepak@edverse.com',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _buildNavigationItem(
    BuildContext context,
    ThemeData theme, {
    required NavigationItemModel item,
    required bool isSelected,
    required VoidCallback onTap,
    required String Function(String, {Map<String, dynamic>? params}) translate,
  }) {
    const selectedColor = CustomAppColors.primary;
    final backgroundColor =
        isSelected ? selectedColor.withValues(alpha: 0.1) : Colors.transparent;
    final textColor =
        isSelected ? selectedColor : theme.textTheme.bodyLarge?.color;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: BaseImage(
          asset: LocalAsset(
            url: isSelected ? item.iconFilledUrl : item.iconUrl,
          ),
          height: 24,
          width: 24,
          fit: BoxFit.contain,
          color: isSelected ? selectedColor : null,
        ),
        title: Text(
          translate(item.labelKey),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: textColor,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    ThemeData theme,
    String Function(String, {Map<String, dynamic>? params}) translate,
  ) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: theme.dividerColor)),
    ),
    child: Column(
      children: [
        // Settings Button
        ListTile(
          leading: BaseImage(
            asset: LocalAsset(url: CustomImages.iconSetting4),
            height: 24,
            width: 24,
            fit: BoxFit.contain,
          ),
          title: Text(translate('settings'), style: theme.textTheme.bodyMedium),
          onTap: () {
            // Navigate to settings
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    ),
  );
}
