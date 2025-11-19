import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A reusable, generic horizontal tab bar widget with Material design
///
/// Features:
/// - Horizontal scrollable tabs
/// - Icon + Label support
/// - Material design with elevation
/// - Customizable colors and styling
/// - Generic type support for any enum or value type
///
/// Example usage:
/// ```dart
/// CustomTabBar<MyTab>(
///   tabs: [
///     TabItem(value: MyTab.home, label: 'Home', icon: Icons.home),
///     TabItem(value: MyTab.settings, label: 'Settings', icon: Icons.settings),
///   ],
///   selectedValue: _selectedTab,
///   onTabSelected: (value) => setState(() => _selectedTab = value),
/// )
/// ```
class CustomTabBar<T> extends StatelessWidget {
  const CustomTabBar({
    required this.tabs,
    required this.selectedValue,
    required this.onTabSelected,
    super.key,
    this.backgroundColor = Colors.white,
    this.selectedTabColor,
    this.unselectedTabColor,
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor,
    this.selectedIconColor = Colors.white,
    this.unselectedIconColor,
    this.height = 40.0,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
    this.tabPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.tabSpacing = 10.0,
    this.borderRadius = 20.0,
    this.selectedElevation = 2.0,
    this.unselectedElevation = 0.0,
    this.iconSize = 18.0,
    this.fontSize = 13.0,
    this.selectedFontWeight = FontWeight.w600,
    this.unselectedFontWeight = FontWeight.w500,
    this.showIcons = true,
    this.iconTextSpacing = 6.0,
    this.scrollPadding = const EdgeInsets.symmetric(horizontal: 16),
  });

  /// List of tabs to display
  final List<TabItem<T>> tabs;

  /// Currently selected value
  final T selectedValue;

  /// Callback when a tab is selected
  final ValueChanged<T> onTabSelected;

  /// Background color of the entire tab bar container
  final Color backgroundColor;

  /// Background color of selected tab (defaults to AppTheme.blue500)
  final Color? selectedTabColor;

  /// Background color of unselected tabs (defaults to AppTheme.slate100)
  final Color? unselectedTabColor;

  /// Text color for selected tab
  final Color selectedTextColor;

  /// Text color for unselected tabs (defaults to AppTheme.slate800)
  final Color? unselectedTextColor;

  /// Icon color for selected tab
  final Color selectedIconColor;

  /// Icon color for unselected tabs (defaults to AppTheme.slate600)
  final Color? unselectedIconColor;

  /// Height of the tab bar
  final double height;

  /// Padding around the entire tab bar
  final EdgeInsets padding;

  /// Padding inside each tab
  final EdgeInsets tabPadding;

  /// Spacing between tabs
  final double tabSpacing;

  /// Border radius for tabs
  final double borderRadius;

  /// Elevation for selected tab
  final double selectedElevation;

  /// Elevation for unselected tabs
  final double unselectedElevation;

  /// Size of icons
  final double iconSize;

  /// Font size of text
  final double fontSize;

  /// Font weight for selected tab text
  final FontWeight selectedFontWeight;

  /// Font weight for unselected tab text
  final FontWeight unselectedFontWeight;

  /// Whether to show icons
  final bool showIcons;

  /// Spacing between icon and text
  final double iconTextSpacing;

  /// Padding for the scrollable area
  final EdgeInsets scrollPadding;

  @override
  Widget build(BuildContext context) {
    final selectedBgColor = selectedTabColor ?? AppTheme.blue500;
    final unselectedBgColor = unselectedTabColor ?? AppTheme.slate100;
    final unselectedTxtColor = unselectedTextColor ?? AppTheme.slate800;
    final unselectedIcnColor = unselectedIconColor ?? AppTheme.slate600;

    return Container(
      color: backgroundColor,
      padding: padding,
      child: SizedBox(
        height: height,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: scrollPadding,
          itemCount: tabs.length,
          itemBuilder: (context, index) {
            final tab = tabs[index];
            final isSelected = selectedValue == tab.value;

            return Padding(
              padding: EdgeInsets.only(right: tabSpacing),
              child: Material(
                color: isSelected ? selectedBgColor : unselectedBgColor,
                borderRadius: BorderRadius.circular(borderRadius),
                elevation: isSelected ? selectedElevation : unselectedElevation,
                child: InkWell(
                  onTap: () => onTabSelected(tab.value),
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Container(
                    padding: tabPadding,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showIcons && tab.icon != null) ...[
                          Icon(
                            tab.icon,
                            size: iconSize,
                            color:
                                isSelected
                                    ? selectedIconColor
                                    : unselectedIcnColor,
                          ),
                          SizedBox(width: iconTextSpacing),
                        ],
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight:
                                isSelected
                                    ? selectedFontWeight
                                    : unselectedFontWeight,
                            color:
                                isSelected ? selectedTextColor : unselectedTxtColor,
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
    );
  }
}

/// Represents a single tab item in the CustomTabBar
class TabItem<T> {
  const TabItem({
    required this.value,
    required this.label,
    this.icon,
  });

  /// The value associated with this tab
  final T value;

  /// The label text to display
  final String label;

  /// Optional icon to display before the label
  final IconData? icon;
}
