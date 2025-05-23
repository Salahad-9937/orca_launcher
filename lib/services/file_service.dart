import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class FileService {
  Future<String?> pickDirectory() async {
    try {
      // Используем file_picker для выбора директории
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        if (kDebugMode) {
          print('User cancelled directory selection');
        }
        return null;
      }
      return selectedDirectory;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking directory: $e');
      }
      return null;
    }
  }
}
