import 'package:dartz/dartz.dart';
import 'dart:io';
import '../models/app_error.dart';
import 'file_service.dart';

/// Класс для обработки операций с файлами, включая запуск ORCA и управление файлами.
/// [_fileService] Сервис для выполнения операций с файлами.
class FileHandler {
  final FileService _fileService;

  FileHandler(this._fileService);

  /// Запускает ORCA с указанным входным файлом и сохраняет вывод в выходной файл.
  /// [orcaPath] Полный путь к исполняемому файлу ORCA.
  /// [inputFilePath] Путь к входному файлу (.inp).
  /// [outputFilePath] Путь к выходному файлу (.out).
  Future<Either<AppError, String>> runOrca(
    String orcaPath,
    String inputFilePath,
    String outputFilePath,
  ) async {
    try {
      final result = await _fileService.runOrca(
        orcaPath,
        inputFilePath,
        outputFilePath,
      );
      return result.fold(
        (error) => Left(AppError(error, type: ErrorType.generic)),
        (output) => Right(output),
      );
    } catch (e) {
      return Left(
        AppError('Ошибка при запуске ORCA: $e', type: ErrorType.generic),
      );
    }
  }

  /// Открывает файл по указанному пути.
  /// [path] Путь к файлу.
  Future<Either<AppError, String>> openFile(String path) async {
    try {
      final content = await _fileService.openFile(path);
      if (content == null) {
        return Left(
          AppError('Файл не существует', type: ErrorType.fileNotFound),
        );
      }
      return Right(content);
    } catch (e) {
      return Left(
        AppError('Ошибка при открытии файла: $e', type: ErrorType.generic),
      );
    }
  }

  /// Сохраняет файл с указанным именем и содержимым в заданной директории.
  /// [path] Путь к директории.
  /// [fileName] Имя файла.
  /// [content] Содержимое файла.
  Future<Either<AppError, String>> saveFile(
    String path,
    String fileName,
    String content,
  ) async {
    try {
      final success = await _fileService.saveFile(path, fileName, content);
      if (!success) {
        return Left(
          AppError('Не удалось сохранить файл', type: ErrorType.saveFailed),
        );
      }
      return Right('$path${Platform.pathSeparator}$fileName');
    } catch (e) {
      return Left(
        AppError('Ошибка при сохранении файла: $e', type: ErrorType.generic),
      );
    }
  }

  /// Сохраняет существующий файл по указанному пути.
  /// [filePath] Полный путь к файлу.
  /// [fileName] Имя файла.
  /// [content] Содержимое файла.
  Future<Either<AppError, String>> saveExistingFile(
    String filePath,
    String fileName,
    String content,
  ) async {
    final directory = filePath.substring(
      0,
      filePath.lastIndexOf(Platform.pathSeparator),
    );
    return saveFile(directory, fileName, content);
  }
}
