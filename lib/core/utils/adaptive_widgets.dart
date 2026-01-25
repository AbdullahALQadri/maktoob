import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'media_query_values.dart';

/// A utility class that provides platform-adaptive UI components.
///
/// This class automatically detects the platform and shows the appropriate
/// UI components:
/// - Android: Material Design components
/// - iOS: Cupertino (Apple) components
class AdaptiveWidgets {
  AdaptiveWidgets._();

  /// Check if the current platform is iOS
  static bool get isIOS => Platform.isIOS;

  /// Check if the current platform is Android
  static bool get isAndroid => Platform.isAndroid;

  // ==================== ALERT DIALOGS ====================

  /// Shows a platform-adaptive alert dialog.
  ///
  /// On Android: Shows a Material AlertDialog
  /// On iOS: Shows a CupertinoAlertDialog
  ///
  /// Returns the result of the dialog (usually the action taken)
  static Future<T?> showAdaptiveAlertDialog<T>({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
    Color? confirmColor,
    Color? cancelColor,
    bool isDestructiveAction = false,
  }) async {
    confirmText ??= 'OK';
    cancelText ??= 'Cancel';

    if (isIOS) {
      return showCupertinoDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(content),
          ),
          actions: [
            if (cancelText != null)
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  onCancel?.call();
                },
                child: Text(cancelText),
              ),
            CupertinoDialogAction(
              isDestructiveAction: isDestructiveAction,
              onPressed: () {
                Navigator.of(context).pop(true);
                onConfirm?.call();
              },
              child: Text(confirmText!),
            ),
          ],
        ),
      );
    } else {
      return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(content),
          actions: [
            if (cancelText != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  onCancel?.call();
                },
                child: Text(
                  cancelText,
                  style: TextStyle(
                    color: cancelColor ?? AppColors.gray600,
                  ),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                onConfirm?.call();
              },
              child: Text(
                confirmText!,
                style: TextStyle(
                  color: isDestructiveAction
                      ? AppColors.red500
                      : (confirmColor ?? AppColors.primaryColor),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  /// Shows a platform-adaptive confirmation dialog.
  ///
  /// Returns true if confirmed, false if cancelled, null if dismissed
  static Future<bool?> showAdaptiveConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructiveAction = false,
  }) async {
    return showAdaptiveAlertDialog<bool>(
      context: context,
      title: title,
      content: content,
      confirmText: confirmText,
      cancelText: cancelText,
      isDestructiveAction: isDestructiveAction,
    );
  }

  /// Shows a platform-adaptive info dialog with only an OK button.
  static Future<void> showAdaptiveInfoDialog({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = 'OK',
  }) async {
    if (isIOS) {
      await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(content),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(buttonText),
            ),
          ],
        ),
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                buttonText,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  /// Shows a platform-adaptive error dialog.
  static Future<void> showAdaptiveErrorDialog({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = 'OK',
  }) async {
    if (isIOS) {
      await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.exclamationmark_circle,
                color: CupertinoColors.destructiveRed,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(content),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(buttonText),
            ),
          ],
        ),
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.red500,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                buttonText,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  /// Shows a platform-adaptive success dialog.
  static Future<void> showAdaptiveSuccessDialog({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = 'OK',
  }) async {
    if (isIOS) {
      await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.checkmark_circle,
                color: CupertinoColors.activeGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(content),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(buttonText),
            ),
          ],
        ),
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: AppColors.green600,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                buttonText,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  // ==================== DATE PICKER ====================

  /// Shows a platform-adaptive date picker.
  ///
  /// On Android: Shows a Material DatePicker dialog
  /// On iOS: Shows a CupertinoDatePicker in a modal bottom sheet
  ///
  /// Returns the selected DateTime or null if cancelled
  static Future<DateTime?> showAdaptiveDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helpText,
    String? cancelText,
    String? confirmText,
    Locale? locale,
  }) async {
    firstDate ??= DateTime(1900);
    lastDate ??= DateTime(2100);

    // Ensure initialDate is within bounds
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }
    if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }

    if (isIOS) {
      return _showCupertinoDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        cancelText: cancelText,
        confirmText: confirmText,
      );
    } else {
      return showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        helpText: helpText,
        cancelText: cancelText,
        confirmText: confirmText,
        locale: locale,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primaryColor,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: AppColors.gray900,
              ),
              datePickerTheme: DatePickerThemeData(
                backgroundColor: Colors.white,
                headerBackgroundColor: AppColors.primaryColor,
                headerForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  textStyle: TextStyle(
                    fontSize: context.dynamicWidth(0.04),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: child!,
            ),
          );
        },
      );
    }
  }

  static Future<DateTime?> _showCupertinoDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    String? cancelText,
    String? confirmText,
  }) async {
    DateTime selectedDate = initialDate;

    final result = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (context) => Container(
        height: context.dynamicHeight(0.35),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(context.dynamicWidth(0.05)),
            topRight: Radius.circular(context.dynamicWidth(0.05)),
          ),
        ),
        child: Column(
          children: [
            // Header with Cancel and Done buttons
            Container(
              padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(context.dynamicWidth(0.05)),
                  topRight: Radius.circular(context.dynamicWidth(0.05)),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(null),
                    child: Text(
                      cancelText ?? 'Cancel',
                      style: TextStyle(
                        color: CupertinoColors.destructiveRed,
                        fontSize: context.dynamicWidth(0.04),
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(selectedDate),
                    child: Text(
                      confirmText ?? 'Done',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: context.dynamicWidth(0.04),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Date Picker
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initialDate,
                minimumDate: firstDate,
                maximumDate: lastDate,
                onDateTimeChanged: (DateTime date) {
                  selectedDate = date;
                },
              ),
            ),
          ],
        ),
      ),
    );

    return result;
  }

  // ==================== TIME PICKER ====================

  /// Shows a platform-adaptive time picker.
  ///
  /// On Android: Shows a Material TimePicker dialog
  /// On iOS: Shows a CupertinoTimerPicker in a modal bottom sheet
  ///
  /// Returns the selected TimeOfDay or null if cancelled
  static Future<TimeOfDay?> showAdaptiveTimePicker({
    required BuildContext context,
    required TimeOfDay initialTime,
    String? helpText,
    String? cancelText,
    String? confirmText,
    bool use24HourFormat = false,
  }) async {
    if (isIOS) {
      return _showCupertinoTimePicker(
        context: context,
        initialTime: initialTime,
        cancelText: cancelText,
        confirmText: confirmText,
        use24HourFormat: use24HourFormat,
      );
    } else {
      return showTimePicker(
        context: context,
        initialTime: initialTime,
        helpText: helpText,
        cancelText: cancelText,
        confirmText: confirmText,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primaryColor,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: AppColors.gray900,
              ),
              timePickerTheme: TimePickerThemeData(
                backgroundColor: Colors.white,
                hourMinuteShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
                ),
                dayPeriodShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  textStyle: TextStyle(
                    fontSize: context.dynamicWidth(0.04),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: use24HourFormat,
                textScaler: const TextScaler.linear(1.0),
              ),
              child: child!,
            ),
          );
        },
      );
    }
  }

  static Future<TimeOfDay?> _showCupertinoTimePicker({
    required BuildContext context,
    required TimeOfDay initialTime,
    String? cancelText,
    String? confirmText,
    bool use24HourFormat = false,
  }) async {
    DateTime selectedDateTime = DateTime(
      2000,
      1,
      1,
      initialTime.hour,
      initialTime.minute,
    );

    final result = await showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (context) => Container(
        height: context.dynamicHeight(0.35),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(context.dynamicWidth(0.05)),
            topRight: Radius.circular(context.dynamicWidth(0.05)),
          ),
        ),
        child: Column(
          children: [
            // Header with Cancel and Done buttons
            Container(
              padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(context.dynamicWidth(0.05)),
                  topRight: Radius.circular(context.dynamicWidth(0.05)),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(null),
                    child: Text(
                      cancelText ?? 'Cancel',
                      style: TextStyle(
                        color: CupertinoColors.destructiveRed,
                        fontSize: context.dynamicWidth(0.04),
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(
                      TimeOfDay(
                        hour: selectedDateTime.hour,
                        minute: selectedDateTime.minute,
                      ),
                    ),
                    child: Text(
                      confirmText ?? 'Done',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: context.dynamicWidth(0.04),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Time Picker
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: selectedDateTime,
                use24hFormat: use24HourFormat,
                onDateTimeChanged: (DateTime dateTime) {
                  selectedDateTime = dateTime;
                },
              ),
            ),
          ],
        ),
      ),
    );

    return result;
  }

  // ==================== DATE AND TIME PICKER ====================

  /// Shows a platform-adaptive date and time picker.
  ///
  /// On Android: Shows Material DatePicker followed by TimePicker
  /// On iOS: Shows a CupertinoDatePicker with dateAndTime mode
  ///
  /// Returns the selected DateTime or null if cancelled
  static Future<DateTime?> showAdaptiveDateTimePicker({
    required BuildContext context,
    required DateTime initialDateTime,
    DateTime? firstDate,
    DateTime? lastDate,
    String? cancelText,
    String? confirmText,
    bool use24HourFormat = false,
  }) async {
    firstDate ??= DateTime(1900);
    lastDate ??= DateTime(2100);

    // Ensure initialDateTime is within bounds
    if (initialDateTime.isBefore(firstDate)) {
      initialDateTime = firstDate;
    }
    if (initialDateTime.isAfter(lastDate)) {
      initialDateTime = lastDate;
    }

    if (isIOS) {
      return _showCupertinoDateTimePicker(
        context: context,
        initialDateTime: initialDateTime,
        firstDate: firstDate,
        lastDate: lastDate,
        cancelText: cancelText,
        confirmText: confirmText,
        use24HourFormat: use24HourFormat,
      );
    } else {
      // Show date picker first
      final date = await showAdaptiveDatePicker(
        context: context,
        initialDate: initialDateTime,
        firstDate: firstDate,
        lastDate: lastDate,
        cancelText: cancelText,
        confirmText: confirmText,
      );

      if (date == null) return null;

      // Check if context is still valid after async gap
      if (!context.mounted) return null;

      // Then show time picker
      final time = await showAdaptiveTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDateTime),
        cancelText: cancelText,
        confirmText: confirmText,
        use24HourFormat: use24HourFormat,
      );

      if (time == null) return null;

      // Combine date and time
      return DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    }
  }

  static Future<DateTime?> _showCupertinoDateTimePicker({
    required BuildContext context,
    required DateTime initialDateTime,
    required DateTime firstDate,
    required DateTime lastDate,
    String? cancelText,
    String? confirmText,
    bool use24HourFormat = false,
  }) async {
    DateTime selectedDateTime = initialDateTime;

    final result = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header with Cancel and Done buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(null),
                    child: Text(
                      cancelText ?? 'Cancel',
                      style: const TextStyle(
                        color: CupertinoColors.destructiveRed,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(selectedDateTime),
                    child: Text(
                      confirmText ?? 'Done',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // DateTime Picker
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: initialDateTime,
                minimumDate: firstDate,
                maximumDate: lastDate,
                use24hFormat: use24HourFormat,
                onDateTimeChanged: (DateTime dateTime) {
                  selectedDateTime = dateTime;
                },
              ),
            ),
          ],
        ),
      ),
    );

    return result;
  }

  // ==================== ACTION SHEET ====================

  /// Shows a platform-adaptive action sheet.
  ///
  /// On Android: Shows a Material Bottom Sheet
  /// On iOS: Shows a CupertinoActionSheet
  static Future<T?> showAdaptiveActionSheet<T>({
    required BuildContext context,
    String? title,
    String? message,
    required List<AdaptiveAction<T>> actions,
    AdaptiveAction<T>? cancelAction,
  }) async {
    if (isIOS) {
      return showCupertinoModalPopup<T>(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: title != null ? Text(title) : null,
          message: message != null ? Text(message) : null,
          actions: actions
              .map(
                (action) => CupertinoActionSheetAction(
                  isDestructiveAction: action.isDestructive,
                  isDefaultAction: action.isDefault,
                  onPressed: () {
                    Navigator.of(context).pop(action.value);
                    action.onPressed?.call();
                  },
                  child: Text(action.label),
                ),
              )
              .toList(),
          cancelButton: cancelAction != null
              ? CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop(cancelAction.value);
                    cancelAction.onPressed?.call();
                  },
                  child: Text(cancelAction.label),
                )
              : null,
        ),
      );
    } else {
      return showModalBottomSheet<T>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (title != null || message != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (title != null)
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      if (message != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          message,
                          style: TextStyle(
                            color: AppColors.gray500,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              const Divider(height: 1),
              ...actions.map(
                (action) => ListTile(
                  leading: action.icon != null
                      ? Icon(
                          action.icon,
                          color: action.isDestructive
                              ? AppColors.red500
                              : AppColors.gray700,
                        )
                      : null,
                  title: Text(
                    action.label,
                    style: TextStyle(
                      color:
                          action.isDestructive ? AppColors.red500 : AppColors.gray900,
                      fontWeight: action.isDefault ? FontWeight.w600 : null,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(action.value);
                    action.onPressed?.call();
                  },
                ),
              ),
              if (cancelAction != null) ...[
                const Divider(height: 1),
                ListTile(
                  title: Text(
                    cancelAction.label,
                    style: TextStyle(color: AppColors.gray500),
                    textAlign: TextAlign.center,
                  ),
                  onTap: () {
                    Navigator.of(context).pop(cancelAction.value);
                    cancelAction.onPressed?.call();
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    }
  }

  // ==================== LOADING DIALOG ====================

  /// Shows a platform-adaptive loading dialog.
  static Future<void> showAdaptiveLoadingDialog({
    required BuildContext context,
    String? message,
  }) async {
    if (isIOS) {
      await showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CupertinoActivityIndicator(radius: 16),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    } else {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
  }

  /// Hides the loading dialog.
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}

/// Represents an action in an adaptive action sheet.
class AdaptiveAction<T> {
  final String label;
  final T value;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isDefault;

  const AdaptiveAction({
    required this.label,
    required this.value,
    this.icon,
    this.onPressed,
    this.isDestructive = false,
    this.isDefault = false,
  });
}
