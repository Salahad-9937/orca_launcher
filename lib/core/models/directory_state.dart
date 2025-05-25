import 'package:flutter/material.dart';

class DirectoryState extends ChangeNotifier {
  String? _orcaDirectory;
  String? _workingDirectory;

  String? get orcaDirectory => _orcaDirectory;
  String? get workingDirectory => _workingDirectory;

  void setOrcaDirectory(String? path) {
    if (_orcaDirectory != path) {
      _orcaDirectory = path;
      notifyListeners();
    }
  }

  void setWorkingDirectory(String? path) {
    if (_workingDirectory != path) {
      _workingDirectory = path;
      notifyListeners();
    }
  }
}
