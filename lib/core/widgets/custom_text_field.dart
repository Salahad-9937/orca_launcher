import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller; // Контроллер для управления текстом
  final FocusNode? focusNode; // Нода фокуса для управления фокусом
  final InputDecoration?
  decoration; // Декорация поля ввода (рамка, подсказки и т.д.)
  final TextStyle? style; // Стиль текста в поле
  final bool autofocus; // Автофокус при загрузке
  final TextInputType? keyboardType; // Тип клавиатуры (например, multiline)
  final TextInputAction?
  textInputAction; // Действие кнопки на клавиатуре (например, "Готово")
  final ValueChanged<String>? onChanged; // Коллбэк при изменении текста
  final int? maxLines; // Максимальное количество строк
  final ScrollPhysics? scrollPhysics; // Физика прокрутки
  final TextAlignVertical?
  textAlignVertical; // Вертикальное выравнивание текста

  const CustomTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.decoration,
    this.style,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.maxLines,
    this.scrollPhysics,
    this.textAlignVertical,
  });

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _effectiveController;
  late FocusNode _effectiveFocusNode;

  @override
  void initState() {
    super.initState();
    // Используем переданный контроллер или создаём новый
    _effectiveController = widget.controller ?? TextEditingController();
    // Используем переданную ноду фокуса или создаём новую
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    // Уничтожаем только если они не были переданы извне
    if (widget.controller == null) {
      _effectiveController.dispose();
    }
    if (widget.focusNode == null) {
      _effectiveFocusNode.dispose();
    }
    super.dispose();
  }

  // Метод для обработки нажатий клавиш
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final text = _effectiveController.text;
    final selection = _effectiveController.selection;
    int offset = selection.baseOffset;

    // Проверка на валидность позиции курсора
    if (offset < 0 || offset > text.length) {
      offset = text.isEmpty ? 0 : text.length;
      _effectiveController.selection = TextSelection.collapsed(offset: offset);
      return KeyEventResult.handled;
    }

    final lines = text.isEmpty ? [''] : text.split('\n');
    int charCount = 0;
    int currentLineIndex = 0;

    // Находим текущую строку и её начальную позицию
    for (int i = 0; i < lines.length; i++) {
      if (charCount + lines[i].length + 1 > offset) {
        currentLineIndex = i;
        break;
      }
      charCount += lines[i].length + 1; // +1 для символа новой строки
    }

    // Проверяем, зажат ли Shift (левый или правый)
    final bool isShiftPressed =
        HardwareKeyboard.instance.logicalKeysPressed.contains(
          LogicalKeyboardKey.shiftLeft,
        ) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(
          LogicalKeyboardKey.shiftRight,
        );

    // Отладочный вывод для отслеживания нажатий
    // print(
    //   'Key: ${event.logicalKey}, Shift: $isShiftPressed, Offset: $offset, Line: $currentLineIndex, CharCount: $charCount',
    // );

    // Проверяем, зажат ли Shift для выделения текста
    final int anchor = selection.baseOffset; // Точка начала выделения

    // Обработка Home и Numpad 7 (Home)
    if (event.logicalKey == LogicalKeyboardKey.home ||
        event.logicalKey == LogicalKeyboardKey.numpad7) {
      final newOffset = charCount; // Начало текущей строки
      _effectiveController.selection =
          isShiftPressed
              ? TextSelection(baseOffset: anchor, extentOffset: newOffset)
              : TextSelection.collapsed(offset: newOffset);
      return KeyEventResult.handled;
    }
    // Обработка End и Numpad 1 (End)
    else if (event.logicalKey == LogicalKeyboardKey.end ||
        event.logicalKey == LogicalKeyboardKey.numpad1) {
      final newOffset =
          charCount + lines[currentLineIndex].length; // Конец текущей строки
      _effectiveController.selection =
          isShiftPressed
              ? TextSelection(baseOffset: anchor, extentOffset: newOffset)
              : TextSelection.collapsed(offset: newOffset);
      return KeyEventResult.handled;
    }
    // Обработка PageUp и Numpad 9 (PageUp)
    else if (event.logicalKey == LogicalKeyboardKey.pageUp ||
        event.logicalKey == LogicalKeyboardKey.numpad9) {
      const newOffset = 0; // Начало текста
      _effectiveController.selection =
          isShiftPressed
              ? TextSelection(baseOffset: anchor, extentOffset: newOffset)
              : TextSelection.collapsed(offset: newOffset);
      return KeyEventResult.handled;
    }
    // Обработка PageDown и Numpad 3 (PageDown)
    else if (event.logicalKey == LogicalKeyboardKey.pageDown ||
        event.logicalKey == LogicalKeyboardKey.numpad3) {
      final newOffset = text.length; // Конец текста
      _effectiveController.selection =
          isShiftPressed
              ? TextSelection(baseOffset: anchor, extentOffset: newOffset)
              : TextSelection.collapsed(offset: newOffset);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _handleKeyEvent, // Перехватываем события клавиш
      child: TextField(
        controller: _effectiveController,
        focusNode: _effectiveFocusNode,
        decoration: widget.decoration, // Передаём декорацию
        style: widget.style, // Передаём стиль текста
        autofocus: widget.autofocus, // Передаём автофокус
        keyboardType:
            widget.keyboardType ??
            TextInputType.multiline, // По умолчанию multiline
        textInputAction: widget.textInputAction, // Передаём действие клавиатуры
        onChanged: widget.onChanged, // Передаём коллбэк при изменении
        maxLines:
            widget
                .maxLines, // Передаём maxLines, по умолчанию null (без ограничений)
        scrollPhysics: widget.scrollPhysics, // Передаём физику скролла
        textAlignVertical:
            widget.textAlignVertical, // Передаём вертикальное выравнивание
      ),
    );
  }
}
