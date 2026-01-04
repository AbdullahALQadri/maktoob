import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  void showSnackBar({required String message, bool error = true}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        backgroundColor: error ? Colors.red.shade800 : Colors.green,
        dismissDirection: DismissDirection.horizontal,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
