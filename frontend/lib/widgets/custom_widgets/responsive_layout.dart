import 'package:flutter/material.dart';

import '../../utils/responsive_utils.dart';

/// A responsive layout builder that provides different layouts for different screen sizes
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.mobile,
    super.key,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final deviceType = ResponsiveUtils.getDeviceType(context);

      switch (deviceType) {
        case DeviceType.mobile:
          return mobile;
        case DeviceType.tablet:
          return tablet ?? mobile;
        case DeviceType.desktop:
          return desktop ?? tablet ?? mobile;
        case DeviceType.largeDesktop:
          return largeDesktop ?? desktop ?? tablet ?? mobile;
      }
    },
  );
}

/// A widget that centers content with a max width for larger screens
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    required this.child,
    super.key,
    this.maxWidth,
    this.padding,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? context.maxContentWidth;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        padding: padding ?? context.responsivePadding,
        child: child,
      ),
    );
  }
}

/// A widget that provides responsive padding
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    required this.child,
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget child;
  final EdgeInsetsGeometry? mobile;
  final EdgeInsetsGeometry? tablet;
  final EdgeInsetsGeometry? desktop;

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry padding;

    if (context.isMobile) {
      padding = mobile ?? const EdgeInsets.all(16.0);
    } else if (context.isTablet) {
      padding = tablet ?? const EdgeInsets.all(24.0);
    } else {
      padding = desktop ?? const EdgeInsets.all(32.0);
    }

    return Padding(padding: padding, child: child);
  }
}

/// A responsive grid that adjusts columns based on screen size
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    required this.children,
    super.key,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    int columns;

    if (context.isMobile) {
      columns = mobileColumns;
    } else if (context.isTablet) {
      columns = tabletColumns;
    } else {
      columns = desktopColumns;
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// A widget that provides different layouts for portrait and landscape orientations
class OrientationLayout extends StatelessWidget {
  const OrientationLayout({required this.portrait, super.key, this.landscape});

  final Widget portrait;
  final Widget? landscape;

  @override
  Widget build(BuildContext context) => OrientationBuilder(
    builder: (context, orientation) {
      if (orientation == Orientation.landscape && landscape != null) {
        return landscape!;
      }
      return portrait;
    },
  );
}

/// A responsive row/column that switches based on screen size
class ResponsiveRowColumn extends StatelessWidget {
  const ResponsiveRowColumn({
    required this.children,
    super.key,
    this.breakpoint = 600,
    this.rowMainAxisAlignment = MainAxisAlignment.start,
    this.rowCrossAxisAlignment = CrossAxisAlignment.start,
    this.columnMainAxisAlignment = MainAxisAlignment.start,
    this.columnCrossAxisAlignment = CrossAxisAlignment.start,
  });

  final List<Widget> children;
  final double breakpoint;
  final MainAxisAlignment rowMainAxisAlignment;
  final CrossAxisAlignment rowCrossAxisAlignment;
  final MainAxisAlignment columnMainAxisAlignment;
  final CrossAxisAlignment columnCrossAxisAlignment;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < breakpoint) {
        return Column(
          mainAxisAlignment: columnMainAxisAlignment,
          crossAxisAlignment: columnCrossAxisAlignment,
          children: children,
        );
      } else {
        return Row(
          mainAxisAlignment: rowMainAxisAlignment,
          crossAxisAlignment: rowCrossAxisAlignment,
          children: children,
        );
      }
    },
  );
}
