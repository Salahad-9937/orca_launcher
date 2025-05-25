import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/editor_state.dart';
import '../models/directory_state.dart';
import '../utils/error_display.dart';
import '../services/file_handler.dart';
import '../widgets/save_file_screen.dart';
import '../widgets/file_system_picker.dart';
import '../screens/settings_screen.dart';

class AppMenuBar extends StatelessWidget {
  final String title;

  const AppMenuBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final editorState = Provider.of<EditorState>(context);
    final directoryState = Provider.of<DirectoryState>(context);
    final fileHandler = Provider.of<FileHandler>(context, listen: false);

    return MenuBar(
      children: [
        SubmenuButton(
          menuChildren: [
            MenuItemButton(
              onPressed: () {
                editorState.updateEditorContent('');
                editorState.setCurrentFileName('Безымянный');
                editorState.setCurrentFilePath(null);
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
                        (context) => FileSystemPicker(
                          onPathSelected: (path) async {
                            final result = await fileHandler.openFile(path);
                            result.fold(
                              (error) => ErrorDisplay.showError(context, error),
                              (content) {
                                editorState.updateEditorContent(content);
                                editorState.setCurrentFileName(
                                  path.split(Platform.pathSeparator).last,
                                );
                                editorState.setCurrentFilePath(path);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Файл открыт: ${editorState.currentFileName}',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          isFilePicker: true,
                          initialPath:
                              directoryState.workingDirectory ??
                              (Platform.isLinux
                                  ? Platform.environment['HOME'] ?? '/home'
                                  : 'C:\\'),
                          titlePrefix: 'Выберите файл',
                        ),
                  ),
                );
              },
              child: const Text('Открыть'),
            ),
            MenuItemButton(
              onPressed: () async {
                if (editorState.currentFilePath != null) {
                  final result = await fileHandler.saveExistingFile(
                    editorState.currentFilePath!,
                    editorState.currentFileName,
                    editorState.editorContent,
                  );
                  result.fold(
                    (error) => ErrorDisplay.showError(context, error),
                    (_) => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Файл сохранён: ${editorState.currentFileName}',
                        ),
                      ),
                    ),
                  );
                } else {
                  _showSaveAsDialog(
                    context,
                    editorState,
                    directoryState,
                    fileHandler,
                  );
                }
              },
              child: const Text('Сохранить'),
            ),
            MenuItemButton(
              onPressed: () {
                _showSaveAsDialog(
                  context,
                  editorState,
                  directoryState,
                  fileHandler,
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
    );
  }

  void _showSaveAsDialog(
    BuildContext context,
    EditorState editorState,
    DirectoryState directoryState,
    FileHandler fileHandler,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SaveFileScreen(
              onSave: (path, fileName) {
                editorState.setCurrentFileName(fileName);
                editorState.setCurrentFilePath(
                  path + Platform.pathSeparator + fileName,
                );
              },
              initialPath:
                  directoryState.workingDirectory ??
                  (Platform.isLinux
                      ? Platform.environment['HOME'] ?? '/home'
                      : 'C:\\'),
            ),
      ),
    );
  }
}
