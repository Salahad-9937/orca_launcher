import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

/// Класс для управления состоянием директорий приложения.
/// [_orcaDirectory] Путь к директории Orca.
/// [_workingDirectory] Путь к рабочей директории.
/// [_projectDirectory] Путь к директории проекта.
/// [_isProjectPanelVisible] Флаг видимости панели директорий.
class DirectoryState extends ChangeNotifier {
  String? _orcaDirectory;
  String? _workingDirectory;
  String? _projectDirectory;
  bool _isProjectPanelVisible = true;

  DirectoryState() {
    _loadPreferences();
  }

  String? get orcaDirectory => _orcaDirectory;
  String? get workingDirectory => _workingDirectory;
  String? get projectDirectory => _projectDirectory;
  bool get isProjectPanelVisible => _isProjectPanelVisible;

  /// Загружает сохранённые пути директорий из SharedPreferences.
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _orcaDirectory = prefs.getString('orcaDirectory');
    _workingDirectory = prefs.getString('workingDirectory');
    _projectDirectory = prefs.getString('projectDirectory');
    _isProjectPanelVisible = prefs.getBool('isProjectPanelVisible') ?? true;
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

  /// Устанавливает путь к директории проекта и сохраняет его в SharedPreferences.
  /// [path] Путь к директории проекта. Если null, путь сбрасывается.
  Future<void> setProjectDirectory(String? path) async {
    _projectDirectory = path;
    final prefs = await SharedPreferences.getInstance();
    if (_projectDirectory != null) {
      await prefs.setString('projectDirectory', _projectDirectory!);
    } else {
      await prefs.remove('projectDirectory');
    }
    notifyListeners();
  }

  /// Переключает видимость панели директорий и сохраняет состояние.
  Future<void> toggleProjectPanelVisibility() async {
    _isProjectPanelVisible = !_isProjectPanelVisible;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isProjectPanelVisible', _isProjectPanelVisible);
    notifyListeners();
  }
}
