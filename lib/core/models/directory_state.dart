import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

/// Класс для управления состоянием директорий приложения.
/// [_orcaDirectory] Путь к директории Orca.
/// [_workingDirectory] Путь к рабочей директории.
class DirectoryState extends ChangeNotifier {
  String? _orcaDirectory;
  String? _workingDirectory;

  DirectoryState() {
    _loadPreferences();
  }

  String? get orcaDirectory => _orcaDirectory;
  String? get workingDirectory => _workingDirectory;

  /// Загружает сохранённые пути директорий из SharedPreferences.
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _orcaDirectory = prefs.getString('orcaDirectory');
    _workingDirectory = prefs.getString('workingDirectory');
    notifyListeners();
  }

  /// Устанавливает путь к директории Orca и сохраняет его в SharedPreferences.
  /// [path] Путь к базовой директории, к которой будет добавлен подкаталог 'orca'. Если null, путь сбрасывается.
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

  /// Устанавливает путь к рабочей директории и сохраняет его в SharedPreferences.
  /// [path] Путь к рабочей директории. Если null, путь сбрасывается.
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
