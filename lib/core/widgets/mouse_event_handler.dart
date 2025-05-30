import 'package:flutter/material.dart';

/// Класс для обработки событий мыши в текстовом поле.
/// [controller] Контроллер текстового поля.
/// [focusNode] Нода фокуса для управления фокусом.
/// [scrollToCursor] Функция для прокрутки к позиции курсора.
/// [style] Стиль текста для синхронизации с TextPainter.
/// [verticalScrollController] Контроллер вертикальной прокрутки для учёта смещения.
class MouseEventHandler {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(int) scrollToCursor;
  final TextStyle? style;
  final ScrollController verticalScrollController;

  MouseEventHandler({
    required this.controller,
    required this.focusNode,
    required this.scrollToCursor,
    required this.style,
    required this.verticalScrollController,
  });

  /// Обрабатывает событие нажатия мыши (тап).
  void handleTap(
    TapDownDetails details,
    BuildContext context, {
    int tapCount = 1,
  }) {
    focusNode.requestFocus();
    _updateSelection(details, context, tapCount: tapCount);
  }

  /// Обрабатывает событие перетаскивания мыши для выделения текста.
  void handleDragUpdate(DragUpdateDetails details, BuildContext context) {
    _updateSelection(details, context);
  }

  /// Обновляет выделение текста на основе позиции мыши.
  /// [details] Детали события (TapDownDetails или DragUpdateDetails).
  /// [context] Контекст для получения RenderBox.
  /// [tapCount] Количество тапов (1 - одиночный, 2 - двойной, 3 - тройной).
  void _updateSelection(
    dynamic details,
    BuildContext context, {
    int tapCount = 1,
  }) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final text = controller.text.isEmpty ? ' ' : controller.text;
    final effectiveStyle =
        style?.copyWith(overflow: TextOverflow.visible, color: Colors.black) ??
        const TextStyle(overflow: TextOverflow.visible, color: Colors.black);

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: effectiveStyle),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: renderBox.size.width);

    // Корректировка позиции с учётом прокрутки
    final verticalScrollOffset =
        verticalScrollController.hasClients
            ? verticalScrollController.position.pixels
            : 0.0;
    final adjustedPosition = Offset(
      localPosition.dx,
      localPosition.dy + verticalScrollOffset,
    );

    final offset = textPainter.getPositionForOffset(adjustedPosition);
    int newOffset = offset.offset.clamp(0, controller.text.length);

    if (details is TapDownDetails) {
      if (tapCount == 1) {
        // Одиночный клик: установка курсора
        controller.selection = TextSelection.collapsed(offset: newOffset);
      } else if (tapCount == 2) {
        // Двойной клик: выделение слова
        final wordRange = _getWordRange(newOffset, text);
        controller.selection = TextSelection(
          baseOffset: wordRange.start,
          extentOffset: wordRange.end,
        );
        newOffset = wordRange.end; // Прокручиваем к концу слова
      } else if (tapCount == 3) {
        // Тройной клик: выделение строки
        final lineRange = _getLineRange(newOffset, text);
        controller.selection = TextSelection(
          baseOffset: lineRange.start,
          extentOffset: lineRange.end,
        );
        newOffset = lineRange.end; // Прокручиваем к концу строки
      }
    } else if (details is DragUpdateDetails) {
      // Перетаскивание: обновление выделения
      final currentSelection = controller.selection;
      controller.selection = TextSelection(
        baseOffset:
            currentSelection.baseOffset >= 0
                ? currentSelection.baseOffset
                : newOffset,
        extentOffset: newOffset,
      );
    }

    scrollToCursor(newOffset);
  }

  /// Возвращает диапазон слова для заданной позиции.
  /// [offset] Позиция курсора.
  /// [text] Текст для анализа.
  TextRange _getWordRange(int offset, String text) {
    if (text.isEmpty) return const TextRange(start: 0, end: 0);

    // Находим начало слова
    int start = offset;
    while (start > 0 && !_isWordBoundary(text[start - 1])) {
      start--;
    }

    // Находим конец слова
    int end = offset;
    while (end < text.length && !_isWordBoundary(text[end])) {
      end++;
    }

    return TextRange(start: start, end: end);
  }

  /// Возвращает диапазон строки для заданной позиции.
  /// [offset] Позиция курсора.
  /// [text] Текст для анализа.
  TextRange _getLineRange(int offset, String text) {
    if (text.isEmpty) return const TextRange(start: 0, end: 0);

    // Находим начало строки
    int start = offset;
    while (start > 0 && text[start - 1] != '\n') {
      start--;
    }

    // Находим конец строки
    int end = offset;
    while (end < text.length && text[end] != '\n') {
      end++;
    }

    return TextRange(start: start, end: end);
  }

  /// Проверяет, является ли символ границей слова.
  bool _isWordBoundary(String char) {
    return RegExp(r'[\s,.!?;:]').hasMatch(char);
  }
}
