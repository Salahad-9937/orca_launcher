import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class SaveFileScreen extends StatefulWidget {
  final Function(String, String) onSave; // Передаёт путь и имя файла
  final String? initialPath;

  const SaveFileScreen({super.key, required this.onSave, this.initialPath});

  @override
  _SaveFileScreenState createState() => _SaveFileScreenState();
}

class _SaveFileScreenState extends State<SaveFileScreen> {
  String _currentPath = '';
  final TextEditingController _fileNameController = TextEditingController();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _fileNameController.text = 'new_file.inp';
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
        return [];
      }
      return dir
          .list(recursive: false)
          .where((entity) => entity is Directory)
          .toList();
    } catch (e) {
      debugPrint('Error listing directory contents: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _fileNameController.dispose();
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
                      errorText: _errorText,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _errorText = null;
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
                        _errorText = 'Имя файла не может быть пустым';
                      });
                      return;
                    }
                    if (!fileName.endsWith('.inp')) {
                      setState(() {
                        _errorText = 'Файл должен иметь расширение .inp';
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
                            });
                          }
                        },
                      );
                    }
                    final entity = entities[index - 1];
                    return ListTile(
                      leading: const Icon(Icons.folder),
                      title: Text(path.basename(entity.path)),
                      onTap: () {
                        setState(() {
                          _currentPath = entity.path;
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
