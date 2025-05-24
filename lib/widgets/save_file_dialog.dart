import 'package:flutter/material.dart';

class SaveFileDialog extends StatefulWidget {
  final Function(String) onSave;

  const SaveFileDialog({super.key, required this.onSave});

  @override
  SaveFileDialogState createState() => SaveFileDialogState();
}

class SaveFileDialogState extends State<SaveFileDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Сохранить файл'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: 'Имя файла (без .inp)',
          errorText: _errorText,
        ),
        onChanged: (value) {
          setState(() {
            _errorText = null; // Сбрасываем ошибку при изменении текста
          });
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            final fileName = _controller.text.trim();
            if (fileName.isEmpty) {
              setState(() {
                _errorText = 'Имя файла не может быть пустым';
              });
              return;
            }
            if (!fileName.endsWith('.inp')) {
              widget.onSave('$fileName.inp');
            } else {
              widget.onSave(fileName);
            }
            Navigator.of(context).pop();
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}
