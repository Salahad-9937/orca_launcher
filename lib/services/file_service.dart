import 'dart:io';
import 'package:flutter/foundation.dart';

class FileService {
  Future<String?> pickDirectory() async {
    // Метод не требуется, так как мы используем DirectoryPicker
    return null;
  }

  Future<bool> saveFile(String path, String fileName, String content) async {
    try {
      final file = File('$path/$fileName');
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
}
