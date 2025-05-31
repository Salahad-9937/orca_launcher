import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/directory_state.dart';

/// Вертикальное меню с инструментами, включая кнопку для управления видимостью панели директорий.
class Toolbar extends StatelessWidget {
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final directoryState = Provider.of<DirectoryState>(context);

    return Column(
      children: [
        IconButton(
          icon: Icon(
            directoryState.isProjectPanelVisible
                ? Icons.folder_open
                : Icons.folder,
          ),
          tooltip:
              directoryState.isProjectPanelVisible
                  ? 'Скрыть панель директорий'
                  : 'Показать панель директорий',
          onPressed: () {
            directoryState.toggleProjectPanelVisibility();
          },
        ),
        // Здесь можно добавить другие кнопки инструментов
      ],
    );
  }
}
