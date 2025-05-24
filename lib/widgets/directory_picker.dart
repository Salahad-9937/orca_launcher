import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DirectoryPicker extends StatefulWidget {
  final Function(String) onPathSelected;

  const DirectoryPicker({super.key, required this.onPathSelected});

  @override
  _DirectoryPickerState createState() => _DirectoryPickerState();
}

class _DirectoryPickerState extends State<DirectoryPicker> {
  String _currentPath = '';

  @override
  void initState() {
    super.initState();
    _initCurrentPath();
  }

  Future<void> _initCurrentPath() async {
    final directory = await getApplicationDocumentsDirectory();
    setState(() {
      _currentPath = directory.path;
    });
  }

  Future<List<FileSystemEntity>> _getDirectoryContents(String path) async {
    final dir = Directory(path);
    return dir
        .list(recursive: false)
        .where((entity) => entity is Directory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Выберите директорию: $_currentPath'),
        actions: [
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
          final directories = snapshot.data ?? [];
          return ListView.builder(
            itemCount: directories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  leading: const Icon(Icons.arrow_back),
                  title: const Text('Назад'),
                  onTap: () {
                    final parentPath = Directory(_currentPath).parent.path;
                    setState(() {
                      _currentPath = parentPath;
                    });
                  },
                );
              }
              final dir = directories[index - 1];
              return ListTile(
                leading: const Icon(Icons.folder),
                title: Text(dir.path.split('/').last),
                onTap: () {
                  setState(() {
                    _currentPath = dir.path;
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
