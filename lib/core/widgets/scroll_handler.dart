import 'package:flutter/material.dart';

/// Класс для управления прокруткой текстового поля.
/// [verticalScrollController] Контроллер вертикальной прокрутки.
/// [horizontalScrollController] Контроллер горизонтальной прокрутки.
/// [lineNumberScrollController] Контроллер прокрутки для синхронизации с LineNumberColumn.
/// [controller] Контроллер текстового поля.
/// [focusNode] Нода фокуса.
/// [style] Стиль текста.
class ScrollHandler {
  final ScrollController verticalScrollController;
  final ScrollController horizontalScrollController;
  final ScrollController? lineNumberScrollController;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextStyle? style;
  bool _isPageUpDown = false;

  ScrollHandler({
    required this.verticalScrollController,
    required this.horizontalScrollController,
    this.lineNumberScrollController,
    required this.controller,
    required this.focusNode,
    this.style,
  }) {
    // Синхронизация прокрутки с LineNumberColumn
    if (lineNumberScrollController != null) {
      verticalScrollController.addListener(_syncScroll);
      lineNumberScrollController!.addListener(_syncScroll);
    }
  }

  /// Синхронизирует прокрутку между контроллерами.
  void _syncScroll() {
    if (verticalScrollController.hasClients &&
        lineNumberScrollController!.hasClients &&
        verticalScrollController.position.pixels !=
            lineNumberScrollController!.position.pixels) {
      lineNumberScrollController!.jumpTo(
        verticalScrollController.position.pixels,
      );
    }
    if (verticalScrollController.hasClients &&
        lineNumberScrollController!.hasClients &&
        verticalScrollController.position.pixels !=
            lineNumberScrollController!.position.pixels) {
      verticalScrollController.jumpTo(
        lineNumberScrollController!.position.pixels,
      );
    }
  }

  /// Прокручивает поле к позиции курсора.
  /// [cursorPosition] Позиция курсора в тексте.
  void scrollToCursor(int cursorPosition) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final text = controller.text.isEmpty ? ' ' : controller.text;
      final style =
          this.style?.copyWith(
            overflow: TextOverflow.visible,
            color: Colors.black,
          ) ??
          const TextStyle(overflow: TextOverflow.visible, color: Colors.black);

      final textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
      )..layout();

      final cursorOffset = textPainter.getOffsetForCaret(
        TextPosition(offset: cursorPosition),
        Rect.zero,
      );

      // Прокрутка по горизонтали
      if (horizontalScrollController.hasClients) {
        final maxScroll = horizontalScrollController.position.maxScrollExtent;
        final horizontalOffset = cursorOffset.dx;
        final newHorizontalOffset =
            _isPageUpDown
                ? (cursorPosition == 0 ? 0.0 : maxScroll)
                : (horizontalOffset - 100).clamp(0.0, maxScroll);
        horizontalScrollController.animateTo(
          newHorizontalOffset,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }

      // Прокрутка по вертикали
      if (verticalScrollController.hasClients) {
        final maxScroll = verticalScrollController.position.maxScrollExtent;
        final viewportHeight =
            verticalScrollController.position.viewportDimension;
        final currentScroll = verticalScrollController.position.pixels;

        if (_isPageUpDown) {
          final newVerticalOffset = cursorPosition == 0 ? 0.0 : maxScroll;
          verticalScrollController.animateTo(
            newVerticalOffset,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        } else {
          final lineHeight =
              style.height != null
                  ? style.fontSize! * style.height!
                  : style.fontSize! * 1.2;
          final topBound = currentScroll + lineHeight;
          final bottomBound = currentScroll + viewportHeight - lineHeight;

          if (cursorOffset.dy < topBound) {
            verticalScrollController.animateTo(
              (cursorOffset.dy - lineHeight).clamp(0.0, maxScroll),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          } else if (cursorOffset.dy > bottomBound) {
            verticalScrollController.animateTo(
              (cursorOffset.dy - viewportHeight + lineHeight * 2).clamp(
                0.0,
                maxScroll,
              ),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        }
      }

      _isPageUpDown = false;
    });
  }
}
