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

    // Обработка Home и Numpad 7 (Home)
    if (event.logicalKey == LogicalKeyboardKey.home ||
        event.logicalKey == LogicalKeyboardKey.numpad7) {
      _effectiveController.selection = TextSelection.collapsed(
        offset: charCount,
      );
      return KeyEventResult.handled;
    }
    // Обработка End и Numpad 1 (End)
    else if (event.logicalKey == LogicalKeyboardKey.end ||
        event.logicalKey == LogicalKeyboardKey.numpad1) {
      _effectiveController.selection = TextSelection.collapsed(
        offset: charCount + lines[currentLineIndex].length,
      );
      return KeyEventResult.handled;
    }
    // Обработка PageUp и Numpad 9 (PageUp)
    else if (event.logicalKey == LogicalKeyboardKey.pageUp ||
        event.logicalKey == LogicalKeyboardKey.numpad9) {
      _effectiveController.selection = const TextSelection.collapsed(offset: 0);
      return KeyEventResult.handled;
    }
    // Обработка PageDown и Numpad 3 (PageDown)
    else if (event.logicalKey == LogicalKeyboardKey.pageDown ||
        event.logicalKey == LogicalKeyboardKey.numpad3) {
      _effectiveController.selection = TextSelection.collapsed(
        offset: text.length,
      );
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
