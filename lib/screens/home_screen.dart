import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/directory_selector.dart';
import '../widgets/text_editor.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('ORCA Input Generator')),
      body: Column(
        children: [
          // MenuBar from material library
          MenuBar(
            children: [
              SubmenuButton(
                menuChildren: [
                  MenuItemButton(
                    onPressed: () {
                      appState.updateEditorContent(''); // Очистка редактора
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('New file created')),
                      );
                    },
                    child: const Text('New'),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      // Логика сохранения будет добавлена позже
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Save functionality not implemented yet',
                          ),
                        ),
                      );
                    },
                    child: const Text('Save'),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Exit'),
                  ),
                ],
                child: const Text('File'),
              ),
              SubmenuButton(
                menuChildren: [
                  MenuItemButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('About ORCA Input Generator'),
                              content: const Text(
                                'A tool for generating ORCA input files.\nVersion 1.0.0',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                      );
                    },
                    child: const Text('About'),
                  ),
                ],
                child: const Text('Help'),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DirectorySelector(
                    label: 'ORCA',
                    currentPath: appState.orcaDirectory,
                    onPathSelected: (path) => appState.setOrcaDirectory(path),
                  ),
                  DirectorySelector(
                    label: 'Working',
                    currentPath: appState.workingDirectory,
                    onPathSelected:
                        (path) => appState.setWorkingDirectory(path),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Input File Editor',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Expanded(child: TextEditor()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
