import 'package:flutter/material.dart';

/// Класс для представления одного открытого файла во вкладке
class TabFile {
  final String fileName;
  final String? filePath;
  final String content;
  final bool isModified;

  TabFile({
    required this.fileName,
    this.filePath,
    required this.content,
    this.isModified = false,
  });

  TabFile copyWith({
    String? fileName,
    String? filePath,
    String? content,
    bool? isModified,
  }) {
    return TabFile(
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      content: content ?? this.content,
      isModified: isModified ?? this.isModified,
    );
  }
}

/// Класс для управления состоянием текстового редактора с поддержкой вкладок.
class EditorState extends ChangeNotifier {
  final List<TabFile> _openFiles = [];
  int _activeTabIndex = -1;
  bool _showLineNumbers = true;

  List<TabFile> get openFiles => List.unmodifiable(_openFiles);
  int get activeTabIndex => _activeTabIndex;
  bool get showLineNumbers => _showLineNumbers;

  // Геттеры для обратной совместимости с существующим кодом
  String get editorContent =>
      hasActiveFile ? _openFiles[_activeTabIndex].content : '';
  String get currentFileName =>
      hasActiveFile ? _openFiles[_activeTabIndex].fileName : 'Безымянный';
  String? get currentFilePath =>
      hasActiveFile ? _openFiles[_activeTabIndex].filePath : null;

  bool get hasActiveFile =>
      _activeTabIndex >= 0 && _activeTabIndex < _openFiles.length;
  bool get hasOpenFiles => _openFiles.isNotEmpty;

  /// Создает новый файл и открывает его во вкладке
  void createNewFile() {
    final newFile = TabFile(
      fileName: 'Безымянный${_openFiles.length + 1}',
      content: '',
    );
    _openFiles.add(newFile);
    _activeTabIndex = _openFiles.length - 1;
    notifyListeners();
  }

  /// Открывает файл во вкладке
  void openFile(String fileName, String? filePath, String content) {
    // Проверяем, не открыт ли уже этот файл
    if (filePath != null) {
      final existingIndex = _openFiles.indexWhere(
        (file) => file.filePath == filePath,
      );
      if (existingIndex != -1) {
        _activeTabIndex = existingIndex;
        notifyListeners();
        return;
      }
    }

    final newFile = TabFile(
      fileName: fileName,
      filePath: filePath,
      content: content,
    );
    _openFiles.add(newFile);
    _activeTabIndex = _openFiles.length - 1;
    notifyListeners();
  }

  /// Закрывает файл по индексу
  void closeFile(int index) {
    if (index < 0 || index >= _openFiles.length) return;

    _openFiles.removeAt(index);

    if (_openFiles.isEmpty) {
      _activeTabIndex = -1;
    } else if (_activeTabIndex >= _openFiles.length) {
      _activeTabIndex = _openFiles.length - 1;
    } else if (_activeTabIndex > index) {
      _activeTabIndex--;
    }

    notifyListeners();
  }

  /// Переключает активную вкладку
  void setActiveTab(int index) {
    if (index >= 0 && index < _openFiles.length && index != _activeTabIndex) {
      _activeTabIndex = index;
      notifyListeners();
    }
  }

  /// Обновляет содержимое активного файла - для обратной совместимости
  void updateEditorContent(String content) {
    if (hasActiveFile) {
      final currentFile = _openFiles[_activeTabIndex];
      _openFiles[_activeTabIndex] = currentFile.copyWith(
        content: content,
        isModified: currentFile.content != content,
      );
      notifyListeners();
    }
  }

  /// Устанавливает имя текущего файла - для обратной совместимости
  void setCurrentFileName(String name) {
    if (hasActiveFile) {
      final currentFile = _openFiles[_activeTabIndex];
      _openFiles[_activeTabIndex] = currentFile.copyWith(fileName: name);
      notifyListeners();
    }
  }

  /// Устанавливает путь к текущему файлу - для обратной совместимости
  void setCurrentFilePath(String? path) {
    if (hasActiveFile) {
      final currentFile = _openFiles[_activeTabIndex];
      _openFiles[_activeTabIndex] = currentFile.copyWith(filePath: path);
      notifyListeners();
    }
  }

  /// Переключает состояние отображения номеров строк
  void toggleLineNumbers() {
    _showLineNumbers = !_showLineNumbers;
    notifyListeners();
  }

  /// Инициализация с первым файлом для обратной совместимости
  EditorState() {
    createNewFile();
  }
}
