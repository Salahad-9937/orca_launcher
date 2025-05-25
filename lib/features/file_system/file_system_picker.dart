import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../../core/utils/file_utils.dart';
import 'create_folder_dialog.dart';
import 'file_system_picker_app_bar.dart';
import 'file_system_entity_list.dart';

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
  final BehaviorSubject<String> _searchSubject = BehaviorSubject<String>();
  String _searchQuery = '';
  bool _showHidden = false;

  @override
  void initState() {
    super.initState();
    _initCurrentPath();
    _searchSubject.debounceTime(const Duration(milliseconds: 300)).listen((
      query,
    ) {
      setState(() {
        _searchQuery = query;
      });
    });
  }

  Future<void> _initCurrentPath() async {
    final initialPath = await FileUtils.getInitialPath(widget.initialPath);
    setState(() {
      _currentPath = initialPath;
    });
  }

  void _navigateBack() {
    final parentPath = Directory(_currentPath).parent.path;
    if (parentPath != _currentPath) {
      setState(() {
        _currentPath = parentPath;
        _searchQuery = '';
        _searchSubject.add('');
      });
    }
  }

  void _onCreateFolder() {
    showDialog(
      context: context,
      builder:
          (context) => CreateFolderDialog(
            currentPath: _currentPath,
            onFolderCreated: () {
              setState(() {});
            },
          ),
    );
  }

  @override
  void dispose() {
    _searchSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FileSystemPickerAppBar(
        currentPath: _currentPath,
        titlePrefix: widget.titlePrefix,
        isFilePicker: widget.isFilePicker,
        showConfirmButton: widget.showConfirmButton,
        showHidden: _showHidden,
        searchSubject: _searchSubject,
        onConfirm: () {
          widget.onPathSelected(_currentPath);
          Navigator.of(context).pop();
        },
        onCreateFolder: _onCreateFolder,
        onToggleHidden: () {
          setState(() {
            _showHidden = !_showHidden;
          });
        },
      ),
      body: FileSystemEntityList(
        currentPath: _currentPath,
        isFilePicker: widget.isFilePicker,
        showHidden: _showHidden,
        searchQuery: _searchQuery,
        onPathSelected: (path) {
          if (widget.isFilePicker && File(path).existsSync()) {
            widget.onPathSelected(path);
            Navigator.of(context).pop();
          } else if (Directory(path).existsSync()) {
            setState(() {
              _currentPath = path;
              _searchQuery = '';
              _searchSubject.add('');
            });
            if (!widget.isFilePicker) {
              widget.onPathSelected(path);
            }
          }
        },
        onNavigateBack: _navigateBack,
      ),
    );
  }
}
