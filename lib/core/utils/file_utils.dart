import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Класс для утилитных операций с файлами и директориями.
class FileUtils {
  /// Возвращает начальный путь для выбора директории или файла.
  /// [providedPath] Предоставленный путь, если есть.
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

  /// Возвращает содержимое директории с учётом фильтров, сортировки и пагинации.
  /// [path] Путь к директории.
  /// [isFilePicker] Если true, показывать файлы и папки, иначе только папки.
  /// [showHidden] Показывать скрытые файлы/папки.
  /// [searchQuery] Поисковый запрос для фильтрации.
  /// [page] Номер страницы для пагинации.
  /// [pageSize] Количество элементов на странице.
  /// [allowedExtensions] Список разрешённых расширений файлов.
  static Future<List<FileSystemEntity>> getDirectoryContents(
    String path, {
    bool isFilePicker = false,
    bool showHidden = false,
    String searchQuery = '',
    int page = 0,
    int pageSize = 50,
    List<String>? allowedExtensions,
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
              if (entity is File) {
                if (allowedExtensions != null && allowedExtensions.isNotEmpty) {
                  return allowedExtensions.any(
                    (ext) =>
                        entity.path.toLowerCase().endsWith(ext.toLowerCase()),
                  );
                }
                return entity.path.endsWith('.inp');
              }
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

      final directories = filteredEntities.whereType<Directory>().toList();
      final files = filteredEntities.whereType<File>().toList();

      int compareNames(String a, String b) {
        bool isSymbolOrDigit(String s) => RegExp(r'^[0-9\W]').hasMatch(s);
        bool isLatin(String s) => RegExp(r'^[a-zA-Z]').hasMatch(s);
        bool isCyrillic(String s) => RegExp(r'^[\u0400-\u04FF]').hasMatch(s);

        final isASymbol = isSymbolOrDigit(a);
        final isBSymbol = isSymbolOrDigit(b);
        final isALatin = isLatin(a);
        final isBLatin = isLatin(b);
        final isACyrillic = isCyrillic(a);
        final isBCyrillic = isCyrillic(b);

        if (isASymbol && !isBSymbol) return -1;
        if (!isASymbol && isBSymbol) return 1;
        if (isALatin && !isBLatin) return -1;
        if (!isALatin && isBLatin) return 1;
        if (isACyrillic && !isBCyrillic) return 1;
        if (!isACyrillic && isBCyrillic) return -1;

        if (isASymbol || isALatin) {
          return a.toLowerCase().compareTo(b.toLowerCase());
        }
        return a.compareTo(b);
      }

      directories.sort(
        (a, b) => compareNames(p.basename(a.path), p.basename(b.path)),
      );
      files.sort(
        (a, b) => compareNames(p.basename(a.path), p.basename(b.path)),
      );

      final sortedEntities = [...directories, ...files];

      final startIndex = page * pageSize;
      final endIndex = min(startIndex + pageSize, sortedEntities.length);
      if (startIndex >= sortedEntities.length) {
        return [];
      }
      return sortedEntities.sublist(startIndex, endIndex);
    } catch (e) {
      if (kDebugMode) {
        print('Error listing directory contents: $e');
      }
      return [];
    }
  }

  /// Проверяет имя файла на валидность.
  /// [fileName] Имя файла для проверки.
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
