import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FileUtils {
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

  static Future<List<FileSystemEntity>> getDirectoryContents(
    String path, {
    bool isFilePicker = false,
    bool showHidden = false,
    String searchQuery = '',
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
        // Показываем файлы .inp и папки
        filteredEntities =
            entities.where((entity) {
              if (entity is Directory) return true;
              if (entity is File && entity.path.endsWith('.inp')) return true;
              return false;
            }).toList();
      } else {
        // Показываем только папки
        filteredEntities = entities.whereType<Directory>().toList();
      }

      // Фильтрация скрытых файлов/папок
      if (!showHidden) {
        filteredEntities =
            filteredEntities.where((entity) {
              return !p.basename(entity.path).startsWith('.');
            }).toList();
      }

      // Фильтрация по поисковому запросу
      if (searchQuery.isNotEmpty) {
        filteredEntities =
            filteredEntities.where((entity) {
              final name = p.basename(entity.path).toLowerCase();
              return name.contains(searchQuery.toLowerCase());
            }).toList();
      }

      return filteredEntities;
    } catch (e) {
      if (kDebugMode) {
        print('Error listing directory contents: $e');
      }
      return [];
    }
  }
}
