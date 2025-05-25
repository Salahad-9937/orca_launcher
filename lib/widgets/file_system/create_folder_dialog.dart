import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

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
      content: TextField(
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
