/// Application Constants
/// Contains timezone, currency, and other app-wide configuration
class AppConstants {
  // ============================================================
  // TIMEZONE
  // ============================================================
  static const String timezone = 'Asia/Gaza';
  static const String timezoneOffset = '+02:00'; // Gaza timezone offset

  // ============================================================
  // CURRENCY - Israeli New Shekel (ILS)
  // ============================================================
  static const String currencyCode = 'ILS';
  static const String currencySymbol = '\u20AA'; // Unicode for ₪
  static const String currencyName = 'Israeli New Shekel';
  static const int currencyDecimalPlaces = 2;

  /// Format amount with currency symbol
  static String formatCurrency(double amount) {
    return '$currencySymbol${amount.toStringAsFixed(currencyDecimalPlaces)}';
  }

  /// Format amount with currency code (for display)
  static String formatCurrencyWithCode(double amount) {
    return '${amount.toStringAsFixed(currencyDecimalPlaces)} $currencyCode';
  }

  /// Parse currency string to double
  static double parseCurrency(String value) {
    // Remove currency symbol and whitespace
    final cleaned = value.replaceAll(currencySymbol, '').replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  // ============================================================
  // LOCALES
  // ============================================================
  static const String defaultLocale = 'ar';
  static const List<String> supportedLocales = ['ar', 'en'];

  // ============================================================
  // API CONFIGURATION
  // ============================================================
  static const int apiTimeout = 30000; // 30 seconds
  static const int uploadTimeout = 60000; // 60 seconds

  // ============================================================
  // PAGINATION
  // ============================================================
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ============================================================
  // USER TYPES
  // ============================================================
  static const String userTypeClient = 'client';
  static const String userTypeScanner = 'scanner';
  static const String userTypeGuest = 'guest';
  static const String userTypeAdmin = 'admin';

  // ============================================================
  // TOKEN NAMES
  // ============================================================
  static const String clientTokenName = 'mobile-app';
  static const String scannerTokenName = 'scanner-app';
  static const String guestTokenName = 'guest-app';
  static const String adminTokenName = 'admin-app';
}
