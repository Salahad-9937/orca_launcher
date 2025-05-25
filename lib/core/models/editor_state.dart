import 'package:flutter/material.dart';

class EditorState extends ChangeNotifier {
  String _editorContent = '';
  String _currentFileName = 'Безымянный';
  String? _currentFilePath;

  String get editorContent => _editorContent;
  String get currentFileName => _currentFileName;
  String? get currentFilePath => _currentFilePath;

  void updateEditorContent(String content) {
    if (_editorContent != content) {
      _editorContent = content;
      notifyListeners();
    }
  }

  void setCurrentFileName(String name) {
    if (_currentFileName != name) {
      _currentFileName = name;
      notifyListeners();
    }
  }

  void setCurrentFilePath(String? path) {
    if (_currentFilePath != path) {
      _currentFilePath = path;
      notifyListeners();
    }
  }
}
