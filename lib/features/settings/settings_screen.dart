import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import '../../core/models/directory_state.dart';
import '../../core/widgets/custom_text_field.dart';
import '../file_system/file_system_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _orcaController = TextEditingController();
  final TextEditingController _workingController = TextEditingController();
  bool _isOrcaValid = true;

  @override
  void initState() {
    super.initState();
    final directoryState = Provider.of<DirectoryState>(context, listen: false);
    // Отображаем только директорию, убирая /orca из пути
    _orcaController.text =
        directoryState.orcaDirectory != null
            ? p.dirname(directoryState.orcaDirectory!)
            : '';
    _workingController.text = directoryState.workingDirectory ?? '';
    _validateOrcaPath(_orcaController.text); // Проверка при инициализации
    _orcaController.addListener(_onOrcaPathChanged);
  }

  void _onOrcaPathChanged() {
    final path = _orcaController.text;
    _validateOrcaPath(path);
    final directoryState = Provider.of<DirectoryState>(context, listen: false);
    directoryState.setOrcaDirectory(path.isEmpty ? null : path);
  }

  void _validateOrcaPath(String path) {
    if (path.isEmpty) {
      setState(() {
        _isOrcaValid = true; // Пустой путь не показывает ошибку
      });
      return;
    }
    // Проверяем существование файла orca в указанной директории
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
                CustomTextField(
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
            CustomTextField(
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
