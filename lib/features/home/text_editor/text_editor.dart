import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/editor_state.dart';
import '../../../core/widgets/custom_file_text_field.dart';
import 'line_number_column.dart';

/// Виджет текстового редактора с колонкой номеров строк.
class TextEditor extends StatefulWidget {
  const TextEditor({super.key});

  @override
  TextEditorState createState() => TextEditorState();
}

/// Состояние текстового редактора, управляющее текстом и синхронизацией.
/// [_textController] Контроллер для управления текстом.
/// [_focusNode] Нода фокуса для управления фокусом.
/// [_lineNumberScrollController] Контроллер прокрутки для LineNumberColumn.
/// [_editorState] Состояние редактора.
/// [_lineInfo] Список информации о строках (номер физической строки и количество визуальных строк).
/// [_lineHeight] Кэш высоты строки.
/// [_currentLine] Текущая визуальная строка курсора.
class TextEditorState extends State<TextEditor> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _lineNumberScrollController = ScrollController();
  late EditorState _editorState;
  List<Map<String, dynamic>>? _lineInfo;
  double? _lineHeight;
  int _currentLine = 1;

  @override
  void initState() {
    super.initState();
    _editorState = Provider.of<EditorState>(context, listen: false);
    _textController.text = _editorState.editorContent;
    _textController.addListener(() {
      _editorState.updateEditorContent(_textController.text);
      _lineInfo = null;
      _updateCurrentLine();
    });

    _editorState.addListener(_updateTextController);
    _focusNode.addListener(_updateCurrentLine);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _editorState = Provider.of<EditorState>(context, listen: false);
    _lineHeight = null;
    _lineInfo = null;
    _updateCurrentLine();
  }

  @override
  void dispose() {
    _editorState.removeListener(_updateTextController);
    _textController.dispose();
    _focusNode.dispose();
    _lineNumberScrollController.dispose();
    super.dispose();
  }

  /// Обновляет содержимое текстового контроллера при изменении состояния редактора.
  void _updateTextController() {
    if (_textController.text != _editorState.editorContent) {
      _textController.text = _editorState.editorContent;
      _textController.selection = TextSelection.collapsed(
        offset: _textController.text.length,
      );
      _lineInfo = null;
      _updateCurrentLine();
    }
  }

  /// Вычисляет текущую визуальную строку на основе позиции курсора.
  void _updateCurrentLine() {
    final text = _textController.text;
    final selection = _textController.selection;
    int offset = selection.baseOffset;

    if (offset < 0 || offset > text.length) {
      offset = text.isEmpty ? 0 : text.length;
    }

    final lines = text.isEmpty ? [''] : text.split('\n');
    int charCount = 0;
    int currentPhysicalLine = 0;

    // Определяем текущую физическую строку
    for (int i = 0; i < lines.length; i++) {
      final lineLength = lines[i].length;
      if (charCount + lineLength + 1 > offset ||
          (i == lines.length - 1 && offset == charCount + lineLength)) {
        currentPhysicalLine = i;
        break;
      }
      charCount += lineLength + 1;
    }

    setState(() {
      _currentLine = currentPhysicalLine + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final editorState = Provider.of<EditorState>(context);
    const textStyle = TextStyle(fontSize: 14, height: 1.5, color: Colors.black);

    _lineHeight ??= () {
      final textPainter = TextPainter(
        text: const TextSpan(text: 'Sample\nSample', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      return textPainter.height / 2;
    }();

    _lineInfo ??= () {
      final lines =
          editorState.editorContent.isEmpty
              ? ['']
              : editorState.editorContent.split('\n');
      List<Map<String, dynamic>> info = [];

      for (int i = 0; i < lines.length; i++) {
        info.add({
          'physicalLine': i + 1,
          'visualLines': 1, // Без переноса строк каждая строка — 1 визуальная
        });
      }

      return info.isEmpty
          ? [
            {'physicalLine': 1, 'visualLines': 1},
          ]
          : info;
    }();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (editorState.showLineNumbers)
          SizedBox(
            width: 56,
            height: MediaQuery.of(context).size.height,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                controller: _lineNumberScrollController,
                child: LineNumberColumn(
                  lineInfo: _lineInfo!,
                  lineHeight: _lineHeight!,
                  textStyle: textStyle,
                  currentLine: _currentLine,
                  controller: _textController,
                ),
              ),
            ),
          ),
        Expanded(
          child: SizedBox(
            width:
                editorState.showLineNumbers
                    ? MediaQuery.of(context).size.width - 56
                    : MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: CustomFileTextField(
              controller: _textController,
              focusNode: _focusNode,
              lineNumberScrollController: _lineNumberScrollController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              style: textStyle,
            ),
          ),
        ),
      ],
    );
  }
}
