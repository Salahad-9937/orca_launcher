import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../core/models/directory_state.dart';
import '../../core/widgets/custom_text_field.dart'; // Новый импорт
import '../file_system/file_system_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _orcaController = TextEditingController();
  final TextEditingController _workingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final directoryState = Provider.of<DirectoryState>(context, listen: false);
    _orcaController.text = directoryState.orcaDirectory ?? '';
    _workingController.text = directoryState.workingDirectory ?? '';
  }

  @override
  void dispose() {
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
                                directoryState.setOrcaDirectory(path);
                              },
                              initialPath:
                                  Platform.isLinux
                                      ? Platform.environment['HOME'] ?? '/home'
                                      : 'C:\\',
                              titlePrefix: 'Выберите директорию ORCA',
                            ),
                      ),
                    );
                  },
                ),
              ),
              onChanged: (value) {
                directoryState.setOrcaDirectory(value.isEmpty ? null : value);
              },
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
