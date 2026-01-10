import 'package:flutter/material.dart';

/// Device type enumeration for responsive design
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Orientation type for responsive design
enum DeviceOrientation {
  portrait,
  landscape,
}

/// Screen size breakpoints
class Breakpoints {
  static const double mobileSmall = 320;
  static const double mobileMedium = 375;
  static const double mobileLarge = 425;
  static const double tablet = 768;
  static const double laptop = 1024;
  static const double desktop = 1440;
}

/// Responsive utility class for handling different screen sizes
class Responsive {
  final BuildContext context;
  late final Size _screenSize;
  late final double _width;
  late final double _height;
  late final DeviceType _deviceType;
  late final DeviceOrientation _orientation;
  late final double _scaleFactor;
  late final EdgeInsets _padding;
  late final double _pixelRatio;

  Responsive(this.context) {
    final mediaQuery = MediaQuery.of(context);
    _screenSize = mediaQuery.size;
    _width = _screenSize.width;
    _height = _screenSize.height;
    _padding = mediaQuery.padding;
    _pixelRatio = mediaQuery.devicePixelRatio;
    _deviceType = _getDeviceType();
    _orientation = _getOrientation();
    _scaleFactor = _getScaleFactor();
  }

  /// Get the screen width
  double get width => _width;

  /// Get the screen height
  double get height => _height;

  /// Get the device type
  DeviceType get deviceType => _deviceType;

  /// Get the device orientation
  DeviceOrientation get orientation => _orientation;

  /// Get the scale factor for responsive sizing
  double get scaleFactor => _scaleFactor;

  /// Get safe area padding
  EdgeInsets get padding => _padding;

  /// Get pixel ratio
  double get pixelRatio => _pixelRatio;

  /// Check if device is mobile
  bool get isMobile => _deviceType == DeviceType.mobile;

  /// Check if device is tablet
  bool get isTablet => _deviceType == DeviceType.tablet;

  /// Check if device is desktop
  bool get isDesktop => _deviceType == DeviceType.desktop;

  /// Check if orientation is portrait
  bool get isPortrait => _orientation == DeviceOrientation.portrait;

  /// Check if orientation is landscape
  bool get isLandscape => _orientation == DeviceOrientation.landscape;

  /// Determine device type based on screen width
  DeviceType _getDeviceType() {
    if (_width < Breakpoints.tablet) {
      return DeviceType.mobile;
    } else if (_width < Breakpoints.laptop) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Determine orientation
  DeviceOrientation _getOrientation() {
    return _width > _height
        ? DeviceOrientation.landscape
        : DeviceOrientation.portrait;
  }

  /// Calculate scale factor based on design width (375 - iPhone X width)
  double _getScaleFactor() {
    const double designWidth = 375.0;
    double scale = _width / designWidth;

    // Clamp scale factor for tablets and desktops
    if (_deviceType == DeviceType.tablet) {
      scale = scale.clamp(1.0, 1.3);
    } else if (_deviceType == DeviceType.desktop) {
      scale = scale.clamp(1.0, 1.5);
    }

    return scale;
  }

  /// Scale a value based on screen size
  double scale(double value) => value * _scaleFactor;

  /// Get width as percentage of screen width
  double wp(double percentage) => _width * (percentage / 100);

  /// Get height as percentage of screen height
  double hp(double percentage) => _height * (percentage / 100);

  /// Get responsive font size
  double sp(double fontSize) {
    double scaledSize = fontSize * _scaleFactor;

    // Ensure minimum and maximum font sizes
    if (scaledSize < fontSize * 0.8) scaledSize = fontSize * 0.8;
    if (scaledSize > fontSize * 1.4) scaledSize = fontSize * 1.4;

    return scaledSize;
  }

  /// Get responsive horizontal padding
  double get horizontalPadding {
    switch (_deviceType) {
      case DeviceType.mobile:
        return 16.0;
      case DeviceType.tablet:
        return 24.0;
      case DeviceType.desktop:
        return 32.0;
    }
  }

  /// Get responsive vertical padding
  double get verticalPadding {
    switch (_deviceType) {
      case DeviceType.mobile:
        return 16.0;
      case DeviceType.tablet:
        return 20.0;
      case DeviceType.desktop:
        return 24.0;
    }
  }

  /// Get responsive border radius
  double get borderRadius {
    switch (_deviceType) {
      case DeviceType.mobile:
        return 12.0;
      case DeviceType.tablet:
        return 16.0;
      case DeviceType.desktop:
        return 20.0;
    }
  }

  /// Get number of grid columns
  int get gridColumns {
    switch (_deviceType) {
      case DeviceType.mobile:
        return isLandscape ? 3 : 2;
      case DeviceType.tablet:
        return isLandscape ? 4 : 3;
      case DeviceType.desktop:
        return isLandscape ? 5 : 4;
    }
  }

  /// Get responsive icon size
  double iconSize({double base = 24}) {
    switch (_deviceType) {
      case DeviceType.mobile:
        return base;
      case DeviceType.tablet:
        return base * 1.2;
      case DeviceType.desktop:
        return base * 1.4;
    }
  }

  /// Get responsive button height
  double get buttonHeight {
    switch (_deviceType) {
      case DeviceType.mobile:
        return 48.0;
      case DeviceType.tablet:
        return 56.0;
      case DeviceType.desktop:
        return 64.0;
    }
  }

  /// Get responsive card elevation
  double get cardElevation {
    switch (_deviceType) {
      case DeviceType.mobile:
        return 2.0;
      case DeviceType.tablet:
        return 4.0;
      case DeviceType.desktop:
        return 6.0;
    }
  }

  /// Get responsive spacing
  double spacing({double base = 8}) {
    return base * _scaleFactor;
  }

  /// Get value based on device type
  T value<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (_deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// Get value based on orientation
  T orientationValue<T>({
    required T portrait,
    required T landscape,
  }) {
    return isPortrait ? portrait : landscape;
  }
}

/// Responsive builder widget for building different layouts based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Responsive responsive) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(context, Responsive(context));
      },
    );
  }
}

