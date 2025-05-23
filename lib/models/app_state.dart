import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String? _orcaDirectory;
  String? _workingDirectory;
  String _editorContent = '';

  String? get orcaDirectory => _orcaDirectory;
  String? get workingDirectory => _workingDirectory;
  String get editorContent => _editorContent;

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
}
