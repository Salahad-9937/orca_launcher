import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/editor_state.dart';
import '../../core/models/directory_state.dart';
import '../../core/utils/file_utils.dart';
import '../../core/utils/error_display.dart';
import '../../core/services/file_handler.dart';
import '../../core/widgets/custom_text_field.dart'; // Новый импорт
import '../file_system/file_system_picker.dart';

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
  String? _selectedPath;

  @override
  void initState() {
    super.initState();
    _fileNameController.text = 'new_file.inp';
    _initSelectedPath();
  }

  void _initSelectedPath() {
    final directoryState = Provider.of<DirectoryState>(context, listen: false);
    _selectedPath =
        widget.initialPath ??
        directoryState.workingDirectory ??
        (Platform.isLinux ? Platform.environment['HOME'] ?? '/home' : 'C:\\');
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    final fileName = _fileNameController.text.trim();
    final fileNameError = FileUtils.validateFileName(fileName);
    if (fileNameError != null) {
      setState(() {
        _fileErrorText = fileNameError;
      });
      return;
    }

    if (_selectedPath == null) {
      setState(() {
        _fileErrorText = 'Директория не выбрана';
      });
      return;
    }

    final fileHandler = Provider.of<FileHandler>(context, listen: false);
    final result = await fileHandler.saveFile(
      _selectedPath!,
      fileName,
      Provider.of<EditorState>(context, listen: false).editorContent,
    );

    result.fold((error) => ErrorDisplay.showError(context, error), (filePath) {
      widget.onSave(_selectedPath!, fileName);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Файл сохранён: $fileName')));
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сохранить файл')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
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
                  onPressed: _handleSave,
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
                setState(() {
                  _selectedPath = path;
                });
              },
              initialPath: _selectedPath,
              titlePrefix: 'Выберите директорию для сохранения',
              showConfirmButton: false,
            ),
          ),
        ],
      ),
    );
  }
}
