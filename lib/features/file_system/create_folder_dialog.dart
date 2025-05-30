import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../../core/widgets/custom_dialog_text_field_.dart';

/// Диалоговое окно для создания новой папки в указанной директории.
/// [currentPath] Текущий путь, где будет создана папка.
/// [onFolderCreated] Коллбэк, вызываемый после создания папки.
class CreateFolderDialog extends StatefulWidget {
  final String currentPath;
  final VoidCallback onFolderCreated;

  const CreateFolderDialog({
    super.key,
    required this.currentPath,
    required this.onFolderCreated,
  });

  @override
  CreateFolderDialogState createState() => CreateFolderDialogState();
}

/// Состояние диалогового окна для создания папки, управляющее вводом имени и валидацией.
/// [_folderNameController] Контроллер для поля ввода имени папки.
/// [_folderErrorText] Текст ошибки при валидации имени папки.
class CreateFolderDialogState extends State<CreateFolderDialog> {
  final TextEditingController _folderNameController = TextEditingController();
  String? _folderErrorText;

  @override
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Создать новую папку'),
      content: SizedBox(
        width: double.maxFinite,
        child: CustomDialogTextField(
          controller: _folderNameController,
          decoration: InputDecoration(
            labelText: 'Имя папки',
            errorText: _folderErrorText,
          ),
          onChanged: (value) {
            setState(() {
              _folderErrorText = null;
            });
          },
          maxLines: 1, // Явно задаём однострочный ввод
          keyboardType: TextInputType.text, // Однострочная клавиатура
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () async {
            final folderName = _folderNameController.text.trim();
            if (folderName.isEmpty) {
              setState(() {
                _folderErrorText = 'Имя папки не может быть пустым';
              });
              return;
            }
            if (RegExp(r'[<>:"/\\|?*]').hasMatch(folderName)) {
              setState(() {
                _folderErrorText = 'Имя содержит недопустимые символы';
              });
              return;
            }
            try {
              final newFolderPath = p.join(widget.currentPath, folderName);
              final newFolder = Directory(newFolderPath);
              if (await newFolder.exists()) {
                setState(() {
                  _folderErrorText = 'Папка уже существует';
                });
                return;
              }
              await newFolder.create();
              widget.onFolderCreated();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            } catch (e) {
              setState(() {
                _folderErrorText = 'Ошибка при создании папки: $e';
              });
            }
          },
          child: const Text('Создать'),
        ),
      ],
    );
  }
}
