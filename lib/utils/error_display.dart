import 'package:flutter/material.dart';
import '../models/app_error.dart';

class ErrorDisplay {
  static void showError(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.localizedMessage),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
