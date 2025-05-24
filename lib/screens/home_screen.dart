import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../services/file_service.dart';
import '../widgets/text_editor.dart';
import '../widgets/save_file_dialog.dart';
import '../widgets/directory_picker.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final fileService = FileService();

    return Scaffold(
      appBar: AppBar(
        title: Text(appState.currentFileName),
        centerTitle: true,
        flexibleSpace: MenuBar(
          children: [
            SubmenuButton(
              menuChildren: [
                MenuItemButton(
                  onPressed: () {
                    appState.updateEditorContent('');
                    appState.setCurrentFileName('Безымянный');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Создан новый файл')),
                    );
                  },
                  child: const Text('Новый'),
                ),
                MenuItemButton(
                  onPressed: () async {
                    if (appState.workingDirectory == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Сначала выберите рабочую директорию'),
                        ),
                      );
                      return;
                    }
                    showDialog(
                      context: context,
                      builder:
                          (context) => SaveFileDialog(
                            onSave: (fileName) async {
                              final success = await fileService.saveFile(
                                appState.workingDirectory!,
                                fileName,
                                appState.editorContent,
                              );
                              if (context.mounted) {
                                if (success) {
                                  appState.setCurrentFileName(fileName);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Файл сохранён: $fileName'),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Ошибка при сохранении файла',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                    );
                  },
                  child: const Text('Сохранить'),
                ),
                MenuItemButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => DirectoryPicker(
                              onPathSelected: (path) {
                                appState.setOrcaDirectory(path);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Выбрана директория ORCA: $path',
                                    ),
                                  ),
                                );
                              },
                            ),
                      ),
                    );
                  },
                  child: const Text('Выбрать директорию ORCA'),
                ),
                MenuItemButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => DirectoryPicker(
                              onPathSelected: (path) {
                                appState.setWorkingDirectory(path);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Выбрана рабочая директория: $path',
                                    ),
                                  ),
                                );
                              },
                            ),
                      ),
                    );
                  },
                  child: const Text('Выбрать рабочую директорию'),
                ),
                MenuItemButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Выход'),
                ),
              ],
              child: const Text('Файл'),
            ),
            SubmenuButton(
              menuChildren: [
                MenuItemButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('О программе'),
                            content: const Text(
                              'Инструмент для создания входных файлов ORCA.\nВерсия 1.0.0',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('ОК'),
                              ),
                            ],
                          ),
                    );
                  },
                  child: const Text('О программе'),
                ),
              ],
              child: const Text('Справка'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Редактор входного файла',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Expanded(child: TextEditor()),
          ],
        ),
      ),
    );
  }
}
