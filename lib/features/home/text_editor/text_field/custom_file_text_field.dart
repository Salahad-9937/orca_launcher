import 'package:flutter/material.dart';
import 'scroll_handler.dart';
import 'key_event_handler.dart';
import 'left_mouse_event_handler.dart';
import 'text_painter_utils.dart';
import 'right_mouse_event_handler.dart';

/// Виджет текстового поля с поддержкой кастомизации и управления прокруткой.
/// [controller] Контроллер для управления текстом.
/// [focusNode] Нода фокуса для управления фокусом.
/// [lineNumberScrollController] Контроллер прокрутки для синхронизации с LineNumberColumn.
/// [style] Стиль текста в поле.
/// [autofocus] Автофокус при загрузке.
/// [keyboardType] Тип клавиатуры.
/// [textInputAction] Действие кнопки на клавиатуре.
/// [onChanged] Коллбэк при изменении текста.
/// [maxLines] Максимальное количество строк.
class CustomFileTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ScrollController? lineNumberScrollController;
  final TextStyle? style;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final int? maxLines;

  const CustomFileTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.lineNumberScrollController,
    this.style,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.maxLines,
  });

  @override
  CustomFileTextFieldState createState() => CustomFileTextFieldState();
}

/// Состояние для виджета CustomTextField, управляющее прокруткой и обработкой событий.
/// [_effectiveController] Контроллер для управления текстом.
/// [_effectiveFocusNode] Нода фокуса для управления фокусом.
/// [_horizontalScrollController] Контроллер горизонтальной прокрутки.
/// [_verticalScrollController] Контроллер вертикальной прокрутки.
/// [_scrollHandler] Обработчик прокрутки.
/// [_keyEventHandler] Обработчик событий клавиатуры.
/// [_leftMouseEventHandler] Обработчик событий левой кнопки мыши.
/// [_rightMouseEventHandler] Обработчик событий правой кнопкимыши.
class CustomFileTextFieldState extends State<CustomFileTextField> {
  late TextEditingController _effectiveController;
  late FocusNode _effectiveFocusNode;
  late ScrollController _horizontalScrollController;
  late ScrollController _verticalScrollController;
  late ScrollHandler _scrollHandler;
  late KeyEventHandler _keyEventHandler;
  late LeftMouseEventHandler _leftMouseEventHandler;
  late RightMouseEventHandler _rightMouseEventHandler;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController();
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
    _horizontalScrollController = ScrollController();
    _verticalScrollController = ScrollController();
    _scrollHandler = ScrollHandler(
      verticalScrollController: _verticalScrollController,
      horizontalScrollController: _horizontalScrollController,
      lineNumberScrollController: widget.lineNumberScrollController,
      controller: _effectiveController,
      focusNode: _effectiveFocusNode,
      style: widget.style,
    );
    _keyEventHandler = KeyEventHandler(
      controller: _effectiveController,
      scrollToCursor: _scrollHandler.scrollToCursor,
    );
    _leftMouseEventHandler = LeftMouseEventHandler(
      controller: _effectiveController,
      focusNode: _effectiveFocusNode,
      scrollToCursor: _scrollHandler.scrollToCursor,
      style: widget.style,
      verticalScrollController: _verticalScrollController,
    );
    _rightMouseEventHandler = RightMouseEventHandler(
      controller: _effectiveController,
      focusNode: _effectiveFocusNode,
    );

    _effectiveFocusNode.addListener(() {
      if (_effectiveFocusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _effectiveFocusNode.requestFocus();
          if (_effectiveController.selection.baseOffset >= 0) {
            _scrollHandler.scrollToCursor(
              _effectiveController.selection.baseOffset,
            );
          }
        });
      }
    });
    _effectiveController.addListener(() {
      if (_effectiveController.selection.baseOffset >= 0) {
        _scrollHandler.scrollToCursor(
          _effectiveController.selection.baseOffset,
        );
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

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _keyEventHandler.handleKeyEvent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double height =
              constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : MediaQuery.of(context).size.height;

          final textPainter = TextPainterUtils.createTextPainter(
            text: _effectiveController.text,
            style: widget.style,
          );

          return GestureDetector(
            onTapDown:
                (details) => _leftMouseEventHandler.handleTap(details, context),
            onDoubleTapDown:
                (details) => _leftMouseEventHandler.handleTap(
                  details,
                  context,
                  isDoubleTap: true,
                ),
            onPanStart:
                (details) =>
                    _leftMouseEventHandler.handleDragStart(details, context),
            onPanUpdate:
                (details) =>
                    _leftMouseEventHandler.handleDragUpdate(details, context),
            onSecondaryTapDown:
                (details) => _rightMouseEventHandler.showContextMenu(
                  context,
                  details.globalPosition,
                ),
            child: Container(
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
                    width: textPainter.width + 32,
                    height: textPainter.height.clamp(
                      height - 32,
                      double.infinity,
                    ),
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
                      selectionColor:
                          Theme.of(context).textSelectionTheme.selectionColor ??
                          Colors.blue.withOpacity(0.4),
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
            ),
          );
        },
      ),
    );
  }
}
