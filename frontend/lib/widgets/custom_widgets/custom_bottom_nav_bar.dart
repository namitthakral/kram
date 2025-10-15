import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/navigation_item_model.dart';
import '../../provider/bottom_nav_provider.dart';
import '../../provider/theme_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/images/base_image.dart';
import '../../utils/images/image_asset.dart';
import '../../utils/localization/app_localizations.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!.translate;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.themeData;

    // Bottom navigation bar - only for mobile
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 0.5, thickness: 0.5, color: theme.dividerTheme.color),
        Consumer<BottomNavProvider>(
          builder: (context, navProvider, child) => NavigationBar(
            labelPadding: EdgeInsets.zero,
            selectedIndex: navProvider.currentIndex,
            onDestinationSelected: (index) => navProvider.setIndex(index),
            height: 60,
            destinations: _buildNavigationDestinations(translate),
          ),
        ),
      ],
    );
  }

  List<NavigationDestination> _buildNavigationDestinations(
    String Function(String, {Map<String, dynamic>? params}) translate,
  ) =>
      NavigationItems.items
          .map(
            (item) => NavigationDestination(
              icon: _buildIcon(item.iconUrl),
              selectedIcon: _buildIcon(item.iconFilledUrl, isSelected: true),
              label: translate(item.labelKey),
            ),
          )
          .toList();

  // Helper method to build icon widgets
  Widget _buildIcon(String iconUrl, {bool isSelected = false}) => BaseImage(
        asset: LocalAsset(url: iconUrl),
        height: 25,
        width: 25,
        fit: BoxFit.contain,
        color: isSelected ? CustomAppColors.primary : null,
      );
}
