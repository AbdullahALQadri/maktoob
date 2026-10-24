import 'package:flutter/widgets.dart';

/// Material 3 window size classes. Layouts switch on these, never on raw
/// pixels: a phone (compact) gets the bottom bar, a tablet (medium) the rail,
/// a laptop or desktop window (expanded / large) the portal's sidebar.
enum WindowSize {
  compact,
  medium,
  expanded,
  large;

  static WindowSize ofWidth(double width) {
    if (width < 600) return WindowSize.compact;
    if (width < 840) return WindowSize.medium;
    if (width < 1200) return WindowSize.expanded;
    return WindowSize.large;
  }

  bool get isCompact => this == WindowSize.compact;
  bool get atLeastMedium => index >= WindowSize.medium.index;
  bool get atLeastExpanded => index >= WindowSize.expanded.index;

  /// Side padding of page content.
  double get gutter => switch (this) {
    WindowSize.compact => 16,
    WindowSize.medium => 24,
    _ => 32,
  };

  /// The widest page content may grow before it is centred, so lines stay
  /// readable on tablets and desktops.
  double get maxContentWidth => switch (this) {
    WindowSize.compact => double.infinity,
    WindowSize.medium => 760,
    WindowSize.expanded => 1040,
    WindowSize.large => 1200,
  };
}

extension WindowSizeContext on BuildContext {
  WindowSize get windowSize => WindowSize.ofWidth(MediaQuery.sizeOf(this).width);

  /// Horizontal padding that keeps page content inside the readable width
  /// while the scroll area itself stays full width.
  double get pageGutter {
    final size = windowSize;
    final spare = (MediaQuery.sizeOf(this).width - size.maxContentWidth) / 2;
    return spare > size.gutter ? spare : size.gutter;
  }
}
