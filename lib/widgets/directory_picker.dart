import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p; // Изменён префикс с path на p

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

      // Фильтрация по поисковому запросу
      if (_searchQuery.isNotEmpty) {
        filteredEntities =
            filteredEntities.where((entity) {
              final name =
                  p
                      .basename(entity.path)
                      .toLowerCase(); // Используем p вместо path
              return name.contains(_searchQuery);
            }).toList();
      }

      return filteredEntities;
    } catch (e) {
      debugPrint('Error listing directory contents: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
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
        ],
      ),
      body: Column(
        children: [
          // Поле для поиска
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Поиск',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // Список файлов и папок
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
                      leading: Icon(
                        entity is File ? Icons.file_open : Icons.folder,
                      ),
                      title: Text(
                        p.basename(entity.path),
                      ), // Используем p вместо path
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
          ),
        ],
      ),
    );
  }
}
