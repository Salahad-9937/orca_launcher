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

  /// Возвращает содержимое директории с учётом фильтров, сортировки и пагинации.
  /// [path] - путь к директории.
  /// [isFilePicker] - если true, показывать файлы и папки, иначе только папки.
  /// [showHidden] - показывать скрытые файлы/папки.
  /// [searchQuery] - поисковый запрос для фильтрации.
  /// [page] - номер страницы для пагинации.
  /// [pageSize] - количество элементов на странице.
  /// [allowedExtensions] - список разрешённых расширений файлов (например, ['.inp']).
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
                return entity.path.endsWith(
                  '.inp',
                ); // Сохранена старая логика как запасная
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

      // Разделяем на директории и файлы
      final directories = filteredEntities.whereType<Directory>().toList();
      final files = filteredEntities.whereType<File>().toList();

      // Определяем функцию сортировки по имени
      int compareNames(String a, String b) {
        // Проверяем категории символов
        bool isSymbolOrDigit(String s) => RegExp(r'^[0-9\W]').hasMatch(s);
        bool isLatin(String s) => RegExp(r'^[a-zA-Z]').hasMatch(s);
        bool isCyrillic(String s) => RegExp(r'^[\u0400-\u04FF]').hasMatch(s);

        // Проверяем категории для a и б
        final isASymbol = isSymbolOrDigit(a);
        final isBSymbol = isSymbolOrDigit(b);
        final isALatin = isLatin(a);
        final isBLatin = isLatin(b);
        final isACyrillic = isCyrillic(a);
        final isBCyrillic = isCyrillic(b);

        // Сравниваем по категориям: символы/цифры → латиница → кириллица
        if (isASymbol && !isBSymbol) return -1;
        if (!isASymbol && isBSymbol) return 1;
        if (isALatin && !isBLatin) return -1; // Латиница перед кириллицей
        if (!isALatin && isBLatin) return 1;
        if (isACyrillic && !isBCyrillic) return 1; // Кириллица после латиницы
        if (!isACyrillic && isBCyrillic) return -1;

        // Внутри категории: символы/цифры и латиница — игнорировать регистр
        if (isASymbol || isALatin) {
          return a.toLowerCase().compareTo(b.toLowerCase());
        }
        // Для кириллицы — учитывать естественный порядок
        return a.compareTo(b);
      }

      // Сортируем директории и файлы по имени
      directories.sort(
        (a, b) => compareNames(p.basename(a.path), p.basename(b.path)),
      );
      files.sort(
        (a, b) => compareNames(p.basename(a.path), p.basename(b.path)),
      );

      // Объединяем: сначала директории, затем файлы
      final sortedEntities = [...directories, ...files];

      // Пагинация
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