/// Responsive layout widget for different screen sizes
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, responsive) {
        switch (responsive.deviceType) {
          case DeviceType.mobile:
            return mobile;
          case DeviceType.tablet:
            return tablet ?? mobile;
          case DeviceType.desktop:
            return desktop ?? tablet ?? mobile;
        }
      },
    );
  }
}

/// Responsive orientation layout widget
class OrientationLayout extends StatelessWidget {
  final Widget portrait;
  final Widget? landscape;

  const OrientationLayout({
    super.key,
    required this.portrait,
    this.landscape,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape && landscape != null) {
          return landscape!;
        }
        return portrait;
      },
    );
  }
}

/// Responsive grid view
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.childAspectRatio = 1.0,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, responsive) {
        return GridView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics,
          padding: padding ?? EdgeInsets.all(responsive.horizontalPadding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: responsive.gridColumns,
            mainAxisSpacing: mainAxisSpacing ?? responsive.spacing(),
            crossAxisSpacing: crossAxisSpacing ?? responsive.spacing(),
            childAspectRatio: childAspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

/// Responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, responsive) {
        EdgeInsets padding;
        switch (responsive.deviceType) {
          case DeviceType.mobile:
            padding = mobilePadding ?? EdgeInsets.all(responsive.horizontalPadding);
            break;
          case DeviceType.tablet:
            padding = tabletPadding ?? mobilePadding ?? EdgeInsets.all(responsive.horizontalPadding);
            break;
          case DeviceType.desktop:
            padding = desktopPadding ?? tabletPadding ?? mobilePadding ?? EdgeInsets.all(responsive.horizontalPadding);
            break;
        }
        return Padding(padding: padding, child: child);
      },
    );
  }
}

/// Responsive sized box
class ResponsiveSizedBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;

  const ResponsiveSizedBox({
    super.key,
    this.width,
    this.height,
    this.child,
  });

  /// Creates a vertical spacing box
  const ResponsiveSizedBox.vertical(double size, {super.key})
      : width = null,
        height = size,
        child = null;

  /// Creates a horizontal spacing box
  const ResponsiveSizedBox.horizontal(double size, {super.key})
      : width = size,
        height = null,
        child = null;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, responsive) {
        return SizedBox(
          width: width != null ? responsive.scale(width!) : null,
          height: height != null ? responsive.scale(height!) : null,
          child: child,
        );
      },
    );
  }
}

/// Responsive container with max width constraint
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final BoxDecoration? decoration;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.alignment = Alignment.center,
    this.padding,
    this.color,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, responsive) {
        double effectiveMaxWidth = maxWidth ?? _getMaxWidth(responsive);

        return Align(
          alignment: alignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
            child: Container(
              width: double.infinity,
              padding: padding,
              color: decoration == null ? color : null,
              decoration: decoration,
              child: child,
            ),
          ),
        );
      },
    );
  }

  double _getMaxWidth(Responsive responsive) {
    switch (responsive.deviceType) {
      case DeviceType.mobile:
        return double.infinity;
      case DeviceType.tablet:
        return 720;
      case DeviceType.desktop:
        return 1200;
    }
  }
}
