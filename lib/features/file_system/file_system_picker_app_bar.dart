import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../../core/widgets/custom_text_field.dart'; // Новый импорт

class FileSystemPickerAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final String currentPath;
  final String titlePrefix;
  final bool isFilePicker;
  final bool showConfirmButton;
  final bool showHidden;
  final BehaviorSubject<String> searchSubject;
  final VoidCallback onConfirm;
  final VoidCallback onCreateFolder;
  final VoidCallback onToggleHidden;

  const FileSystemPickerAppBar({
    super.key,
    required this.currentPath,
    required this.titlePrefix,
    required this.isFilePicker,
    required this.showConfirmButton,
    required this.showHidden,
    required this.searchSubject,
    required this.onConfirm,
    required this.onCreateFolder,
    required this.onToggleHidden,
  });

  @override
  FileSystemPickerAppBarState createState() => FileSystemPickerAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class FileSystemPickerAppBarState extends State<FileSystemPickerAppBar> {
  final TextEditingController _searchController = TextEditingController();
  late StreamSubscription<String> _searchSubscription;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      widget.searchSubject.add(_searchController.text);
    });
    _searchSubscription = widget.searchSubject.listen((query) {
      if (_searchController.text != query) {
        _searchController.text = query;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        '${widget.titlePrefix}: ${widget.currentPath}',
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        if (!widget.isFilePicker && widget.showConfirmButton)
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: widget.onConfirm,
          ),
        IconButton(
          icon: const Icon(Icons.create_new_folder),
          tooltip: 'Создать новую папку',
          onPressed: widget.onCreateFolder,
        ),
        IconButton(
          icon: Icon(
            widget.showHidden ? Icons.visibility : Icons.visibility_off,
          ),
          tooltip:
              widget.showHidden
                  ? 'Скрыть скрытые файлы'
                  : 'Показать скрытые файлы',
          onPressed: widget.onToggleHidden,
        ),
        SizedBox(
          width: 300,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: CustomTextField(
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
    );
  }
}
