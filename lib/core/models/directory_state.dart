import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class DirectoryState extends ChangeNotifier {
  String? _orcaDirectory;
  String? _workingDirectory;

  DirectoryState() {
    _loadPreferences(); // Загружаем сохранённые настройки при инициализации
  }

  String? get orcaDirectory => _orcaDirectory;
  String? get workingDirectory => _workingDirectory;

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _orcaDirectory = prefs.getString('orcaDirectory');
    _workingDirectory = prefs.getString('workingDirectory');
    notifyListeners();
  }

  Future<void> setOrcaDirectory(String? path) async {
    if (path != null) {
      _orcaDirectory = '$path${Platform.pathSeparator}orca';
    } else {
      _orcaDirectory = null;
    }
    final prefs = await SharedPreferences.getInstance();
    if (_orcaDirectory != null) {
      await prefs.setString('orcaDirectory', _orcaDirectory!);
    } else {
      await prefs.remove('orcaDirectory');
    }
    notifyListeners();
  }

  Future<void> setWorkingDirectory(String? path) async {
    _workingDirectory = path;
    final prefs = await SharedPreferences.getInstance();
    if (_workingDirectory != null) {
      await prefs.setString('workingDirectory', _workingDirectory!);
    } else {
      await prefs.remove('workingDirectory');
    }
    notifyListeners();
  }
}
