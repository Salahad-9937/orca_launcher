import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/app_error.dart';
import '../../../core/models/editor_state.dart';
import '../../../core/models/directory_state.dart';
import '../../../core/utils/error_display.dart';
import '../../../core/services/file_handler.dart';
import '../../file_system/file_system_picker.dart';

/// Меню для запуска ORCA с текущим или выбранным файлом.
class RunMenu extends StatelessWidget {
  const RunMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final editorState = Provider.of<EditorState>(context);
    final directoryState = Provider.of<DirectoryState>(context);
    final fileHandler = Provider.of<FileHandler>(context, listen: false);

    return SubmenuButton(
      menuChildren: [
        MenuItemButton(
          onPressed: () async {
            if (directoryState.orcaDirectory == null) {
              if (context.mounted) {
                ErrorDisplay.showError(
                  context,
                  AppError('Путь к ORCA не указан', type: ErrorType.generic),
                );
              }
              return;
            }
            if (editorState.currentFilePath == null) {
              if (context.mounted) {
                ErrorDisplay.showError(
                  context,
                  AppError(
                    'Нет открытого файла для запуска',
                    type: ErrorType.generic,
                  ),
                );
              }
              return;
            }
            if (!editorState.currentFileName.endsWith('.inp')) {
              if (context.mounted) {
                ErrorDisplay.showError(
                  context,
                  AppError(
                    'Файл должен иметь расширение .inp',
                    type: ErrorType.generic,
                  ),
                );
              }
              return;
            }
            final bool? confirm = await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Подтверждение запуска'),
                    content: Text(
                      'Запустить ORCA для файла ${editorState.currentFileName}?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Запустить'),
                      ),
                    ],
                  ),
            );
            if (confirm != true || !context.mounted) return;
            final saveResult = await fileHandler.saveExistingFile(
              editorState.currentFilePath!,
              editorState.currentFileName,
              editorState.editorContent,
            );
            if (!context.mounted) return;
            saveResult.fold((error) => ErrorDisplay.showError(context, error), (
              _,
            ) async {
              final outputFilePath = editorState.currentFilePath!.replaceAll(
                '.inp',
                '.out',
              );
              final result = await fileHandler.runOrca(
                directoryState.orcaDirectory!,
                editorState.currentFilePath!,
                outputFilePath,
              );
              if (!context.mounted) return;
              result.fold(
                (error) => ErrorDisplay.showError(context, error),
                (_) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'ORCA успешно запущена: результат в $outputFilePath',
                    ),
                  ),
                ),
              );
            });
          },
          child: const Text('Запуск'),
        ),
        MenuItemButton(
          onPressed: () {
            if (directoryState.orcaDirectory == null) {
              if (context.mounted) {
                ErrorDisplay.showError(
                  context,
                  AppError('Путь к ORCA не указан', type: ErrorType.generic),
                );
              }
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => FileSystemPicker(
                      onPathSelected: (path) async {
                        if (!path.endsWith('.inp')) {
                          if (context.mounted) {
                            ErrorDisplay.showError(
                              context,
                              AppError(
                                'Выберите файл с расширением .inp',
                                type: ErrorType.generic,
                              ),
                            );
                          }
                          return;
                        }
                        final outputFilePath = path.replaceAll('.inp', '.out');
                        final result = await fileHandler.runOrca(
                          directoryState.orcaDirectory!,
                          path,
                          outputFilePath,
                        );
                        if (context.mounted) {
                          result.fold(
                            (error) => ErrorDisplay.showError(context, error),
                            (_) => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'ORCA успешно запущена: результат в $outputFilePath',
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      isFilePicker: true,
                      initialPath:
                          directoryState.workingDirectory ??
                          (Platform.isLinux
                              ? Platform.environment['HOME'] ?? '/home'
                              : 'C:\\'),
                      titlePrefix: 'Выберите .inp файл',
                      allowedExtensions: ['.inp'],
                    ),
              ),
            );
          },
          child: const Text('Запуск из файла'),
        ),
      ],
      child: const Text('Запуск'),
    );
  }
}
