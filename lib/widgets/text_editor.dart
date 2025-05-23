import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Обработчик клавиш Home и End
  void _handleKeyEvent(LogicalKeyboardKey key) {
    if (!_focusNode.hasFocus) return;

    final text = _textController.text;
    final selection = _textController.selection;
    final lines = text.isEmpty ? [''] : text.split('\n');
    int currentLineIndex = 0;
    int charCount = 0;

    // Находим текущую строку
    for (int i = 0; i < lines.length; i++) {
      if (charCount + lines[i].length >= selection.baseOffset) {
        currentLineIndex = i;
        break;
      }
      charCount += lines[i].length + 1;
    }

    if (key == LogicalKeyboardKey.home) {
      // Перемещение в начало текущей строки
      final startOfLine = charCount;
      _textController.selection = TextSelection.collapsed(offset: startOfLine);
    } else if (key == LogicalKeyboardKey.end) {
      // Перемещение в конец текущей строки
      final endOfLine = charCount + lines[currentLineIndex].length;
      _textController.selection = TextSelection.collapsed(offset: endOfLine);
    }
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
    final lineHeight = textPainter.height / 2; // Делим на 2, так как 2 строки

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.home): const HomeIntent(),
        LogicalKeySet(LogicalKeyboardKey.end): const EndIntent(),
      },
      child: Actions(
        actions: {
          HomeIntent: CallbackAction<HomeIntent>(
            onInvoke: (intent) {
              _handleKeyEvent(LogicalKeyboardKey.home);
              return null;
            },
          ),
          EndIntent: CallbackAction<EndIntent>(
            onInvoke: (intent) {
              _handleKeyEvent(LogicalKeyboardKey.end);
              return null;
            },
          ),
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Нумерация строк с начальным сдвигом
            Column(
              children: [
                const SizedBox(height: 4), // Начальный сдвиг
                Container(
                  width: 40,
                  color: Colors.grey[200],
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      children: List.generate(
                        lineCount,
                        (index) => SizedBox(
                          height: lineHeight,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
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
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top, // Текст сверху
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                ),
                style: textStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Интенты для Home и End
class HomeIntent extends Intent {
  const HomeIntent();
}

class EndIntent extends Intent {
  const EndIntent();
}
