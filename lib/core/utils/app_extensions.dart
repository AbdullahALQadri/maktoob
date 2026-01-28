import 'package:flutter/material.dart';

import 'app_text_styles.dart';

/// BuildContext extensions for easy access to theme and utilities.
///
/// Example usage:
/// ```dart
/// // Access theme colors
/// context.primaryColor
/// context.backgroundColor
///
/// // Access text styles
/// context.headlineLarge
/// context.bodyMedium
///
/// // Show snackbar/dialog
/// context.showSnackBar('Message')
/// context.showAppDialog(...)
/// ```
extension BuildContextExtensions on BuildContext {
  // ===========================================================================
  // THEME ACCESS
  // ===========================================================================

  /// Get current theme
  ThemeData get theme => Theme.of(this);

  /// Get color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;

  /// Check if dark mode is enabled
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // ===========================================================================
  // COLORS
  // ===========================================================================

  /// Primary color
  Color get primaryColor => colorScheme.primary;

  /// On primary color
  Color get onPrimaryColor => colorScheme.onPrimary;

  /// Secondary color
  Color get secondaryColor => colorScheme.secondary;

  /// Background color
  Color get backgroundColor => colorScheme.surface;

  /// Surface color
  Color get surfaceColor => colorScheme.surface;

  /// Error color
  Color get errorColor => colorScheme.error;

  /// Scaffold background color
  Color get scaffoldColor => theme.scaffoldBackgroundColor;

  // ===========================================================================
  // TEXT STYLES (from AppTextStyles)
  // ===========================================================================

  /// Headline extra large
  TextStyle get headlineXLarge => AppTextStyles.headlineXLarge;

  /// Headline large
  TextStyle get headlineLarge => AppTextStyles.headlineLarge;

  /// Headline medium
  TextStyle get headlineMedium => AppTextStyles.headlineMedium;

  /// Headline small
  TextStyle get headlineSmall => AppTextStyles.headlineSmall;

  /// Title large
  TextStyle get titleLarge => AppTextStyles.titleLarge;

  /// Title medium
  TextStyle get titleMedium => AppTextStyles.titleMedium;

  /// Title small
  TextStyle get titleSmall => AppTextStyles.titleSmall;

  /// Body large
  TextStyle get bodyLarge => AppTextStyles.bodyLarge;

  /// Body medium
  TextStyle get bodyMedium => AppTextStyles.bodyMedium;

  /// Body small
  TextStyle get bodySmall => AppTextStyles.bodySmall;

  /// Label large
  TextStyle get labelLarge => AppTextStyles.labelLarge;

  /// Label medium
  TextStyle get labelMedium => AppTextStyles.labelMedium;

  /// Label small
  TextStyle get labelSmall => AppTextStyles.labelSmall;

  /// Caption style
  TextStyle get caption => AppTextStyles.caption;

  // ===========================================================================
  // MEDIA QUERY
  // ===========================================================================

  /// Screen padding (safe area)
  EdgeInsets get screenPadding => MediaQuery.paddingOf(this);

  /// View insets (keyboard height, etc.)
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  /// Is keyboard visible
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  /// Device pixel ratio
  double get devicePixelRatio => MediaQuery.devicePixelRatioOf(this);

  /// Orientation
  Orientation get orientation => MediaQuery.orientationOf(this);

  /// Is landscape
  bool get isLandscape => orientation == Orientation.landscape;

  /// Is portrait
  bool get isPortrait => orientation == Orientation.portrait;

  // ===========================================================================
  // RESPONSIVE BREAKPOINTS
  // ===========================================================================

  /// Is mobile (width < 600)
  bool get isMobile => MediaQuery.sizeOf(this).width < 600;

  /// Is tablet (600 <= width < 1200)
  bool get isTablet {
    final w = MediaQuery.sizeOf(this).width;
    return w >= 600 && w < 1200;
  }

  /// Is desktop (width >= 1200)
  bool get isDesktop => MediaQuery.sizeOf(this).width >= 1200;

  /// Get responsive value based on screen size
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  // ===========================================================================
  // NAVIGATION
  // ===========================================================================

  /// Navigator state
  NavigatorState get navigator => Navigator.of(this);

  /// Pop current route
  void pop<T>([T? result]) => navigator.pop(result);

