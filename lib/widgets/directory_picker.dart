import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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

  @override
  void initState() {
    super.initState();
    _initCurrentPath();
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
          // Для Windows корневой директории проверяем доступность
          return [];
        }
        return [];
      }
      final entities = await dir.list(recursive: false).toList();
      if (widget.isFilePicker) {
        // Показываем файлы .inp и папки
        return entities.where((entity) {
          if (entity is Directory) return true;
          if (entity is File && entity.path.endsWith('.inp')) return true;
          return false;
        }).toList();
      } else {
        // Показываем только папки
        return entities.whereType<Directory>().toList();
      }
    } catch (e) {
      debugPrint('Error listing directory contents: $e');
      return [];
    }
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
                    // Предотвращаем выход за пределы корневой директории
                    if (parentPath != _currentPath) {
                      setState(() {
                        _currentPath = parentPath;
                      });
                    }
                  },
                );
              }
              final entity = entities[index - 1];
              return ListTile(
                leading: Icon(entity is File ? Icons.file_open : Icons.folder),
                title: Text(path.basename(entity.path)),
                onTap: () {
                  if (widget.isFilePicker && entity is File) {
                    widget.onPathSelected(entity.path);
                    Navigator.of(context).pop();
                  } else if (entity is Directory) {
                    setState(() {
                      _currentPath = entity.path;
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
