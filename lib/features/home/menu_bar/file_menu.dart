import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            editorState.createNewFile();
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
                            final fileName =
                                path.split(Platform.pathSeparator).last;
                            editorState.openFile(fileName, path, content);
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
            directoryState.setProjectDirectory(null);
            if (!directoryState.isProjectPanelVisible) {
              await directoryState.toggleProjectPanelVisibility();
            }
          },
          child: const Text('Закрыть проект'),
        ),
        MenuItemButton(
          onPressed:
              editorState.hasActiveFile
                  ? () async {
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
                  }
                  : null,
          child: const Text('Сохранить'),
        ),
        MenuItemButton(
          onPressed:
              editorState.hasActiveFile
                  ? () {
                    _showSaveAsDialog(
                      context,
                      editorState,
                      directoryState,
                      fileHandler,
                    );
                  }
                  : null,
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
            SystemNavigator.pop();
          },
          child: const Text('Выход'),
        ),
      ],
      child: const Text('Файл'),
    );
  }

  /// Открывает диалог "Сохранить как" для сохранения файла.
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
