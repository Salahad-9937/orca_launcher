import 'package:dartz/dartz.dart';
import 'dart:io';
import 'file_service.dart';

class FileHandler {
  final FileService _fileService;

  FileHandler(this._fileService);

  Future<Either<String, String>> openFile(String path) async {
    try {
      final content = await _fileService.openFile(path);
      if (content == null) {
        return Left('Ошибка при открытии файла: файл не существует');
      }
      return Right(content);
    } catch (e) {
      return Left('Ошибка при открытии файла: $e');
    }
  }

  Future<Either<String, void>> saveFile(
    String path,
    String fileName,
    String content,
  ) async {
    try {
      final success = await _fileService.saveFile(path, fileName, content);
      if (!success) {
        return Left('Ошибка при сохранении файла');
      }
      return const Right(null);
    } catch (e) {
      return Left('Ошибка при сохранении файла: $e');
    }
  }

  Future<Either<String, void>> saveExistingFile(
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
