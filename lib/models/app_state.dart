import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String? _orcaDirectory;
  String? _workingDirectory;
  String _editorContent = '';
  String _currentFileName = 'Безымянный';

  String? get orcaDirectory => _orcaDirectory;
  String? get workingDirectory => _workingDirectory;
  String get editorContent => _editorContent;
  String get currentFileName => _currentFileName;

  void setOrcaDirectory(String? path) {
    _orcaDirectory = path;
    notifyListeners();
  }

  void setWorkingDirectory(String? path) {
    _workingDirectory = path;
    notifyListeners();
  }

  void updateEditorContent(String content) {
    _editorContent = content;
    notifyListeners();
  }

  void setCurrentFileName(String name) {
    _currentFileName = name;
    notifyListeners();
  }
}
