import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Extension methods on BuildContext for easy access to common properties.
///
/// Example usage:
/// ```dart
/// // Access theme
/// final primaryColor = context.primaryColor;
///
/// // Access media query
/// final screenWidth = context.screenWidth;
/// final isTablet = context.isTablet;
///
/// // Show snackbar
/// context.showSuccessSnackBar('Item saved successfully');
/// ```
extension ContextExtensions on BuildContext {
  // ===== Theme Extensions =====

  /// Returns the current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Returns the current [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Returns the current [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Returns the primary color from the theme.
  Color get primaryColor => Theme.of(this).primaryColor;

  /// Returns whether the current theme is dark mode.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // ===== Media Query Extensions =====

  /// Returns the current [MediaQueryData].
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Returns the screen size.
  Size get screenSize => MediaQuery.of(this).size;

  /// Returns the screen width.
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Returns the screen height.
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Returns the device pixel ratio.
  double get devicePixelRatio => MediaQuery.of(this).devicePixelRatio;

  /// Returns the top padding (status bar height).
  double get topPadding => MediaQuery.of(this).padding.top;

  /// Returns the bottom padding (home indicator height).
  double get bottomPadding => MediaQuery.of(this).padding.bottom;

  /// Returns the view insets (keyboard height when visible).
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  /// Returns the keyboard height.
  double get keyboardHeight => MediaQuery.of(this).viewInsets.bottom;

  /// Returns whether the keyboard is visible.
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  /// Returns the orientation of the device.
  Orientation get orientation => MediaQuery.of(this).orientation;

  /// Returns whether the device is in landscape mode.
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  /// Returns whether the device is in portrait mode.
  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;

  // ===== Device Type Extensions =====

  /// Returns whether the device is a phone (width < 600).
  bool get isPhone => screenWidth < 600;

  /// Returns whether the device is a tablet (width >= 600 && width < 900).
  bool get isTablet => screenWidth >= 600 && screenWidth < 900;

  /// Returns whether the device is a desktop (width >= 900).
  bool get isDesktop => screenWidth >= 900;

  /// Returns the device type.
  DeviceType get deviceType {
    if (screenWidth < 600) return DeviceType.phone;
    if (screenWidth < 900) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  // ===== Navigation Extensions =====

  /// Pushes a new route onto the navigator.
  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// Pushes a named route onto the navigator.
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }

  /// Replaces the current route with a new route.
  Future<T?> pushReplacement<T, TO>(Widget page) {
    return Navigator.of(this).pushReplacement<T, TO>(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// Replaces the current route with a named route.
  Future<T?> pushReplacementNamed<T, TO>(String routeName,
      {Object? arguments}) {
    return Navigator.of(this)
        .pushReplacementNamed<T, TO>(routeName, arguments: arguments);
  }

  /// Pops the current route off the navigator.
  void pop<T>([T? result]) => Navigator.of(this).pop<T>(result);

  /// Pops routes until the predicate returns true.
  void popUntil(bool Function(Route<dynamic>) predicate) {
    Navigator.of(this).popUntil(predicate);
  }

  /// Pops all routes and pushes a new named route.
  Future<T?> pushNamedAndRemoveUntil<T>(
    String newRouteName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return Navigator.of(this).pushNamedAndRemoveUntil<T>(
      newRouteName,
      predicate,
      arguments: arguments,
    );
  }

  /// Returns whether the navigator can pop.
  bool canPop() => Navigator.of(this).canPop();

  // ===== Snackbar Extensions =====

  /// Shows a snackbar with the given message.
  void showSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color? backgroundColor,
    Color? textColor,
  }) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor ?? AppColors.white),
        ),
        duration: duration,
        backgroundColor: backgroundColor ?? AppColors.gray900,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Shows a success snackbar.
  void showSuccessSnackBar(String message) {
    showSnackBar(
      message: message,
      backgroundColor: AppColors.green600,
    );
  }

  /// Shows an error snackbar.
  void showErrorSnackBar(String message) {
    showSnackBar(
      message: message,
      backgroundColor: AppColors.red500,
    );
  }

  /// Shows a warning snackbar.
  void showWarningSnackBar(String message) {
    showSnackBar(
      message: message,
      backgroundColor: AppColors.amber600,
      textColor: AppColors.black,
    );
  }

  /// Shows an info snackbar.
  void showInfoSnackBar(String message) {
    showSnackBar(
      message: message,
      backgroundColor: AppColors.blue600,
    );
  }

  // ===== Focus Extensions =====

  /// Unfocuses the current focus scope.
  void unfocus() {
    FocusScope.of(this).unfocus();
  }

  /// Requests focus on the given focus node.
  void requestFocus(FocusNode node) {
    FocusScope.of(this).requestFocus(node);
  }
}

