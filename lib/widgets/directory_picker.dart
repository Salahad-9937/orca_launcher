import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class DirectoryPicker extends StatefulWidget {
  final Function(String) onPathSelected;
  final bool isFilePicker; // true для выбора файла, false для выбора директории
  final String? initialPath; // Начальная директория

  const DirectoryPicker({
    super.key,
    required this.onPathSelected,
    this.isFilePicker = false,
    this.initialPath,
  });

  @override
  DirectoryPickerState createState() => DirectoryPickerState();
}

class DirectoryPickerState extends State<DirectoryPicker> {
  String _currentPath = '';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showHidden = false; // Переключатель для скрытых файлов/папок
  final TextEditingController _folderNameController = TextEditingController();
  String? _folderErrorText;

  @override
  void initState() {
    super.initState();
    _initCurrentPath();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _initCurrentPath() async {
    String initialPath;
    if (widget.initialPath != null) {
      initialPath = widget.initialPath!;
    } else {
      if (Platform.isLinux) {
        initialPath = Platform.environment['HOME'] ?? '/home';
      } else if (Platform.isWindows) {
        initialPath = 'C:\\';
      } else {
        initialPath = (await getApplicationDocumentsDirectory()).path;
      }
    }
    setState(() {
      _currentPath = initialPath;
    });
  }

  Future<List<FileSystemEntity>> _getDirectoryContents(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) {
        if (Platform.isWindows && path == 'C:\\') {
          return [];
        }
        return [];
      }
      final entities = await dir.list(recursive: false).toList();
      List<FileSystemEntity> filteredEntities;
      if (widget.isFilePicker) {
        // Показываем файлы .inp и папки
        filteredEntities =
            entities.where((entity) {
              if (entity is Directory) return true;
              if (entity is File && entity.path.endsWith('.inp')) return true;
              return false;
            }).toList();
      } else {
        // Показываем только папки
        filteredEntities = entities.whereType<Directory>().toList();
      }

      // Фильтрация скрытых файлов/папок
      if (!_showHidden) {
        filteredEntities =
            filteredEntities.where((entity) {
              return !p.basename(entity.path).startsWith('.');
            }).toList();
      }

      // Фильтрация по поисковому запросу
      if (_searchQuery.isNotEmpty) {
        filteredEntities =
            filteredEntities.where((entity) {
              final name = p.basename(entity.path).toLowerCase();
              return name.contains(_searchQuery);
            }).toList();
      }

      return filteredEntities;
    } catch (e) {
      debugPrint('Error listing directory contents: $e');
      return [];
    }
  }

  // Диалоговое окно для создания новой папки
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
                  // Проверка недопустимых символов
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
                    setState(() {}); // Обновляем список
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
          widget.isFilePicker
              ? 'Выберите файл: $_currentPath'
              : 'Выберите директорию: $_currentPath',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (!widget.isFilePicker)
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
            width:
                300, // Фиксированная ширина для поля поиска (по твоему запросу)
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
        future: _getDirectoryContents(_currentPath),
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