  /// Push named route
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) =>
      navigator.pushNamed<T>(routeName, arguments: arguments);

  /// Push replacement named route
  Future<T?> pushReplacementNamed<T>(String routeName, {Object? arguments}) =>
      navigator.pushReplacementNamed<T, dynamic>(routeName, arguments: arguments);

  /// Push and remove until
  Future<T?> pushNamedAndRemoveUntil<T>(
    String routeName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) =>
      navigator.pushNamedAndRemoveUntil<T>(routeName, predicate, arguments: arguments);

  /// Can pop
  bool get canPop => navigator.canPop();

  // ===========================================================================
  // FOCUS
  // ===========================================================================

  /// Unfocus (dismiss keyboard)
  void unfocus() => FocusScope.of(this).unfocus();

  /// Request focus on a node
  void requestFocus(FocusNode node) => FocusScope.of(this).requestFocus(node);

  // ===========================================================================
  // SCAFFOLD MESSENGER
  // ===========================================================================

  /// Show snackbar
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    return ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Hide current snackbar
  void hideSnackBar() => ScaffoldMessenger.of(this).hideCurrentSnackBar();

  /// Clear all snackbars
  void clearSnackBars() => ScaffoldMessenger.of(this).clearSnackBars();
}

/// String extensions for common operations.
extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize each word
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Check if string is email
  bool get isEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this);
  }

  /// Check if string is phone number
  bool get isPhoneNumber {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(replaceAll(' ', '').replaceAll('-', ''));
  }

  /// Check if string is URL
  bool get isUrl {
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    return urlRegex.hasMatch(this);
  }

  /// Get initials from name
  String get initials {
    if (isEmpty) return '';
    final words = trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }

  /// Truncate string with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

/// Widget extensions for padding and margin.
extension WidgetExtensions on Widget {
  /// Add padding to all sides
  Widget paddingAll(double value) => Padding(
        padding: EdgeInsets.all(value),
        child: this,
      );

  /// Add horizontal padding
  Widget paddingHorizontal(double value) => Padding(
        padding: EdgeInsets.symmetric(horizontal: value),
        child: this,
      );

  /// Add vertical padding
  Widget paddingVertical(double value) => Padding(
        padding: EdgeInsets.symmetric(vertical: value),
        child: this,
      );

  /// Add custom padding
  Widget padding(EdgeInsetsGeometry padding) => Padding(
        padding: padding,
        child: this,
      );

  /// Add symmetric padding
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) => Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        child: this,
      );

  /// Add only specific sides padding
  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      Padding(
        padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
        child: this,
      );

  /// Center the widget
  Widget centered() => Center(child: this);

  /// Expand the widget
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);

  /// Make widget flexible
  Widget flexible({int flex = 1}) => Flexible(flex: flex, child: this);

  /// Add tap gesture
  Widget onTap(VoidCallback? onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: this,
      );

  /// Add opacity
  Widget opacity(double opacity) => Opacity(opacity: opacity, child: this);

  /// Clip with border radius
  Widget clipRounded(double radius) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: this,
      );

  /// Add safe area
  Widget safeArea({
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
  }) =>
      SafeArea(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: this,
      );

  /// Make scrollable
  Widget scrollable({
    ScrollController? controller,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
  }) =>
      SingleChildScrollView(
        controller: controller,
        physics: physics,
        padding: padding,
        child: this,
      );

  /// Add hero animation
  Widget hero(Object tag) => Hero(tag: tag, child: this);

  /// Add tooltip
  Widget withTooltip(String message) => Tooltip(message: message, child: this);

  /// Conditional visibility
  Widget visible(bool isVisible) => Visibility(visible: isVisible, child: this);

  /// Show or replace with sized box
  Widget showIf(bool condition) => condition ? this : const SizedBox.shrink();
}

/// List extensions.
extension ListExtensions<T> on List<T> {
  /// Get element at index or null if out of bounds
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Separate list items with a widget (like ListView.separated)
  List<Widget> separatedBy(Widget separator) {
    if (isEmpty) return [];
    if (this is! List<Widget>) return [];

    final widgets = this as List<Widget>;
    final result = <Widget>[];

    for (var i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i < widgets.length - 1) {
        result.add(separator);
      }
    }

    return result;
  }
}

/// DateTime extensions.
extension DateTimeExtensions on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Format as relative time (e.g., "2 hours ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${difference.inDays > 730 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${difference.inDays > 60 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

/// Color extensions.
extension ColorExtensions on Color {
  /// Darken the color by a percentage (0.0 - 1.0)
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  /// Lighten the color by a percentage (0.0 - 1.0)
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }
}
