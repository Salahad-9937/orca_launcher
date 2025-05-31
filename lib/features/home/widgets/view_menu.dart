import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/editor_state.dart';

/// Подменю "Просмотр" для панели меню приложения.
class ViewMenu extends StatelessWidget {
  const ViewMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final editorState = Provider.of<EditorState>(context);

    return SubmenuButton(
      menuChildren: [
        MenuItemButton(
          trailingIcon:
              editorState.showLineNumbers
                  ? const Icon(Icons.check, size: 16)
                  : const SizedBox(width: 16),
          onPressed: () {
            editorState.toggleLineNumbers();
          },
          child: const Text('Нумерация строк'),
        ),
      ],
      child: const Text('Просмотр'),
    );
  }
}
