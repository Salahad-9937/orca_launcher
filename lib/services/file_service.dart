import 'dart:io';
import 'package:flutter/foundation.dart';

class FileService {
  Future<String?> pickDirectory() async {
    // Метод не требуется, так как используется DirectoryPicker
    return null;
  }

  /// Сохраняет файл с указанным именем и содержимым в заданной директории.
  /// Возвращает [true] при успехе, [false] при ошибке.
  Future<bool> saveFile(String path, String fileName, String content) async {
    try {
      final file = File('$path/$fileName');
      if (await file.exists()) {
        // Можно добавить логику для подтверждения перезаписи
        if (kDebugMode) {
          print('Overwriting existing file: ${file.path}');
        }
      }
      await file.writeAsString(content);
      if (kDebugMode) {
        print('File saved: ${file.path}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving file: $e');
      }
      return false;
    }
  }

  /// Открывает файл по указанному пути и возвращает его содержимое.
  /// Возвращает [null], если путь не указывает на существующий файл.
  Future<String?> openFile(String path) async {
    try {
      final file = File(path);
      // Проверяем, является ли путь файлом
      if (!await file.exists()) {
        if (kDebugMode && await Directory(path).exists()) {
          print('Path is a directory, not a file: $path');
        } else if (kDebugMode) {
          print('File does not exist: $path');
        }
        return null;
      }
      final content = await file.readAsString();
      if (kDebugMode) {
        print('File opened: $path');
      }
      return content;
    } catch (e) {
      if (kDebugMode) {
        print('Error opening file: $e');
      }
      return null;
    }
  }
}
