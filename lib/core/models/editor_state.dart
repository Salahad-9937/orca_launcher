import 'package:flutter/material.dart';

/// Класс для управления состоянием текстового редактора.
/// [_editorContent] Содержимое редактора.
/// [_currentFileName] Имя текущего файла.
/// [_currentFilePath] Путь к текущему файлу.
class EditorState extends ChangeNotifier {
  String _editorContent = '';
  String _currentFileName = 'Безымянный';
  String? _currentFilePath;

  String get editorContent => _editorContent;
  String get currentFileName => _currentFileName;
  String? get currentFilePath => _currentFilePath;

  /// Обновляет содержимое редактора и уведомляет слушателей, если содержимое изменилось.
  /// [content] Новое содержимое редактора.
  void updateEditorContent(String content) {
    if (_editorContent != content) {
      _editorContent = content;
      notifyListeners();
    }
  }

  /// Устанавливает имя текущего файла и уведомляет слушателей, если имя изменилось.
  /// [name] Новое имя файла.
  void setCurrentFileName(String name) {
    if (_currentFileName != name) {
      _currentFileName = name;
      notifyListeners();
    }
  }

  /// Устанавливает путь к текущему файлу и уведомляет слушателей, если путь изменился.
  /// [path] Новый путь к файлу. Может быть null, если файл не сохранён.
  void setCurrentFilePath(String? path) {
    if (_currentFilePath != path) {
      _currentFilePath = path;
      notifyListeners();
    }
  }
}
