import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

class TextEditor extends StatelessWidget {
  const TextEditor({super.key});

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
            itemCount: lineCount,
            itemBuilder:
                (context, index) => Container(
                  height: 20,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
          ),
        ),
        // Текстовый редактор
        Expanded(
          child: TextField(
            maxLines: 10,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Input File Content',
            ),
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