/// Extension methods on String.
extension StringExtensions on String {
  /// Returns whether the string is a valid email.
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Returns whether the string is a valid phone number.
  bool get isValidPhone {
    return RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(this);
  }

  /// Returns whether the string is a valid URL.
  bool get isValidUrl {
    return Uri.tryParse(this)?.hasAbsolutePath ?? false;
  }

  /// Capitalizes the first letter of the string.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes the first letter of each word.
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Truncates the string to the given length.
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Removes all whitespace from the string.
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Returns the initials of the string (e.g., "John Doe" -> "JD").
  String get initials {
    if (isEmpty) return '';
    final words = trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }
}

/// Extension methods on DateTime.
extension DateTimeExtensions on DateTime {
  /// Returns whether this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns whether this date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Returns whether this date is tomorrow.
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Returns whether this date is in the past.
  bool get isPast => isBefore(DateTime.now());

  /// Returns whether this date is in the future.
  bool get isFuture => isAfter(DateTime.now());

  /// Returns the start of the day (midnight).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns the end of the day (23:59:59.999).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Formats the date as "MMM d, yyyy" (e.g., "Jan 15, 2024").
  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[month - 1]} $day, $year';
  }

  /// Formats the time as "h:mm a" (e.g., "2:30 PM").
  String get formattedTime {
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  /// Returns a relative time string (e.g., "2 hours ago", "in 3 days").
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.isNegative) {
      return _formatFuture(difference.abs());
    }
    return _formatPast(difference);
  }

  String _formatPast(Duration difference) {
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    }
    if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    }
    return 'Just now';
  }

  String _formatFuture(Duration difference) {
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'in $years ${years == 1 ? 'year' : 'years'}';
    }
    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'in $months ${months == 1 ? 'month' : 'months'}';
    }
    if (difference.inDays > 0) {
      return 'in ${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'}';
    }
    if (difference.inHours > 0) {
      return 'in ${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'}';
    }
    if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'}';
    }
    return 'Just now';
  }
}

/// Extension methods on num (int and double).
extension NumExtensions on num {
  /// Returns a SizedBox with this value as width.
  SizedBox get horizontalSpace => SizedBox(width: toDouble());

  /// Returns a SizedBox with this value as height.
  SizedBox get verticalSpace => SizedBox(height: toDouble());

  /// Returns EdgeInsets with all sides equal to this value.
  EdgeInsets get allPadding => EdgeInsets.all(toDouble());

  /// Returns EdgeInsets with horizontal padding equal to this value.
  EdgeInsets get horizontalPadding =>
      EdgeInsets.symmetric(horizontal: toDouble());

  /// Returns EdgeInsets with vertical padding equal to this value.
  EdgeInsets get verticalPadding => EdgeInsets.symmetric(vertical: toDouble());

  /// Returns a BorderRadius with all corners equal to this value.
  BorderRadius get borderRadius => BorderRadius.circular(toDouble());

  /// Formats the number as currency.
  String toCurrency({String symbol = '\$', int decimals = 2}) {
    return '$symbol${toStringAsFixed(decimals)}';
  }

  /// Formats the number as percentage.
  String toPercentage({int decimals = 0}) {
    return '${(this * 100).toStringAsFixed(decimals)}%';
  }
}

/// Extension methods on List.
extension ListExtensions<T> on List<T> {
  /// Returns the first element that satisfies the predicate, or null if none.
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  /// Returns the last element that satisfies the predicate, or null if none.
  T? lastWhereOrNull(bool Function(T) test) {
    for (var i = length - 1; i >= 0; i--) {
      if (test(this[i])) return this[i];
    }
    return null;
  }

  /// Returns the element at index, or null if out of bounds.
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}

/// Device type enum for responsive design.
enum DeviceType {
  phone,
  tablet,
  desktop,
}
