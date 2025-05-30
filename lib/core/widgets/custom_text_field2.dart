import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Виджет текстового поля с поддержкой кастомизации и управления прокруткой.
/// [controller] Контроллер для управления текстом.
/// [focusNode] Нода фокуса для управления фокусом.
/// [style] Стиль текста в поле.
/// [autofocus] Автофокус при загрузке.
/// [keyboardType] Тип клавиатуры.
/// [textInputAction] Действие кнопки на клавиатуре.
/// [onChanged] Коллбэк при изменении текста.
/// [maxLines] Максимальное количество строк.
class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextStyle? style;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final int? maxLines;

  const CustomTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.style,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.maxLines,
  });

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

/// Состояние для виджета CustomTextField, управляющее прокруткой и обработкой клавиш.
/// [_effectiveController] Контроллер для управления текстом.
/// [_effectiveFocusNode] Нода фокуса для управления фокусом.
/// [_horizontalScrollController] Контроллер горизонтальной прокрутки.
/// [_verticalScrollController] Контроллер вертикальной прокрутки.
/// [_startKey] Ключ для начала текста.
/// [_endKey] Ключ для конца текста.
class CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _effectiveController;
  late FocusNode _effectiveFocusNode;
  late ScrollController _horizontalScrollController;
  late ScrollController _verticalScrollController;
  final _startKey = GlobalKey();
  final _endKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController();
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
    _horizontalScrollController = ScrollController();
    _verticalScrollController = ScrollController();
    _effectiveFocusNode.addListener(() {
      if (_effectiveFocusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _effectiveFocusNode.requestFocus();
        });
      }
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _effectiveController.dispose();
    }
    if (widget.focusNode == null) {
      _effectiveFocusNode.dispose();
    }
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  /// Прокручивает поле к позиции курсора.
  /// [cursorPosition] Позиция курсора в тексте.
  void _scrollToCursor(int cursorPosition) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;

        final isStart = cursorPosition == 0;
        final key = isStart ? _startKey : _endKey;

        if (key.currentContext == null) {
          return;
        }

        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: isStart ? 0.0 : 1.0,
        );
      });
    });
  }

  /// Обрабатывает события клавиш для управления выделением и прокруткой.
  /// [node] Нода фокуса.
  /// [event] Событие клавиатуры.
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final text = _effectiveController.text;
    final selection = _effectiveController.selection;
    int offset = selection.baseOffset;

    if (offset < 0 || offset > text.length) {
      offset = text.isEmpty ? 0 : text.length;
      _effectiveController.selection = TextSelection.collapsed(offset: offset);
      _scrollToCursor(offset);
      return KeyEventResult.handled;
    }

    final lines = text.isEmpty ? [''] : text.split('\n');
    int charCount = 0;
    int currentLineIndex = 0;

    for (int i = 0; i < lines.length; i++) {
      if (charCount + lines[i].length + 1 > offset) {
        currentLineIndex = i;
        break;
      }
      charCount += lines[i].length + 1;
    }

    final bool isShiftPressed =
        HardwareKeyboard.instance.logicalKeysPressed.contains(
          LogicalKeyboardKey.shiftLeft,
        ) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(
          LogicalKeyboardKey.shiftRight,
        );

    final int anchor = selection.baseOffset;

    if (event.logicalKey == LogicalKeyboardKey.home ||
        event.logicalKey == LogicalKeyboardKey.numpad7) {
      final newOffset = charCount;
      _effectiveController.selection =
          isShiftPressed
              ? TextSelection(baseOffset: anchor, extentOffset: newOffset)
              : TextSelection.collapsed(offset: newOffset);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.end ||
        event.logicalKey == LogicalKeyboardKey.numpad1) {
      final newOffset = charCount + lines[currentLineIndex].length;
      _effectiveController.selection =
          isShiftPressed
              ? TextSelection(baseOffset: anchor, extentOffset: newOffset)
              : TextSelection.collapsed(offset: newOffset);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.pageUp ||
        event.logicalKey == LogicalKeyboardKey.numpad9) {
      const newOffset = 0;
      _effectiveController.selection =
          isShiftPressed
              ? TextSelection(baseOffset: anchor, extentOffset: newOffset)
              : TextSelection.collapsed(offset: newOffset);
      _scrollToCursor(newOffset);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.pageDown ||
        event.logicalKey == LogicalKeyboardKey.numpad3) {
      final newOffset = text.length;
      _effectiveController.selection =
          isShiftPressed
              ? TextSelection(baseOffset: anchor, extentOffset: newOffset)
              : TextSelection.collapsed(offset: newOffset);
      _scrollToCursor(newOffset);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _handleKeyEvent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Используем конечные размеры из constraints
          final double height =
              constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : MediaQuery.of(context).size.height;

          // Вычисляем ширину текста для предотвращения переноса строк
          final textPainter = TextPainter(
            text: TextSpan(
              text:
                  _effectiveController.text.isEmpty
                      ? ' '
                      : _effectiveController.text,
              style:
                  widget.style?.copyWith(
                    overflow: TextOverflow.visible,
                    color: Colors.black,
                  ) ??
                  const TextStyle(
                    overflow: TextOverflow.visible,
                    color: Colors.black,
                  ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();

          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(4.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: _verticalScrollController,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                child: SizedBox(
                  width: textPainter.width + 16, // Учитываем padding
                  height: height,
                  child: EditableText(
                    controller: _effectiveController,
                    focusNode: _effectiveFocusNode,
                    style:
                        widget.style?.copyWith(
                          overflow: TextOverflow.visible,
                          color: Colors.black,
                        ) ??
                        const TextStyle(
                          overflow: TextOverflow.visible,
                          color: Colors.black,
                        ),
                    cursorColor:
                        Theme.of(context).textSelectionTheme.cursorColor ??
                        Colors.blue,
                    backgroundCursorColor: Colors.grey,
                    textAlign: TextAlign.left,
                    textDirection: TextDirection.ltr,
                    maxLines: widget.maxLines,
                    keyboardType:
                        widget.keyboardType ?? TextInputType.multiline,
                    textInputAction: widget.textInputAction,
                    onChanged: widget.onChanged,
                    autofocus: widget.autofocus,
                    scrollPhysics: const ClampingScrollPhysics(),
                    rendererIgnoresPointer: false,
                    enableInteractiveSelection: true,
                    selectionControls: MaterialTextSelectionControls(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
