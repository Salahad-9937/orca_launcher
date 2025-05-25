import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../utils/file_utils.dart';

class FileSystemPicker extends StatefulWidget {
  final Function(String) onPathSelected;
  final bool isFilePicker;
  final String? initialPath;
  final String titlePrefix;
  final bool showConfirmButton;

  const FileSystemPicker({
    super.key,
    required this.onPathSelected,
    this.isFilePicker = false,
    this.initialPath,
    this.titlePrefix = 'Выберите',
    this.showConfirmButton = true,
  });

  @override
  FileSystemPickerState createState() => FileSystemPickerState();
}

class FileSystemPickerState extends State<FileSystemPicker> {
  String _currentPath = '';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _folderNameController = TextEditingController();
  String _searchQuery = '';
  bool _showHidden = false;
  String? _folderErrorText;

  @override
  void initState() {
    super.initState();
    _initCurrentPath();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  Future<void> _initCurrentPath() async {
    final initialPath = await FileUtils.getInitialPath(widget.initialPath);
    setState(() {
      _currentPath = initialPath;
    });
  }

  Future<void> _showCreateFolderDialog() async {
    _folderNameController.clear();
    _folderErrorText = null;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                    final newFolderPath = p.join(_currentPath, folderName);
                    final newFolder = Directory(newFolderPath);
                    if (await newFolder.exists()) {
                      setState(() {
                        _folderErrorText = 'Папка уже существует';
                      });
                      return;
                    }
                    await newFolder.create();
                    setState(() {});
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
          ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _folderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.titlePrefix}: $_currentPath',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (!widget.isFilePicker && widget.showConfirmButton)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                widget.onPathSelected(_currentPath);
                Navigator.of(context).pop();
              },
            ),
          IconButton(
            icon: const Icon(Icons.create_new_folder),
            tooltip: 'Создать новую папку',
            onPressed: _showCreateFolderDialog,
          ),
          IconButton(
            icon: Icon(_showHidden ? Icons.visibility : Icons.visibility_off),
            tooltip:
                _showHidden ? 'Скрыть скрытые файлы' : 'Показать скрытые файлы',
            onPressed: () {
              setState(() {
                _showHidden = !_showHidden;
              });
            },
          ),
          SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Поиск',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 0.0),
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: FileUtils.getDirectoryContents(
          _currentPath,
          isFilePicker: widget.isFilePicker,
          showHidden: _showHidden,
          searchQuery: _searchQuery,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          final entities = snapshot.data ?? [];
          return ListView.builder(
            itemCount: entities.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  leading: const Icon(Icons.arrow_back),
                  title: const Text('Назад'),
                  onTap: () {
                    final parentPath = Directory(_currentPath).parent.path;
                    if (parentPath != _currentPath) {
                      setState(() {
                        _currentPath = parentPath;
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    }
                  },
                );
              }
              final entity = entities[index - 1];
              return ListTile(
                leading: Icon(entity is File ? Icons.file_open : Icons.folder),
                title: Text(p.basename(entity.path)),
                onTap: () {
                  if (widget.isFilePicker && entity is File) {
                    widget.onPathSelected(entity.path);
                    Navigator.of(context).pop();
                  } else if (entity is Directory) {
                    setState(() {
                      _currentPath = entity.path;
                      _searchController.clear();
                      _searchQuery = '';
                    });
                    if (!widget.isFilePicker) {
                      widget.onPathSelected(entity.path);
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
