import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/editor_state.dart';
import '../../../core/widgets/custom_text_field.dart'; // Новый импорт
import '../components/line_number_column.dart';

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
  double? _lineHeight; // Кэш для высоты строки

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
    _lineHeight = null; // Сбрасываем кэш при изменении зависимостей
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

  @override
  Widget build(BuildContext context) {
    final editorState = Provider.of<EditorState>(context);
    // Мемоизация количества строк
    _lineCount ??=
        editorState.editorContent.isEmpty
            ? 1
            : editorState.editorContent.split('\n').length;

    const textStyle = TextStyle(fontSize: 14, height: 1.5);

    // Мемоизация высоты строки
    _lineHeight ??= () {
      final textPainter = TextPainter(
        text: const TextSpan(text: 'Sample\nSample', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      return textPainter.height / 2;
    }();

    return SingleChildScrollView(
      controller: _scrollController,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LineNumberColumn(
            lineCount: _lineCount!,
            lineHeight: _lineHeight!,
            textStyle: textStyle,
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: _lineHeight! * _lineCount!,
              ),
              child: CustomTextField(
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
    );
  }
}
