import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../provider/bottom_nav_provider.dart';
import '../../provider/theme_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/extensions.dart';
import '../../utils/images/base_image.dart';
import '../../utils/images/image_asset.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.themeData;
    final currentRoute = GoRouterState.of(context).uri.path;

    // Bottom navigation bar - only for mobile
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 0.5, thickness: 0.5, color: theme.dividerTheme.color),
        Consumer<BottomNavProvider>(
          builder: (context, navProvider, child) {
            // Check if navigation is initialized
            if (navProvider.navigationItems.isEmpty) {
              return const SizedBox.shrink();
            }

            // Get current index based on route
            final selectedIndex = navProvider.getCurrentIndex(currentRoute);

            return NavigationBar(
              labelPadding: EdgeInsets.zero,
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                navProvider.navigateToIndex(context, index);
              },
              height: 60,
              destinations:
                  navProvider.navigationItems
                      .map(
                        (item) => NavigationDestination(
                          icon: _buildIcon(item.iconUrl),
                          selectedIcon: _buildIcon(
                            item.iconFilledUrl,
                            isSelected: true,
                          ),
                          label: context.translate(item.labelKey),
                        ),
                      )
                      .toList(),
            );
          },
        ),
      ],
    );
  }

  // Helper method to build icon widgets
  Widget _buildIcon(String iconUrl, {bool isSelected = false}) => BaseImage(
    asset: LocalAsset(url: iconUrl),
    height: 25,
    width: 25,
    fit: BoxFit.contain,
    color: isSelected ? CustomAppColors.primary : null,
  );
}
