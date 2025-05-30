import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import '../../core/models/directory_state.dart';
import '../../core/widgets/custom_dialog_text_field_.dart';
import '../file_system/file_system_picker.dart';

/// Экран настроек для управления директориями приложения.
/// [_orcaController] Контроллер для поля ввода директории ORCA.
/// [_workingController] Контроллер для поля ввода рабочей директории.
/// [_isOrcaValid] Флаг валидности пути к ORCA.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

/// Состояние экрана настроек, управляющее полями ввода и валидацией.
/// [_orcaController] Контроллер для поля ввода директории ORCA.
/// [_workingController] Контроллер для поля ввода рабочей директории.
/// [_isOrcaValid] Флаг валидности пути к ORCA.
class SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _orcaController = TextEditingController();
  final TextEditingController _workingController = TextEditingController();
  bool _isOrcaValid = true;

  @override
  void initState() {
    super.initState();
    final directoryState = Provider.of<DirectoryState>(context, listen: false);
    _orcaController.text =
        directoryState.orcaDirectory != null
            ? p.dirname(directoryState.orcaDirectory!)
            : '';
    _workingController.text = directoryState.workingDirectory ?? '';
    _validateOrcaPath(_orcaController.text);
    _orcaController.addListener(_onOrcaPathChanged);
  }

  /// Обрабатывает изменение пути к директории ORCA и обновляет состояние.
  void _onOrcaPathChanged() {
    final path = _orcaController.text;
    _validateOrcaPath(path);
    final directoryState = Provider.of<DirectoryState>(context, listen: false);
    directoryState.setOrcaDirectory(path.isEmpty ? null : path);
  }

  /// Проверяет валидность пути к директории ORCA.
  /// [path] Путь к директории ORCA.
  void _validateOrcaPath(String path) {
    if (path.isEmpty) {
      setState(() {
        _isOrcaValid = true;
      });
      return;
    }
    final orcaFile = File('$path${Platform.pathSeparator}orca');
    setState(() {
      _isOrcaValid = orcaFile.existsSync();
    });
  }

  @override
  void dispose() {
    _orcaController.removeListener(_onOrcaPathChanged);
    _orcaController.dispose();
    _workingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final directoryState = Provider.of<DirectoryState>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomDialogTextField(
                  controller: _orcaController,
                  decoration: InputDecoration(
                    labelText: 'Директория ORCA',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.folder_open),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => FileSystemPicker(
                                  onPathSelected: (path) {
                                    _orcaController.text = path;
                                    _validateOrcaPath(path);
                                    directoryState.setOrcaDirectory(path);
                                  },
                                  initialPath:
                                      Platform.isLinux
                                          ? Platform.environment['HOME'] ??
                                              '/home'
                                          : 'C:\\',
                                  titlePrefix: 'Выберите директорию ORCA',
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (!_isOrcaValid && _orcaController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                    child: Text(
                      'В указанной директории нет исполняемого файла orca!',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            CustomDialogTextField(
              controller: _workingController,
              decoration: InputDecoration(
                labelText: 'Рабочая директория',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => FileSystemPicker(
                              onPathSelected: (path) {
                                _workingController.text = path;
                                directoryState.setWorkingDirectory(path);
                              },
                              initialPath:
                                  Platform.isLinux
                                      ? Platform.environment['HOME'] ?? '/home'
                                      : 'C:\\',
                              titlePrefix: 'Выберите рабочую директорию',
                            ),
                      ),
                    );
                  },
                ),
              ),
              onChanged: (value) {
                directoryState.setWorkingDirectory(
                  value.isEmpty ? null : value,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
