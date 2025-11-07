import 'package:flutter/material.dart';

import '../../utils/responsive_utils.dart';

/// A modular builder that adapts to screen size, orientation, and platform
/// This makes it easy to write responsive code without hassle
class AdaptiveBuilder extends StatelessWidget {
  const AdaptiveBuilder({required this.builder, super.key});

  /// Builder function that provides responsive context
  final Widget Function(BuildContext context, AdaptiveInfo info) builder;

  @override
  Widget build(BuildContext context) => OrientationBuilder(
    builder: (context, orientation) {
      final info = AdaptiveInfo(
        deviceType: context.deviceType,
        orientation: orientation,
        screenWidth: MediaQuery.of(context).size.width,
        screenHeight: MediaQuery.of(context).size.height,
        isLandscape: context.isLandscape,
        isPortrait: context.isPortrait,
        isMobile: context.isMobile,
        isTablet: context.isTablet,
        isDesktop: context.isDesktop,
        gridColumns: ResponsiveUtils.getGridColumnsWithOrientation(context),
        padding: ResponsiveUtils.responsivePaddingWithOrientation(context),
      );

      return builder(context, info);
    },
  );
}

/// Information about the current adaptive state
class AdaptiveInfo {
  const AdaptiveInfo({
    required this.deviceType,
    required this.orientation,
    required this.screenWidth,
    required this.screenHeight,
    required this.isLandscape,
    required this.isPortrait,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.gridColumns,
    required this.padding,
  });

  final DeviceType deviceType;
  final Orientation orientation;
  final double screenWidth;
  final double screenHeight;
  final bool isLandscape;
  final bool isPortrait;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final int gridColumns;
  final EdgeInsets padding;

  /// Helper to check if mobile in portrait
  bool get isMobilePortrait => isMobile && isPortrait;

  /// Helper to check if mobile in landscape
  bool get isMobileLandscape => isMobile && isLandscape;

  /// Helper to check if tablet in portrait
  bool get isTabletPortrait => isTablet && isPortrait;

  /// Helper to check if tablet in landscape
  bool get isTabletLandscape => isTablet && isLandscape;

  /// Get a value based on current state
  /// Note: Mobile devices ignore orientation and always return mobilePortrait value
  T when<T>({
    required T mobilePortrait,
    T? mobileLandscape,
    T? tabletPortrait,
    T? tabletLandscape,
    T? desktop,
  }) {
    if (isMobile) {
      // Mobile devices: same value for both portrait and landscape
      return mobilePortrait;
    } else if (isTablet) {
      return isLandscape
          ? (tabletLandscape ?? tabletPortrait ?? mobilePortrait)
          : (tabletPortrait ?? mobilePortrait);
    } else {
      return desktop ?? tabletLandscape ?? tabletPortrait ?? mobilePortrait;
    }
  }

  /// Get aspect ratio for current screen
  double get aspectRatio => screenWidth / screenHeight;

  /// Check if screen is wide (landscape with good aspect ratio)
  bool get isWideScreen => isLandscape && aspectRatio > 1.5;
}

/// A widget that provides different layouts based on screen size and orientation
class ResponsiveOrientationLayout extends StatelessWidget {
  const ResponsiveOrientationLayout({
    required this.mobilePortrait,
    super.key,
    this.mobileLandscape,
    this.tabletPortrait,
    this.tabletLandscape,
    this.desktop,
  });

  final Widget mobilePortrait;
  final Widget? mobileLandscape;
  final Widget? tabletPortrait;
  final Widget? tabletLandscape;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) => AdaptiveBuilder(
    builder:
        (context, info) => info.when(
          mobilePortrait: mobilePortrait,
          mobileLandscape: mobileLandscape,
          tabletPortrait: tabletPortrait,
          tabletLandscape: tabletLandscape,
          desktop: desktop,
        ),
  );
}

/// A flexible widget that arranges children in a row or column based on screen
class AdaptiveFlexLayout extends StatelessWidget {
  const AdaptiveFlexLayout({
    required this.children,
    super.key,
    this.mobileLayout = AdaptiveLayoutType.column,
    this.tabletLayout = AdaptiveLayoutType.row,
    this.desktopLayout = AdaptiveLayoutType.row,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing = 16.0,
  });

  final List<Widget> children;
  final AdaptiveLayoutType mobileLayout;
  final AdaptiveLayoutType tabletLayout;
  final AdaptiveLayoutType desktopLayout;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double spacing;

  @override
  Widget build(BuildContext context) => AdaptiveBuilder(
    builder: (context, info) {
      final layoutType =
          info.isMobile
              ? mobileLayout
              : info.isTablet
              ? tabletLayout
              : desktopLayout;

      final spacedChildren = <Widget>[];
      for (var i = 0; i < children.length; i++) {
        spacedChildren.add(children[i]);
        if (i < children.length - 1) {
          spacedChildren.add(
            SizedBox(
              width: layoutType == AdaptiveLayoutType.row ? spacing : 0,
              height: layoutType == AdaptiveLayoutType.column ? spacing : 0,
            ),
          );
        }
      }

      if (layoutType == AdaptiveLayoutType.row) {
        return Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: mainAxisSize,
          children: spacedChildren,
        );
      } else {
        return Column(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: mainAxisSize,
          children: spacedChildren,
        );
      }
    },
  );
}

/// Enum for layout types
enum AdaptiveLayoutType { row, column }

/// A grid that adapts columns based on screen size and orientation
class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    required this.children,
    super.key,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.childAspectRatio = 1.0,
    this.shrinkWrap = false,
    this.physics,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double childAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) => AdaptiveBuilder(
    builder:
        (context, info) => GridView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: info.gridColumns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        ),
  );
}

/// A scrollable list that adapts its layout
class AdaptiveListView extends StatelessWidget {
  const AdaptiveListView({
    required this.children,
    super.key,
    this.spacing = 16.0,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  final List<Widget> children;
  final double spacing;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) => AdaptiveBuilder(
    builder:
        (context, info) => ListView.separated(
          shrinkWrap: shrinkWrap,
          physics: physics,
          padding: padding ?? info.padding,
          itemCount: children.length,
          separatorBuilder: (context, index) => SizedBox(height: spacing),
          itemBuilder: (context, index) => children[index],
        ),
  );
}

/// A container with adaptive padding and max width
class AdaptiveContainer extends StatelessWidget {
  const AdaptiveContainer({
    required this.child,
    super.key,
    this.usePadding = true,
    this.useMaxWidth = true,
    this.maxWidth,
    this.customPadding,
    this.color,
    this.decoration,
  });

  final Widget child;
  final bool usePadding;
  final bool useMaxWidth;
  final double? maxWidth;
  final EdgeInsetsGeometry? customPadding;
  final Color? color;
  final Decoration? decoration;

  @override
  Widget build(BuildContext context) => AdaptiveBuilder(
    builder: (context, info) {
      var content = child;

      // Apply padding
      if (usePadding) {
        content = Padding(
          padding: customPadding ?? info.padding,
          child: content,
        );
      }

      // Apply max width constraint for desktop
      if (useMaxWidth && info.isDesktop) {
        content = Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth ?? context.maxContentWidth,
            ),
            child: content,
          ),
        );
      }

      // Apply decoration
      if (color != null || decoration != null) {
        content = Container(
          color: color,
          decoration: decoration,
          child: content,
        );
      }

      return content;
    },
  );
}
