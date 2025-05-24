import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class SaveFileScreen extends StatefulWidget {
  final Function(String, String) onSave; // Передаёт путь и имя файла
  final String? initialPath;

  const SaveFileScreen({super.key, required this.onSave, this.initialPath});

  @override
  SaveFileScreenState createState() => SaveFileScreenState();
}

class SaveFileScreenState extends State<SaveFileScreen> {
  String _currentPath = '';
  final TextEditingController _fileNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _folderNameController = TextEditingController();
  String? _fileErrorText;
  String? _folderErrorText;
  String _searchQuery = '';
  bool _showHidden = false; // Переключатель для скрытых файлов/папок

  @override
  void initState() {
    super.initState();
    _fileNameController.text = 'new_file.inp';
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
        return [];
      }
      final entities =
          await dir
              .list(recursive: false)
              .where((entity) => entity is Directory)
              .toList();

      // Фильтрация скрытых папок
      var filteredEntities = entities;
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
    _fileNameController.dispose();
    _searchController.dispose();
    _folderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Сохранить файл: $_currentPath',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
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
            width: 300, // Фиксированная ширина для поля поиска
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
                    widget.onSave(_currentPath, fileName);
                    Navigator.of(context).pop();
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
            child: FutureBuilder<List<FileSystemEntity>>(
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
                          final parentPath =
                              Directory(_currentPath).parent.path;
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
                      leading: const Icon(Icons.folder),
                      title: Text(p.basename(entity.path)),
                      onTap: () {
                        setState(() {
                          _currentPath = entity.path;
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
