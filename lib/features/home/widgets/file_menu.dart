import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/editor_state.dart';
import '../../../core/models/directory_state.dart';
import '../../../core/utils/error_display.dart';
import '../../../core/services/file_handler.dart';
import '../../file_system/save_file_screen.dart';
import '../../file_system/file_system_picker.dart';
import '../../settings/settings_screen.dart';

/// Виджет меню "Файл" с командами для работы с файлами и настройками.
class FileMenu extends StatelessWidget {
  const FileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final editorState = Provider.of<EditorState>(context);
    final directoryState = Provider.of<DirectoryState>(context);
    final fileHandler = Provider.of<FileHandler>(context, listen: false);

    return SubmenuButton(
      menuChildren: [
        MenuItemButton(
          onPressed: () {
            editorState.updateEditorContent('');
            editorState.setCurrentFileName('Безымянный');
            editorState.setCurrentFilePath(null);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Создан новый файл')),
              );
            }
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
                        if (!context.mounted) return;
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => FileSystemPicker(
                      onPathSelected: (path) async {
                        directoryState.setProjectDirectory(path);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Проект открыт: $path')),
                          );
                        }
                      },
                      isFilePicker: false,
                      initialPath:
                          directoryState.workingDirectory ??
                          (Platform.isLinux
                              ? Platform.environment['HOME'] ?? '/home'
                              : 'C:\\'),
                      titlePrefix: 'Выберите директорию проекта',
                      showConfirmButton: true,
                    ),
              ),
            );
          },
          child: const Text('Открыть проект'),
        ),
        MenuItemButton(
          onPressed: () async {
            if (editorState.currentFilePath != null) {
              final result = await fileHandler.saveExistingFile(
                editorState.currentFilePath!,
                editorState.currentFileName,
                editorState.editorContent,
              );
              if (!context.mounted) return;
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
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
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
    );
  }

  /// Открывает диалог "Сохранить как" для сохранения файла.
  /// [context] Контекст для отображения диалога.
  /// [editorState] Состояние редактора.
  /// [directoryState] Состояние директорий.
  /// [fileHandler] Обработчик файлов.
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
