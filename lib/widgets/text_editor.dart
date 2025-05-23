import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

class TextEditor extends StatefulWidget {
  const TextEditor({super.key});

  @override
  _TextEditorState createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final controller = TextEditingController(text: appState.editorContent);

    // Подсчет количества строк
    int lineCount =
        appState.editorContent.isEmpty
            ? 1
            : appState.editorContent.split('\n').length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Нумерация строк
        Container(
          width: 40,
          color: Colors.grey[200],
          child: ListView.builder(
            controller: _scrollController,
            itemCount: lineCount,
            itemBuilder:
                (context, index) => Container(
                  height: 24, // Синхронизация с высотой строки TextField
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 14, // Синхронизация со шрифтом TextField
                      color: Colors.grey,
                      height: 1.5, // Учет межстрочного интервала
                    ),
                  ),
                ),
          ),
        ),
        // Текстовый редактор
        Expanded(
          child: TextField(
            maxLines: 10,
            scrollController: _scrollController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Содержимое входного файла',
            ),
            style: const TextStyle(fontSize: 14, height: 1.5),
            onChanged: (value) {
              appState.updateEditorContent(value);
            },
            controller: controller,
          ),
        ),
      ],
    );
  }
}
