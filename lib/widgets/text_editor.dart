import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/editor_state.dart';
import 'line_number_column.dart';

class TextEditor extends StatefulWidget {
  const TextEditor({super.key});

  @override
  TextEditorState createState() => TextEditorState();
}

class TextEditorState extends State<TextEditor> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late EditorState _editorState;
  int? _lineCount; // Кэш для количества строк

  @override
  void initState() {
    super.initState();
    _editorState = Provider.of<EditorState>(context, listen: false);
    _textController.text = _editorState.editorContent;
    _textController.addListener(() {
      _editorState.updateEditorContent(_textController.text);
      _lineCount = null; // Сбрасываем кэш при изменении текста
    });

    _editorState.addListener(_updateTextController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _editorState = Provider.of<EditorState>(context, listen: false);
  }

  @override
  void dispose() {
    _editorState.removeListener(_updateTextController);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateTextController() {
    if (_textController.text != _editorState.editorContent) {
      _textController.text = _editorState.editorContent;
      _textController.selection = TextSelection.collapsed(
        offset: _textController.text.length,
      );
      _lineCount = null; // Сбрасываем кэш при обновлении контента
    }
  }

  void _handleKeyEvent(LogicalKeyboardKey key) {
    if (!_focusNode.hasFocus) return;

    final text = _textController.text;
    final selection = _textController.selection;
    final lines = text.isEmpty ? [''] : text.split('\n');
    int currentLineIndex = 0;
    int charCount = 0;

    for (int i = 0; i < lines.length; i++) {
      if (charCount + lines[i].length >= selection.baseOffset) {
        currentLineIndex = i;
        break;
      }
      charCount += lines[i].length + 1;
    }

    if (key == LogicalKeyboardKey.home) {
      final startOfLine = charCount;
      _textController.selection = TextSelection.collapsed(offset: startOfLine);
    } else if (key == LogicalKeyboardKey.end) {
      final endOfLine = charCount + lines[currentLineIndex].length;
      _textController.selection = TextSelection.collapsed(offset: endOfLine);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editorState = Provider.of<EditorState>(context);
    // Мемоизация количества строк
    _lineCount ??=
        editorState.editorContent.isEmpty
            ? 1
            : editorState.editorContent.split('\n').length;

    const textStyle = TextStyle(fontSize: 14, height: 1.5);

    final textPainter = TextPainter(
      text: const TextSpan(text: 'Sample\nSample', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final lineHeight = textPainter.height / 2;

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
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LineNumberColumn(
                lineCount: _lineCount!,
                lineHeight: lineHeight,
                textStyle: textStyle,
              ),
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: lineHeight * _lineCount!,
                  ),
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    maxLines: null,
                    scrollPhysics: const NeverScrollableScrollPhysics(),
                    textAlignVertical: TextAlignVertical.top,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeIntent extends Intent {
  const HomeIntent();
}

class EndIntent extends Intent {
  const EndIntent();
}
