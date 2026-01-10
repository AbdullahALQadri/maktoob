import 'package:flutter/material.dart';
import 'responsive.dart';

/// Extension on BuildContext for easy access to responsive utilities
extension ResponsiveContext on BuildContext {
  /// Get Responsive instance
  Responsive get responsive => Responsive(this);

  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Get device pixel ratio
  double get devicePixelRatio => MediaQuery.of(this).devicePixelRatio;

  /// Get safe area padding
  EdgeInsets get safePadding => MediaQuery.of(this).padding;

  /// Get view insets (keyboard, etc.)
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  /// Check if device is mobile
  bool get isMobile => screenWidth < Breakpoints.tablet;

  /// Check if device is tablet
  bool get isTablet =>
      screenWidth >= Breakpoints.tablet && screenWidth < Breakpoints.laptop;

  /// Check if device is desktop
  bool get isDesktop => screenWidth >= Breakpoints.laptop;

  /// Check if orientation is portrait
  bool get isPortrait => screenHeight > screenWidth;

  /// Check if orientation is landscape
  bool get isLandscape => screenWidth > screenHeight;

  /// Get device type
  DeviceType get deviceType {
    if (isMobile) return DeviceType.mobile;
    if (isTablet) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// Get width percentage
  double wp(double percentage) => screenWidth * (percentage / 100);

  /// Get height percentage
  double hp(double percentage) => screenHeight * (percentage / 100);
}

/// Extension on num for responsive sizing
extension ResponsiveNum on num {
  /// Scale value based on screen width (design width: 375)
  double w(BuildContext context) {
    const double designWidth = 375.0;
    return (this * context.screenWidth / designWidth).toDouble();
  }

  /// Scale value based on screen height (design height: 812)
  double h(BuildContext context) {
    const double designHeight = 812.0;
    return (this * context.screenHeight / designHeight).toDouble();
  }

  /// Get responsive font size
  double sp(BuildContext context) {
    final responsive = context.responsive;
    return responsive.sp(toDouble());
  }

  /// Get responsive spacing
  double r(BuildContext context) {
    final responsive = context.responsive;
    return responsive.scale(toDouble());
  }
}

/// Extension on Widget for responsive wrapping
extension ResponsiveWidget on Widget {
  /// Wrap widget with responsive padding
  Widget withResponsivePadding(BuildContext context) {
    final responsive = Responsive(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.horizontalPadding,
        vertical: responsive.verticalPadding,
      ),
      child: this,
    );
  }

  /// Wrap widget with responsive horizontal padding
  Widget withResponsiveHorizontalPadding(BuildContext context) {
    final responsive = Responsive(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
      child: this,
    );
  }

  /// Wrap widget with responsive vertical padding
  Widget withResponsiveVerticalPadding(BuildContext context) {
    final responsive = Responsive(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: responsive.verticalPadding),
      child: this,
    );
  }

  /// Constrain widget to max width for tablets/desktop
  Widget constrainedWidth({double? maxWidth}) {
    return ResponsiveBuilder(
      builder: (context, responsive) {
        if (responsive.isMobile) return this;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth ?? (responsive.isTablet ? 720 : 1200),
            ),
            child: this,
          ),
        );
      },
    );
  }

  /// Show widget only on mobile
  Widget mobileOnly() {
    return ResponsiveBuilder(
      builder: (context, responsive) {
        if (responsive.isMobile) return this;
        return const SizedBox.shrink();
      },
    );
  }

  /// Show widget only on tablet
  Widget tabletOnly() {
    return ResponsiveBuilder(
      builder: (context, responsive) {
        if (responsive.isTablet) return this;
        return const SizedBox.shrink();
      },
    );
  }

  /// Show widget only on desktop
  Widget desktopOnly() {
    return ResponsiveBuilder(
      builder: (context, responsive) {
        if (responsive.isDesktop) return this;
        return const SizedBox.shrink();
      },
    );
  }

  /// Show widget on tablet and desktop
  Widget tabletAndAbove() {
    return ResponsiveBuilder(
      builder: (context, responsive) {
        if (!responsive.isMobile) return this;
        return const SizedBox.shrink();
      },
    );
  }

  /// Show widget on mobile and tablet
  Widget mobileAndTablet() {
    return ResponsiveBuilder(
      builder: (context, responsive) {
        if (!responsive.isDesktop) return this;
        return const SizedBox.shrink();
      },
    );
  }
}

/// Extension on TextStyle for responsive font sizing
extension ResponsiveTextStyle on TextStyle {
  /// Get responsive text style
  TextStyle responsive(BuildContext context) {
    final responsive = Responsive(context);
    return copyWith(
      fontSize: fontSize != null ? responsive.sp(fontSize!) : null,
    );
  }
}

/// Extension on EdgeInsets for responsive padding
extension ResponsiveEdgeInsets on EdgeInsets {
  /// Scale all values responsively
  EdgeInsets responsive(BuildContext context) {
    final r = Responsive(context);
    return EdgeInsets.only(
      left: r.scale(left),
      top: r.scale(top),
      right: r.scale(right),
      bottom: r.scale(bottom),
    );
  }
}

/// Extension on BorderRadius for responsive border radius
extension ResponsiveBorderRadius on BorderRadius {
  /// Scale all values responsively
  BorderRadius responsive(BuildContext context) {
    final r = Responsive(context);
    return BorderRadius.only(
      topLeft: Radius.circular(r.scale(topLeft.x)),
      topRight: Radius.circular(r.scale(topRight.x)),
      bottomLeft: Radius.circular(r.scale(bottomLeft.x)),
      bottomRight: Radius.circular(r.scale(bottomRight.x)),
    );
  }
}
