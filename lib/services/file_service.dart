import 'dart:io';
import 'package:flutter/foundation.dart';

class FileService {
  Future<String?> pickDirectory() async {
    // Метод не требуется, так как используется DirectoryPicker
    return null;
  }

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

  Future<String?> openFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final content = await file.readAsString();
        if (kDebugMode) {
          print('File opened: $path');
        }
        return content;
      } else {
        if (kDebugMode) {
          print('File does not exist: $path');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error opening file: $e');
      }
      return null;
    }
  }
}
