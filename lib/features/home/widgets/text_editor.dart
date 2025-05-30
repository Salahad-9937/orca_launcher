import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/editor_state.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../components/line_number_column.dart';

/// Виджет текстового редактора с колонкой номеров строк.
class TextEditor extends StatefulWidget {
  const TextEditor({super.key});

  @override
  TextEditorState createState() => TextEditorState();
}

/// Состояние текстового редактора, управляющее текстом и синхронизацией.
/// [_scrollController] Контроллер прокрутки.
/// [_textController] Контроллер для управления текстом.
/// [_focusNode] Нода фокуса для управления фокусом.
/// [_editorState] Состояние редактора.
/// [_lineInfo] Список информации о строках (номер физической строки и количество визуальных строк).
/// [_lineHeight] Кэш высоты строки.
/// [_currentLine] Текущая визуальная строка курсора.
class TextEditorState extends State<TextEditor> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late EditorState _editorState;
  List<Map<String, dynamic>>?
  _lineInfo; // Список: {physicalLine: int, visualLines: int}
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
    _scrollController.dispose();
    _focusNode.dispose();
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
    final availableWidth =
        MediaQuery.of(context).size.width -
        56; // Учитываем ширину LineNumberColumn и padding
    int charCount = 0;
    int currentPhysicalLine = 0;
    int visualLineCount = 0;

    // Определяем текущую физическую строку
    for (int i = 0; i < lines.length; i++) {
      if (charCount + lines[i].length + 1 > offset) {
        currentPhysicalLine = i;
        break;
      }
      charCount += lines[i].length + 1;
      final painter = TextPainter(
        text: TextSpan(
          text: lines[i],
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        textDirection: TextDirection.ltr,
      );
      painter.layout(maxWidth: availableWidth);
      visualLineCount += painter.computeLineMetrics().length;
    }

    // Вычисляем визуальную строку для текущей физической строки
    final textPainter = TextPainter(
      text: TextSpan(
        text: lines[currentPhysicalLine],
        style: const TextStyle(fontSize: 14, height: 1.5),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: availableWidth);

    final lineOffset = offset - charCount;
    final lineMetrics = textPainter.computeLineMetrics();
    int currentVisualLine = 0;
    int currentCharPos = 0;

    // Находим визуальную строку, в которой находится курсор
    for (int i = 0; i < lineMetrics.length; i++) {
      final metric = lineMetrics[i];
      final charsInLine =
          (metric.width / textPainter.preferredLineHeight).ceil();
      if (currentCharPos + charsInLine > lineOffset) {
        currentVisualLine = i;
        break;
      }
      currentCharPos += charsInLine;
    }

    // Добавляем визуальные строки текущей физической строки
    visualLineCount += currentVisualLine + 1;

    setState(() {
      _currentLine = visualLineCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final editorState = Provider.of<EditorState>(context);
    const textStyle = TextStyle(fontSize: 14, height: 1.5);

    _lineHeight ??= () {
      final textPainter = TextPainter(
        text: const TextSpan(text: 'Sample\nSample', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      return textPainter.height / 2;
    }();

    _lineInfo ??= () {
      final availableWidth =
          MediaQuery.of(context).size.width -
          56; // Учитываем ширину LineNumberColumn и padding
      final lines =
          editorState.editorContent.isEmpty
              ? ['']
              : editorState.editorContent.split('\n');
      List<Map<String, dynamic>> info = [];

      for (int i = 0; i < lines.length; i++) {
        final textPainter = TextPainter(
          text: TextSpan(text: lines[i], style: textStyle),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: availableWidth);
        info.add({
          'physicalLine': i + 1,
          'visualLines': textPainter.computeLineMetrics().length,
        });
      }

      return info.isEmpty
          ? [
            {'physicalLine': 1, 'visualLines': 1},
          ]
          : info;
    }();

    return SingleChildScrollView(
      controller: _scrollController,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LineNumberColumn(
            lineInfo: _lineInfo!,
            lineHeight: _lineHeight!,
            textStyle: textStyle,
            currentLine: _currentLine,
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    _lineHeight! *
                    _lineInfo!.fold<int>(
                      0,
                      (sum, info) => sum + (info['visualLines'] as int),
                    ),
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
