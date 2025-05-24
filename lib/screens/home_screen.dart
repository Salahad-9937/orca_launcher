import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../services/file_service.dart';
import '../widgets/text_editor.dart';
import '../widgets/save_file_screen.dart';
import '../widgets/directory_picker.dart';
import '../screens/settings_screen.dart';

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
                    appState.setCurrentFilePath(null);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Создан новый файл')),
                    );
                  },
                  child: const Text('Создать'),
                ),
                MenuItemButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => DirectoryPicker(
                              onPathSelected: (path) async {
                                final content = await fileService.openFile(
                                  path,
                                );
                                if (content != null) {
                                  appState.updateEditorContent(content);
                                  appState.setCurrentFileName(
                                    path.split(Platform.pathSeparator).last,
                                  );
                                  appState.setCurrentFilePath(path);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Файл открыт: ${appState.currentFileName}',
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Ошибка при открытии файла',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              isFilePicker: true,
                              initialPath:
                                  appState.workingDirectory ??
                                  (Platform.isLinux
                                      ? Platform.environment['HOME'] ?? '/home'
                                      : 'C:\\'),
                            ),
                      ),
                    );
                  },
                  child: const Text('Открыть'),
                ),
                MenuItemButton(
                  onPressed: () async {
                    if (appState.currentFilePath != null) {
                      // Сохраняем существующий файл
                      final success = await fileService.saveFile(
                        appState.currentFilePath!.substring(
                          0,
                          appState.currentFilePath!.lastIndexOf(
                            Platform.pathSeparator,
                          ),
                        ),
                        appState.currentFileName,
                        appState.editorContent,
                      );
                      if (success) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Файл сохранён: ${appState.currentFileName}',
                              ),
                            ),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ошибка при сохранении файла'),
                            ),
                          );
                        }
                      }
                    } else {
                      // Открываем экран для выбора директории и имени файла
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => SaveFileScreen(
                                onSave: (path, fileName) async {
                                  final success = await fileService.saveFile(
                                    path,
                                    fileName,
                                    appState.editorContent,
                                  );
                                  if (success) {
                                    appState.setCurrentFileName(fileName);
                                    appState.setCurrentFilePath(
                                      path + Platform.pathSeparator + fileName,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Файл сохранён: $fileName',
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Ошибка при сохранении файла',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                initialPath:
                                    appState.workingDirectory ??
                                    (Platform.isLinux
                                        ? Platform.environment['HOME'] ??
                                            '/home'
                                        : 'C:\\'),
                              ),
                        ),
                      );
                    }
                  },
                  child: const Text('Сохранить'),
                ),
                MenuItemButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => SaveFileScreen(
                              onSave: (path, fileName) async {
                                final success = await fileService.saveFile(
                                  path,
                                  fileName,
                                  appState.editorContent,
                                );
                                if (success) {
                                  appState.setCurrentFileName(fileName);
                                  appState.setCurrentFilePath(
                                    path + Platform.pathSeparator + fileName,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Файл сохранён: $fileName',
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  if (context.mounted) {
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
                              initialPath:
                                  appState.workingDirectory ??
                                  (Platform.isLinux
                                      ? Platform.environment['HOME'] ?? '/home'
                                      : 'C:\\'),
                            ),
                      ),
                    );
                  },
                  child: const Text('Сохранить как'),
                ),
                MenuItemButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  child: const Text('Настройки'),
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
