import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FileUtils {
  /// Возвращает начальный путь для выбора директории или файла.
  static Future<String> getInitialPath(String? providedPath) async {
    if (providedPath != null) {
      return providedPath;
    }
    if (Platform.isLinux) {
      return Platform.environment['HOME'] ?? '/home';
    } else if (Platform.isWindows) {
      return 'C:\\';
    } else {
      return (await getApplicationDocumentsDirectory()).path;
    }
  }

  /// Возвращает содержимое директории с учётом фильтров и пагинации.
  /// [path] - путь к директории.
  /// [isFilePicker] - если true, показывать файлы .inp и папки, иначе только папки.
  /// [showHidden] - показывать скрытые файлы/папки.
  /// [searchQuery] - поисковый запрос для фильтрации.
  /// [page] - номер страницы для пагинации.
  /// [pageSize] - количество элементов на странице.
  static Future<List<FileSystemEntity>> getDirectoryContents(
    String path, {
    bool isFilePicker = false,
    bool showHidden = false,
    String searchQuery = '',
    int page = 0,
    int pageSize = 50,
  }) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) {
        if (Platform.isWindows && path == 'C:\\') {
          return [];
        }
        return [];
      }
      final entities = await dir.list(recursive: false).toList();
      List<FileSystemEntity> filteredEntities;

      if (isFilePicker) {
        filteredEntities =
            entities.where((entity) {
              if (entity is Directory) return true;
              if (entity is File && entity.path.endsWith('.inp')) return true;
              return false;
            }).toList();
      } else {
        filteredEntities = entities.whereType<Directory>().toList();
      }

      if (!showHidden) {
        filteredEntities =
            filteredEntities.where((entity) {
              return !p.basename(entity.path).startsWith('.');
            }).toList();
      }

      if (searchQuery.isNotEmpty) {
        filteredEntities =
            filteredEntities.where((entity) {
              final name = p.basename(entity.path).toLowerCase();
              return name.contains(searchQuery.toLowerCase());
            }).toList();
      }

      // Пагинация
      final startIndex = page * pageSize;
      final endIndex = min(startIndex + pageSize, filteredEntities.length);
      if (startIndex >= filteredEntities.length) {
        return [];
      }
      return filteredEntities.sublist(startIndex, endIndex);
    } catch (e) {
      if (kDebugMode) {
        print('Error listing directory contents: $e');
      }
      return [];
    }
  }

  /// Проверяет имя файла на валидность.
  static String? validateFileName(String fileName) {
    if (fileName.isEmpty) {
      return 'Имя файла не может быть пустым';
    }
    if (!fileName.endsWith('.inp')) {
      return 'Файл должен иметь расширение .inp';
    }
    return null;
  }
}
