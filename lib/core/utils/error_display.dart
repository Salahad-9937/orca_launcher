import 'package:flutter/material.dart';
import '../models/app_error.dart';

/// Класс для отображения ошибок приложения в виде всплывающих уведомлений.
class ErrorDisplay {
  /// Показывает ошибку в виде SnackBar в предоставленном контексте.
  /// [context] BuildContext для отображения SnackBar.
  /// [error] Объект ошибки для отображения.
  static void showError(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.localizedMessage),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
