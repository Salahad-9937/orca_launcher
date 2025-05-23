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
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _textController.text = appState.editorContent;
    _textController.addListener(() {
      appState.updateEditorContent(_textController.text);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    // Подсчет количества строк
    int lineCount =
        appState.editorContent.isEmpty
            ? 1
            : appState.editorContent.split('\n').length;

    // Определение стиля текста
    const textStyle = TextStyle(fontSize: 14, height: 1.5);

    // Вычисление точной высоты строки с помощью TextPainter
    final textPainter = TextPainter(
      text: const TextSpan(text: 'Sample\nSample', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final lineHeight = (textPainter.height) / 2; // Делим на 2, так как 2 строки

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Нумерация строк
        Column(
          children: [
            SizedBox(height: 4),
            Container(
              width: 40,
              color: Colors.grey[200],
              child: SingleChildScrollView(
                controller: _scrollController,
                physics:
                    const NeverScrollableScrollPhysics(), // Отключаем независимую прокрутку
                child: Column(
                  children: List.generate(
                    lineCount,
                    (index) => SizedBox(
                      height: lineHeight, // Точная высота строки
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8, top: 0),
                          child: Text(
                            '${index + 1}',
                            style: textStyle.copyWith(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Текстовый редактор
        Expanded(
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            maxLines: 50,
            scrollController: _scrollController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            ),
            style: textStyle,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),
        ),
      ],
    );
  }
}
