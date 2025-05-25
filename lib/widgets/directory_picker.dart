import 'package:flutter/material.dart';
import '../widgets/file_system_picker.dart';

class DirectoryPicker extends StatelessWidget {
  final Function(String) onPathSelected;
  final bool isFilePicker;
  final String? initialPath;

  const DirectoryPicker({
    super.key,
    required this.onPathSelected,
    this.isFilePicker = false,
    this.initialPath,
  });

  @override
  Widget build(BuildContext context) {
    return FileSystemPicker(
      onPathSelected: onPathSelected,
      isFilePicker: isFilePicker,
      initialPath: initialPath,
      titlePrefix: isFilePicker ? 'Выберите файл' : 'Выберите директорию',
    );
  }
}
