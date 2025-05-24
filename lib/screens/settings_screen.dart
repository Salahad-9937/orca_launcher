import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/directory_picker.dart';

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
    final appState = Provider.of<AppState>(context, listen: false);
    _orcaController.text = appState.orcaDirectory ?? '';
    _workingController.text = appState.workingDirectory ?? '';
  }

  @override
  void dispose() {
    _orcaController.dispose();
    _workingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
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
                            (context) => DirectoryPicker(
                              onPathSelected: (path) {
                                _orcaController.text = path;
                                appState.setOrcaDirectory(path);
                              },
                              initialPath:
                                  Platform.isLinux
                                      ? Platform.environment['HOME'] ?? '/home'
                                      : 'C:\\',
                            ),
                      ),
                    );
                  },
                ),
              ),
              onChanged: (value) {
                appState.setOrcaDirectory(value.isEmpty ? null : value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
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
                            (context) => DirectoryPicker(
                              onPathSelected: (path) {
                                _workingController.text = path;
                                appState.setWorkingDirectory(path);
                              },
                              initialPath:
                                  Platform.isLinux
                                      ? Platform.environment['HOME'] ?? '/home'
                                      : 'C:\\',
                            ),
                      ),
                    );
                  },
                ),
              ),
              onChanged: (value) {
                appState.setWorkingDirectory(value.isEmpty ? null : value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
