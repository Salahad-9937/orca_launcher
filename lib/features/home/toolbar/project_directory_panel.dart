import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import '../../../core/models/directory_state.dart';
import '../../../core/models/editor_state.dart';
import '../../../core/services/file_handler.dart';
import '../../../core/utils/error_display.dart';
import '../../file_system/file_system_picker.dart';
import '../../file_system/file_system_entity_list.dart';

/// Панель для отображения директории проекта с поддержкой сворачивания поддиректорий.
class ProjectDirectoryPanel extends StatelessWidget {
  const ProjectDirectoryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final directoryState = Provider.of<DirectoryState>(context);
    final fileHandler = Provider.of<FileHandler>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            directoryState.projectDirectory != null
                ? p.basename(directoryState.projectDirectory!)
                : 'Директория не выбрана',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child:
              directoryState.projectDirectory != null
                  ? FileSystemEntityList(
                    currentPath: directoryState.projectDirectory!,
                    isFilePicker: true,
                    showHidden: false,
                    searchQuery: '',
                    allowedExtensions: const ['.inp', '.out', '.xyz'],
                    onPathSelected: (path) async {
                      final result = await fileHandler.openFile(path);
                      result.fold(
                        (error) => ErrorDisplay.showError(context, error),
                        (content) {
                          final editorState = Provider.of<EditorState>(
                            context,
                            listen: false,
                          );
                          // Используем метод openFile для создания новой вкладки
                          editorState.openFile(
                            path.split(Platform.pathSeparator).last,
                            path,
                            content,
                          );
                        },
                      );
                    },
                    onNavigateBack: () {},
                    isCollapsible: true,
                    showBackButton: false,
                  )
                  : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Директория не выбрана',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => FileSystemPicker(
                                      onPathSelected: (path) async {
                                        directoryState.setProjectDirectory(
                                          path,
                                        );
                                      },
                                      isFilePicker: false,
                                      initialPath:
                                          directoryState.workingDirectory ??
                                          (Platform.isLinux
                                              ? Platform.environment['HOME'] ??
                                                  '/home'
                                              : 'C:\\'),
                                      titlePrefix:
                                          'Выберите директорию проекта',
                                      showConfirmButton: true,
                                    ),
                              ),
                            );
                          },
                          child: const Text('Открыть проект'),
                        ),
                      ],
                    ),
                  ),
        ),
      ],
    );
  }
}
