import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/editor_state.dart';
import 'widgets/app_menu_bar.dart';
import 'widgets/editor_header.dart';
import 'widgets/text_editor.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final editorState = Provider.of<EditorState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(editorState.currentFileName),
        centerTitle: true,
        flexibleSpace: AppMenuBar(title: editorState.currentFileName),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [EditorHeader(), Expanded(child: TextEditor())],
        ),
      ),
    );
  }
}
