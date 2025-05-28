import 'dart:io';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

/// Класс для выполнения низкоуровневых операций с файлами и запуска ORCA.
class FileService {
  /// Выбирает директорию для файловых операций.
  Future<String?> pickDirectory() async {
    // Метод не требуется, так как используется DirectoryPicker
    return null;
  }

  /// Запускает ORCA с указанным входным файлом и сохраняет вывод в выходной файл.
  /// [orcaPath] Полный путь к исполняемому файлу ORCA.
  /// [inputFilePath] Путь к входному файлу (.inp).
  /// [outputFilePath] Путь к выходному файлу (.out).
  Future<Either<String, String>> runOrca(
    String orcaPath,
    String inputFilePath,
    String outputFilePath,
  ) async {
    try {
      final result = await Process.run(
        orcaPath,
        [inputFilePath],
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );
      await File(outputFilePath).writeAsString(result.stdout);
      if (result.exitCode != 0) {
        return Left('Ошибка при запуске ORCA: ${result.stderr}');
      }
      if (kDebugMode) {
        print('ORCA executed successfully: $inputFilePath -> $outputFilePath');
      }
      return Right(result.stdout);
    } catch (e) {
      if (e is ProcessException &&
          e.message.contains('Нет такого файла или каталога')) {
        return Left('Путь к исполняемому файлу orca указан некорректно!');
      }
      if (kDebugMode) {
        print('Error running ORCA: $e');
      }
      return Left('Ошибка при запуске ORCA: $e');
    }
  }

  /// Сохраняет файл с указанным именем и содержимым в заданной директории.
  /// [path] Путь к директории.
  /// [fileName] Имя файла.
  /// [content] Содержимое файла.
  Future<bool> saveFile(String path, String fileName, String content) async {
    try {
      final file = File('$path/$fileName');
      if (await file.exists()) {
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
  /// [path] Путь к файлу.
  Future<String?> openFile(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        if (kDebugMode && await Directory(path).exists()) {
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
