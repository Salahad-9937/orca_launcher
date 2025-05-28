enum ErrorType { fileNotFound, invalidFile, saveFailed, generic }

/// Класс для представления ошибок приложения.
/// [message] Сообщение об ошибке.
/// [type] Тип ошибки, по умолчанию ErrorType.generic.
class AppError {
  final String message;
  final ErrorType type;

  AppError(this.message, {this.type = ErrorType.generic});

  /// Возвращает локализованное сообщение об ошибке на основе её типа.
  String get localizedMessage {
    switch (type) {
      case ErrorType.fileNotFound:
        return 'Файл не найден: $message';
      case ErrorType.invalidFile:
        return 'Недопустимый файл: $message';
      case ErrorType.saveFailed:
        return 'Не удалось сохранить файл: $message';
      case ErrorType.generic:
        return message;
    }
  }
}
