import 'package:flutter/material.dart';
import '../widgets/file_system_picker.dart';

class SaveFileScreen extends StatefulWidget {
  final Function(String, String) onSave;
  final String? initialPath;

  const SaveFileScreen({super.key, required this.onSave, this.initialPath});

  @override
  SaveFileScreenState createState() => SaveFileScreenState();
}

class SaveFileScreenState extends State<SaveFileScreen> {
  final TextEditingController _fileNameController = TextEditingController();
  String? _fileErrorText;

  @override
  void initState() {
    super.initState();
    _fileNameController.text = 'new_file.inp';
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fileNameController,
                    decoration: InputDecoration(
                      labelText: 'Имя файла (с .inp)',
                      errorText: _fileErrorText,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _fileErrorText = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final fileName = _fileNameController.text.trim();
                    if (fileName.isEmpty) {
                      setState(() {
                        _fileErrorText = 'Имя файла не может быть пустым';
                      });
                      return;
                    }
                    if (!fileName.endsWith('.inp')) {
                      setState(() {
                        _fileErrorText = 'Файл должен иметь расширение .inp';
                      });
                      return;
                    }
                    // Будет вызвано из FileSystemPicker
                  },
                  child: const Text(
                    'Сохранить',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FileSystemPicker(
              onPathSelected: (path) {
                final fileName = _fileNameController.text.trim();
                if (fileName.isEmpty) {
                  setState(() {
                    _fileErrorText = 'Имя файла не может быть пустым';
                  });
                  return;
                }
                if (!fileName.endsWith('.inp')) {
                  setState(() {
                    _fileErrorText = 'Файл должен иметь расширение .inp';
                  });
                  return;
                }
                widget.onSave(path, fileName);
                Navigator.of(context).pop();
              },
              initialPath: widget.initialPath,
              titlePrefix: 'Сохранить файл',
            ),
          ),
        ],
      ),
    );
  }
}
