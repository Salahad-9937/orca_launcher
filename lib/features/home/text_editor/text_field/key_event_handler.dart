import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Класс для обработки событий клавиатуры.
/// [controller] Контроллер текстового поля.
/// [scrollToCursor] Функция для прокрутки к позиции курсора.
class KeyEventHandler {
  final TextEditingController controller;
  final void Function(int) scrollToCursor;

  KeyEventHandler({required this.controller, required this.scrollToCursor});

  /// Обрабатывает события клавиш для управления выделением и прокруткой.
  /// [node] Нода фокуса.
  /// [event] Событие клавиатуры.
  KeyEventResult handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final text = controller.text;
    final selection = controller.selection;
    int offset = selection.baseOffset;

    if (offset < 0 || offset > text.length) {
      offset = text.isEmpty ? 0 : text.length;
      controller.selection = TextSelection.collapsed(offset: offset);
      scrollToCursor(offset);
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
      controller.selection =
          isShiftPressed
              ? TextSelection(baseOffset: anchor, extentOffset: newOffset)
              : TextSelection.collapsed(offset: newOffset);
      scrollToCursor(newOffset);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.end ||
        event.logicalKey == LogicalKeyboardKey.numpad1) {
      final newOffset = charCount + lines[currentLineIndex].length;
      controller.selection =
          isShiftPressed
              ? TextSelection(baseOffset: anchor, extentOffset: newOffset)
              : TextSelection.collapsed(offset: newOffset);
      scrollToCursor(newOffset);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.pageUp ||
        event.logicalKey == LogicalKeyboardKey.numpad9) {
      const newOffset = 0;
      controller.selection =
          isShiftPressed
              ? TextSelection(baseOffset: anchor, extentOffset: newOffset)
              : TextSelection.collapsed(offset: newOffset);
      scrollToCursor(newOffset);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.pageDown ||
        event.logicalKey == LogicalKeyboardKey.numpad3) {
      final newOffset = text.length;
      controller.selection =
          isShiftPressed
              ? TextSelection(baseOffset: anchor, extentOffset: newOffset)
              : TextSelection.collapsed(offset: newOffset);
      scrollToCursor(newOffset);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}
