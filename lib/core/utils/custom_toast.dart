import 'package:flutter/material.dart';

import '../widgets/snackbar/app_snackbar.dart';

/// Mixin for showing modern snackbar messages
mixin CustomToast {
  /// Shows a snackbar with the given message
  /// [error] - if true, shows error style (red), otherwise success style (green)
  void showSnackBar(
    BuildContext context, {
    required String message,
    required bool error,
  }) {
    if (error) {
      AppSnackBar.showError(context, message: message);
    } else {
      AppSnackBar.showSuccess(context, message: message);
    }
  }

  /// Shows a success snackbar
  void showSuccessSnackBar(BuildContext context, String message) {
    AppSnackBar.showSuccess(context, message: message);
  }

  /// Shows an error snackbar
  void showErrorSnackBar(BuildContext context, String message) {
    AppSnackBar.showError(context, message: message);
  }

  /// Shows a warning snackbar
  void showWarningSnackBar(BuildContext context, String message) {
    AppSnackBar.showWarning(context, message: message);
  }

  /// Shows an info snackbar
  void showInfoSnackBar(BuildContext context, String message) {
    AppSnackBar.showInfo(context, message: message);
  }
}
