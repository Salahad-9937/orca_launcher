import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/directory_state.dart';
import '../../../core/models/editor_state.dart';
import '../../../core/services/file_handler.dart';
import '../../../core/utils/error_display.dart';
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
            'Директория проекта',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: FileSystemEntityList(
            currentPath: directoryState.projectDirectory!,
            isFilePicker: true,
            showHidden: false,
            searchQuery: '',
            allowedExtensions: const ['.inp', '.out', '.xyz'],
            onPathSelected: (path) async {
              final result = await fileHandler.openFile(path);
              result.fold((error) => ErrorDisplay.showError(context, error), (
                content,
              ) {
                final editorState = Provider.of<EditorState>(
                  context,
                  listen: false,
                );
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
              });
            },
            onNavigateBack: () {},
            isCollapsible: true,
          ),
        ),
      ],
    );
  }
}
