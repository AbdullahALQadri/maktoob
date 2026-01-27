import 'package:flutter/material.dart';

import '../widgets/snackbar/app_snackbar.dart';

extension ContextExtension on BuildContext {
  /// Shows a snackbar with the given message
  /// [error] - if true, shows error style (red), otherwise success style (green)
  void showSnackBar({required String message, bool error = true}) {
    if (error) {
      AppSnackBar.showError(this, message: message);
    } else {
      AppSnackBar.showSuccess(this, message: message);
    }
  }

  /// Shows a success snackbar
  void showSuccessSnackBar(String message) {
    AppSnackBar.showSuccess(this, message: message);
  }

  /// Shows an error snackbar
  void showErrorSnackBar(String message) {
    AppSnackBar.showError(this, message: message);
  }

  /// Shows a warning snackbar
  void showWarningSnackBar(String message) {
    AppSnackBar.showWarning(this, message: message);
  }

  /// Shows an info snackbar
  void showInfoSnackBar(String message) {
    AppSnackBar.showInfo(this, message: message);
  }
}
