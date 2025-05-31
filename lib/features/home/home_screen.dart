import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/editor_state.dart';
import '../../core/models/directory_state.dart';
import 'widgets/app_menu_bar.dart';
import 'widgets/editor_header.dart';
import 'widgets/text_editor.dart';
import 'components/project_directory_panel.dart';
import 'widgets/toolbar.dart';

/// Главный экран приложения с текстовым редактором, меню и панелью директорий.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final editorState = Provider.of<EditorState>(context);
    final directoryState = Provider.of<DirectoryState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(editorState.currentFileName),
        centerTitle: true,
        flexibleSpace: AppMenuBar(title: editorState.currentFileName),
      ),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [const EditorHeader(), Expanded(child: TextEditor())],
              ),
            ),
          ),
          if (directoryState.isProjectPanelVisible &&
              directoryState.projectDirectory != null)
            Container(
              width: 300,
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.grey.shade300)),
              ),
              child: ProjectDirectoryPanel(),
            ),
          Container(
            width: 60,
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Colors.grey.shade300)),
            ),
            child: const Toolbar(),
          ),
        ],
      ),
    );
  }
}
