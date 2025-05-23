import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../services/file_service.dart';

class DirectorySelector extends StatelessWidget {
  final String label;
  final String? currentPath;
  final Function(String?) onPathSelected;

  const DirectorySelector({
    super.key,
    required this.label,
    required this.currentPath,
    required this.onPathSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              currentPath ?? 'No directory selected',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final fileService = FileService();
              final path = await fileService.pickDirectory();
              onPathSelected(path);
            },
            child: Text('Select $label Directory'),
          ),
        ],
      ),
    );
  }
}
